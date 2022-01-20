//
//  CCComment.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import Foundation
import Parse

class CCComment : PFObject, PFSubclassing {
    
    
    /*private static var __once: () = {
            self.registerSubclass()
        }()
 
    
    override class func initialize() {
        struct Static {
            static var onceToken : Int = 0;
        }
        _ = CCComment.__once
    }
    */
    static func parseClassName() -> String {
        
        return "CCComment"
    }


    @NSManaged var commentLocation: CCLocation!
    
    @NSManaged var commentor: CCUser!
    
    @NSManaged var strCommentText: String!

}
