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
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        albumNameLbl.font = Settings.sharedInstance.fontBoldSizeMedium()
        albumNameLbl.textColor = Settings.sharedInstance.fontColorGrayDark()
        albumNameLbl.adjustsFontSizeToFitWidth = true
    }
    
    override func setup(album: PhotoAlbum)
    {
        super.setup(album: album)
        
        photosCountLbl.isHidden = true
        
        super.addMask()
    }
}
