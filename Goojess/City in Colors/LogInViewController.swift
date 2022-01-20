//
//  LogInViewController.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import UIKit
import Parse

class LogInViewController: UIViewController {

    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = false
        
        customizeUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    func customizeUI() {
        
        self.emailField.becomeFirstResponder()
        
        //let frame = CGRect(x: 0, y: 0, width: 90, height: emailField.bounds.height)
        
        //self.emailField.addLeftViewLabel("EMAIL", frame: frame)
        
        //self.passwordField.addLeftViewLabel("PASSWORD", frame: frame)
        
        self.passwordField.isSecureTextEntry = true
        
        self.navigationController?.isNavigationBarHidden = false
        
        let back = UIBarButtonItem(title: "BACK", style: .plain, target: self, action: #selector(LogInViewController.goBack))
        
        back.tintColor = UIColor.black
        
        back.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 12)], for: UIControlState())
        
        self.navigationItem.leftBarButtonItem = back
        
        let signIn = UIBarButtonItem(title: "GO", style: .plain, target: self, action: #selector(LogInViewController.signIn))
        
        signIn.tintColor = UIColor.black
        
        signIn.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 12)], for: UIControlState())
        
        self.navigationItem.rightBarButtonItem = signIn
        
        self.title = "SIGN IN"
        
        self.whiteView.layer.masksToBounds = true
        self.whiteView.layer.cornerRadius = 5
        
        //Change navigation bar title and font
        let fontSize: CGFloat = 16
        
        let attributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: fontSize)]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        self.navigationController?.navigationBar.barTintColor = cityInColorRed
        
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont.systemFont(ofSize: 12)], for: UIControlState())
        
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont.systemFont(ofSize: 12)], for: UIControlState())
    }
    
    func goBack () {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func signIn() {
        
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        
        activityIndicator.color = UIColor.black
        
        let barItem = UIBarButtonItem(customView: activityIndicator)
        
        self.navigationItem.rightBarButtonItem = barItem
        
        activityIndicator.startAnimating()
        
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        
        PFUser.logInWithUsername(inBackground: emailField.text!, password: passwordField.text!) { (user, error) -> Void in
            
            if user != nil {
                
                activityIndicator.stopAnimating()
                
                PFInstallation.current()?.setValue(user!, forKey: "User")
                
                PFInstallation.current()?.saveInBackground()
                
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
                
            else {
                
                activityIndicator.stopAnimating()
                
                self.navigationItem.leftBarButtonItem?.isEnabled = true
                
                let signIn = UIBarButtonItem(title: "GO", style: .plain, target: self, action: #selector(LogInViewController.signIn))
                
                signIn.tintColor = UIColor.black
                
                signIn.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 12)], for: UIControlState())
                
                self.navigationItem.rightBarButtonItem = signIn
                
                let alert = UIAlertController(title: "Error - Couldn't log in", message: error?.localizedDescription, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func forgottenPassword(_ sender: Any) {
        
        let alert = UIAlertController(title: "Enter email address", message: "Please enter your email address", preferredStyle: .alert)
        
        
        alert.addTextField { (textfield) -> Void in
            
            textfield.textColor = UIColor.darkGray
        }
        
        let done = UIAlertAction(title: "Send", style: .default) { (action) -> Void in
            
            appDelegate.startLoadingView()
            
            let email = alert.textFields?.first?.text
            
            if let email = email?.replacingOccurrences(of: " ", with: "") {
                
                PFUser.requestPasswordResetForEmail(inBackground: email, block: { (success, error) -> Void in
                    
                    appDelegate.stopLoadingView()
                    
                    
                    if success {
                        
                        let alert = UIAlertController(title: "Sent!", message: "An email was sent to you. Follow the instructions to reset your password.", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    else {
                        
                        let alert = UIAlertController(title: "Error!", message: "An error occured. Check the email address you entered.", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (action) -> Void in
            
            
        }
        
        alert.addAction(cancel)
        alert.addAction(done)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
