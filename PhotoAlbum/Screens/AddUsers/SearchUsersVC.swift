//
//  SearchUsersVC.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 3/3/18.
//  Copyright © 2018 Ilija Antonijevic. All rights reserved.
//

import Foundation
import UIKit

class SearchUsersVC:UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DatabaseDelegate
{
    @IBOutlet weak var searchTxtField: UITextField!
    
    @IBOutlet weak var usersCollection: UICollectionView!
    
    var sharedAlbum:PhotoAlbum?
    
    private var usersList = [FirebaseUser]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        usersCollection.delegate = self
        usersCollection.dataSource = self
        
        searchTxtField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //MARK: Search engine
    func searchUsersBy(name: String)
    {
        usersList.removeAll()
        
        if name != ""
        {
            let firebaseDatabase = FirebaseDatabaseController()
            firebaseDatabase.searchForUsers(byName: name)
            firebaseDatabase.databaseDelegate = self
        }
        else
        {
            print("Empty")
        }
    }
    
    //MARK: Firebase delegate
    func userDataLoaded(usersData: [String:Any])
    {
        for data in usersData.enumerated()
        {
            if let userData = data.element.value as? [String:Any]
            {
                if let name = userData[user_nameKey] as? String
                {
                    let user = FirebaseUser(name: name)
                    user.setKey(data.element.key)
                    usersList.append(user)
                    
                    usersCollection.reloadData()
                }
            }
        }
    }
    
    
    //MARK: IBActions
    @IBAction func backBtnAction()
    {
        if hideKeyboardIfNeeded()
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.dismiss(animated: true, completion: nil)
            })
        }
        else
        {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func addUserBtnPressed()
    {
        //add user on current album
    }
    
    //MARK: Keyboard methods
    var isKeyboardShown = false
    
    @objc func keyboardWillShow()
    {
        isKeyboardShown = true
    }
    
    @objc func keyboardWillHide()
    {
        isKeyboardShown = false
    }
    
    func hideKeyboardIfNeeded() -> Bool
    {
        if isKeyboardShown
        {
            self.view.endEditing(true)
     
            return true
        }
        return false
    }
    
    //MARK: textfield delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        if let prefixName = textField.text
        {
            print("Search users by name: \(prefixName)")
            searchUsersBy(name: prefixName)
        }
        
        return true
    }
    
    //MARK: Collection view delegate, data source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return usersList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FirebaseUserCell", for: indexPath) as! FirebaseUserCell
        
        cell.user = usersList[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if let album = self.sharedAlbum
        {
            usersList[indexPath.item].addSharedAlbum(album: album)
            print("User added on album")
            
            let alert = UIAlertController(title: "Info", message: "User \(usersList[indexPath.item].username) have access on album \(album.name) now.", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = collectionView.frame.width
        let height = width * 0.2
        
        return CGSize(width: width, height: height)
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
        return UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
}
