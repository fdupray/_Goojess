//
//  SignUpViewController.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import UIKit
import Parse
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


class SignUpViewController: UIViewController {

    //Password, email address and phone number text fields respectively.
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailAddressField: UITextField!
    @IBOutlet weak var usernameField: UITextField!

    
    //View containing the 3 text fields
    @IBOutlet weak var textFieldsView: UIView!

    var activityIndicator: UIActivityIndicatorView!
    

    var emailIsValid: Bool = false
    var numberIsValid: Bool = false
    var passwordIsValid: Bool = false
    
    //Used to remove spaces in text fields
    let characterSet = CharacterSet.whitespaces
    
    //Show status bar
    override var prefersStatusBarHidden : Bool {
        
        return false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = false
        
        activityIndicator = UIActivityIndicatorView()
        
        customizeUI()
    }
    
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    
    //Function called when user ends editing
    func verifyEmail() {
        
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        activity.hidesWhenStopped = true
        
        emailAddressField.rightView = activity
        emailAddressField.rightViewMode = .always
        
        activity.startAnimating()
        
        
        emailAddressField.text = emailAddressField.text!.trimmingCharacters(in: characterSet)
        
        emailAddressField.text = emailAddressField.text!.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        let valid: Bool = validateEmail(emailAddressField.text!)
        
        if valid {
            
            let query = PFQuery(className: "_User")
            
            query.whereKey("email", equalTo: emailAddressField.text!)
            
            query.findObjectsInBackground(block: { (list, error) -> Void in
                
                DispatchQueue.main.async {
                    
                    if list?.count > 0 {
                        
                        //Email address already exists
                        self.setNextButton()
                        activity.stopAnimating()
                        
                        self.emailAddressField.rightView = nil
                        self.emailAddressField.textColor = UIColor.red
                        
                        self.emailIsValid = false
                        
                        self.setNextButton()
                    }
                        
                    else {
                        
                        activity.stopAnimating()
                        
                        self.emailAddressField.rightView = nil
                        
                        self.emailAddressField.textColor = UIColor.green
                        
                        self.emailIsValid = true
                        
                        self.mobileVerification()
                        
                        //self.verifyFields()
                    }
                }
            })
        }
            
        else {
            
            activity.stopAnimating()
            
            self.emailAddressField.rightView = nil
            
            //Incorrect email address, so change  text colour to red
            emailAddressField.textColor = UIColor.red
            
            emailIsValid = false
        }
        
        //Verify all fields
        //verifyFields()
    }
    
    
    
