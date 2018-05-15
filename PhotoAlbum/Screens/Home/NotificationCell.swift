//
//  NotificationCell.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 5/15/18.
//  Copyright © 2018 Ilija Antonijevic. All rights reserved.
//

import Foundation
import UIKit

class NotificationCell:UICollectionViewCell
{
    
    @IBOutlet weak var iconImgView:UIImageView!
    
    @IBOutlet weak var textLbl:UILabel!
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        //TODO: setup
        textLbl.numberOfLines = 2
        textLbl.adjustsFontSizeToFitWidth = true
    }
    
    var notificationData: NotificationData?
    {
        didSet
        {
            if let notificationData = self.notificationData
            {
                //TODO: setup icon depends of notification action
                //TODO: set atributed string
                let time = abs(Int(notificationData.date.timeIntervalSinceNow / 60.0))
                let txt = "\(notificationData.body). \(time) min"
                textLbl.text = txt
            }
        }
    }
}
