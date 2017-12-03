//
//  LoginVC.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 11/26/17.
//  Copyright © 2017 Ilija Antonijevic. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate
{
    private let keyboardAnimateDuration = 0.3
    
    private var username: String = ""
    private var password: String = ""
    
    @IBOutlet weak var profileImgView: UIButton!
    
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var usernameTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        usernameTxtField.delegate = self
        passwordTxtField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        setup()
    }
    
    func setup()
    {
        usernameTxtField.font = UIFont(name: Settings.sharedInstance.appFont(), size: Settings.sharedInstance.fontSizeNormal())
        usernameTxtField.textColor = Settings.sharedInstance.fontColorGray()
        
        passwordTxtField.font = UIFont(name: Settings.sharedInstance.appFont(), size: Settings.sharedInstance.fontSizeNormal())
        passwordTxtField.textColor = Settings.sharedInstance.fontColorGray()
        passwordTxtField.isSecureTextEntry = true
    }
    
    func hide()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func animateView(constant: CGFloat)
    {
        UIView.animate(withDuration: keyboardAnimateDuration)
        {
            self.viewBottomConstraint.constant = constant
            self.loadViewIfNeeded()
        }
    }
    
    func createProfilePicutre(withImage image: UIImage)
    {
        //profileImgView.setBackgroundImage(image, for: .normal)
        let viewFrame = CGRect(origin: CGPoint(x: profileImgView.frame.minX, y: profileImgView.frame.minY), size: CGSize(width: profileImgView.frame.width, height: profileImgView.frame.height))
        let imageView = UIImageView(frame: viewFrame)
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        self.profileImgView.superview?.insertSubview(imageView, belowSubview: profileImgView)
        profileImgView.setBackgroundImage(nil, for: .normal)
    }
    
    func loggin()
    {
        let loginStatus = User.sharedInstance.loggIn(username: self.username, password: self.password)
        
        if loginStatus == .loginSuccess
        {
            //login success, show home
            self.hide()
        }
        else if loginStatus == .signUpSuccess
        {
            //signed success, show home
            self.hide()
        }
        else
        {
            let alert = UIAlertController(title: "Login failed", message: "You cant loggin. \(loginStatus)", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
            alert.present(self, animated: true, completion: nil)
        }
    }
    
    //MARK: Keyboard notification
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
            
            self.animateView(constant: 0)
            
            return true
        }
        return false
    }
    
    //MARK: Text field delegate
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        print("close keyboard")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == usernameTxtField
        {
            print("username changed")
        }
        else
        {
            print("password changed")
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        print("animate view")
        
        self.animateView(constant: -(UIScreen.main.bounds.size.height * 0.3))
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.animateView(constant: 0)
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: IBActions
    @IBAction func loggInBtnAction()
    {
        let hide = self.hideKeyboardIfNeeded()
        
        if hide
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + keyboardAnimateDuration + 0.1, execute: {
                self.loggin()
            })
        }
        else
        {
            loggin()
        }
    }
    
    @IBAction func addProfilePhoto()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.cameraDevice = .front
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: {
                print("camera opened")
            })
        }
    }
    
    //MARK: image picker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            self.createProfilePicutre(withImage: image)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
}
