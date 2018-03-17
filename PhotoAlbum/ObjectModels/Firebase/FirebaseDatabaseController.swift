//
//  FirebaseController.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 2/11/18.
//  Copyright © 2018 Ilija Antonijevic. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

let usersKey = "userskey_"
let user_nameKey = "name"
let user_emailKey = "email"

let album_nameKey = "name"
let album_ownerKey = "owner"
let album_creatioDateKey = "creationDate"
let album_imagesKey = "images"

let photo_urlKey = "url"
let photo_transformKey = "transform"

let privilegiesKey = "privilegies"
let privilegies_readKey = "read"
let privilegies_writeKey = "write"
let privilegies_updateKey = "update"
let privilegies_deleteKey = "delete"

@objc protocol DatabaseDelegate:class
{
    @objc optional func myAlbumsLoaded(myAlbumsData: [Any])
    @objc optional func sharedAlbumsLoaded(sharedAlbumsData: [Any])
    @objc optional func userDataLoaded(usersData: [String:Any])
}

class FirebaseDatabaseController
{
    private var dbRef: DatabaseReference
    
    weak var databaseDelegate: DatabaseDelegate?
    
    init()
    {
        dbRef = Database.database().reference()
    }
    
    //MARK: CRUD
    
    //MARK: CREATE firebase methods
    public func createUser()
    {
        if let currentUser = Auth.auth().currentUser
        {
            let id = currentUser.uid
            let name = currentUser.displayName
            let email = currentUser.email
            
            self.createUser(withUid: id, name: name!, email: email!)
        }
    }
    
    private func createUser(withUid uid:String, name:String, email:String)
    {
        let userRef = self.dbRef.child("users").child(usersKey + uid)

        var userInfo = [String:Any]()
        userInfo[user_nameKey] = name
        userInfo[user_emailKey] = email
        userRef.setValue(userInfo)
        
        print("User created!")
    }
    
    func createPhotoAlbum(_ album:PhotoAlbum)
    {
        let albumRef = self.dbRef.child("photoalbums").childByAutoId()
        
        var albumData = [String:Any]()
        albumData[album_creatioDateKey] = album.creationDate.description
        albumData[album_nameKey] = album.name
        if let owner = Auth.auth().currentUser?.displayName
        {
            albumData[album_ownerKey] = owner
        }
        albumData[album_imagesKey] = nil
        
        albumRef.setValue(albumData)
    }
    
    func addImageToPhotoAlbum(albumID:String, imageUrl:String)
    {
        let imageRef = self.dbRef.child("photoalbums").child(albumID).child(album_imagesKey).childByAutoId()
        
        imageRef.setValue([photo_urlKey:imageUrl])
    }
    
    func addPhotoToAlbum(_ photo: Photo, albumID:String)
    {
        let imageRef = self.dbRef.child("photoalbums").child(albumID).child(album_imagesKey).childByAutoId()
        
        imageRef.setValue([photo_urlKey:photo.url?.absoluteString])
        imageRef.setValue([photo_transformKey:photo.getTransformData()])
    }
    
    func addUserOnAlbum(userID:String, albumID:String, withPrivilegies privilegies:Privilegies)
    {
        let sharedAlbum = self.dbRef.child("sharedalbums").child(userID).child(albumID).child(privilegiesKey)
        
        var privilegiesData = [String:Any]()
        privilegiesData[privilegies_readKey] = privilegies.read
        privilegiesData[privilegies_writeKey] = privilegies.write
        privilegiesData[privilegies_updateKey] = privilegies.update
        privilegiesData[privilegies_deleteKey] = privilegies.delete
        
        sharedAlbum.setValue(privilegiesData)
        //sharedAlbum.updateChildValues(privilegiesData)
    }
    
