//
//  Photo.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 12/3/17.
//  Copyright © 2017 Ilija Antonijevic. All rights reserved.
//

import Foundation
import  UIKit

class Photo
{
    private var img: UIImage?
    
    var image: UIImage?
    {
        get
        {
            return img
        }
        set
        {
            img = newValue
        }
    }
    
    init()
    {
        
    }
    
    init(image: UIImage)
    {
        self.img = image
    }
    
    
}
