//
//  NavigationViewController.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 5/26/18.
//  Copyright © 2018 Ilija Antonijevic. All rights reserved.
//

import Foundation
import UIKit

class NavigationViewController:UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil)
    {
        let screenWidth = UIScreen.main.bounds.size.width
        
        let window = UIApplication.shared.keyWindow
        
        if let last = window?.subviews.last
        {
            if let number = window?.subviews.count
            {
                if let previous = window?.subviews[number - 2]
                {
                    window?.insertSubview(previous, aboveSubview: last)
                }
            }
        }
        // Animate the transition.
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.frame = self.view.frame.offsetBy(dx: screenWidth, dy: 0.0)
            
        }) { (Finished) -> Void in
            super.dismiss(animated: false, completion: completion)
        }
    }
}
