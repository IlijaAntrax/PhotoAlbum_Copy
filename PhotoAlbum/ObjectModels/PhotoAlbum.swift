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
    
    init() {
        
    }
    
    init(name: String, date: Date)
    {
        self.name = name
        self.creationDate = date
    }
    
}
