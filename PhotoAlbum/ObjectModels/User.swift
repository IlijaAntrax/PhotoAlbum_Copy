//
//  User.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 11/26/17.
//  Copyright © 2017 Ilija Antonijevic. All rights reserved.
//

import Foundation

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

class User:NSObject
{
    static let sharedInstance: User = {
        let instance = User()
        // setup code
        return instance
    }()
    
    private var isLogged = false
    
    private var username:String = ""
    private var password:String = ""
    
    var myAlbums = [PhotoAlbum]()
    var sharedAlbums = [PhotoAlbum]()
    
    override init()
    {
        super.init()
    }
    
    func isLoggedIn() -> Bool
    {
        return self.isLogged
    }
    
    func register(username: String, password:String)
    {
        self.username = username
        self.password = password
    }
    
    func loggIn(username: String, password:String) -> LogginStatus
    {
        if self.username == "" && self.password == ""
        {
            self.register(username: username, password: password)
            self.isLogged = true
            return LogginStatus.signUpSuccess
        }
        
        if self.username != username && self.password != password
        {
            return LogginStatus.wrongUserAndPassword
        }
        else if self.username != username
        {
            return LogginStatus.wrongUsername
        }
        else if self.password != password
        {
            return LogginStatus.wrongPassword
        }
        else
        {
            self.isLogged = true
            return LogginStatus.loginSuccess
        }
    }
}