    //MARK: READ firebase methods
    func getSelfUserData()
    {
        if let uid = Auth.auth().currentUser?.uid
        {
            print(uid)
            let selfUserRef = self.dbRef.child("users").child(usersKey + uid)
            selfUserRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let selfUserInfo = snapshot.value as? [String:Any]
                {
                    if let username = selfUserInfo[user_nameKey] as? String
                    {
                        print(username)
                    }
                    if let email = selfUserInfo[user_emailKey] as? String
                    {
                        print(email)
                    }
                }
            })
        }
    }
    
    public func getUser(byName name: String)
    {
        let userRef = self.dbRef.child("users").queryOrdered(byChild: user_nameKey).queryEqual(toValue: name)
        
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            print(snapshot)
            if let userInfo = snapshot.value as? [String:Any]
            {
                if let userDictionary = userInfo.first
                {
                    print(userDictionary.key)
                    print(userDictionary.value)
                }
            }
        }
    }
    
    public func getPhotoAlbumsBySelf()
    {
        if let currentUserName = Auth.auth().currentUser?.displayName
        {
            let albumRef = self.dbRef.child("photoalbums").queryOrdered(byChild: album_ownerKey).queryEqual(toValue: currentUserName)
            
            albumRef.observeSingleEvent(of: .value) { (snapshot) in
                
                var albums = [Any]()
                
                if let albumInfo = snapshot.value as? [String:Any]
                {
                    for album in albumInfo.enumerated()
                    {
                        print(album.element.key)
                        albums.append(album.element)
                        print(album.element)
                        print(album.offset)
                    }
                }
                
                self.databaseDelegate?.myAlbumsLoaded?(myAlbumsData: albums)
            }
        }
    }
    
    func getPhotoAlbums(byUser username:String)
    {
        let albumRef = self.dbRef.child("photoalbums").queryOrdered(byChild: album_ownerKey).queryEqual(toValue: username)
        
        albumRef.observeSingleEvent(of: .value) { (snapshot) in
            
            if let albumInfo = snapshot.value as? [String:Any]
            {
                for album in albumInfo.enumerated()
                {
                    print(album.element)
                    print(album.offset)
                }
            }
        }
    }
    
    func getSharedAlbumsBySelf()
    {
        if let uid = Auth.auth().currentUser?.uid
        {
            let sharedAlbumsRef = self.dbRef.child("sharedalbums").child(usersKey + uid)
            
            sharedAlbumsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let photoAlbums = snapshot.value as? [String:Any]
                {
                    var albums = [Any]()
                    
                    var albumsCnt = photoAlbums.count
                    
                    for photoAlbum in photoAlbums.enumerated()
                    {
                        print(photoAlbum.element.value)
                        self.getPhotoAlbum(byId: photoAlbum.element.key, completionHandler: { (data) in
                            
                            albumsCnt -= 1
                            
                            var albumData = [String:Any]()
                            
                            if let data = data as? [String:Any]
                            {
                                print(data)
                                albumData = data
                                if let privilegiesData = photoAlbum.element.value as? [String:Any]
                                {
                                    albumData[privilegiesKey] = privilegiesData[privilegiesKey]
                                }
                                
                                albums.append(albumData)
                            }
                            
                            if albumsCnt == 0
                            {
                                self.databaseDelegate?.sharedAlbumsLoaded?(sharedAlbumsData: albums)
                            }
                        })
                    }
                }
            })
        }
    }
    
    func getPhotoAlbum(byId albumID:String, completionHandler:@escaping (Any?) -> ())
    {
        let albumRef = self.dbRef.child("photoalbums").child(albumID)
        
        albumRef.observeSingleEvent(of: .value) { (snapshot) in
            
            var data:Any?
            if let albumData = snapshot.value as? [String:Any]
            {
                //print(albumData)
                data = albumData
            }
            
            completionHandler(data)
        }
    }
    
    func searchForUsers(byName name:String)
    {
        let usersRef = self.dbRef.child("users").queryOrdered(byChild: user_nameKey).queryEqual(toValue: name)
        
        usersRef.observeSingleEvent(of: .value) { (snapshot) in
            print(snapshot)
            if let user = snapshot.value as? [String:Any]
            {
                print(user)
                self.databaseDelegate?.userDataLoaded?(usersData: user)
            }
        }
    }
    
    //MARK: UPDATE firebase methods
    func updatePhotoTransform(_ photoID: String, albumID: String, transformData: [CGFloat])
    {
        let imageRef = self.dbRef.child("photoalbums").child(albumID).child(album_imagesKey).child(photoID)
        
        imageRef.setValue([photo_transformKey:transformData])
    }
    
    //MARK: DELETE firebase methods
}