    //Function called when user ends editing
    func mobileVerification() {
        
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        activity.hidesWhenStopped = true
        
        usernameField.rightView = activity
        usernameField.rightViewMode = .always
        
        activity.startAnimating()
        
        
        
        usernameField.text = usernameField.text!.trimmingCharacters(in: characterSet)
        
        usernameField.text = usernameField.text!.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        print("SHOULD VERIFY")
        
        let query = PFQuery(className: "_User")
        
        query.whereKey("username", equalTo: usernameField.text!)
        
        
        query.findObjectsInBackground(block: { (list, error) -> Void in
            
            if error != nil {
                
                print(error)
            }
            
            if list?.count > 0 {
                
                self.usernameField.textColor = UIColor.red
                
                self.usernameField.rightView = nil
                
                activity.stopAnimating()
                
                //Phone number already taken
                self.numberIsValid = false
                
                self.setNextButton()
            }
                
            else {
                
                
                self.usernameField.rightView = activity
                
                activity.stopAnimating()
                
                //WE CAN NOW PROCEED TO PHONE NUMBER
                self.numberIsValid = true
                
                self.usernameField.textColor = UIColor.green
                
                self.passwordVerification()
                
                self.setNextButton()
                
                //self.verifyFields()
            }
        })
        
        //Verify all fields
        //verifyFields()
    }
    
    
    //Function called when user ends editing
    func passwordVerification() {
        
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        activity.hidesWhenStopped = true
        
        passwordField.rightView = activity
        passwordField.rightViewMode = .always
        
        activity.startAnimating()
        
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: self.passwordField.frame.height))
        
        label.text = "⚠️"
        
        //Password needs a minimum of 5 characters
        if passwordField.text!.characters.count < 5 {
            
            passwordIsValid = false
            
            passwordField.rightViewMode = UITextFieldViewMode.always
            
            passwordField.rightView = label
            
            self.setNextButton()
        }
            
        else {
            
            //Password is valid
            passwordIsValid = true
            
            activity.stopAnimating()
            
            passwordField.rightView = nil
            
            self.setNextButton()
            
            self.signUpUser()
        }
        
        //verifyFields()
    }
    
    
    func setNextButton () {
        
        let nextButton = UIBarButtonItem(title: "NEXT", style: .plain, target: self, action: #selector(SignUpViewController.toNextPage))
        
        nextButton.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 12)], for: UIControlState())
        
        self.navigationItem.rightBarButtonItem = nextButton
        
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.red
    }
    
    
    //UI MODIFICATIONS
    
    func customizeUI() {
        
        self.emailAddressField.becomeFirstResponder()
        
        self.navigationController?.isNavigationBarHidden = false
        
        //Nav controller title
        self.navigationController?.title = "Register"
        
        //Show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        
        //Change navigation bar title and font
        self.navigationController?.navigationBar.titleTextAttributes = [NSBackgroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont.systemFont(ofSize: 17)]
        
        
        
        //Add text field targets for editing did change. These functions verify the credentials' availability
        /*emailAddressField.addTarget(self, action: "verifyEmail", forControlEvents: .EditingChanged)
        
        usernameField.addTarget(self, action: "mobileVerification", forControlEvents: .EditingChanged)
        
        passwordField.addTarget(self, action: "passwordVerification", forControlEvents: .EditingChanged)*/
        
        
        
        //This is an extension available in DesignUtils
        //textFieldsView.setRoundedCorners(5)
        
        //Add left view to textfields
        /*let frame = CGRect(x: 0, y: 0, width: 85, height: passwordField.bounds.height)
        
        passwordField.addLeftViewLabel("PASSWORD", frame: frame)
        
        emailAddressField.addLeftViewLabel("EMAIL", frame: frame)
        
        phoneNumberField.addLeftViewLabel("MOBILE", frame: frame)*/
        
        
        //phoneNumberField.backgroundColor = UIColor.whiteColor()
        
        //self.textFieldsView.backgroundColor = UIColor.whiteColor()
        
        /*//Add the US flag as a UIButton on the right side of the mobile number text field
        let flagSelection: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: phoneNumberField.bounds.height))
        
        flagSelection.setTitle("🇺🇸", forState: .Normal)
        
        phoneNumberField.rightViewMode = UITextFieldViewMode.Always
        
        phoneNumberField.rightView = flagSelection*/
        
        
        
        
        //Add bar button items
        let cancelButton = UIBarButtonItem(title: "CANCEL", style: .plain, target: self, action: #selector(SignUpViewController.goBack))
        
        cancelButton.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 12)], for: UIControlState())
        
        navigationItem.leftBarButtonItem = cancelButton
        
        navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        
        
        let nextButton = UIBarButtonItem(title: "NEXT", style: .plain, target: self, action: #selector(SignUpViewController.toNextPage))
        
        nextButton.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 12)], for: UIControlState())
        
        navigationItem.rightBarButtonItem = nextButton
        
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        navigationItem.rightBarButtonItem?.tintColor = UIColor.black
        
        let fontSize: CGFloat = 16
        
        let attributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: fontSize)]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        self.navigationController?.navigationBar.barTintColor = cityInColorRed
        
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont.systemFont(ofSize: 12)], for: UIControlState())
        
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont.systemFont(ofSize: 12)], for: UIControlState())
        
        //Navigation bar background colour
        self.title = "CREATE AN ACCOUNT"
                
        //self.view.backgroundColor = DesignUtils.primaryAppColour
    }
    
    
    
    
    //Cancel everything and dismiss view controller
    func goBack () {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //Function called often to check if all fields are filled, then activate
    /*func verifyFields () {
        
        if emailIsValid && passwordIsValid && numberIsValid {
            
            navigationItem.rightBarButtonItem?.enabled = true
        }
    }*/
    
    
    
    //Called by "nextButton". Calls segue
    func toNextPage () {
        
        //UIAlert
                
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        
        activityIndicator.startAnimating()
        
        self.verifyEmail()
    }
    
    
    func signUpUser() {
        
        let user = CCUser()
        user.username = usernameField.text!
        user.email = emailAddressField.text!
        user.password = passwordField.text!
        
        
        user.signUpInBackground { (success, error) -> Void in
            
            self.setNextButton()
            
            if success {
                
                self.dismiss(animated: true, completion: nil)
            }
                
            else {
                
                self.setNextButton()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    
    //Check if email format is correct
    func validateEmail(_ candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    //Check if phone number format is correct
    /*func validateMobile(value: String) -> Bool {
        
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        
        let result =  phoneTest.evaluateWithObject(value)
        
        return result
        
    }*/
}
