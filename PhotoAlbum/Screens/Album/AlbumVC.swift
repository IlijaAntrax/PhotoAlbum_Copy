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
    
    @IBOutlet weak var contentView:UIView!
    
    @IBOutlet weak var photosCollection: UICollectionView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        photosCollection.delegate = self
        photosCollection.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAlbum), name: NSNotification.Name.init(rawValue: NotificationPhotosAddedToAlbum), object: nil)
        
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
