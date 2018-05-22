//
//  SharedAlbumCell.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 5/9/18.
//  Copyright © 2018 Ilija Antonijevic. All rights reserved.
//

import Foundation
import UIKit

class SharedAlbumCell:AlbumCell
{
    
    override func setup(album: PhotoAlbum)
    {
        super.setup(album: album)
        
        super.addMask()
    }
}
