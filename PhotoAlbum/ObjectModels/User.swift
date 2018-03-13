
//
//  User.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 11/26/17.
//  Copyright © 2017 Ilija Antonijevic. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage

enum LogginStatus:String
{
    case loginSuccess = "loggin success"
    case loginFailed = "login failed"
    case wrongUserAndPassword = "wrong username and password"
    case wrongUsername = "wrong username"
    case wrongPassword = "wrong password"
    case notRegistered = "not registered"
    case signUpSuccess = "signUp success"
    case signUpFailed = "signUp failed"
}

//MARK: Notifications observers
let NotificationLogginStatus = "NotificationLogginStatus"
let NotificationMyAlbumsLoaded = "NotificationMyAlbumsLoaded"
let NotificationSharedAlbumsLoaded = "NotificationSharedAlbumsLoaded"
let NotificationPhotosAddedToAlbum = "NotificationPhotosAddedToAlbum"

class User:NSObject, DatabaseDelegate
{
    static let sharedInstance: User = {
        let instance = User()
        // setup code
        return instance
    }()
    
    private var isLogged = false
    
    private var _username:String = ""
    private var _password:String = ""
    
    var username:String
    {
        return self._username
    }
    
    var profileImage: UIImage?
    
    var myAlbums = [PhotoAlbum]()
    var sharedAlbums = [PhotoAlbum]()
    
    override init()
    {
        super.init()
    }
    
    func getStorage() -> StorageReference
    {
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        return storageRef
    }
    
    func isLoggedIn() -> Bool
    {
        self.isLogged = false
        
        if let user = Auth.auth().currentUser
        {
            print(user.uid)
            
            if let username = user.displayName
            {
                self._username = username
            }
            
            if !getProfileImageFromLocal()
            {
                if let photoUrl = user.photoURL
                {
                    //download profile picture
                    print(photoUrl)
                    self.downloadProfilePicture(fromUrl: photoUrl)
                }
            }
            
            if let email = user.email
            {
                print(email)
                //self.username = email
            }
            
            self.firebaseTest()
            
            self.isLogged = true
        }
        
        return self.isLogged
    }
    
    private func createEmail(fromUsername username: String) -> String
    {
        let email = username + "_pa@gmail.com"
        
        return email
    }
    
    private func getUsername(fromEmail email: String) -> String
    {
        let username = email.components(separatedBy: "_pa@").first!
        
        return username
    }
    
