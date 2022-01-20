//
//  UIView+CCView.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func getViewWithTag (_ tag: Int) -> UIView? {
        
        if self.viewWithTag(tag) != nil {
            
            return self.viewWithTag(tag)!
        }
        
        else {
            
            if self.superview?.viewWithTag(tag) != nil {
                
                return self.superview!.viewWithTag(tag)!
            }
            
            if let superview = self.superview?.superview {
                
                for view in superview.subviews {
                    
                    if view.subviews.count == 0 {
                        
                        return view.viewWithTag(tag)!
                    }
                }
            }
        }
        
        return nil
    }
    
    var xValue: CGFloat {
        
        return self.frame.origin.x
    }
    
    var yValue: CGFloat {
        
        return self.frame.origin.y
    }
    
    var width: CGFloat {
        
        return self.frame.size.width
    }
    
    var height: CGFloat {
        
        return self.frame.size.height
    }
    
    
    func setXValue (_ xValue: CGFloat) {
        
        var selfFrame = self.frame
        
        selfFrame.origin.x = xValue
        
        self.frame = selfFrame
    }
    
    func setYValue (_ xValue: CGFloat) {
        
        var selfFrame = self.frame
        
        selfFrame.origin.y = yValue
        
        self.frame = selfFrame
    }
    
    
    func setWidth (_ width: CGFloat) {
        
        var selfFrame = self.frame
        
        selfFrame.size.width = width
        
        self.frame = selfFrame
    }
    
    func setHeight (_ height: CGFloat) {
        
        var selfFrame = self.frame
        
        selfFrame.size.height = height
        
        self.frame = selfFrame
    }

    
    /*func topConstraint () -> NSLayoutConstraint {
        
        let predicate = NSPredicate(format: "firstAttribute = %d", argumentArray: [NSLayoutAttribute.Top].first)
        
        return (self.constraints as! NSArray).filteredArrayUsingPredicate(predicate)
    }
    
    func bottomConstraint () -> NSLayoutConstraint {
        
        let predicate = NSPredicate(format: "firstAttribute = %d", argumentArray: [NSLayoutAttribute.Bottom].first)
        
        return (self.constraints as! NSArray).filteredArrayUsingPredicate(predicate)
    }
    
    func heightConstraint () -> NSLayoutConstraint {
        
        let predicate = NSPredicate(format: "firstAttribute = %d", argumentArray: [NSLayoutAttribute.Height].first)
        
        return (self.constraints as! NSArray).filteredArrayUsingPredicate(predicate)
    }
    
    func widthConstraint () -> NSLayoutConstraint {
        
        let predicate = NSPredicate(format: "firstAttribute = %d", argumentArray: [NSLayoutAttribute.Width].first)
        
        return (self.constraints as! NSArray).filteredArrayUsingPredicate(predicate)
    }
    
    
    func collapseView () {
        
        if self.heightConstraint() {
            
            self.heightConstraint().priority = 1000
            
            self.topConstraint().constant = 0
            
            self.bottomConstraint().constant = 0

            self.heightConstraint().constant = 0
        }
        
        self.hidden = true
    }*/
}
