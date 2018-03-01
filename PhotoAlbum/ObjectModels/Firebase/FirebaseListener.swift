//
//  FirebaseListener.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 2/11/18.
//  Copyright © 2018 Ilija Antonijevic. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FirebaseListener
{
    
    private var dbRef: DatabaseReference
    
    init()
    {
        dbRef = Database.database().reference()
    }
    
}
