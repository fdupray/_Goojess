//
//  CCActivity.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import Foundation
import Parse

class CCActivity : PFObject, PFSubclassing {
    
    
    /*private static var __once: () = {
        
            self.registerSubclass()
        }()
    
    
    override class func initialize() {
        struct Static {
            static var onceToken : Int = 0;
        }
        _ = CCActivity.__once
    }*/
    
    static func parseClassName() -> String {
        
        return "CCActivity"
    }

    
    @NSManaged var activityLocation: CCLocation!
    
    @NSManaged var activityPoster: CCUser!
    
    //@NSManaged var strActivityName: String!
    
    @NSManaged var strActivities: [String]!

}
