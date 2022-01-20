//
//  TutorialMethods.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import Foundation

class TutorialMethods: NSObject {
    
    override init() {
        super.init()
    }
    
    class func showFirstStepInTutorial (hostVC vc: UIViewController) {
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "ShowTutorial") != true {
            
            userDefaults.set(true, forKey: "ShowTutorial")
            
            userDefaults.synchronize()
            
            
            let popoverContent = vc.storyboard?.instantiateViewController(withIdentifier: "TutorialPVC") as! TutorialPageVC
            
            popoverContent.modalPresentationStyle = .overFullScreen
            
            popoverContent.view.backgroundColor = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 0.7)
            
            vc.present(popoverContent, animated: true, completion: nil)
        }
    }
    
    
    class func showSecondStepInTutorial (hostVC vc: UIViewController, presentedBy: UIViewController) {
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "ShowTutorial2") != true {
            
            userDefaults.set(true, forKey: "ShowTutorial2")
            
            userDefaults.synchronize()
            
            
            let popoverContent = vc.storyboard?.instantiateViewController(withIdentifier: "StepThree") as! StepThreeTutorialVC
            
            popoverContent.modalPresentationStyle = .overFullScreen
            
            popoverContent.view.backgroundColor = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 0.75)
            
            presentedBy.present(popoverContent, animated: true, completion: nil)
        }
    }

    
    class func showThirdStepInTutorial (hostVC vc: UIViewController) {
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "ShowTutorial3") != true {
            
            userDefaults.set(true, forKey: "ShowTutorial3")
            
            userDefaults.synchronize()
            
            
            let popoverContent = vc.storyboard?.instantiateViewController(withIdentifier: "StepFive") as! StepFourTutorialVC
            
            popoverContent.modalPresentationStyle = .overFullScreen
            
            popoverContent.view.backgroundColor = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 0.9)
            
            vc.present(popoverContent, animated: true, completion: nil)
        }
    }
}
