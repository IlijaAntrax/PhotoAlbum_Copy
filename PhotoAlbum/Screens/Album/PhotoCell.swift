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
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.imgView.contentMode = .scaleAspectFill
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        if self.activityIndicatorView != nil
        {
            activityIndicatorView?.frame = contentView.frame
            activityIndicatorView?.startAnimating()
        }
    }
    
    
    @IBAction func deleteBtnPressed(_ sender: Any)
    {
        //delete image
       self.showLoader()
        self.photo?.deleteImageFromStorage(completionHandler: { (success) in
            if success
            {
                //remove from album, and reload collection
            }
            else
            {
                //print alert
            }
            self.hideLoader()
        })
    }
    
    var isDownloading = false
    
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
                else if !isDownloading
                {
                    if let url = photo.url
                    {
                        //download image
                        //photo?.downloadFromFirebase()
                        
                        let firebaseStorage = FirebaseStorageController()
                        
                        self.showLoader()
                        
                        self.isDownloading = true
                        
                        firebaseStorage.downloadImage(withUrlPath: url.path.replaceUrl(url), completionHandler: { (image) in
                            
                            let img = FilterStore.filterImage(image: image, filterType: photo.filter, intensity: 0.5)
                            self.imgView.image = img
                            
                            self.photo?.image = image
                            
                            self.imgView.layer.transform = self.photo?.transform ?? CATransform3DIdentity
                            
                            self.hideLoader()
                            
                            self.isDownloading = false
                        })
                    }
                }
            }
        }
    }
    
    var activityIndicatorView:NVActivityIndicatorView?
    
    func showLoader()
    {
        let frame = self.contentView.frame
        activityIndicatorView = NVActivityIndicatorView(frame: frame,
                                                            type: NVActivityIndicatorType.ballPulseSync)
        
        activityIndicatorView?.padding = self.contentView.frame.width / 4
        activityIndicatorView?.color = Settings.sharedInstance.activityIndicatorColor()
        activityIndicatorView?.backgroundColor = Settings.sharedInstance.activityIndicatorBgdColor()
        
        self.contentView.addSubview(activityIndicatorView!)
        activityIndicatorView?.startAnimating()
    }
    
    func hideLoader()
    {
        activityIndicatorView?.stopAnimating()
        activityIndicatorView?.removeFromSuperview()
    }
}
