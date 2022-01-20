//
//  CCParticipant.swift
//  Goojess
//
//  Created by Simon Blomqvist on 2017-04-15.
//  Copyright © 2017 Carman. All rights reserved.
//

import UIKit

class CCParticipant: PFObject, PFSubclassing {
    
    /*private static var __once: () = {
            self.registerSubclass()
        }()
    
    override class func initialize() {
        struct Static {
            static var onceToken : Int = 0;
        }
        _ = CCParticipant.__once
    }*/
    
    static func parseClassName() -> String {
        
        return "CCParticipant"
    }
    
    @NSManaged var event: CCLocation!
    
    @NSManaged var user: CCUser!
    
    @NSManaged var generatedPost: CCTimelinePost!
}
