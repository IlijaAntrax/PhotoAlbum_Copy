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
    
    func addImages(fromData imagesData:[String : Any])
    {
        for data in imagesData.enumerated()
        {
            if let imageData = data.element.value as? [String:Any]
            {
                let photo = Photo(key: data.element.key)
                
                if let urlPath = imageData[photo_urlKey] as? String
                {
                    let url = URL(fileURLWithPath: urlPath)
                    photo.url = url
                }
                
                if let transformData = imageData[photo_transformKey] as? [CGFloat]
                {
                    photo.setTransform(fromData: transformData)
                }
                
                if let filterValue = imageData[photo_filterKey] as? Int
                {
                    photo.filter = FilterType(rawValue: filterValue)!
                }
                
                self.add(photo)
            }
        }
    }
    
    func setPrivilegies(fromData privilegiesData: [String : Any])
    {
        let privilegies = Privilegies(owner: false)
        
        if let read = privilegiesData[privilegies_readKey] as? Bool
        {
            privilegies.read = read
        }
        
        if let write = privilegiesData[privilegies_writeKey] as? Bool
        {
            privilegies.write = write
        }
        
        if let update = privilegiesData[privilegies_updateKey] as? Bool
        {
            privilegies.update = update
        }
        
        if let delete = privilegiesData[privilegies_deleteKey] as? Bool
        {
            privilegies.delete = delete
        }
        
        self.privilegies = privilegies
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
        
        if photo.image != nil
        {
            photo.uploadToFirebase()
        }
        
        if photo.url != nil
        {
            //photo.downloadFromFirebase()
        }
    }
    
    func remove(_ photo: Photo)
    {
        if let index = self.photoImages.index(where: { (photoImg) -> Bool in
            if photo.key == photoImg.key
            {
                return true
            }
            return false
        })
        {
            self.photoImages.remove(at: index)
        }
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
            self.write = true
            self.update = false
            self.delete = false
        }
    }
}
