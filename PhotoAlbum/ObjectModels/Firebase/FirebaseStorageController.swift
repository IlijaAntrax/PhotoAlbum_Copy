//
//  FirebaseStorageController.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 2/22/18.
//  Copyright © 2018 Ilija Antonijevic. All rights reserved.
//

import Foundation
import FirebaseStorage

protocol StorageDelegate:class
{
    func photoUploaded(withUrl url:URL)
    func photoUploadFailed()
}

class FirebaseStorageController
{
    
    private var storageRef:StorageReference
    
    weak var storageDelegate:StorageDelegate?
    
    init()
    {
        storageRef = Storage.storage().reference()
    }
    
    public func uploadImage(withData data:Data, withUrlName urlName:String)
    {
        let localUrlImage = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(urlName)
        if FileManager.default.fileExists(atPath: localUrlImage.path)
        {
            print("exist")
        }
        
        let imgRef = storageRef.child("albumsImages/\(urlName)")
        print(imgRef.fullPath)
        
        //User.sharedInstance.uploadPicture(fromURL: localUrlImage)
        // Upload the file to the path "images/rivers.jpg"
        _ = imgRef.putData(data, metadata: nil) { (metadata, error) in
            print(error)
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                self.storageDelegate?.photoUploadFailed()
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            let downloadURL = metadata.downloadURL()
            print(metadata.size)
            print(downloadURL)
            self.storageDelegate?.photoUploaded(withUrl: downloadURL!)
        }
    }
    
}
