//
//  AppDelegate.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//  G00jess  
// > Remove all City in color....


import Foundation
import UIKit
import CoreData
import Parse
import GooglePlaces
import SVProgressHUD
import ParseFacebookUtilsV4
//import ACTReporter

///IMPORTANT!!!!
//GOOJESS - AWS MASTER KEY = mkey769876g9876b9876g98768557f765v6587653322--992017


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        GMSPlacesClient.provideAPIKey("AIzaSyBxwxnXRN6FKUdlL58lGZAPmZQga5aaBaU")
        
        CCLocation.registerSubclass()
        CCUser.registerSubclass()
        CCComment.registerSubclass()
        CCActivity.registerSubclass()
        CCPhoto.registerSubclass()
        CCReview.registerSubclass()
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert , .badge , .sound], categories: nil))
        
        //HEROKU SERVER
        let parseConfiguration = ParseClientConfiguration(block: { (ParseMutableClientConfiguration) -> Void in
            
            ParseMutableClientConfiguration.applicationId = "comehlgoojess05052017simonfredaws"
            ParseMutableClientConfiguration.clientKey = nil
            ParseMutableClientConfiguration.server = "http://parseserver-326pq-env.us-east-1.elasticbeanstalk.com" //"https://goojess.herokuapp.com/parse"
        })
        
        //NODECHEF CITY IN COLOR SERVER
        /*
 
         let parseConfiguration = ParseClientConfiguration(block: { (ParseMutableClientConfiguration) -> Void in
         
         ParseMutableClientConfiguration.applicationId = "N7vBJCyNOgZ8wtYuBrRtOVQysWl8oZGBNhcRjZIi" //"Dqzyqd539dYc2QWD9aIP6fWBWBdPECSUQfN4lOH6"
         ParseMutableClientConfiguration.clientKey = nil //"esP5LKLmLjp5PTjcVdoQpRx9KClIEHfId5RW6XcP"
         ParseMutableClientConfiguration.server = "https://city-in-color-677.nodechef.com/parse" //"https://pg-app-l79xsh2drdii4pda4drx2paybqctxy.scalabl.cloud/1/"
         })
         
        */
        
        Parse.initialize(with: parseConfiguration)
        
        CCUser.enableRevocableSessionInBackground()
        
        PFAnalytics.trackAppOpened(launchOptions: launchOptions)
        
        CCServiceManager.sharedManager().locationManager?.startUpdatingLocation()
        
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 20), NSForegroundColorAttributeName: UIColor.darkGray]
        
        UITextField.appearance().textColor = UIColor.darkGray
        UITextField.appearance().keyboardAppearance = UIKeyboardAppearance.dark
        
        UISegmentedControl.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 13)], for: UIControlState())
        //UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        
        //UIBarButtonItem.appearance().tintColor = .darkGrayColor()
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont.systemFont(ofSize: 14)], for: UIControlState())
        //UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.darkGrayColor(), NSFontAttributeName: UIFont.systemFontOfSize(24)], forState: .Highlighted)
        
        //application.setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
        
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
        
        // Override point for customization after application launch.
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ application: UIApplication,
                     open url: URL,
                             sourceApplication: String?,
                             annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            open: url,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
         FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.Caman.City_in_Colors" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "City_in_Colors", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

    
    func startLoadingView () {
        
        self.startLoadingViewWithTitle("Please Wait...")
    }
    
    func startLoadingViewWithTitle(_ title: String) {
        
        self.window?.endEditing(true)
        
        SVProgressHUD.setBackgroundColor(UIColor.white.withAlphaComponent(0.75))
        
        SVProgressHUD.setForegroundColor(UIColor.darkGray)
        
        //SVProgressHUD.setFont(UIFont(name: "Avenir-Medium", size: 14))
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.gradient)
        
        SVProgressHUD.show(withStatus: title)
    }
    
    func stopLoadingView () {
        
        DispatchQueue.main.async(execute: {
            
            SVProgressHUD.dismiss()
        })
    }
    
    
    func showAlertWithMessage (_ message: String) {
        
        let alert = UIAlertController(title: APP_NAME, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func notImplemented () {
        
        let alert = UIAlertController(title: "Feature Unavailable", message: "Feature unavailable in this build. Please contact the developer team and / or view the release notes.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithTitle (_ title: String, message: String) {
        
        self.window?.endEditing(true)
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func showActionSheetWithTitles (_ vc: UIViewController) {
        
        self.window?.endEditing(true)
        
        let sheet = UIAlertController(title: APP_NAME, message: "", preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        sheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (action) -> Void in
            
            if let vc = vc as? LocationDetailViewController {
                
                vc.imagePicker.sourceType = .camera
                
                vc.present(vc.imagePicker, animated: true, completion: nil)
            }
        }))
        
        sheet.addAction(UIAlertAction(title: "Choose from Gallery", style: .default, handler: { (action) -> Void in
            
            if let vc = vc as? LocationDetailViewController {
                
                vc.imagePicker.sourceType = .photoLibrary
                
                vc.present(vc.imagePicker, animated: true, completion: nil)
            }
        }))

        vc.present(sheet, animated: true, completion: nil)
    }
    
    
    
    
    
    /*#pragma mark - Alert
    
    - (void)showAlertWithMessage:(NSString *)message {
    [self showAlertWithTitle:APP_NAME
    message:message
    buttonTitles:@[ @"OK" ]
    colors:@[ THEME_BLUE_COLOR ]
    withSelectionHandler:nil];
    }
    
    - (void)notImplemented {
    [self showAlertWithTitle:@"Feature Unavailable".uppercaseString
    message:@"Feature unavailable in this build. Please "
    @"contact the developer team and / or concern the "
    @"release notes."
    buttonTitles:@[ @"OK" ]
    colors:@[ THEME_BLUE_COLOR ]
    withSelectionHandler:nil];
    }
    
    - (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    [self showAlertWithTitle:title
    message:message
    buttonTitles:@[ @"OK" ]
    colors:@[ THEME_BLUE_COLOR ]
    withSelectionHandler:nil];
    }
    
    - (void)showAlertWithTitle:(NSString *)title
    message:(NSString *)message
    buttonTitles:(NSArray *)titles
    colors:(NSArray *)colors
    withSelectionHandler:(void (^)(NSInteger))selectionHandler {
    
    [self.window endEditing:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
    message:message
    delegate:nil
    cancelButtonTitle:@"Ok"
    otherButtonTitles:nil, nil];
    [alertView show];
    

    }
    
    #pragma mark - Action Sheet
    - (void)showActionSheetWithTitles:(NSArray *)titles
    onSelection:(void (^)(NSInteger))selectionHandler {
    
    [self.window endEditing:YES];
    
    UIActionSheet *actionSheet =
    [[UIActionSheet alloc] initWithTitle:APP_NAME
    delegate:self
    cancelButtonTitle:@"Cancel"
    destructiveButtonTitle:nil
    otherButtonTitles:@"CHOOSE FROM CAMERA",
    @"CHOOSE FROM GALLERY", nil];
    [actionSheet showInView:self.window.rootViewController.view];
    if (selectionHandler) {
    _actionSheetHandler = selectionHandler;
    }

    }
    
    - (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (_actionSheetHandler) {
    _actionSheetHandler(buttonIndex);
    }
    }*/
}