    func register(username: String, password:String, pictureUrl: URL?)
    {
        self._username = username
        self._password = password
        
        let email = createEmail(fromUsername: username)
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let currentUser = user
            {
                //additional setup
                self.isLogged = true
                
                if let email = currentUser.email
                {
                    let name = self.getUsername(fromEmail: email)
                    print(name)
                    self.updateUserInfo(pictureUrl: nil, displayName: name)
                }
                
                if let url = pictureUrl
                {
                    if FileManager.default.fileExists(atPath: url.path)
                    {
                        self.uploadPicture(fromURL: url)
                    }
                }
                
                let status = LogginStatus.loginSuccess
                NotificationCenter.default.post(name: NSNotification.Name(
                    NotificationLogginStatus), object: nil, userInfo: ["loginStatus" : status])
            }
            
            if let err = error
            {
                print(err)
                let status = LogginStatus.notRegistered
                NotificationCenter.default.post(name: NSNotification.Name(
                    NotificationLogginStatus), object: nil, userInfo: ["loginStatus" : status])
            }
        }
    }
    
    func updateUserInfo(pictureUrl: URL?, displayName: String?)
    {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        
        changeRequest?.displayName = displayName
        changeRequest?.photoURL = pictureUrl
        
        changeRequest?.commitChanges { (error) in
            if let err = error
            {
                print(err)
            }
            else
            {
                print("Updated succesfully")
            }
        }
    }
    
    func uploadPicture(fromURL localFile:URL)
    {
        // Create a reference to the file you want to upload
        let pictureName = self._username + "_profileImg.jpg"
        let imageRef = getStorage().child("profileimages/\(pictureName)")
        
        // Upload the file to the path "images/rivers.jpg"
        _ = imageRef.putFile(from: localFile, metadata: nil)  { metadata, error in
            if let error = error {
                print(error)
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata!.downloadURL()
                if let url = downloadURL
                {
                    print(url)
                    self.updateUserInfo(pictureUrl: url, displayName: nil)
                }
            }
        }
        
        //uploadTask.resume()
    }
    
    func downloadProfilePicture(fromUrl url: URL)
    {
        let reference = Storage.storage().reference(forURL: url.path)
        
        reference.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if let imageData = data
            {
                if let image = UIImage(data: imageData)
                {
                    self.profileImage = image
                    //send notification for image
                }
            }
            if let err = error
            {
                print(err)
            }
        }
    }
    
    func getProfileImageFromLocal() -> Bool
    {
        let profileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("profile_image.jpg")
        
        if FileManager.default.fileExists(atPath: profileUrl.path)
        {
            //send notification profileimage
            return true
        }
        
        return false
    }
    
    func loggIn(username: String, password:String, pictureUrl:URL?)
    {
        if self._username == ""
        {
            self.register(username: username, password: password, pictureUrl: pictureUrl)
            //self.isLogged = true
            return
        }
        
        Auth.auth().signIn(withEmail: username, password: password) { (user, error) in
            if let currentUser = user
            {
                if let email = currentUser.email
                {
                    print(username)
                    self._username = self.getUsername(fromEmail: email)
                }
                let status = LogginStatus.loginSuccess
                NotificationCenter.default.post(name: NSNotification.Name(
                    NotificationLogginStatus), object: nil, userInfo: ["loginStatus" : status])
            }
            
            if let err = error
            {
                print(err)
                let status = LogginStatus.loginFailed
                NotificationCenter.default.post(name: NSNotification.Name(
                    NotificationLogginStatus), object: nil, userInfo: ["loginStatus" : status])
            }
        }
    }
    
    //MARK: Firebase database methods
    func getMyAlbums()
    {
        let firebase = FirebaseDatabaseController()
        firebase.databaseDelegate = self
        
        firebase.getPhotoAlbumsBySelf()
    }
    
    func getSharedAlbums()
    {
        let firebase = FirebaseDatabaseController()
        firebase.databaseDelegate = self
        
        firebase.getSharedAlbumsBySelf()
    }
    
    //MARK: Firebase Test
    func firebaseTest()
    {
        //let firebase = FirebaseController.init()
        
        //firebase.createUser()
        //firebase.getUser(byName: "st_antrax")
        //firebase.getPhotoAlbums(byUser: "st_antrax")
        //firebase.getSelfUserData()
        //firebase.getSharedAlbumsBySelf()
        //firebase.searchForUsers(byPrefixName: "st")
        //firebase.createPhotoAlbum(PhotoAlbum(name: "Amsterdam", date: Date()))
        //firebase.addImageToPhotoAlbum(albumID: "-L55JEp-c_caFUyT5bON", imageUrl: "firebase.google.com/photoalbum/resque_bobi_i_holanjanka.png")
        //firebase.createPhotoAlbum(PhotoAlbum(name: "ZakintosNight", date: Date()))
        //firebase.addUserOnAlbum(userID: "userskey_2g2iXujeV5MvXIcFolkxcB94gNu1", albumID: "-L55JEp-c_caFUyT5bON", withPrivilegies: Privilegies.init(owner: false))
    }
    
    
    //MARK: Database delegate methods
    func myAlbumsLoaded(myAlbumsData: [Any])
    {
        var photoAlbums = [PhotoAlbum]()
        
        for data in myAlbumsData
        {
            if let albumElement = data as? (key: String, value: Any)
            {
                if let albumData = albumElement.value as? [String:Any]
                {
                    guard let name = albumData[album_nameKey] as? String,
                          let date = albumData[album_creatioDateKey]
                    else { continue }
                    
                    let photoAlbum = PhotoAlbum(name: name, date: Date())
                    photoAlbum.setKey(albumElement.key)
                    
                    if let images = albumData[album_imagesKey] as? [String:Any]
                    {
                        for data in images.enumerated()
                        {
                            if let imageData = data.element.value as? [String:Any]
                            {
                                if let urlPath = imageData[photo_urlKey] as? String
                                {
                                    let url = URL(fileURLWithPath: urlPath)
                                    photoAlbum.add(Photo(url: url))
                                }
                            }
                        }
                    }
                    
                    photoAlbums.append(photoAlbum)
                }
            }
        }
        
        self.myAlbums = photoAlbums
        NotificationCenter.default.post(name: Notification.Name.init(rawValue: NotificationMyAlbumsLoaded), object: nil)
    }
    
    func sharedAlbumsLoaded(sharedAlbumsData: [Any])
    {
        var photoAlbums = [PhotoAlbum]()
        
        for data in sharedAlbumsData
        {
            if let albumData = data as? [String:Any]
            {
                guard let name = albumData[album_nameKey] as? String, let date = albumData[album_creatioDateKey] else { continue }
                
                print(name)
                print(date)
                
                let photoAlbum = PhotoAlbum(name: name, date: Date())
                photoAlbums.append(photoAlbum)
            }
        }
        
        self.sharedAlbums = photoAlbums
        NotificationCenter.default.post(name: Notification.Name.init(rawValue: NotificationSharedAlbumsLoaded), object: nil)
    }
    
}
