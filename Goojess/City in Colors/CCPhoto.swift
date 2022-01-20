//
//  CCPhoto.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import Foundation
import Parse

class CCPhoto : PFObject, PFSubclassing {
    
    
    /*private static var __once: () = {
            self.registerSubclass()
        }()
    
    
    override class func initialize() {
        struct Static {
            static var onceToken : Int = 0;
        }
        _ = CCPhoto.__once
    }*/
    
    static func parseClassName() -> String {
        
        return "CCPhoto"
    }

    
    @NSManaged var photoFile: PFFile!
    
    @NSManaged var photoUploader: CCUser!
    
    @NSManaged var photoLocation: CCLocation!
    
}
