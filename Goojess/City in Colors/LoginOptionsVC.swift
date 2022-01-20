//
//  LoginOptionsVC.swift
//  Goojess
//
//  Created by Frederick Dupray on 28/02/17.
//  Copyright © 2017 Goojess. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

class LoginOptionsVC: UIViewController {
    
    var appDel: AppDelegate!
    var isConnecting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isConnecting {
            
            self.appDel.stopLoadingView()
        }
    }
    
    
    @IBAction func fbLogin (_ sender: Any) {
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        appDel.startLoadingView()
        
        let permissions = ["email", "public_profile"]
        
        
        PFFacebookUtils.logInInBackground(withReadPermissions: permissions) { (user, error) in
            
            if let error = error {
                
                self.isConnecting = false
                
                self.appDel.stopLoadingView()
                
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
            
            else {
                
                if let user = user {
                    
                    self.isConnecting = true
                    
                    PFInstallation.current()?.setValue(user, forKey: "User")
                    
                    PFInstallation.current()?.saveInBackground()
                    
                    if user.isNew {
                        
                        self.getUserData()
                    }
                    
                    else {
                        
                        self.isConnecting = false
                        
                        self.appDel.stopLoadingView()
                        
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                }
                
                else {
                    
                    self.isConnecting = false
                    
                    self.appDel.stopLoadingView()
                }
            }
        }
    }
    
    func getUserData () {
        
        var email: String!
        var name: String!
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("graphrequest error: \(error)")
            }
            else
            {
                //if this works, we can store user name und PFUser and mail in    PFuser....
                //not working yet
                /*
                 
                 id
                 name
                 first_name
                 last_name
                 link
                 gender
                 locale
                 timezone
                 updated_time
                 verified
                 
                 
                 */
                
                let facebookID:String = (result as AnyObject).value(forKey: "id") as AnyObject? as! String
                
                let pictureURL = "https://graph.facebook.com/\(facebookID)/picture?type=large&return_ssl_resources=1"
                
                let URLRequest = URL(string: pictureURL)
                let URLRequestNeeded = Foundation.URLRequest(url: URLRequest!)
                
                
                /*NSURLConnection.sendAsynchronousRequest(URLRequestNeeded, queue: OperationQueue.main, completionHandler: {(response: URLResponse?,data: Data?, error: NSError?) -> Void in
                    if error == nil {
                        
                        let picture = PFFile(data: data!)
                        
                        PFUser.current()!.setObject(picture!, forKey: "userProfilePicture")
                        
                        PFUser.current()?.saveInBackground()
                    }
                    else {
                        print("Error: \(error!.localizedDescription)")
                    }
                } as! (URLResponse?, Data?, Error?) -> Void)*/
                
                
                URLSession.shared.dataTask(with: URLRequestNeeded, completionHandler: { (data, response, error) in
                    
                    if error == nil {
                        
                        let picture = PFFile(data: data!)
                        
                        PFUser.current()!.setObject(picture!, forKey: "userProfilePicture")
                        
                        PFUser.current()?.saveInBackground()
                    }
                    else {
                        print("Error: \(error!.localizedDescription)")
                    }
                })
                
                email = (result as AnyObject).value(forKey: "email") as? String
                name = (result as AnyObject).value(forKey: "name") as? String
            }
            
            //print("updating current user")
            
            if let name = name {
                
                PFUser.current()?.username = name
            }
            
            if let email = email {
                
                PFUser.current()?.email = email
            }
            
            self.isConnecting = false
            
            PFUser.current()?.saveInBackground(block: { (success, error) in
                
                self.appDel.stopLoadingView()
                
                self.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
    }
}
