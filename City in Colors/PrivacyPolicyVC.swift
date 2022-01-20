//
//  PrivacyPolicyVC.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import UIKit

class PrivacyPolicyVC: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Privacy Policy"
        
        if let rtf = Bundle.main.url(forResource: "CityinColorPrivacyPolicy", withExtension: "rtf", subdirectory: nil, localization: nil) {
            
            do {
                
                let attributedString = try NSAttributedString(url: rtf, options: [NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType], documentAttributes: nil)
                
                textView.attributedText = attributedString
                
                textView.isEditable = false
                
            } catch _ {}
        }
        
        let backButton = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(PrivacyPolicyVC.back))
        
        self.navigationItem.leftBarButtonItem = backButton
        
        backButton.tintColor = .white
    }
    
    
    func back () {
        
        self.navigationController?.popViewController(animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
