//
//  validationsHelper.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import Foundation
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class validationsHelper: NSObject {
    
    func textFieldEmptyValidationsForTextFields (_ textFields : [UITextField]) -> Bool {
        
        for textField in textFields {
            
            let strText = textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            if strText?.characters.count == 0 {
                
                appDelegate.showAlertWithTitle("Error", message: (textField.placeholder?.characters.count > 0 ? NSString(format: "Please enter %@", textField.placeholder!) : "Please enter all details") as String)
                
                return false
            }
        }
        
        return true
    }
    
    func isGivenEmailValid (_ checkString: String) -> Bool {
        
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        
        let boolToReturn = emailTest.evaluate(with: checkString)
        
        if !boolToReturn {
            
            appDelegate.showAlertWithTitle("Error", message: "Please enter valid email address")
        }
        
        return boolToReturn
    }
    
    func isGivenPairOfPasswordsValid (_ passwords: [NSString]) -> Bool {
        
        let boolToReturn = passwords.first!.isEqual(to: passwords.last as! String)
        
        if !boolToReturn {
            
            appDelegate.showAlertWithTitle("Error", message: "Passwords do not match")
        }
        
        return boolToReturn
    }
    
}
