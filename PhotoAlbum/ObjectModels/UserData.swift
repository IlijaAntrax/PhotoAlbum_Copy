//
//  UserData.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 5/12/18.
//  Copyright © 2018 Ilija Antonijevic. All rights reserved.
//

import Foundation
import NotificationCenter

class UserData:NSObject, NSCoding, DatabaseDelegate
{
    var sharedAlbums = [SharedPhotoAlbum]()
    
    var notificationData = [NotificationData]()
    
    override init()
    {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        sharedAlbums = aDecoder.decodeObject(forKey: "SharedAlbums") as! [SharedPhotoAlbum]
        notificationData = aDecoder.decodeObject(forKey: "NotificationsData") as! [NotificationData]
    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(sharedAlbums, forKey: "SharedAlbums")
        aCoder.encode(notificationData, forKey: "NotificationsData")
    }
    
    func updateData(albums: [SharedPhotoAlbum])
    {
        self.sharedAlbums = albums
        User.sharedInstance.saveUserData()
    }
    
    func searchForAlbumsUpdates()
    {
        //User.sharedInstance.loadUserData()
        
        let firebase = FirebaseDatabaseController()
        firebase.databaseDelegate = self
        
        firebase.getSharedAlbumsBySelf()
    }
    
    func checkIsDataUpdated(remoteAlbums: [SharedPhotoAlbum])
    {
        for remoteAlbum in remoteAlbums
        {
            if let key = remoteAlbum.databaseKey
            {
                if let sharedAlbumIndex = self.sharedAlbums.index(where: { (album) -> Bool in
                    if let albumKey = album.databaseKey
                    {
                        if albumKey == key
                        {
                            return true
                        }
                    }
                    return false
                })
                {
                    //check for new photos in album
                    let differenceOfPhotos = self.sharedAlbums[sharedAlbumIndex].photosCount - remoteAlbum.photosCount
                    if differenceOfPhotos < 0
                    {
                        //self.sharedAlbums[sharedAlbumIndex].photosCount += abs(differenceOfPhotos)
                        //new photos, send notification, add photos too
                        let notificationBody = "\(remoteAlbum.owner) added \(abs(differenceOfPhotos)) new photos to \(remoteAlbum.name) album"
                        
                        self.addAlbumNotification(key: key, body: notificationBody)
                        
                        self.sendNotification(body: notificationBody)
                    }
                    else if differenceOfPhotos > 0
                    {
                        //deleted some photos
                        print("Photos deleted")
                    }
                }
                else
                {
                    //self.sharedAlbums.append(remoteAlbum)
                    //new album
                    let notificationBody = "\(remoteAlbum.owner) has added you to new album \(remoteAlbum.name)"
                    self.addAlbumNotification(key: key, body: notificationBody)
                    self.sendNotification(body: notificationBody)
                }
            }
        }
    }
    
    func sharedAlbumsLoaded(sharedAlbumsData: [Any])
    {
        let remoteSharedAlbums = getPhotoAlbums(from: sharedAlbumsData)
        
        self.checkIsDataUpdated(remoteAlbums: remoteSharedAlbums)
        //TODO: add for deleted albums and photos?
        
        //update data
        self.updateData(albums: remoteSharedAlbums)
    }
    
    func getPhotoAlbums(from albumsData: [Any]) -> [SharedPhotoAlbum]
    {
        var photoAlbums = [SharedPhotoAlbum]()
        
        for data in albumsData
        {
            if let albumElement = data as? (key: String, value: Any)
            {
                if let albumData = albumElement.value as? [String:Any]
                {
                    if let photoAlbum = getAlbum(fromData: albumData)
                    {
                        photoAlbum.setKey(albumElement.key)
                        
                        photoAlbums.append(photoAlbum)
                    }
                }
            }
        }
        
        return photoAlbums
    }
    
    func getAlbum(fromData albumData: [String : Any]) -> SharedPhotoAlbum?
    {
        guard let name = albumData[album_nameKey] as? String else { return nil }
    
        let photoAlbum = SharedPhotoAlbum(name: name)
        
        if let owner = albumData[album_ownerKey] as? String
        {
            photoAlbum.owner = owner
        }
        
        var numberOfPhotos = 0
        
        if let imagesData = albumData[album_imagesKey] as? [String:Any]
        {
            numberOfPhotos = imagesData.count
        }
        
        photoAlbum.photosCount = numberOfPhotos

        return photoAlbum
    }
    
    func addAlbumNotification(key: String, body: String)
    {
        let notificationData = NotificationData(body: body, date: Date())
        notificationData.setAction(.showAlbum, key: key)
        self.notificationData.append(notificationData)
    }
    
    func sendNotification(body: String)
    {
        let notification = UILocalNotification()
        notification.timeZone = NSTimeZone.default
        notification.fireDate = Date().addingTimeInterval(5)
        notification.alertBody = body
        notification.applicationIconBadgeNumber = 1
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(notification)
    }
}
