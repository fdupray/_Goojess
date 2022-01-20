//
//  CCLocation.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import Foundation
import Parse

class CCLocation: PFObject, PFSubclassing {
    
    /*private static var __once: () = {
            self.registerSubclass()
        }()
    
    override class func initialize() {
        struct Static {
            static var onceToken : Int = 0;
        }
        _ = CCLocation.__once
    }*/
    
    static func parseClassName() -> String {
        
        return "CCLocation"
    }
    
    
    @NSManaged var strLocationName: String!
    
    @NSManaged var strLocationActivities: [String]!
    
    @NSManaged var srtLocationCategory: Float
    
    @NSManaged var strLocationDescription: String!
    
    @NSManaged var geoPointLocation: PFGeoPoint!
    
    @NSManaged var geoPointLocationAddress: String!
    
    @NSManaged var locationUploader: CCUser!
    
    @NSManaged var uploaderUsername: String!
    
    //If these aren't nil, then location is an event
    @NSManaged var expiryDate: Date!
    
    @NSManaged var startDate: Date!
    
    
    //@NSManaged var amountOfFavourites: Int
    
    /*var peopleWhoFavourited: PFRelation! {
     
     return relationForKey("peopleWhoFavourited")
     }*/
    
    //@NSManaged var amountOfLikes: Int
    
    //@NSManaged var peopleWhoLiked: [CCUser]!
    
    
    
    func getUploaderUsername () -> String {
        
        return self.object(forKey: "uploaderUsername") as! String
    }
    
    func getLocationUploader () ->  CCUser {
        
        return self.object(forKey: "locationUploader") as! CCUser
    }
    
    func getGeoPointLocation () -> PFGeoPoint {
        
        return self["geoPointLocation"] as! PFGeoPoint
    }
    
    func getStrLocationDetail () -> String {
        
        return self.object(forKey: "strLocationActivities") as! String
    }
    
    func getStrLocationName () -> String {
        
        return self.object(forKey: "strLocationName") as! String
    }
    
    func getStrLocationDescription () -> String {
        
        return self.object(forKey: "strLocationDescription") as! String
    }
}
