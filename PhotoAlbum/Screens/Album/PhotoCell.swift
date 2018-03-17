//
//  PhotoCell.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 12/3/17.
//  Copyright © 2017 Ilija Antonijevic. All rights reserved.
//

import Foundation
import UIKit

class PhotoCell: UICollectionViewCell, StorageDelegate //add observer image downloaded for current photo
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
            if let image = photo?.image
            {
                imgView.image = image
                imgView.layer.transform = self.photo?.transform ?? CATransform3DIdentity
            }
            else if let url = photo?.url
            {
                //download image
                //photo?.downloadFromFirebase()
                
                let firebaseStorage = FirebaseStorageController()
                firebaseStorage.storageDelegate = self
                firebaseStorage.downloadImage(withUrlPath: url.path.replacingOccurrences(of: "/https:/", with: "https://"))
            }
        }
    }
    
    //upload
    func photoUploaded(withUrl url:URL)
    {
        
    }
    func photoUploadFailed()
    {
        
    }
    //download
    func photoDownloaded(image: UIImage)
    {
        self.imgView.image = image
        self.photo?.image = image
        
        self.imgView.layer.transform = self.photo?.transform ?? CATransform3DIdentity
    }
    func photoDonwloadFailed()
    {
        
    }
}
