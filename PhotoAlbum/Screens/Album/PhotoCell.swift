//
//  PhotoCell.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 12/3/17.
//  Copyright © 2017 Ilija Antonijevic. All rights reserved.
//

import Foundation
import UIKit

class PhotoCell: UICollectionViewCell
{
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        //self.imgView.contentMode = .scaleToFill
    }
    
    var photo: Photo?
    {
        didSet
        {
            imgView.image = photo?.image
        }
    }
}
