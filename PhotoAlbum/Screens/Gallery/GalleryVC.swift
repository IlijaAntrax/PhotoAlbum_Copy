//
//  GalleryVC.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 11/21/17.
//  Copyright © 2017 Ilija Antonijevic. All rights reserved.
//

import Foundation
import UIKit
import Photos
import FirebaseStorage

class GalleryVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    private let cellsInRow:Int = 4
    private let insetOffset:CGFloat = 2.0
    
    var photoAlbum:PhotoAlbum?
    
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult<PHAsset>!
    var assetThumbnailSize: CGSize!
    var requestOptions: PHImageRequestOptions!
    
    var selectedImageIndexes: [Int] = [Int]()
    
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        galleryCollectionView.delegate = self
        galleryCollectionView.dataSource = self
        
        setupAssetCollcetion()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        fetchPhotosFromAssetCollection()
    }
    
    func setupAssetCollcetion()
    {
        let fetchOptions = PHFetchOptions()
        
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let first_Obj:AnyObject = collection.firstObject
        {
            //found the album
            self.assetCollection = first_Obj as! PHAssetCollection
        }
    }
    
    func fetchPhotosFromAssetCollection()
    {
        if let cellSize = (galleryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize
        {
            self.assetThumbnailSize = CGSize(width: cellSize.width * 2.0, height: cellSize.height * 2.0)
        }
        
        self.requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.resizeMode = .fast
        requestOptions.deliveryMode = .highQualityFormat

        //fetch the photos from collection
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        self.photosAsset = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        self.galleryCollectionView.reloadData()
    }
    
    //MARK: fecth photos from gallery
    private var galleryImageSize = CGSize()
    private var imagesFromGallery = [UIImage]()
    
    func prepareOptionsForFecthing()
    {
        
    }
    
    func photosLoadedFromGallery()
    {
        if imagesFromGallery.count > 0
        {
            for image in imagesFromGallery
            {
                let photo = Photo(image: image)
                photoAlbum?.add(photo)
            }
            
            NotificationCenter.default.post(name: Notification.Name.init(rawValue: NotificationPhotosAddedToAlbum), object: nil)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    //IBActions
    @IBAction func backBtnAction()
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPhotosBtnAction()
    {
        let dispacthGroup = DispatchGroup()
        
        for index in selectedImageIndexes
        {
            
//            DispatchQueue.main.async {
//                
//                let asset: PHAsset = self.photosAsset[index]
//                
//                PHImageManager.default().requestImageData(for: asset, options: self.requestOptions, resultHandler: { (data, name, orientation, info) in
//                    
//                    if let imgData = data
//                    {
//                        let urlName = "photo1try"
//                        let storage = Storage.storage().reference()
//                        let imgRef = storage.child("albumsImages/\(urlName)")
//                        imgRef.putData(imgData, metadata: nil, completion: { (metadata, error) in
//                            if let downloadUrl = metadata?.downloadURL()
//                            {
//                                print(downloadUrl)
//                            }
//                            print(error)
//                        })
//                    }
//                    
//                })
//            }
            dispacthGroup.enter()
            
            let imageQueue = DispatchQueue(label: "assetAppendQueue_" + String(index))
            imageQueue.async {
                
                let asset: PHAsset = self.photosAsset[index]
                
                let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
                print(size)
                
                PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: PHImageContentMode.aspectFit, options: self.requestOptions, resultHandler: {(result, info)in
                    if let image = result
                    {
                        self.imagesFromGallery.append(image)
                    }
                    dispacthGroup.leave()
                })

            }
        }
        
        dispacthGroup.notify(queue: DispatchQueue.main) {
            self.photosLoadedFromGallery()
        }
    }
    
    
    //MARK: CollectionView delegate methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if self.photosAsset != nil
        {
            return self.photosAsset.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCell
        
        let asset: PHAsset = self.photosAsset[indexPath.item]
        
        PHImageManager.default().requestImage(for: asset, targetSize: self.assetThumbnailSize, contentMode: .aspectFill, options: requestOptions, resultHandler: {(result, info)in
            if result != nil {
                cell.photoView.image = result
                cell.isPictureSelected = self.selectedImageIndexes.contains(indexPath.row)
            }
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        print(indexPath)
        if let cell = collectionView.cellForItem(at: indexPath) as? GalleryCell
        {
            cell.isPictureSelected = !cell.isPictureSelected
            
            if selectedImageIndexes.contains(indexPath.row)
            {
                selectedImageIndexes.remove(at: selectedImageIndexes.index(of: indexPath.row)!)
            }
            else
            {
                selectedImageIndexes.append(indexPath.row)
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = (collectionView.frame.width - (CGFloat(cellsInRow) + 1) * insetOffset) / CGFloat(cellsInRow)
        let height = width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return insetOffset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return insetOffset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets.init(top: 0.0, left: insetOffset, bottom: 0.0, right: insetOffset)
    }
}
