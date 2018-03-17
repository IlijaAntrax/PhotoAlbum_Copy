//
//  UIColor+.swift
//  NailArtBasic
//
//  Created by Nikola Bozinovic on 3/11/15.
//  Copyright (c) 2015 Webelinx. All rights reserved.
//

import UIKit

public extension UIColor
{
    private class func colorComponentFrom(string:String, start:Int, lenght:Int)->CGFloat
    {
        //let range = Range(start: start, end: start+lenght)
        let substring = (string as NSString).substring(with: NSMakeRange(start, lenght))
        let fullHex = lenght==2 ? substring : "\(substring)\(substring)"
        
        var hexComponent:UInt32 = 0
        Scanner(string: fullHex).scanHexInt32(&hexComponent)
        
        return CGFloat(Float(hexComponent)/255.0)
    }
    
    public class func colorWithHexString(hexString:String)->UIColor
    {
        let colorString = hexString.replacingOccurrences(of: "#", with: "").uppercased()
        var alpha:CGFloat = 0, red:CGFloat = 0, blue:CGFloat = 0, green:CGFloat = 0
        
        switch colorString.lengthOfBytes(using: String.Encoding.utf8)
        {
        case 3: // #RGB
            alpha = 1.0;
            red   = UIColor.colorComponentFrom(string: colorString, start: 0, lenght: 1)
            green = UIColor.colorComponentFrom(string: colorString, start: 1, lenght: 1)
            blue  = UIColor.colorComponentFrom(string: colorString, start: 2, lenght: 1)
            break;
        case 4: // #ARGB
            alpha = UIColor.colorComponentFrom(string: colorString, start: 0, lenght: 1)
            red   = UIColor.colorComponentFrom(string: colorString, start: 1, lenght: 1)
            green = UIColor.colorComponentFrom(string: colorString, start: 2, lenght: 1)
            blue  = UIColor.colorComponentFrom(string: colorString, start: 3, lenght: 1)
            break;
        case 6: // #RRGGBB
            alpha = 1.0;
            red   = UIColor.colorComponentFrom(string: colorString, start: 0, lenght: 2)
            green = UIColor.colorComponentFrom(string: colorString, start: 2, lenght: 2)
            blue  = UIColor.colorComponentFrom(string: colorString, start: 4, lenght: 2)
            break;
        case 8: // #AARRGGBB
            alpha = UIColor.colorComponentFrom(string: colorString, start: 0, lenght: 2)
            red   = UIColor.colorComponentFrom(string: colorString, start: 2, lenght: 2)
            green = UIColor.colorComponentFrom(string: colorString, start: 4, lenght: 2)
            blue  = UIColor.colorComponentFrom(string: colorString, start: 6, lenght: 2)
            break;
        default:
            let error = NSError(domain: " ", code: -843, userInfo: nil)
            NSException.raise(NSExceptionName(rawValue: "Invalid color value"), format: "Color value \(hexString) is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", arguments: getVaList([error]))
            break;
        }
        
        //print("\(hexString) r:\(red*255) g:\(green*255) b:\(blue*255) a\(alpha*255)")
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func hexStringFromColor() -> String
    {
        let components = self.cgColor.components
        
        let r = Float((components?[0])!)
        let g = Float((components?[1])!)
        let b = Float((components?[2])!)
        
        return String(format: "%02lX%02lX%02lX", arguments: [lroundf(r * 255),
                                                             lroundf(g * 255),
                                                             lroundf(b * 255)])
    }
    
    class func randomColor() -> UIColor
    {
        let r = CGFloat(arc4random()%70)/100.0 + 0.3
        let g = CGFloat(arc4random()%70)/100.0 + 0.3
        let b = CGFloat(arc4random()%70)/100.0 + 0.3
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    func invertedColor()-> UIColor
    {
        let components = self.cgColor.components
        
        let r = CGFloat((components?[0])!)
        let g = CGFloat((components?[1])!)
        let b = CGFloat((components?[2])!)
        let a = CGFloat((components?[3])!)
        
        return UIColor(red: (1 - r), green: (1 - g), blue: (1 - b), alpha: a) // Assuming you want the same alpha value.
    }
    
    public class func colorFromImage(image: UIImage?)-> UIColor
    {
        if let image = image
        {
            let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
            let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
            let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
            context!.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: 1, height: 1))
            
            var color: UIColor? = nil
            
            if pixel[3] > 0 {
                let alpha:CGFloat = CGFloat(pixel[3]) / 255.0
                let multiplier:CGFloat = alpha / 255.0
                
                color = UIColor(red: CGFloat(pixel[0]) * multiplier, green: CGFloat(pixel[1]) * multiplier, blue: CGFloat(pixel[2]) * multiplier, alpha: alpha)
            }else{
                
                color = UIColor(red: CGFloat(pixel[0]) / 255.0, green: CGFloat(pixel[1]) / 255.0, blue: CGFloat(pixel[2]) / 255.0, alpha: CGFloat(pixel[3]) / 255.0)
            }
            
            pixel.deallocate(capacity: 4)
            
            if color != nil
            {
                return color!
            }
            else
            {
                return UIColor.black
            }
        }
        return UIColor.black
    }
}
