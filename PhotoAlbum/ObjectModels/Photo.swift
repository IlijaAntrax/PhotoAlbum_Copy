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

class Photo //: StorageDelegate
{
    private var _id: String?
    
    private var img: UIImage?
    
    private var asset: PHAsset?
    
    private var myAlbum: PhotoAlbum?
    
    private var imgUrl: URL?
    
    private var _transform = CATransform3DIdentity
    
    private var _filter: FilterType = FilterType.NoFilter
    
    var key: String?
    {
        return _id
    }
    
    var image: UIImage?
    {
        get
        {
            return img
        }
        set
        {
            img = newValue
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
            imgUrl = newValue
        }
    }
    
    var transform:CATransform3D
    {
        get
        {
            return _transform
        }
        set
        {
            _transform = newValue
        }
    }
    
    var filter:FilterType
    {
        get
        {
            return _filter
        }
        set
        {
            _filter = newValue
        }
    }
    
    init()
    {
        
    }
    
    init(key: String)
    {
        self._id = key
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
    
    //MARK: Firebase helper methods
    //transform
    func update()
    {
        updateTransformData()
        updateFilterData()
    }
    
    func updateTransformData()
    {
        guard let photoKey = key, let albumKey = myAlbum?.databaseKey else {
            return
        }
        let firebaseDatabase = FirebaseDatabaseController()
        
        firebaseDatabase.updatePhotoTransform(photoKey, albumID: albumKey, transformData: getTransformData())
    }
    
    func getTransformData() -> [CGFloat]
    {
        let transformData = [transform.m11, transform.m12, transform.m13, transform.m14,
                             transform.m21, transform.m22, transform.m23, transform.m24,
                             transform.m31, transform.m32, transform.m33, transform.m34,
                             transform.m41, transform.m42, transform.m43, transform.m44]
        
        return transformData
    }
    
    func setTransform(fromData transformData:[CGFloat])
    {
        self.transform = CATransform3D.init(m11: transformData[0], m12: transformData[1], m13: transformData[2], m14: transformData[3], m21: transformData[4], m22: transformData[5], m23: transformData[6], m24: transformData[7], m31: transformData[8], m32: transformData[9], m33: transformData[10], m34: transformData[11], m41: transformData[12], m42: transformData[13], m43: transformData[14], m44: transformData[15])
    }
    //filters
    func updateFilterData()
    {
        guard let photoKey = key, let albumKey = myAlbum?.databaseKey else {
            return
        }
        let firebaseDatabase = FirebaseDatabaseController()
        
        firebaseDatabase.updatePhotoFilter(photoKey, albumID: albumKey, filterValue: _filter.rawValue)
    }
    
    func photoUploaded(withUrl url: URL?)
    {
        self.url = url
        
        if let albumKey = myAlbum?.databaseKey
        {
            let firebaseDatabase = FirebaseDatabaseController()
            //firebaseDatabase.addImageToPhotoAlbum(albumID: albumKey, imageUrl: url.absoluteString)
            firebaseDatabase.addPhotoToAlbum(self, albumID: albumKey)
        }
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
                
                let filename = User.sharedInstance.getDocumentsDirectory().appendingPathComponent(imageUrlName)
                try? imageData.write(to: filename)
                print(filename)
                
                let firebaseStorage = FirebaseStorageController()
                
                firebaseStorage.uploadImage(withData: imageData, withUrlName: imageUrlName, completionHandler: { (url) in
                    self.photoUploaded(withUrl: url)
                })
            }
        }
    }
    
    func downloadFromFirebase()
    {
        if let url = self.imgUrl
        {
            let firebaseStorage = FirebaseStorageController()
            
            firebaseStorage.downloadImage(withUrlPath: url.absoluteString, completionHandler: { (image) in
                self.image = image
            })
        }
    }
    
    //MARK: Delete image
    func deleteImageFromStorage(completionHandler:@escaping (Bool) -> ())
    {
        if let url = self.url
        {
            let firebaseStorage = FirebaseStorageController()
            firebaseStorage.deleteImage(withUrlPath: url.path.replaceUrl(url), completionHandler: { (success) in
                if success
                {
                    guard let photoKey = self.key, let albumKey = self.myAlbum?.databaseKey else {
                        completionHandler(false)
                        return
                    }
                    let firebaseDatabase = FirebaseDatabaseController()
                    firebaseDatabase.deletePhoto(photoKey, albumID: albumKey)
                    self.myAlbum?.remove(self)
                    completionHandler(true)
                }
                else
                {
                    completionHandler(false)
                }
            })
        }
        completionHandler(false)
    }
    
}
