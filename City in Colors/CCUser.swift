//
//  CCUser.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//extension Date {

import Foundation
import Parse

class CCUser: PFUser {
    
    @NSManaged var strFirstName: String!
    
    @NSManaged var strLastName: String!
    
    @NSManaged var currentGeoPoint: PFGeoPoint!
    
    @NSManaged var userProfilePicture: PFFile!
    
    @NSManaged var userCoverPicture: PFFile!
    
    @NSManaged var strPhoneNumber: [String]!
    
    @NSManaged var userInterests: [Float]!
    
    @NSManaged var lastMessageReceived: Date
    
    /*var favouriteLocations: PFRelation! {
        
        return relationForKey("favouriteLocations")
    }*/
    
    //var cachedFavouriteLocations: [CCLocation]!

    
    dynamic var currentUser: CCUser {
        
        return CCUser.current()! 
    }
    
    
    override init() {
        super.init()
    }
    
    /*func settStrFirstName (strFirstName: String) {
        
        self.setObject(strFirstName, forKey: "strFirstName")
    }
    
    func settStrLastName (strLastName: String) {
        
        self.setObject(strLastName, forKey: "strLastName")
    }
    
    @nonobjc func setUserProfilePicture (userProfilePicture: PFFile) {
        
        self.setObject(userProfilePicture, forKey: "userProfilePicture")
    }
    
    @nonobjc func setStrPhoneNumber (strPhoneNumber: String) {
     
        self.setObject(strPhoneNumber, forKey: "strPhoneNumber")
    }
    
    @nonobjc func setCurrentGeoPoint (currentGeoPoint: PFGeoPoint) {
        
        self.setObject(currentGeoPoint, forKey: "currentGeoPoint")
    }
    
    
    func getFirstName () -> String {
        
        return self.objectForKey("strFirstName") as! String
    }
    
    func getLastName () -> String {
        
        return self.objectForKey("strLastName") as! String
    }*/
    
    
    /*func getFavouriteLocations (completionHandler: ([CCLocation]?, NSError?) -> Void) {
        
        let query = self.favouriteLocations.query()
        
        query.limit = 1000
        
        query.findObjectsInBackgroundWithBlock { (locations, error) -> Void in
            
            if locations != nil {
                
                completionHandler(locations as? [CCLocation], error)
                
                self.cachedFavouriteLocations = locations as? [CCLocation]
            }
            
            else if locations == nil && error == nil {
                
                completionHandler(locations as? [CCLocation], error)
                
                self.cachedFavouriteLocations = locations as? [CCLocation]
            }
            
            else {
                
                completionHandler(locations as? [CCLocation], error)
                
                self.cachedFavouriteLocations = locations as? [CCLocation]
            }
        }
    }*/
}

