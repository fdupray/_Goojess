//
//  CCReview.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import Foundation
import Parse

class CCReview: PFObject, PFSubclassing {
    
    
    /*private static var __once: () = {
            self.registerSubclass()
        }()
    
    
    override class func initialize() {
        struct Static {
            static var onceToken : Int = 0;
        }
        _ = CCReview.__once
    }
    */
    static func parseClassName() -> String {
        
        return "CCReview"
    }

    @NSManaged var strReportText: String!
    
    @NSManaged var reporter: CCUser!
    
    @NSManaged var reportedLocation: CCLocation!

}
