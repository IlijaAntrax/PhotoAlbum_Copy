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
        let width:CGFloat = 150.0
        let height = width * withImage.size.height / withImage.size.width
        let scaledImage = withImage.scaledToSize(size: CGSize.init(width: width, height: height))
        let filteredImage = FilterStore.filterImage(image: scaledImage, filterType: filter, intensity: 0.5)
        
        filterImgView.image = filteredImage
    }
}
