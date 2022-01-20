//
//  CalloutBubble.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import UIKit

class CalloutBubble: NSObject {

    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var postedBy: UILabel!
    @IBOutlet weak var view: UIView!
    
    override init() {
        super.init()
        
        Bundle.main.loadNibNamed("CalloutBubble", owner: self, options: nil)
        
        self.roundedCornersWithBorder(cityInColorRed)
    }
    
    fileprivate func roundedCornersWithBorder(_ colour: UIColor) {
        
        self.view.layer.borderColor = colour.cgColor
        self.view.layer.borderWidth = 1
        self.view.layer.cornerRadius = 5
    }
}
