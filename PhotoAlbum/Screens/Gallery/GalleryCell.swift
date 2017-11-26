//
//  GalleryCell.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 11/21/17.
//  Copyright © 2017 Ilija Antonijevic. All rights reserved.
//

import Foundation
import UIKit

class GalleryCell:UICollectionViewCell
{
    @IBOutlet weak var photoView: UIImageView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
    }
    
    func setupCell(withImage image: UIImage)
    {
        photoView.image = image
    }
    
}
