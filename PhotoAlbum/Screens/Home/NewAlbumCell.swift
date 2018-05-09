//
//  NewAlbumCell.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 5/9/18.
//  Copyright © 2018 Ilija Antonijevic. All rights reserved.
//

import Foundation
import UIKit

class NewAlbumCell:AlbumCell
{
    
    @IBOutlet weak var peopleCountLbl: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    func setupDefault()
    {
        super.albumImgView.image = Settings.sharedInstance.emptyAlbumImage()
        super.albumNameLbl.text = "Create album"
        super.photosCountLbl.text = "0 photos"
        self.peopleCountLbl.text = "Not shared"
    }
    
    @IBAction func add(_ sender: Any)
    {
        addNew()
    }
    
    func addNew()
    {
        
    }
}
