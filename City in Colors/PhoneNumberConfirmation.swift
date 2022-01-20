//
//  PhoneNumberConfirmation.swift
//  Goojess
//
//  Created by Simon Blomqvist on 2017-04-15.
//  Copyright © 2017 Carman. All rights reserved.
//

import UIKit

class PhoneNumberConfirmation: UIViewController {
    
    var phoneNumberFormats: [String]!
    
    fileprivate var codeToBeEntered: Int!
    
    @IBOutlet weak var tF1: UITextField!
    @IBOutlet weak var tF2: UITextField!
    @IBOutlet weak var tF3: UITextField!
    @IBOutlet weak var tF4: UITextField!
    
    @IBOutlet var tFs: [UITextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        codeToBeEntered = generateRandomCode()
        
        let number = phoneNumberFormats[1].replacingOccurrences(of: "+", with: "00")
        
        self.title = phoneNumberFormats[1]
        
        print(phoneNumberFormats)
        
        // https://shoescape.se/smsapi/?s=goj2345d&t=\(number)&m=Please%20enter%20this%activation%20code%20in%the%20Goojess%app:%20\(codeToBeEntered!)
        
        
        if let url = URL(string: "https://www.shoescape.se/smsgateway/index.php?s=goj2345d&t=Please+enter+this+code+in+Goojess+\(number)&m=\(codeToBeEntered!)") {
            
            URLSession.shared.dataTask(with: url).resume()
        }
        
//https://www.shoescape.se/smsgateway/index.php?s
        
        /*if let url = URL(string: "http://smsapi.ehl.nu/?s=goj2345d&t=\(number)&m=Please%20enter%20this%activation%20code%20in%the%20Goojess%app:%20\(codeToBeEntered!)") {
            
            UIApplication.shared.openURL(url)
        }*/
        
        for tf in tFs {
            
            tf.keyboardType = .numberPad
            tf.keyboardAppearance = .default
            
            tf.addTarget(self, action: #selector(PhoneNumberConfirmation.next(_:)), for: .editingChanged)
        }
        
        self.tF1.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    fileprivate func generateRandomCode () -> Int {
        
        let random = arc4random_uniform(9000) + 1000
        
        return Int(random)
    }
    
    @objc fileprivate func next (_ sender: UITextField) {
        
        //If text has been deleted.
        if sender.text == nil || sender.text == "" {
            
            for tf in self.tFs {
                
                tf.text = ""
            }
            
            self.tF1.becomeFirstResponder()
        }
            
        else {
            
            let index = self.tFs.index(where: {$0 == sender})!
            
            if index != (tFs.count - 1) {
                
                self.tFs[index+1].becomeFirstResponder()
            }
                
            else {
                
                
                var finalDigitString = ""
                
                //Test code
                for tf in tFs {
                    
                    finalDigitString =  "\(finalDigitString)\(tf.text!)"
                }
                
                print(finalDigitString)
                
                if Int(finalDigitString) == self.codeToBeEntered {
                    
                    self.saveUser()
                }
                    
                else {
                    
                    let alert = UIAlertController(title: "Wrong code", message: "Please enter the correct code or change phone number", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: { (action) in
                        
                        for tf in self.tFs {
                            
                            tf.text = ""
                        }
                        
                        self.tF1.becomeFirstResponder()
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Change Number", style: .default, handler: { (action) in
                        
                        self.navigationController?.popViewController(animated: true)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    fileprivate func saveUser () {
        
        print(phoneNumberFormats)
        
        CCUser.current()!.strPhoneNumber = phoneNumberFormats
        
        CCUser.current()?.saveEventually()
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
