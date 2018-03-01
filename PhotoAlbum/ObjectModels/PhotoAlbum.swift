//
//  PhotoAlbum.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 12/3/17.
//  Copyright © 2017 Ilija Antonijevic. All rights reserved.
//

import Foundation
import UIKit

class PhotoAlbum
{
    var name: String = ""
    var albumImage: UIImage?
    var creationDate: Date = Date()
    
    private var photoImages = [Photo]()
    private var key:String?
    
    var photos:[Photo]
    {
        return self.photoImages
    }
    
    var databaseKey:String?
    {
        if let key = self.key
        {
            return key
        }
        return nil
    }
    
    var privilegies:Privilegies = Privilegies(owner: true)
    
    init() {
        
    }
    
    init(name: String, date: Date)
    {
        self.name = name
        self.creationDate = date
    }
    
    func setPrivilegies(read:Bool, write:Bool, update:Bool, delete:Bool)
    {
        self.privilegies.read = read
        self.privilegies.write = write
        self.privilegies.update = update
        self.privilegies.delete = delete
    }
    
    func setKey(_ key:String)
    {
        self.key = key
    }
    
    //MARK: CRUD methods
    func save()
    {
        let firebase = FirebaseDatabaseController()
        firebase.createPhotoAlbum(self)
    }
    
    //Photos methods
    func uploadPhotos()
    {
        
    }
    
    func add(_ photo: Photo)
    {
        self.photoImages.append(photo)
        photo.setMyAlbum(self)
        photo.uploadToFirebase()
    }
    
}

class Privilegies
{
    var read:Bool
    var write:Bool
    var update:Bool
    var delete:Bool
    
    init(owner:Bool)
    {
        if owner
        {
            self.read = true
            self.write = true
            self.update = true
            self.delete = true
        }
        else
        {
            self.read = true
            self.write = false
            self.update = false
            self.delete = false
        }
    }
}
