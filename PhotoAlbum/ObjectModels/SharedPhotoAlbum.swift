//
//  SharedPhotoAlbum.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 5/9/18.
//  Copyright © 2018 Ilija Antonijevic. All rights reserved.
//

import Foundation

class SharedPhotoAlbum:PhotoAlbum, NSCoding
{
    var owner = ""
    var photosCount:Int = 0
    
    init(name: String)
    {
        super.init()
        
        super.name = name
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init()
        
        super.name = aDecoder.decodeObject(forKey: "SharedAlbumName") as! String
        owner = aDecoder.decodeObject(forKey: "SharedAlbumOwner") as! String
        photosCount = aDecoder.decodeInteger(forKey: "SharedAlbumPhotosCnt")
    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(super.name, forKey: "SharedAlbumName")
        aCoder.encode(owner, forKey: "SharedAlbumOwner")
        aCoder.encode(photosCount, forKey: "SharedAlbumPhotosCnt")
    }
    
}
