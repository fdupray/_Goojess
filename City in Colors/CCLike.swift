//
//  CCLike.swift
//  Goojess
//
//  Created by Simon Blomqvist on 2017-04-15.
//  Copyright © 2017 Carman. All rights reserved.
//

import UIKit

class CCLike: PFObject, PFSubclassing {
    
    /*private static var __once: () = {
            self.registerSubclass()
        }()
    
    override class func initialize() {
        struct Static {
            static var onceToken : Int = 0;
        }
        _ = CCLike.__once
    }*/
    
    static func parseClassName() -> String {
        
        return "CCLike"
    }
    
    @NSManaged var post: CCTimelinePost!
    
    @NSManaged var user: CCUser!
}
