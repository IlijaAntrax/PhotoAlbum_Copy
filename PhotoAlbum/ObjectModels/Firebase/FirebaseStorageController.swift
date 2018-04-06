//
//  FirebaseStorageController.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 2/22/18.
//  Copyright © 2018 Ilija Antonijevic. All rights reserved.
//

import Foundation
import FirebaseStorage
import UIKit

protocol StorageDelegate:class
{
    //upload
    func photoUploaded(withUrl url:URL)
    func photoUploadFailed()
    //download
    func photoDownloaded(image: UIImage)
    func photoDonwloadFailed()
}

class FirebaseStorageController
{
    private var storageRef:StorageReference
    
    //weak var storageDelegate:StorageDelegate?
    
    init()
    {
        storageRef = Storage.storage().reference()
    }
    
    public func uploadImage(withData data:Data, withUrlName urlName:String, completionHandler:@escaping (URL?) -> ())
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
            
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                //self.storageDelegate?.photoUploadFailed()
                completionHandler(nil)
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            let downloadURL = metadata.downloadURL()
            //self.storageDelegate?.photoUploaded(withUrl: downloadURL!)
            completionHandler(downloadURL)
        }
    }
    
    func downloadImage(withUrlPath url:String, completionHandler:@escaping (UIImage?) -> ())
    {
        let reference = Storage.storage().reference(forURL: url)
        
        reference.getData(maxSize: 4 * 1024 * 1024) { (data, error) in
            if let imageData = data
            {
                if let image = UIImage(data: imageData)
                {
                    //set delegate for image
                    //self.storageDelegate?.photoDownloaded(image: image)
                    completionHandler(image)
                }
            }
            if let err = error
            {
                print(err)
                
                //self.storageDelegate?.photoDonwloadFailed()
                completionHandler(nil)
            }
        }
    }
    
}
