//
//  FirebaseUserCell.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 3/3/18.
//  Copyright © 2018 Ilija Antonijevic. All rights reserved.
//

import Foundation
import UIKit

class FirebaseUserCell:UICollectionViewCell
{
    @IBOutlet weak var profileImgView: UIImageView!
    
    @IBOutlet weak var usernameLbl: UILabel!
    
    
    var user:FirebaseUser?
    {
        didSet
        {
            if let user = user
            {
                profileImgView.image = user.profileImg ?? UIImage(named: "empty_image.png")
                usernameLbl.text = user.username
            }
        }
    }
}
