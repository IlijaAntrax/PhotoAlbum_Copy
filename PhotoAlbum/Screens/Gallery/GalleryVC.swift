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

class GalleryVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    private let cellsInRow:Int = 4
    private let insetOffset:CGFloat = 2.0
    
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
            self.assetThumbnailSize = CGSize(width: cellSize.width, height: cellSize.height)
        }
        
        self.requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat

        //fetch the photos from collection
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        self.photosAsset = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        self.galleryCollectionView.reloadData()
    }
    
    //IBActions
    @IBAction func backBtnAction()
    {
        dismiss(animated: true, completion: nil)
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
