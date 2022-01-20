//
//  LocationLikeManager.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import Foundation

class CCLocationRatingsManager: NSObject {
    
    let currentUser = CCUser.current()!
    
    var location: CCLocation!
    
    init(location: CCLocation) {
        super.init()
        
        self.location = location
    }
    
    
    ///Add/Remove from favourites
    /*func toggleFavourites (didAddToFavourites completionHandler: (Bool, NSError?) -> Void) {
        
        //Check cache, if not
        
        if let locations = currentUser.cachedFavouriteLocations {
            
            if let i = locations.indexOf({$0.objectId == self.location.objectId}) {
                
                self.currentUser.cachedFavouriteLocations!.removeAtIndex(i)
                
                self.removeLocationFromFavourites()
                
                completionHandler(false, nil)
            }
            
            else {
                
                self.currentUser.cachedFavouriteLocations.append(self.location)
                
                self.addLocationToFavourites()
                
                completionHandler(true, nil)
            }
            
            return
        }
        
        //If cache is empty, then query database
        
        let query = self.location.peopleWhoFavourited.query()
        
        query.getObjectInBackgroundWithId(currentUser.objectId!) { (user, error) -> Void in
            
            //If user is found, then remove location from favourites
            if user != nil {
                
                self.removeLocationFromFavourites()
                
                completionHandler(false, error)
            }
                
            //If not then do the opposite
            else {
                
                self.addLocationToFavourites()
                
                completionHandler(true, error)
            }
        }
    }*/
    
    
    /*private func addLocationToFavourites () {
        
        if location.amountOfFavourites > 0 {
            
            location.amountOfFavourites += 1
        }
            
        else {
            
            location.amountOfFavourites = 1
        }
        
        
        
        location.relationForKey("peopleWhoFavourited").addObject(currentUser)
        
        currentUser.relationForKey("favouriteLocations").addObject(self.location)
        
        
        
        location.saveEventually()
        
        currentUser.saveEventually()
    }
    
    
    private func removeLocationFromFavourites () {
        
        location.amountOfFavourites -= 1
        
        
        currentUser.relationForKey("favouriteLocations").removeObject(location)
        
        location.relationForKey("peopleWhoFavourited").removeObject(currentUser)
        
        
        location.saveEventually()
        
        currentUser.saveEventually()
    }*/
    
    
    /*func addLikeToLocation () {
        
        if location.amountOfLikes > 0 {
            
            location.amountOfLikes += 1
        }
        
        else {
            
            location.amountOfLikes = 1
        }
        
        if location.peopleWhoLiked != nil {
            
            location.peopleWhoLiked.append(currentUser)
        }
        
        else {
            
            location.peopleWhoLiked = [currentUser]
        }
        
        location.saveEventually()
    }
 
    
    func removeLikeFromLocation () {
        
        location.amountOfLikes -= 1
        
        for var i = 0; i > location.peopleWhoLiked.count-1; ++i {
            
            if location.peopleWhoLiked[i].objectId! == currentUser.objectId! {
                
                location.peopleWhoLiked.removeAtIndex(i)
            }
        }
        
        location.saveEventually()
    }*/
}
