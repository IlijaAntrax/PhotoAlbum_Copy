//
//  CustomNavigationController.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 5/26/18.
//  Copyright © 2018 Ilija Antonijevic. All rights reserved.
//

import Foundation
import UIKit

class CustomNavigationController:UIViewController
{
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        addBackBarBtn()
    }
    
    func addBackBarBtn()
    {
        let btnWidth = (navigationController?.navigationBar.frame.height)!
        let image = UIImage(named: "back.png")!
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0.0, y: 0.0, width: btnWidth, height: btnWidth)
        backBtn.setBackgroundImage(image, for: .normal)
        backBtn.addTarget(self, action: #selector(popSelf), for: .touchUpInside)
        
        let backBarItem = UIBarButtonItem(customView: backBtn)
        let currWidth = backBarItem.customView?.widthAnchor.constraint(equalToConstant: btnWidth)
        currWidth?.isActive = true
        let currHeight = backBarItem.customView?.heightAnchor.constraint(equalToConstant: btnWidth)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = backBarItem
    }
    
    @objc func popSelf()
    {
        navigationController?.popViewController(animated: true)
        // do your stuff if you needed
    }
}
