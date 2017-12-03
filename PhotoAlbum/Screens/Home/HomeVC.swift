//
//  HomeVC.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 11/4/17.
//  Copyright © 2017 Ilija Antonijevic. All rights reserved.
//

import UIKit

class HomeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    
    private let cellsInRow:Int = 2
    private let insetOffset:CGFloat = 10.0

    
    @IBOutlet weak var myAlbumsHolder: UIView!
    @IBOutlet weak var sharedAlbumsHolder: UIView!
    
    @IBOutlet weak var myAlbumsCollection: UICollectionView!
    @IBOutlet weak var sharedAlbumsCollection: UICollectionView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        myAlbumsCollection.delegate = self
        myAlbumsCollection.dataSource = self
        
        sharedAlbumsCollection.delegate = self
        sharedAlbumsCollection.dataSource = self
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        myAlbumsHolder.layer.addBorder(edge: .top, color: Settings.sharedInstance.albumsBorderColor(), thickness: Settings.sharedInstance.albumsBorderWidth())
        
        sharedAlbumsHolder.layer.addBorder(edge: .top, color: Settings.sharedInstance.albumsBorderColor(), thickness: Settings.sharedInstance.albumsBorderWidth())
    }
    
    func setup()
    {
        
    }
    
    func showAlbumVC(forAlbum: PhotoAlbum)
    {
        performSegue(withIdentifier: "albumSegueIdentifier", sender: self)
    }
    
    
    //MARK: Add new album control
    func addNewAlbum()
    {
        let alert = UIAlertController(title: "New Album", message: "Enter a name for new album", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addTextField(configurationHandler: nil)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:nil))
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler:{ (UIAlertAction) in
            if let tField = alert.textFields?.first
            {
                if let albumName = tField.text
                {
                    self.createNewAlbum(withName: albumName)
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func createNewAlbum(withName albumName: String)
    {
        //create new album, with name, date of creation,...
        print("create new album: \(albumName)")
        
        let album = PhotoAlbum(name: albumName, date: Date())
        User.sharedInstance.myAlbums.append(album)
        
        myAlbumsCollection.reloadData()
    }
    
    
    //MARK: IBActions
    @IBAction func newAlbumBtnAction()
    {
        addNewAlbum()
    }
    
    //MARK: CollectionView delegate, data source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView == myAlbumsCollection
        {
            return User.sharedInstance.myAlbums.count + 1
        }
        else
        {
            return User.sharedInstance.sharedAlbums.count + 1
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if indexPath.row == 0
        {
            var albumInfo = Settings.sharedInstance.sharedAlbumsName()
            var albumsCount = User.sharedInstance.sharedAlbums.count
            
            if collectionView == myAlbumsCollection
            {
                albumInfo = Settings.sharedInstance.myAlbumsName()
                albumsCount = User.sharedInstance.myAlbums.count
            }
            //info cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumsInfoCell", for: indexPath) as! AlbumsInfoCell
            
            cell.info = albumInfo
            cell.count = albumsCount
            
            return cell
        }
        else
        {
            var album = PhotoAlbum()
     
            if collectionView == myAlbumsCollection
            {
                album = User.sharedInstance.myAlbums[indexPath.row - 1]
            }
            else
            {
                album = User.sharedInstance.sharedAlbums[indexPath.row - 1]
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AlbumCell
            
            cell.setup(withImage: album.albumImage, albumName: album.name, imgCnt: album.photos.count)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if collectionView == myAlbumsCollection
        {
            showAlbumVC(forAlbum: User.sharedInstance.myAlbums[indexPath.row - 1])
        }
        else
        {
            showAlbumVC(forAlbum: User.sharedInstance.sharedAlbums[indexPath.row - 1])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if indexPath.row == 0
        {
            //info cell size
            let width = collectionView.frame.width - 1.9 * insetOffset
            
            return CGSize(width: width, height: width * 0.1)
        }
        
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

extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect.init(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect.init(x: 0, y: 0, width: thickness, height: frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect.init(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        self.addSublayer(border)
    }
}
