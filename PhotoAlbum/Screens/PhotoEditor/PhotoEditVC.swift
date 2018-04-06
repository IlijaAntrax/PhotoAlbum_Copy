//
//  PhotoEditVC.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 3/13/18.
//  Copyright © 2018 Ilija Antonijevic. All rights reserved.
//

import Foundation
import UIKit

class PhotoEditVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    var photo:Photo?
    var selectedFilter = FilterType.NoFilter
    
    var editorImageView: EditorImageView!
    
    
    @IBOutlet weak var filtersCollection: UICollectionView!
    
    @IBOutlet weak var photoView: UIView!
    
    @IBOutlet weak var editorOptionsBtn: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let photo = self.photo
        {
            let image = FilterStore.filterImage(image: photo.image, filterType: photo.filter, intensity: 0.5)
            
            let editorImgView = EditorImageView(image: image)
            editorImgView.initialPosition()
            editorImgView.hasScale = true
            editorImgView.hasRotate = true
            editorImgView.hasAutoAlign = true
            editorImgView.layer.transform = photo.transform
            //photoImgView.image = photo?.image
            
            photoView.addSubview(editorImgView)
            
            editorImageView = editorImgView
        }
        
        filtersCollection.delegate = self
        filtersCollection.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(photoTransformed(_:)), name: NSNotification.Name.init(imageEditingEndedNotificaiton), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.filtersCollection.reloadData()
    }
    
    //MARK: Observer method
    @objc func photoTransformed(_ notification:NSNotification)
    {
        if let transform = notification.object as? CATransform3D
        {
            //update transform matrix to server
            photo?.transform = transform
            
            //photo?.updateTransformData()
        }
    }
    
    @IBAction func closeBtnPressed(_ sender: Any)
    {
        photo?.update()
        
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Collection view delegate, data source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return FilterType.filtersNumber()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterImageCell", for: indexPath) as! FilterImageCell
        
        cell.setup(withImage: (photo?.image)!, filter: FilterType(rawValue: indexPath.item)!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        self.selectedFilter = FilterType(rawValue: indexPath.item)!
        editorImageView.image = FilterStore.filterImage(image: photo?.image, filterType: selectedFilter, intensity: 0.5)
        photo?.filter = self.selectedFilter
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = collectionView.frame.height

        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets.init(top: 0.0, left: editorOptionsBtn.frame.width, bottom: 0.0, right: 0.0)
    }
    
}
