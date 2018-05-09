//
//  AlbumVC.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 12/3/17.
//  Copyright © 2017 Ilija Antonijevic. All rights reserved.
//

import Foundation
import UIKit

class AlbumVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    private let cellsInRow:Int = 2
    private let insetOffset:CGFloat = 10.0
    
    var photoAlbum: PhotoAlbum?
    
    var selectedPhoto: Photo?
    
    @IBOutlet weak var contentView:UIView!
    
    @IBOutlet weak var photosCollection: UICollectionView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        photosCollection.delegate = self
        photosCollection.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAlbum), name: NSNotification.Name.init(rawValue: NotificationPhotosAddedToAlbum), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showDeleteAlert(_:)), name: NSNotification.Name.init(rawValue: NotificationDeletePhotoFromAlbum), object: nil)
        
        setup()
    }
    
    func setup()
    {
        if let album = photoAlbum
        {
            print(album.name)
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        contentView.layer.addBorder(edge: .top, color: Settings.sharedInstance.albumsBorderColor(), thickness: Settings.sharedInstance.albumsBorderWidth())
        contentView.layer.addBorder(edge: .bottom, color: Settings.sharedInstance.albumsBorderColor(), thickness: Settings.sharedInstance.albumsBorderWidth())
        contentView.layer.addBorder(edge: .left, color: Settings.sharedInstance.albumsBorderColor(), thickness: Settings.sharedInstance.albumsBorderWidth())
        contentView.layer.addBorder(edge: .right, color: Settings.sharedInstance.albumsBorderColor(), thickness: Settings.sharedInstance.albumsBorderWidth())
        
        self.photosCollection.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "gallerySegueIdentifier"
        {
            if let galleryVC = segue.destination as? GalleryVC
            {
                galleryVC.photoAlbum = self.photoAlbum
            }
        }
        else if segue.identifier == "searchUsersSegueIdentifier"
        {
            if let searchUsersVC = segue.destination as? SearchUsersVC
            {
                searchUsersVC.sharedAlbum = self.photoAlbum
            }
        }
        else if segue.identifier == "photoEditorSegueIdentifier"
        {
            if let photoEditVC = segue.destination as? PhotoEditVC
            {
                photoEditVC.photo = self.selectedPhoto
            }
        }
    }
    
    @objc func showDeleteAlert(_ notification: NSNotification)
    {
        if let photo = notification.object as? Photo
        {
            let deleteAlert = UIAlertController(title: "Delete photo!", message: "Are you sure, you want to delete this photo?", preferredStyle: .actionSheet)
            let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
                //delete photo
                self.deletePhoto(photo: photo)
                deleteAlert.dismiss(animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            deleteAlert.addAction(yesAction)
            deleteAlert.addAction(cancelAction)
            self.present(deleteAlert, animated: true, completion: nil)
        }
    }
    
    func deletePhoto(photo: Photo?)
    {
        //self.showLoader()
        photo?.deleteImageFromStorage(completionHandler: { (success) in
            if success
            {
                //remove from album, and reload collection
                self.photosCollection.reloadData()
            }
            else
            {
                //print alert
            }
            //self.hideLoader()
        })
    }
    
    
    
    @objc func reloadAlbum()
    {
        photosCollection.reloadData()
    }
    
    //MARK: IBActions
    @IBAction func backBtnAction()
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPhotosBtnAction()
    {
        performSegue(withIdentifier: "gallerySegueIdentifier", sender: self)
    }
    
    //MARK: Collection view delegate, data source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if let album = photoAlbum
        {
            return album.photos.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        cell.photo = photoAlbum?.photos[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        self.selectedPhoto = photoAlbum?.photos[indexPath.item]
        
        performSegue(withIdentifier: "photoEditorSegueIdentifier", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = (collectionView.frame.width - (CGFloat(cellsInRow) + 1) * insetOffset) / CGFloat(cellsInRow)
        let height = width * 1.1
        
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
