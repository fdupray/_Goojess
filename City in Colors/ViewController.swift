//
//  ViewController.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        logoView.image = UIImage(named: "Goojess Logo small")
        
        logoView.contentMode = .scaleAspectFit
        
        navigationItem.titleView = logoView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

