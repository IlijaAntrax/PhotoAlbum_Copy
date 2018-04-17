//
//  Settings.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 12/2/17.
//  Copyright © 2017 Ilija Antonijevic. All rights reserved.
//

import Foundation
import UIKit

class Settings
{
    private var font = "HelveticaNeue"
    
    static let sharedInstance: Settings = {
        let instance = Settings()
        // setup code
        return instance
    }()
    
    func appFont() -> String
    {
        return font
    }
    
    func fontColorGray() -> UIColor
    {
        return UIColor.lightGray
    }
    
    func fontColorBlue() -> UIColor
    {
        return UIColor.blue
    }
    
    func fontSizeSmall() -> CGFloat
    {
        return UIScreen.main.bounds.size.width * 0.035
    }
    
    func fontSizeNormal() -> CGFloat
    {
        return UIScreen.main.bounds.size.width * 0.05
    }
    
    func fontSizeLarge() -> CGFloat
    {
        return UIScreen.main.bounds.size.width * 0.07
    }
    
    func albumsBorderWidth() -> CGFloat
    {
        return 1.5
    }
    
    func albumsBorderColor() -> UIColor
    {
        return UIColor.lightGray
    }
    
    func sharedAlbumsName() -> String
    {
        return "Shared Albums"
    }
    
    func myAlbumsName() -> String
    {
        return "My Albums"
    }
    
    func emptyAlbumImage() -> UIImage
    {
        return UIImage(named: "empty_image.png")!
    }
    
    func activityIndicatorColor() -> UIColor
    {
        return UIColor.init(red: 95/255, green: 144/255, blue: 236/255, alpha: 1.0)
    }
    
    func activityIndicatorBgdColor() -> UIColor
    {
        return UIColor.init(red: 120/255, green: 116/255, blue: 115/255, alpha: 1.0)
    }
}
