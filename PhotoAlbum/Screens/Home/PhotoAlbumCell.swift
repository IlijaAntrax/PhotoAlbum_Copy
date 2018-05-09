//
//  AlbumCell.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 12/2/17.
//  Copyright © 2017 Ilija Antonijevic. All rights reserved.
//

import Foundation
import UIKit

class PhotoAlbumCell: UICollectionViewCell
{
    @IBOutlet weak var albumImgView: UIImageView!
    
    @IBOutlet weak var albumNameLbl: UILabel!
    
    @IBOutlet weak var photosCntLbl: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        customInit()
    }
    
    func customInit()
    {
        albumNameLbl.font = UIFont(name: Settings.sharedInstance.appFont(), size: Settings.sharedInstance.fontSizeNormal())
        albumNameLbl.textColor = Settings.sharedInstance.fontColorGray()
        albumNameLbl.adjustsFontSizeToFitWidth = true
        
        photosCntLbl.font = UIFont(name: Settings.sharedInstance.appFont(), size: Settings.sharedInstance.fontSizeNormal())
        photosCntLbl.textColor = Settings.sharedInstance.fontColorGray()
        photosCntLbl.adjustsFontSizeToFitWidth = true
        
        albumImgView.contentMode = .scaleAspectFill
    }
    
    func setup(withImage image: UIImage?, albumName: String, imgCnt: Int)
    {
        if let albumImage = image
        {
            albumImgView.image = albumImage
        }
        else
        {
            albumImgView.image = Settings.sharedInstance.emptyAlbumImage()
        }
        
        albumNameLbl.text = albumName
        
        photosCntLbl.text = String(imgCnt)
    }
    
}

class AlbumsInfoCell: UICollectionViewCell
{
    
    @IBOutlet weak var infoLbl: UILabel!
    
    @IBOutlet weak var cntLbl: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        infoLbl.font = UIFont(name: Settings.sharedInstance.appFont(), size: Settings.sharedInstance.fontSizeLarge())
        infoLbl.textColor = Settings.sharedInstance.fontColorGray()
        
        cntLbl.font = UIFont(name: Settings.sharedInstance.appFont(), size: Settings.sharedInstance.fontSizeLarge())
        cntLbl.textColor = Settings.sharedInstance.fontColorGray()
        
        self.contentView.layer.addBorder(edge: .bottom, color: Settings.sharedInstance.albumsBorderColor(), thickness: 1.0)
    }
    
    var info: String = ""
    {
        didSet
        {
            infoLbl.text = info
        }
    }
    
    var count: Int = 0
    {
        didSet
        {
            cntLbl.text = String(count)
        }
    }
}
