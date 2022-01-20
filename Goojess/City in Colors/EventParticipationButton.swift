//
//  EventParticipationButton.swift
//  Goojess
//
//  Created by Simon Blomqvist on 2017-04-15.
//  Copyright © 2017 Carman. All rights reserved.
//

import UIKit

enum EventParticipationButtonState {
    
    case participating
    case notParticipating
}

class EventParticipationButton: UIButton {
    
    let grayColor = UIColor.lightGray
    
    
    var currentState: EventParticipationButtonState!
    
    
    ///Switch to opposite state
    func toggleState () {
        
        if self.currentState == .notParticipating {
            
            self.changeToGoing()
        }
            
        else {
            
            self.changeToNotGoing()
        }
    }
    
    
    ///Switch to state of your choice
    func changeToState (toState state: EventParticipationButtonState) {
        
        if state == .participating {
            
            self.changeToGoing()
        }
            
        else {
            
            self.changeToNotGoing()
        }
    }
    
    
    func disableButton () {
        
        self.isEnabled = false
        
        self.changeToNotGoing()
    }
    
    
    func enableButton (toState state: EventParticipationButtonState) {
        
        self.isEnabled = true
        
        if state == .participating {
            
            self.changeToGoing()
        }
            
        else {
            
            self.changeToNotGoing()
        }
    }
    
    
    fileprivate func changeToGoing () {
        
        self.currentState = .participating
        
        self.setTitle("Going", for: UIControlState())
        
        self.setTitleColor(UIColor.white, for: UIControlState())
        
        self.backgroundColor = UIColor.blue
    }
    
    
    fileprivate func changeToNotGoing () {
        
        self.currentState = .notParticipating
        
        self.setTitle("Not Going", for: UIControlState())
        
        self.setTitleColor(UIColor.white, for: UIControlState())
        
        self.backgroundColor = UIColor.gray
    }
    
}
