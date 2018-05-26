//
//  UserProfileCell.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 5/16/18.
//  Copyright © 2018 Ilija Antonijevic. All rights reserved.
//

import Foundation
import UIKit

class UserProfileCell: UICollectionViewCell
{
 
    @IBOutlet weak var bgdImgView: UIImageView!
    
    @IBOutlet weak var usernameLbl: UILabel!
    
    @IBOutlet weak var friendsLbl: UILabel!
    @IBOutlet weak var friendsCntLbl: UILabel!
    
    @IBOutlet weak var myAlbumsLbl: UILabel!
    @IBOutlet weak var myAlbumsCntLbl: UILabel!
    
    @IBOutlet weak var sharedLbl: UILabel!
    @IBOutlet weak var sharedCntLbl: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        bgdImgView.contentMode = .scaleAspectFill
        bgdImgView.image = UIImage(named: "profile_default_cover.jpg")
        bgdImgView.alpha = 0.175
        
        usernameLbl.font = Settings.sharedInstance.fontBoldSizeLarge()
        usernameLbl.textColor = Settings.sharedInstance.fontColorGrayDark()
        
        friendsLbl.font = Settings.sharedInstance.fontRegularSizeSmall()
        friendsLbl.textColor = Settings.sharedInstance.fontColorGrayNormal()
        friendsCntLbl.font = Settings.sharedInstance.fontBoldSizeSmall()
        friendsCntLbl.textColor = Settings.sharedInstance.fontColorDefault()
        
        myAlbumsLbl.font = Settings.sharedInstance.fontRegularSizeSmall()
        myAlbumsLbl.textColor = Settings.sharedInstance.fontColorGrayNormal()
        myAlbumsCntLbl.font = Settings.sharedInstance.fontBoldSizeSmall()
        myAlbumsCntLbl.textColor = Settings.sharedInstance.fontColorDefault()
        
        sharedLbl.font = Settings.sharedInstance.fontRegularSizeSmall()
        sharedLbl.textColor = Settings.sharedInstance.fontColorGrayNormal()
        sharedCntLbl.font = Settings.sharedInstance.fontBoldSizeSmall()
        sharedCntLbl.textColor = Settings.sharedInstance.fontColorDefault()
    }
    
    func setup()
    {
        self.usernameLbl.text = "\(User.sharedInstance.username)"
        self.myAlbumsCntLbl.text = "\(User.sharedInstance.myAlbums.count)"
        self.sharedCntLbl.text = "\(User.sharedInstance.sharedAlbums.count)"
    }
    
}
