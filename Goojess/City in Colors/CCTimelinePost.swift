//
//  CCTimelinePost.swift
//  Goojess
//
//  Created by Simon Blomqvist on 2017-04-15.
//  Copyright © 2017 Carman. All rights reserved.
//

import UIKit
import UIKit

class CCTimelinePost: PFObject, PFSubclassing {
    
    /*private static var __once: () = {
            self.registerSubclass()
        }()
    
    override class func initialize() {
        struct Static {
            static var onceToken : Int = 0;
        }
        _ = CCTimelinePost.__once
    }
    */
    static func parseClassName() -> String {
        
        return "CCTimelinePost"
    }
    
    
    @NSManaged var poster: CCUser!
    
    @NSManaged var targetUsers: [CCUser]!
    
    @NSManaged var location: CCLocation!
    
    @NSManaged var postType: Int
    
    //There are 3 types of posts for now:
    /*
     
     Type 1: You were near are certain place!
     Type 2: You added an event!
     Type 3: You're going to this event!
     Type 4: You liked this location!
     Type 5: You added a location to the map!
     
     */
    
    func getTimelineString (_ completionHandler: @escaping (String) -> Void) {
        
        location.fetchInBackground { (object, error) in
            
            guard object != nil else {
                
                return
            }
            
            let location = object as! CCLocation
            
            self.poster.fetchInBackground { (object, error) in
                
                guard object != nil else {
                    
                    return
                }
                
                let poster = object as! CCUser
                
                //Get type, then return necessary localized String.
                switch self.postType {
                    
                case 1:
                    
                    var str = "You were"
                    
                    if poster != CCUser.current() {
                        
                        str = "\(poster.username!) was"
                    }
                    
                    completionHandler("\(str) near \(location.strLocationName)!")
                    
                case 2:
                    
                    var str = "You"
                    
                    if poster != CCUser.current() {
                        
                        str = "\(poster.username!)"
                    }
                    
                    completionHandler("\(str) added an event to the map - '\(location.strLocationName)'.")
                    
                case 3:
                    
                    var str = "You're"
                    
                    if poster != CCUser.current() {
                        
                        str = "\(poster.username!) is"
                    }
                    
                    completionHandler("\(str) going to the event - \(location.strLocationName)!")
                    
                case 4:
                    
                    var str = "You"
                    
                    if poster != CCUser.current() {
                        
                        str = "\(poster.username!)"
                    }
                    
                    completionHandler("\(str) liked '\(location.strLocationName).'")
                    
                case 5:
                    
                    var str = "You"
                    
                    if poster != CCUser.current() {
                        
                        str = "\(poster.username!)"
                    }
                    
                    completionHandler("\(str) added '\(location.strLocationName)' to the map.")
                    
                default:
                    
                    completionHandler("")
                }
            }
        }
    }
}
