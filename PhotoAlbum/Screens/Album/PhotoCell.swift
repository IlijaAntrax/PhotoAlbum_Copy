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
        
        self.imgView.contentMode = .scaleAspectFill
    }
    
    var photo: Photo?
    {
        didSet
        {
            if let photo = self.photo
            {
                if let image = photo.image
                {
                    if photo.filter != .NoFilter
                    {
                        let img = FilterStore.filterImage(image: image, filterType: photo.filter, intensity: 0.5)
                        imgView.image = img
                    }
                    else
                    {
                        imgView.image = image
                    }
                    imgView.layer.transform = self.photo?.transform ?? CATransform3DIdentity
                }
                else if let url = photo.url
                {
                    //download image
                    //photo?.downloadFromFirebase()
                    
                    let firebaseStorage = FirebaseStorageController()
                    
                    firebaseStorage.downloadImage(withUrlPath: url.path.replacingOccurrences(of: "/https:/", with: "https://"), completionHandler: { (image) in
                        self.imgView.image = image
                        self.photo?.image = image
                        
                        self.imgView.layer.transform = self.photo?.transform ?? CATransform3DIdentity
                    })
                }
            }
        }
    }
    
}
