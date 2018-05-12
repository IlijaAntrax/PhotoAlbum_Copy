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
    
    override init()
    {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        sharedAlbums = aDecoder.decodeObject(forKey: "SharedAlbums") as! [SharedPhotoAlbum]
    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(sharedAlbums, forKey: "SharedAlbums")
    }
    
    func updateData(albums: [SharedPhotoAlbum])
    {
        self.sharedAlbums = albums
        //User.sharedInstance.saveUserData()
    }
    
    func searchForAlbumsUpdates()
    {
        let firebase = FirebaseDatabaseController()
        firebase.databaseDelegate = self
        
        firebase.getSharedAlbumsBySelf()
    }
    
    func checkIsDataUpdated(remoteAlbums: [SharedPhotoAlbum])
    {
        for remoteAlbum in remoteAlbums
        {
            //            if self.sharedAlbums.contains(where: { (album) -> Bool in
            //                guard let albumKey = album.databaseKey, let remoteAlbumKey = remoteAlbum.databaseKey else { return false }
            //                if albumKey == remoteAlbumKey
            //                {
            //                    return true
            //                }
            //                return false
            //            })
            //            {
            //                //check for new photos in album
            //
            //            }
            
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
                        //new photos, send notification
                        let notificationBody = "\(remoteAlbum.owner) added \(abs(differenceOfPhotos)) new photos to \(remoteAlbum.name) album"
                        self.sendNotification(body: notificationBody)
                    }
                }
                else
                {
                    //new album
                    let notificationBody = "\(remoteAlbum.owner) has added you to new album \(remoteAlbum.name)"
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
        
//        if let imagesData = albumData[album_imagesKey] as? [String:Any]
//        {
//            for data in imagesData.enumerated()
//            {
//                if let imageData = data.element.value as? [String:Any]
//                {
//                    numberOfPhotos += 1
//                    let photo = Photo(key: data.element.key)
//
//                    photoAlbum.add(photo)
//                }
//            }
//        }
        
        photoAlbum.photosCount = numberOfPhotos
        
//        if let privilegiesData = albumData[privilegiesKey] as? [String:Any]
//        {
//            photoAlbum.setPrivilegies(fromData: privilegiesData)
//        }
        
        return photoAlbum
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
