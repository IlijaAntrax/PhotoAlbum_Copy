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
    
    //class func
    func isPhone() -> Bool
    {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    //
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
    
    func fontColorDefault() -> UIColor
    {
        return UIColor.init(red: 80/255, green: 109/255, blue: 238/255, alpha: 1.0)
    }
    
    func fontColorWhite() -> UIColor
    {
        return UIColor.white
    }
    
    func fontColorGrayLight() -> UIColor
    {
        return UIColor.init(red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0)
    }
    
    func fontColorGrayNormal() -> UIColor
    {
        return UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
    }
    
    func fontColorGrayDark() -> UIColor
    {
        return UIColor.init(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
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
    
    func fontRegularSizeSmall() -> UIFont
    {
        return UIFont(name: "SFProDisplay-Regular", size: isPhone() ? (UIScreen.main.bounds.size.width * 0.035) : (UIScreen.main.bounds.size.width * 0.0275))!
    }
    func fontBoldSizeSmall() -> UIFont
    {
        return UIFont(name: "SFProDisplay-Bold", size: isPhone() ? (UIScreen.main.bounds.size.width * 0.035) : (UIScreen.main.bounds.size.width * 0.0275))!
    }
    
    func fontRegularSizeMedium() -> UIFont
    {
        return UIFont(name: "SFProDisplay-Regular", size: isPhone() ? (UIScreen.main.bounds.size.width * 0.05) : (UIScreen.main.bounds.size.width * 0.04))!
    }
    func fontBoldSizeMedium() -> UIFont
    {
        return UIFont(name: "SFProDisplay-Bold", size: isPhone() ? (UIScreen.main.bounds.size.width * 0.05) : (UIScreen.main.bounds.size.width * 0.04))!
    }

    func fontRegularSizeLarge() -> UIFont
    {
        return UIFont(name: "SFProDisplay-Regular", size: isPhone() ? (UIScreen.main.bounds.size.width * 0.07) : (UIScreen.main.bounds.size.width * 0.0575))!
    }
    func fontBoldSizeLarge() -> UIFont
    {
        return UIFont(name: "SFProDisplay-Bold", size: isPhone() ? (UIScreen.main.bounds.size.width * 0.07) : (UIScreen.main.bounds.size.width * 0.0575))!
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
        return UIColor.init(red: 80/255, green: 109/255, blue: 238/255, alpha: 1.0)
    }
    
    func activityIndicatorBgdColor() -> UIColor
    {
        return UIColor.init(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
    }
}
