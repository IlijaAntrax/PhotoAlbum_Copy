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
    
    func addHandleGesture()
    {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        
        self.addGestureRecognizer(gesture)
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer)
    {
        if sender.state == .began
        {
            //show delete button
        }
    }
    
    
    
    @IBAction func deleteBtnPressed(_ sender: Any)
    {
        //self.showDeleteAlert()
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: NotificationDeletePhotoFromAlbum), object: photo, userInfo: nil)
    }
    
    var isDownloading = false
    
    var photo: Photo?
    {
        didSet
        {
            if let photo = self.photo
            {
                self.addMask()
                
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
    
    func addMask()
    {
        if imgView.layer.mask == nil
        {
            let maskImg = UIImage(named: "photo_mask.png")!
            let mask = CALayer()
            mask.contents = maskImg.cgImage
            mask.frame = CGRect.init(x: 0.0, y: 0.0, width: imgView.frame.width, height: imgView.frame.height)
            imgView.layer.mask = mask
            imgView.layer.masksToBounds = true
        }
        else
        {
            imgView.layer.mask?.frame = CGRect.init(x: 0.0, y: 0.0, width: imgView.frame.width, height: imgView.frame.height)
        }
    }
}
