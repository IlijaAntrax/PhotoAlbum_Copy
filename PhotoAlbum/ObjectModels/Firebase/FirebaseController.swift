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

class FirebaseController
{
    private let usersKey = "userskey_"
    private let user_nameKey = "name"
    private let user_emailKey = "email"
    
    private let album_nameKey = "name"
    private let album_ownerKey = "owner"
    private let album_creatioDateKey = "creationDate"
    private let album_imagesKey = "images"
    
    private let photo_urlKey = "url"
    
    private let privilegiesKey = "privilegies"
    private let privilegies_readKey = "read"
    private let privilegies_writeKey = "write"
    private let privilegies_updateKey = "update"
    private let privilegies_deleteKey = "delete"
    
    private var dbRef: DatabaseReference
    
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
    
    func addUserOnAlbum(userID:String, albumID:String, withPrivilegies privilegies:Privilegies)
    {
        let sharedAlbum = self.dbRef.child("sharedalbums").child(userID).child(albumID).child(privilegiesKey)
        
        var privilegiesData = [String:Any]()
        privilegiesData[privilegies_readKey] = privilegies.read
        privilegiesData[privilegies_writeKey] = privilegies.write
        privilegiesData[privilegies_updateKey] = privilegies.update
        privilegiesData[privilegies_deleteKey] = privilegies.delete
        
        sharedAlbum.setValue(privilegiesData)
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
                    if let username = selfUserInfo[self.user_nameKey] as? String
                    {
                        print(username)
                    }
                    if let email = selfUserInfo[self.user_emailKey] as? String
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
            self.getPhotoAlbums(byUser: currentUserName)
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
                    for photoAlbum in photoAlbums.enumerated()
                    {
                        print(photoAlbum.element)
                        self.getPhotoAlbum(byId: photoAlbum.element.key)
                    }
                }
            })
        }
    }
    
    func getPhotoAlbum(byId albumID:String)
    {
        let albumRef = self.dbRef.child("photoalbums").child(albumID)
        
        albumRef.observeSingleEvent(of: .value) { (snapshot) in
            if let albumData = snapshot.value as? [String:Any]
            {
                print(albumData)
            }
        }
    }
    
    func searchForUsers(byPrefixName name:String)
    {
        let usersRef = self.dbRef.child("users").queryOrdered(byChild: user_nameKey).queryStarting(atValue: name)
        
        usersRef.observeSingleEvent(of: .value) { (snapshot) in
            print(snapshot)
            if let users = snapshot.value as? [String:Any]
            {
                print(users)
            }
        }
    }
    
    //MARK: UPDATE firebase methods
    
    
    //MARK: DELETE firebase methods
}
