//
//  CCServiceManager.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import Foundation
import Parse
import CoreLocation
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
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}



class CCServiceManager : NSObject, CLLocationManagerDelegate {
    
    
    
    var locationChangeHandler: CLLocationCoordinate2D?
        
    var locationManager: CLLocationManager?
    
    
    override init() {
        
        
    }
    
    class func sharedManager () -> CCServiceManager {
        
        let sharedInstance: CCServiceManager = CCServiceManager()
        
        struct Static {
            
            static var token: Int = 0
        }
        
        _ = CCServiceManager.__once
        
        return sharedInstance
    }
    
    private static var __once: () = {
     
        //instance = CCServiceManager()
        
     }()
    
    
    @objc func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if locationManager == nil {
            
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.distanceFilter = kCLLocationAccuracyNearestTenMeters
            
            if Float(UIDevice.current.systemVersion) >= 8 {
                
                let code = CLLocationManager.authorizationStatus()
                
                if code != CLAuthorizationStatus.authorizedWhenInUse || code != CLAuthorizationStatus.authorizedAlways && manager.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)) || manager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
                    
                    if Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysUsageDescription") != nil {
                        
                        locationManager?.requestAlwaysAuthorization()
                    }
                        
                    else if Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil {
                        
                        locationManager?.requestWhenInUseAuthorization()
                    }
                        
                    else {
                        
                        NSLog("Info.plist does not contain NSLocationAlwaysUsageDescription "
                            + "or NSLocationWhenInUseUsageDescription")
                    }
                }
                
                if CLLocationManager.locationServicesEnabled() {
                    
                    locationManager?.startUpdatingLocation()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let newLocation = locations.first!
        
        if let currentUser = CCUser.current() {
            
            currentUser.currentGeoPoint = PFGeoPoint(location: newLocation)
            
            currentUser.saveInBackground()
            
            manager.stopUpdatingLocation()
            
            self.locationChangeHandler = newLocation.coordinate
        }
    }
 

    func addNewLocation(_ locationToAdd: CCLocation, withCompletion completionHandler: @escaping (Bool, NSError?) -> Void) {
        
        appDelegate.startLoadingView()
        
        locationToAdd.saveInBackground { (success, error) -> Void in
            
            appDelegate.stopLoadingView()
            
            completionHandler(success, error as NSError?)
        }
    }
    
    @objc func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        
    }
    
    @objc func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        
    }
        
    func getLocationsWithCompletion (_ categories: [Float]?, geoPoint: PFGeoPoint, completionHandler: @escaping (Bool, [CCLocation]?) -> Void) {
        
        appDelegate.startLoadingView()
        
        let queryLocations = PFQuery(className: "CCLocation")
        
        queryLocations.limit = 1000
        
        //print(" THE GP: \(geoPoint)")
        
        queryLocations.whereKey("geoPointLocation", nearGeoPoint: geoPoint, withinMiles: 100)
        
        if let cat = categories {
            
            if cat.count > 0 {
                
                var arr: [Float] = [0]
                
                arr.append(contentsOf: cat)
                
                queryLocations.whereKey("srtLocationCategory", containedIn: arr)
            }
        }
        
        queryLocations.findObjectsInBackground(block: { (objects, error) -> Void in
            
            appDelegate.stopLoadingView()
            
            if objects != nil {
                
                //print(objects!)
                
                //print(" OBJECTS \(objects!.count)")
                
                for object in objects as! [CCLocation] {
                    
                    if object.startDate != nil && object.expiryDate != nil {
                        
                        object.srtLocationCategory = 0
                        
                        object.saveInBackground()
                    }
                }
                
                completionHandler(true, objects as? [CCLocation])
            }
                
            else if error != nil {
            
                
                appDelegate.showAlertWithMessage(error!.localizedDescription)
                
                completionHandler(false, nil)
            }
            
            /*else {
             
             print(" OBJECTS \(objects!.count)")
             
             completionHandler(true, objects as? [CCLocation])
             }*/
        })
    }
    
    func addActivity(_ strActivity: [String], toLocation: CCLocation) {
        
        let activityToAdd = CCActivity()
        
        activityToAdd.strActivities = toLocation.strLocationActivities
        activityToAdd.activityPoster = CURRENT_USER!
        activityToAdd.activityLocation = toLocation
        
        activityToAdd.saveInBackground { (success, error) -> Void in
            
            if error != nil {
                
                NSLog("Error in saving activity")
            }
            
            else {
                
                NSLog("Activity Saved")
            }
        }
    }
}

class UIHelper: NSObject {
    
    class func getHeightForText (_ text: String?, width: CGFloat, font: UIFont) -> CGFloat {
        
        var size = CGSize.zero
        
        if text != nil {
            
            let frame = (text! as NSString).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: nil)
            
            size = CGSize(width: frame.size.width, height: frame.size.height + 1)
        }
        
        return size.height
    }
}
