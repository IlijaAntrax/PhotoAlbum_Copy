//
//  HomeVC.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 11/4/17.
//  Copyright © 2017 Ilija Antonijevic. All rights reserved.
//

import UIKit

enum AlbumType
{
    case myAlbums
    case sharedAlbums
}

class HomeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    
    private let cellsInRow:Int = 3

    var selectedAlbum:PhotoAlbum?
    
    var selectedAlbumType:AlbumType = .myAlbums
    
    @IBOutlet weak var albumsCollection: UICollectionView!
    
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var notificationBtn: UIButton!
    @IBOutlet weak var accountBtn: UIButton!
    
    @IBOutlet weak var searchHolder: UIView!
    @IBOutlet weak var notificationsHolder: UIView!
    @IBOutlet weak var accountHolder: UIView!
    
    @IBOutlet weak var sharedAlbumsBtn: UIButton!
    @IBOutlet weak var myAlbumsBtn: UIButton!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        albumsCollection.delegate = self
        albumsCollection.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMyAlbumsData), name: Notification.Name.init(rawValue: NotificationMyAlbumsLoaded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSharedAlbumsData), name: Notification.Name.init(rawValue: NotificationSharedAlbumsLoaded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSelectedAlbum), name: NSNotification.Name.init(rawValue: NotificationPhotosAddedToAlbum), object: nil)
        
        setup()
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        albumsCollection.reloadData()
    }
    
    func setup()
    {
        User.sharedInstance.getMyAlbums()
        User.sharedInstance.getSharedAlbums()
        
        setupView()
    }
    
    func setupView()
    {
        showAccountView()
    }
    
    func showAlbumVC(forAlbum: PhotoAlbum)
    {
        self.selectedAlbum = forAlbum
        
        performSegue(withIdentifier: "albumSegueIdentifier", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "albumSegueIdentifier"
        {
            if let albumVC = segue.destination as? AlbumVC
            {
                albumVC.photoAlbum = selectedAlbum
            }
        }
    }
    
    @objc func reloadMyAlbumsData()
    {
        if selectedAlbumType == .myAlbums
        {
            albumsCollection.reloadData()
        }
    }
    
    @objc func reloadSharedAlbumsData()
    {
        if selectedAlbumType == .sharedAlbums
        {
            albumsCollection.reloadData()
        }
    }
    
    @objc func reloadSelectedAlbum()
    {
        albumsCollection.reloadData()
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
        album.save()
        User.sharedInstance.myAlbums.append(album)
        
        albumsCollection.reloadData()
    }
    
    
    func showSearchView()
    {
        searchBtn.alpha = 1.0
        notificationBtn.alpha = 0.5
        accountBtn.alpha = 0.5
        
        accountHolder.isHidden = true
        notificationsHolder.isHidden = true
        searchHolder.isHidden = false
    }
    
    func showNotificationsView()
    {
        searchBtn.alpha = 0.5
        notificationBtn.alpha = 1.0
        accountBtn.alpha = 0.5
        
        accountHolder.isHidden = true
        notificationsHolder.isHidden = false
        searchHolder.isHidden = true
    }
    
    func showAccountView()
    {
        searchBtn.alpha = 0.5
        notificationBtn.alpha = 0.5
        accountBtn.alpha = 1.0
        
        accountHolder.isHidden = false
        notificationsHolder.isHidden = true
        searchHolder.isHidden = true
        
        if selectedAlbumType == .myAlbums
        {
            showMyAlbums()
        }
        else
        {
            showSharedAlbums()
        }
    }
    
    func showMyAlbums()
    {
        sharedAlbumsBtn.alpha = 0.5
        myAlbumsBtn.alpha = 1.0
        
        selectedAlbumType = .myAlbums
        albumsCollection.reloadData()
    }
    
    func showSharedAlbums()
    {
        sharedAlbumsBtn.alpha = 1.0
        myAlbumsBtn.alpha = 0.5
        
        selectedAlbumType = .sharedAlbums
        albumsCollection.reloadData()
    }
    
    //MARK: IBActions
    @IBAction func searchAlbumsPressed(_ sender: Any)
    {
        showSearchView()
    }
    
    @IBAction func notificationPressed(_ sender: Any)
    {
        showNotificationsView()
    }
    
    @IBAction func accountPressed(_ sender: Any)
    {
        showAccountView()
    }
    
    @IBAction func sharedBtnPressed(_ sender: Any)
    {
        showSharedAlbums()
    }
    
    @IBAction func myAlbumsBtnPressed(_ sender: Any)
    {
        showMyAlbums()
    }
    
    //MARK: CollectionView delegate, data source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if selectedAlbumType == .myAlbums
        {
            return User.sharedInstance.myAlbums.count + 1
        }
        else
        {
            return User.sharedInstance.sharedAlbums.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if selectedAlbumType == .myAlbums
        {
            if indexPath.item == 0
            {
                //TODO: show add new album cell
                let newAlbumCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewAlbumCell", for: indexPath) as? NewAlbumCell
                
                newAlbumCell?.setupDefault()
                
                return newAlbumCell!
            }
            else
            {
                //TODO: show albums
                let myAlbumCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyAlbumCell", for: indexPath) as? MyAlbumCell
                
                myAlbumCell?.album = User.sharedInstance.myAlbums[indexPath.item - 1]
                
                return myAlbumCell!
            }
        }
        else
        {
            //show shared albums
            let sharedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SharedAlbumCell", for: indexPath) as? SharedAlbumCell
            
            sharedCell?.album = User.sharedInstance.sharedAlbums[indexPath.item]
            
            return sharedCell!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if selectedAlbumType == .myAlbums
        {
            if indexPath.item == 0
            {
                self.addNewAlbum()
            }
            else
            {
                showAlbumVC(forAlbum: User.sharedInstance.myAlbums[indexPath.row - 1])
            }
        }
        else
        {
            showAlbumVC(forAlbum: User.sharedInstance.sharedAlbums[indexPath.row])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if selectedAlbumType == .myAlbums
        {
            if indexPath.item == 0
            {
                let width = collectionView.frame.width
                let height = width * 270 / 1240
                
                return CGSize(width: width, height: height)
            }
            else
            {
                let width = collectionView.frame.width
                let height = width * 445 / 1240
                
                return CGSize(width: width, height: height)
            }
        }
        else
        {
            let width = collectionView.frame.width * 0.3
            let height = width * 400 / 450
            
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        var insset:CGFloat = 0.0
        if selectedAlbumType == .sharedAlbums
        {
            insset = collectionView.frame.width * 0.1
        }
        return insset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        var insset:CGFloat = 0.0
        if selectedAlbumType == .sharedAlbums
        {
            insset = collectionView.frame.width * 0.1
        }
        return insset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        var insset:CGFloat = 0.0
        if selectedAlbumType == .sharedAlbums
        {
            insset = collectionView.frame.width * 0.1
        }
        return UIEdgeInsets.init(top: 0.0, left: insset, bottom: 0.0, right: insset)
    }
    
}
