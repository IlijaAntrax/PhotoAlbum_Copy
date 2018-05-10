//
//  MyAlbumCell.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 5/9/18.
//  Copyright © 2018 Ilija Antonijevic. All rights reserved.
//

import Foundation
import UIKit

class MyAlbumCell:NewAlbumCell
{
    
    @IBOutlet weak var albumUsersCollection: UICollectionView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
    }
    
    override func setup(album: PhotoAlbum)
    {
        super.setup(album: album)
        
        if let myAlbum = album as? MyPhotoAlbum
        {
            super.peopleCountLbl.text = "shared with \(myAlbum.albumUsers.count) people" //TODO: add album users on album and setup cells
        }
    }
    
    override func addNew()
    {
        //add new user on album
    }
}
