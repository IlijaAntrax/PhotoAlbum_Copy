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
        albumImgView.image = album.albumImage
        albumNameLbl.text = album.name
        photosCountLbl.text = String(album.photos.count) + " photos"
    }
}
