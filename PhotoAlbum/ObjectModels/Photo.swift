//
//  Photo.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 12/3/17.
//  Copyright © 2017 Ilija Antonijevic. All rights reserved.
//

import Foundation
import  UIKit
import Photos

enum ImageQuality
{
    case low
    case medium
    case high
}

class Photo: StorageDelegate
{
    private var img: UIImage?
    
    private var asset: PHAsset?
    
    private var myAlbum: PhotoAlbum?
    
    private var imgUrl: URL?
    
    var image: UIImage?
    {
        get
        {
            return img
        }
        set
        {
            img = image
        }
    }
    
    var url: URL?
    {
        get
        {
            return imgUrl
        }
        set
        {
            imgUrl = url
        }
    }
    
    init()
    {
        
    }
    
    init(image: UIImage)
    {
        self.img = image
    }
    
    init(asset: PHAsset)
    {
        self.asset = asset
    }
    
    init(url: URL)
    {
        self.imgUrl = url
    }
    
    public func setMyAlbum(_ photoAlbum:PhotoAlbum?)
    {
        self.myAlbum = photoAlbum
    }
    
    public func getImage(quality: ImageQuality, completionHandler:@escaping (UIImage?) -> ())
    {
        if let asset = self.asset
        {
            switch quality {
            case .low:
                self.getLowQualityImage(fromAsset: asset, completionHandler: { (image) in
                    completionHandler(image)
                })
            case .medium:
                self.getMediumQualityImage(fromAsset: asset, completionHandler: { (image) in
                    completionHandler(image)
                })
            case .high:
                self.getHighQualityImage(fromAsset: asset, completionHandler: { (image) in
                    completionHandler(image)
                })
            }
        }
        else
        {
            completionHandler(nil)
        }
    }
    
    private func getImage(fromAsset asset: PHAsset, forOptions requestOptions: PHImageRequestOptions, size: CGSize, completionHandler:@escaping (UIImage?) -> ())
    {
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions, resultHandler: {(result, info)in
            completionHandler(result)
        })
    }
    
    private func getLowQualityImage(fromAsset asset: PHAsset, completionHandler:@escaping (UIImage?) -> ())
    {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.resizeMode = .fast
        requestOptions.deliveryMode = .fastFormat
        
        let size = CGSize(width: asset.pixelWidth / 4, height: asset.pixelHeight / 4)
        
        getImage(fromAsset: asset, forOptions: requestOptions, size: size, completionHandler: { (image) in
            completionHandler(image)
        })
    }
    
    private func getMediumQualityImage(fromAsset asset: PHAsset, completionHandler:@escaping (UIImage?) -> ())
    {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.resizeMode = .exact
        requestOptions.deliveryMode = .opportunistic
        
        let size = CGSize(width: asset.pixelWidth / 2, height: asset.pixelHeight / 2)
        
        getImage(fromAsset: asset, forOptions: requestOptions, size: size, completionHandler: { (image) in
            completionHandler(image)
        })
    }
    
    private func getHighQualityImage(fromAsset asset: PHAsset, completionHandler:@escaping (UIImage?) -> ())
    {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.resizeMode = .none
        requestOptions.deliveryMode = .highQualityFormat
        
        let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        
        getImage(fromAsset: asset, forOptions: requestOptions, size: size, completionHandler: { (image) in
            completionHandler(image)
        })
    }
    
    //MARK: Firebase Storage Delegate
    func getDocumentsDirectory() -> URL
    {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func photoUploaded(withUrl url: URL)
    {
        print(url.path)
        
        if let albumKey = myAlbum?.databaseKey
        {
            let firebaseDatabase = FirebaseDatabaseController()
            firebaseDatabase.addImageToPhotoAlbum(albumID: albumKey, imageUrl: url.absoluteString)
        }
    }
    
    func photoUploadFailed()
    {
        print("Photo upload failed")
    }
    
    func photoDownloaded(image: UIImage)
    {
        self.image = image
        //send norification i download image
    }
    
    func photoDonwloadFailed()
    {
        print("Photo download failed")
    }
    
    //MARK: Firebase upload/download
    func uploadToFirebase()
    {
        // Data in memory
        if let imageData = UIImageJPEGRepresentation(self.img!, 0.5)
        {
            if let myAlbum = self.myAlbum
            {
                let imageUrlName = User.sharedInstance.username + "_" + myAlbum.name + "_" + Date().description + ".jpg"
                
                let filename = getDocumentsDirectory().appendingPathComponent(imageUrlName)
                try? imageData.write(to: filename)
                print(filename)
                
                let firebaseStorage = FirebaseStorageController()
                firebaseStorage.storageDelegate = self
                firebaseStorage.uploadImage(withData: imageData, withUrlName: imageUrlName)
            }
        }
    }
    
    func downloadFromFirebase()
    {
        if let url = self.imgUrl
        {
            let firebaseStorage = FirebaseStorageController()
            firebaseStorage.storageDelegate = self
            firebaseStorage.downloadImage(withUrlPath: url.absoluteString)
        }
    }
    
}
