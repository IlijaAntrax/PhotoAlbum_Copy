//
//  NotificationData.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 5/15/18.
//  Copyright © 2018 Ilija Antonijevic. All rights reserved.
//

import Foundation

enum ActionType:String
{
    case none = "none"
    case showAlbum = "showAlbum"
    case showPhoto = "showPhoto"
    case showSharedAlbums = "showSharedAlbums"
    case showMyAlbums = "showMyAlbums"
}

class NotificationData: NSObject, NSCoding
{
    var body:String
    var date:Date
    
    var actionType:ActionType
    var actionKey:String
    
    override init()
    {
        body = ""
        date = Date()
        
        actionKey = ""
        actionType = .none
        
        super.init()
    }
    
    init(body: String, date: Date)
    {
        self.body = body
        self.date = date
        
        actionKey = ""
        actionType = .none
        
        super.init()
    }
    
    func setAction(_ action: ActionType, key: String)
    {
        self.actionType = action
        self.actionKey = key
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        body = aDecoder.decodeObject(forKey: "NotificationDataBody") as! String
        date = aDecoder.decodeObject(forKey: "NotificationDataDate") as! Date
        
        actionKey = aDecoder.decodeObject(forKey: "NotificationDataActionKey") as! String
        actionType = ActionType(rawValue: aDecoder.decodeObject(forKey: "NotificationDataActionType") as! String)!
    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(body, forKey: "NotificationDataBody")
        aCoder.encode(date, forKey: "NotificationDataDate")
        
        aCoder.encode(actionKey, forKey: "NotificationDataActionKey")
        aCoder.encode(actionType.rawValue, forKey: "NotificationDataActionType")
    }
}
