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
    
    //@IBOutlet weak var searchBtn: UIButton!
    var notificationBtn: UIButton!
    var accountBtn: UIButton!
    
    @IBOutlet weak var searchHolder: UIView!
    @IBOutlet weak var notificationsHolder: UIView!
    @IBOutlet weak var notificationsCollection: UICollectionView!
    @IBOutlet weak var accountHolder: UIView!
    
    @IBOutlet weak var sharedAlbumsBtn: UIButton!
    @IBOutlet weak var myAlbumsBtn: UIButton!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        albumsCollection.delegate = self
        albumsCollection.dataSource = self
        
        addNotificationBtn()
        addAccountBtn()
        
        notificationsCollection.delegate = self
        notificationsCollection.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMyAlbumsData), name: Notification.Name.init(rawValue: NotificationMyAlbumsLoaded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSharedAlbumsData), name: Notification.Name.init(rawValue: NotificationSharedAlbumsLoaded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSelectedAlbum), name: NSNotification.Name.init(rawValue: NotificationPhotosAddedToAlbum), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addUsersOnAlbum(_:)), name: NSNotification.Name.init(rawValue: NotificationPhotosAddedToAlbum), object: nil)
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        albumsCollection.reloadData()
    }
    
    //NavigationBarItems
    func addNotificationBtn()
    {
        let btnWidth = (navigationController?.navigationBar.frame.height)!
        notificationBtn = UIButton(type: .custom)
        notificationBtn.frame = CGRect(x: 0.0, y: 0.0, width: btnWidth, height: btnWidth)
        notificationBtn.setBackgroundImage(UIImage(named: "notification_inactive.png"), for: .normal)
        notificationBtn.setBackgroundImage(UIImage(named: "notification_active.png"), for: .selected)
        notificationBtn.addTarget(self, action: #selector(showNotificationsView), for: .touchUpInside)
        
        let notificationBarItem = UIBarButtonItem(customView: notificationBtn)
        let currWidth = notificationBarItem.customView?.widthAnchor.constraint(equalToConstant: btnWidth)
        currWidth?.isActive = true
        let currHeight = notificationBarItem.customView?.heightAnchor.constraint(equalToConstant: btnWidth)
        currHeight?.isActive = true
        
        self.navigationItem.leftBarButtonItem = notificationBarItem
    }
    
    func addAccountBtn()
    {
        let btnWidth = (navigationController?.navigationBar.frame.height)!
        accountBtn = UIButton(type: .custom)
        accountBtn.frame = CGRect(x: 0.0, y: 0.0, width: btnWidth, height: btnWidth)
        accountBtn.setBackgroundImage(UIImage(named: "profie_inactive.png"), for: .normal)
        accountBtn.setBackgroundImage(UIImage(named: "profie_active.png"), for: .selected)
        accountBtn.addTarget(self, action: #selector(showAccountView), for: .touchUpInside)
        
        let accountBarItem = UIBarButtonItem(customView: accountBtn)
        let currWidth = accountBarItem.customView?.widthAnchor.constraint(equalToConstant: btnWidth)
        currWidth?.isActive = true
        let currHeight = accountBarItem.customView?.heightAnchor.constraint(equalToConstant: btnWidth)
        currHeight?.isActive = true
        
        self.navigationItem.rightBarButtonItem = accountBarItem
    }
    
    func setup()
    {
        User.sharedInstance.getMyAlbums()
        User.sharedInstance.getSharedAlbums()
        
        setupView()
        setupLblsBtns()
    }
    
    func setupLblsBtns()
    {
        myAlbumsBtn.titleLabel?.font = Settings.sharedInstance.fontBoldSizeMedium()
        myAlbumsBtn.setTitleColor(Settings.sharedInstance.fontColorDefault(), for: .normal)
        
        sharedAlbumsBtn.titleLabel?.font = Settings.sharedInstance.fontBoldSizeMedium()
        sharedAlbumsBtn.setTitleColor(Settings.sharedInstance.fontColorDefault(), for: .normal)
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
    
    @objc func addUsersOnAlbum(_ notification: NSNotification)
    {
        if let album = notification.object as? PhotoAlbum
        {
            performSegue(withIdentifier: "searchUsersSegueIdentifier", sender: album)
        }
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
        else if segue.identifier == "searchUsersSegueIdentifier"
        {
            if let searchUsersVC = segue.destination as? SearchUsersVC
            {
                if let album = sender as? PhotoAlbum
                {
                    searchUsersVC.sharedAlbum = album
                }
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
        //searchBtn.isSelected = true
        notificationBtn.isSelected = false
        accountBtn.isSelected = false
        
        accountHolder.isHidden = true
        notificationsHolder.isHidden = true
        searchHolder.isHidden = false
    }
    
    @objc func showNotificationsView()
    {
        //searchBtn.isSelected = false
        notificationBtn.isSelected = true
        accountBtn.isSelected = false
        
        accountHolder.isHidden = true
        notificationsHolder.isHidden = false
        searchHolder.isHidden = true
    }
    
    @objc func showAccountView()
    {
        //searchBtn.isSelected = false
        notificationBtn.isSelected = false
        accountBtn.isSelected = true
        
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
        if collectionView == notificationsCollection
        {
            return User.sharedInstance.userData.notificationData.count
        }
        else
        {
            if selectedAlbumType == .myAlbums
            {
                return User.sharedInstance.myAlbums.count + 2
            }
            else
            {
                return User.sharedInstance.sharedAlbums.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView == notificationsCollection
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotificationCell", for: indexPath) as? NotificationCell
            
            cell?.notificationData = User.sharedInstance.userData.notificationData[indexPath.item]
            
            return cell!
        }
        else
        {
            if selectedAlbumType == .myAlbums
            {
                if indexPath.item == 0 // profile cell
                {
                    let profileCell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserProfileCell", for: indexPath) as? UserProfileCell
                    
                    profileCell?.setup()
                    
                    return profileCell!
                }
                else if indexPath.item == 1
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
                    
                    myAlbumCell?.album = User.sharedInstance.myAlbums[indexPath.item - 2]
                    
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
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if collectionView == notificationsCollection
        {
            let notification = User.sharedInstance.userData.notificationData[indexPath.item]
            
            //TODO: show on notification action
            if notification.actionType == .showAlbum
            {
                let albumKey = notification.actionKey
                print("Show album with key: \(albumKey)")
            }
            else
            {
                
            }
        }
        else
        {
            if selectedAlbumType == .myAlbums
            {
                if indexPath.item == 0
                {
                    //TODO: show profile, or do nothing
                }
                else if indexPath.item == 1
                {
                    self.addNewAlbum()
                }
                else
                {
                    showAlbumVC(forAlbum: User.sharedInstance.myAlbums[indexPath.row - 2])
                }
            }
            else
            {
                showAlbumVC(forAlbum: User.sharedInstance.sharedAlbums[indexPath.row])
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if collectionView == notificationsCollection
        {
            let width = collectionView.frame.width
            let height = width * 200 / 1242
            
            return CGSize(width: width, height: height)
        }
        else
        {
            if selectedAlbumType == .myAlbums
            {
                if indexPath.item == 0
                {
                    let width = collectionView.frame.width
                    let height = width * 420 / 1242
                    
                    return CGSize(width: width, height: height)
                }
                else if indexPath.item == 1
                {
                    let width = collectionView.frame.width
                    let height = width * 270 / 1242
                    
                    return CGSize(width: width, height: height)
                }
                else
                {
                    let width = collectionView.frame.width
                    let height = width * 445 / 1242
                    
                    return CGSize(width: width, height: height)
                }
            }
            else
            {
                let insset = collectionView.frame.width * 0.02
                let offsets = 2.0 * insset + 2.0 * insset
                let width = (collectionView.frame.width - offsets) * 0.33
                let height = width * 500 / 400
                
                return CGSize(width: width, height: height)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        var insset:CGFloat = 0.0
        if collectionView == notificationsCollection
        {
            
        }
        else
        {
            if selectedAlbumType == .sharedAlbums
            {
                insset = collectionView.frame.width * 0.02
            }
        }
        return insset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        var insset:CGFloat = 0.0
        if collectionView == notificationsCollection
        {
            
        }
        else
        {
            if selectedAlbumType == .sharedAlbums
            {
                insset = collectionView.frame.width * 0.02
            }
        }
        return insset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        var insset:CGFloat = 0.0
        if collectionView == notificationsCollection
        {
            
        }
        else
        {
            if selectedAlbumType == .sharedAlbums
            {
                insset = collectionView.frame.width * 0.02
            }
        }
        return UIEdgeInsets.init(top: insset, left: insset, bottom: 0.0, right: insset)
    }
    
}
