//
//  FavouriteButton.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import UIKit

enum FavouriteButtonState {
    
    case favourited
    case notFavourited
}


class FavouriteButton: UIButton {
    
    
    let favouritedImage = UIImage(named: "FavouriteButton2.png")!
    
    let notFavouritedImage = UIImage(named: "FavouriteButton.png")!

    let grayColor = UIColor.lightGray
    
    
    var currentState: FavouriteButtonState!

    
    ///Switch to opposite state
    func toggleState () {
        
        if self.currentState == .notFavourited {
            
            self.changeToFavourited()
        }
            
        else {
            
            self.changeToNotFavourited()
        }
    }
    
    
    ///Switch to state of your choice
    func changeToState (toState state: FavouriteButtonState) {
        
        if state == .favourited {
            
            self.changeToFavourited()
        }
            
        else {
            
            self.changeToNotFavourited()
        }
    }
    
    
    func disableButton () {
        
        self.isEnabled = false
        
        self.changeToNotFavourited()
    }
    
    
    func enableButton (toState state: FavouriteButtonState) {
        
        self.isEnabled = true
        
        if state == .favourited {
         
            self.changeToFavourited()
        }
        
        else {
            
            self.changeToNotFavourited()
        }
    }
    
    
    fileprivate func changeToFavourited () {
        
        self.currentState = .favourited
        
        self.setImage(favouritedImage, for: UIControlState())
        
        self.setTitle("  Remove from Favourites", for: UIControlState())
        
        self.setTitleColor(cityInColorRed, for: UIControlState())
    }
    
    
    fileprivate func changeToNotFavourited () {
        
        self.currentState = .notFavourited
        
        self.setImage(notFavouritedImage, for: UIControlState())
        
        self.setTitle("  Add to Favourites", for: UIControlState())
        
        setTitleColor(grayColor, for: UIControlState())

    }
}
