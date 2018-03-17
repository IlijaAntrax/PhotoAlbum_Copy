//
//  FilterImageCell.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 3/17/18.
//  Copyright © 2018 Ilija Antonijevic. All rights reserved.
//

import Foundation
import UIKit

class FilterImageCell:UICollectionViewCell
{
    @IBOutlet weak var filterImgView:UIImageView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.filterImgView.contentMode = .scaleAspectFill
    }
    
    func setup(withImage: UIImage, filter: FilterType)
    {
        let filteredImage = FilterStore.filterImage(image: withImage, filterType: filter, intensity: 100.0)
        
        filterImgView.image = filteredImage
    }
}
