//
//  ViewController.swift
//  PhotoAlbum
//
//  Created by Ilija Antonijevic on 11/4/17.
//  Copyright © 2017 Ilija Antonijevic. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if User.sharedInstance.isLoggedIn()
        {
            self.showHomeVC()
        }
        else
        {
            self.showLoginVC()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        super.prepare(for: segue, sender: sender)
        
        print("Prepare for next screen!")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func showHomeVC()
    {
        performSegue(withIdentifier: "homeSegueIdentifier", sender: self)
    }
    
    func showLoginVC()
    {
        performSegue(withIdentifier: "loginSegueIdentifier", sender: self.view)
    }
}

