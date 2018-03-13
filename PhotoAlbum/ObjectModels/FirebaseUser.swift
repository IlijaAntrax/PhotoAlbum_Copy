//
//  FirebaseUser.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 3/3/18.
//  Copyright © 2018 Ilija Antonijevic. All rights reserved.
//

import Foundation
import UIKit

class FirebaseUser
{
    private var id:String?
    
    var username:String
    
    var profileImg:UIImage?
    
    func addSharedAlbum(album: PhotoAlbum)
    {
        guard let userID = id, let albumID = album.databaseKey else { return }
        
        let privilegies = Privilegies(owner: false)
        
        let firebase = FirebaseDatabaseController()
        firebase.addUserOnAlbum(userID: userID, albumID: albumID, withPrivilegies: privilegies)
    }
    
    init(name: String)
    {
        self.username = name
    }
    
    func setKey(_ key: String)
    {
        self.id = key
    }
}
