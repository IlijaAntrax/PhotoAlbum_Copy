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
    
    var photos = [Photo]()
    
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
