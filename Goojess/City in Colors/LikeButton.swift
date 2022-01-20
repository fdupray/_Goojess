//
//  LikeButton.swift
//  Goojess
//
//  Created by Simon Blomqvist on 2017-04-15.
//  Copyright © 2017 Carman. All rights reserved.
//

import UIKit

enum LikeButtonState {
    
    case liked
    case notLiked
}


class LikeButton: UIButton {
    
    
    let likedImage = UIImage(named: "FavouriteButton2.png")!
    
    let notLikedImage = UIImage(named: "FavouriteButton.png")!
    
    let grayColor = UIColor.lightGray
    
    
    var currentState: LikeButtonState!
    
    
    ///Switch to opposite state
    func toggleState () {
        
        if self.currentState == .notLiked {
            
            self.changeToLiked()
        }
            
        else {
            
            self.changeToNotLiked()
        }
    }
    
    
    ///Switch to state of your choice
    func changeToState (toState state: LikeButtonState) {
        
        if state == .liked {
            
            self.changeToLiked()
        }
            
        else {
            
            self.changeToNotLiked()
        }
    }
    
    
    func disableButton () {
        
        self.isEnabled = false
        
        self.changeToNotLiked()
    }
    
    
    func enableButton (toState state: LikeButtonState) {
        
        self.isEnabled = true
        
        if state == .liked {
            
            self.changeToLiked()
        }
            
        else {
            
            self.changeToNotLiked()
        }
    }
    
    
    fileprivate func changeToLiked () {
        
        self.currentState = .liked
        
        self.setImage(likedImage, for: UIControlState())
        
        self.setTitle("  Liked", for: UIControlState())
        
        self.setTitleColor(UIColor.blue, for: UIControlState())
    }
    
    
    fileprivate func changeToNotLiked () {
        
        self.currentState = .notLiked
        
        self.setImage(notLikedImage, for: UIControlState())
        
        self.setTitle("  Like", for: UIControlState())
        
        self.setTitleColor(grayColor, for: UIControlState())
        
    }
}
