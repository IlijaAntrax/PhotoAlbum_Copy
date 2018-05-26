//
//  NavigationCustomSegue.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 5/26/18.
//  Copyright © 2018 Ilija Antonijevic. All rights reserved.
//

import Foundation
import UIKit

class NavigationCustomSegue:UIStoryboardSegue
{
 
    override func perform()
    {
        // Assign the source and destination views to local variables.
        let firstVCView = self.source.view!
        
        let secondVCView = self.destination.view!
        
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        // Specify the initial position of the destination view.
        secondVCView.frame = CGRect(x: screenWidth, y: 0.0, width: screenWidth, height: screenHeight)
        
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(secondVCView, aboveSubview: firstVCView)
        
        // Animate the transition.
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            secondVCView.frame = secondVCView.frame.offsetBy(dx: -screenWidth, dy: 0.0)
            
        }) { (Finished) -> Void in
            self.source.present(self.destination as UIViewController,
                                                            animated: false,
                                                            completion: nil)
        }
    }
}
