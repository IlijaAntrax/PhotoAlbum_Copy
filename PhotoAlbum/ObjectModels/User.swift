
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
let NotificationDeletePhotoFromAlbum = "NotificationDeletePhotoFromAlbum"

class User:NSObject, DatabaseDelegate
{
    static let sharedInstance: User = {
        let instance = User()
        // setup code
        return instance
    }()
    
    private var isLogged = false
    
    private var _id:String?
    private var _username:String = ""
    private var _password:String = ""
    private var email:String?
    
    var username:String
    {
        return self._username
    }
    
    var profileImageURL:URL?
    var profileImage: UIImage?
    
    var myAlbums = [PhotoAlbum]()
    var sharedAlbums = [PhotoAlbum]()
    
    override init()
    {
        super.init()
        
        self.loadUserData()
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
            self._id = user.uid
            
            if let email = user.email
            {
                self.email = email
            }
            
            if let username = user.displayName
            {
                self._username = username
            }
            
            if let url = getProfileImageFromLocal()
            {
                self.profileImageURL = url
            }
            else
            {
                if let photoUrl = user.photoURL
                {
                    self.downloadProfilePicture(fromUrl: photoUrl)
                }
            }
            
            self.isLogged = true
        }
        
        return self.isLogged
    }
    
    func loggIn(username: String, password:String)
    {
        if self._username == "" //check if user exists with username
        {
            self.register(username: username, password: password)
        }
        else
        {
            let email = self.getEmail(fromUsername: username)
            
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
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
    }
    
    private func getEmail(fromUsername username: String) -> String
    {
        let email = username + "_pa@gmail.com"
        
        return email
    }
    
    private func getUsername(fromEmail email: String) -> String
    {
        let username = email.components(separatedBy: "_pa@").first!
        
        return username
    }
    
    func register(username: String, password:String)
    {
        self._username = username
        self._password = password
        
        let email = getEmail(fromUsername: username)
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let currentUser = user
            {
                //additional setup
                self.isLogged = true
                
                if let email = currentUser.email
                {
                    self.email = email
                    
                    let name = self.getUsername(fromEmail: email)
                    self.updateUserInfo(pictureUrl: nil, displayName: name)
                }
                
                if let url = self.profileImageURL
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
                    self.saveProfilePictureAtLocal(image: image)
                }
            }
            if let err = error
            {
                print(err)
            }
        }
    }
    
    func getProfileImageFromLocal() -> URL?
    {
        let profileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("profile_image.jpg")
        
        if FileManager.default.fileExists(atPath: profileUrl.path)
        {
            //send notification profileimage
            return profileUrl
        }
        
        return nil
    }
    
    func saveProfilePictureAtLocal(image: UIImage?)
    {
        if let image = image
        {
            if let data = UIImageJPEGRepresentation(image, 0.75)
            {
                let filename = getDocumentsDirectory().appendingPathComponent("profile_image.jpg")
                self.profileImageURL = filename
                try? data.write(to: filename)
                print(filename)
            }
        }
    }
    
    func getDocumentsDirectory() -> URL
    {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func getCacheDirectory() -> URL
    {
        return FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first!
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
    
    
    //MARK: Database delegate methods
    func myAlbumsLoaded(myAlbumsData: [Any])
    {
        self.myAlbums = getPhotoAlbums(from: myAlbumsData)
        
        NotificationCenter.default.post(name: Notification.Name.init(rawValue: NotificationMyAlbumsLoaded), object: nil)
    }
    
    func sharedAlbumsLoaded(sharedAlbumsData: [Any])
    {
        self.sharedAlbums = getPhotoAlbums(from: sharedAlbumsData)
        
        //self.userData.updateData(albums: self.sharedAlbums)
        //self.userData.searchForAlbumsUpdates()
        //self.loadUserData()
        self.userData.sharedAlbumsLoaded(sharedAlbumsData: sharedAlbumsData)
        
        NotificationCenter.default.post(name: Notification.Name.init(rawValue: NotificationSharedAlbumsLoaded), object: nil)
    }
    
    func getPhotoAlbums(from albumsData: [Any]) -> [PhotoAlbum]
    {
        var photoAlbums = [PhotoAlbum]()
        
        for data in albumsData
        {
            if let albumElement = data as? (key: String, value: Any)
            {
                if let albumData = albumElement.value as? [String:Any]
                {
                    if let photoAlbum = getAlbum(fromData: albumData)
                    {
                        photoAlbum.setKey(albumElement.key)
                        
                        photoAlbums.append(photoAlbum)
                    }
                }
            }
        }
        
        return photoAlbums
    }
    
    func getAlbum(fromData albumData: [String : Any]) -> PhotoAlbum?
    {
        guard let name = albumData[album_nameKey] as? String, let date = albumData[album_creatioDateKey] else { return nil }
        
        var albumDate = Date()
        if let date = date as? String
        {
            if let albumdate = date.getDate()
            {
                albumDate = albumdate
            }
        }
        
        let photoAlbum = PhotoAlbum(name: name, date: albumDate)
        
        if let imagesData = albumData[album_imagesKey] as? [String:Any]
        {
            photoAlbum.addImages(fromData: imagesData)
        }
        
        if let privilegiesData = albumData[privilegiesKey] as? [String:Any]
        {
            photoAlbum.setPrivilegies(fromData: privilegiesData)
        }
        
        return photoAlbum
    }
    
    
    //MARK: User local data
    var userData = UserData()
    
    func saveUserData()
    {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: self.userData)
        //save to userDefaults
        
        let userDefaults: UserDefaults = UserDefaults.standard
        userDefaults.set(encodedData, forKey: "UserData")
        userDefaults.synchronize()
    }
    
    func loadUserData()
    {
        let userDefaults: UserDefaults = UserDefaults.standard
        if let data = userDefaults.object(forKey: "UserData")
        {
            if let data = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? UserData
            {
                self.userData = data
            }
        }
    }
}
