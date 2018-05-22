//
//  AlbumCell.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 5/9/18.
//  Copyright © 2018 Ilija Antonijevic. All rights reserved.
//

import Foundation
import UIKit

class AlbumCell:UICollectionViewCell
{
    
    @IBOutlet weak var albumImgView: UIImageView!
    @IBOutlet weak var albumNameLbl:UILabel!
    @IBOutlet weak var photosCountLbl:UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        albumImgView.contentMode = .scaleAspectFill
    }
    
    var album:PhotoAlbum?
    {
        didSet
        {
            if let album = album
            {
                setup(album: album)
            }
        }
    }
    
    func setup(album: PhotoAlbum)
    {
        albumImgView.image = album.albumImage ?? album.photos.first?.image
        albumNameLbl.text = album.name
        photosCountLbl.text = String(album.photos.count) + " photos"
    }
    
    func addMask()
    {
        if albumImgView.layer.mask == nil
        {
            let maskImg = UIImage(named: "photo_mask.png")!
            let mask = CALayer()
            mask.contents = maskImg.cgImage
            mask.frame = CGRect.init(x: 0.0, y: 0.0, width: albumImgView.frame.width, height: albumImgView.frame.height)
            albumImgView.layer.mask = mask
            albumImgView.layer.masksToBounds = true
        }
        else
        {
            albumImgView.layer.mask?.frame = CGRect.init(x: 0.0, y: 0.0, width: albumImgView.frame.width, height: albumImgView.frame.height)
        }
    }
}
