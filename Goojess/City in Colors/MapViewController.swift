//
//  MapViewController.swift
//  City in Colors
//
//  Created by Freder/Users/FDUPRAY/Downloads/1024/ios/AppIcon.appiconset/Icon-App-20x20@2x.pngick Dupray on 18/02/16.
//  Copyright © 2016 Carman. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces
import GoogleMobileAds
import Parse
import EventKit
import EventKitUI

public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    public class func once(token: String, block:(Void) -> Void) {
        
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        
        if _onceTracker.contains(token) {
            
            return
        }
        
        _onceTracker.append(token)
    }
}

extension Date {
    
    func daysBetweenDate(toDate: Date) -> Int {
        
        let components = Calendar.current.dateComponents([.day], from: self, to: toDate)
        return components.day ?? 0
    }
}

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


extension Date {
    
    func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
}

//Convert colour to image
extension UIColor {
    
    func toImage() -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        
        self.setFill()
        
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
    }
}

let cityInColorRed = UIColor.white //UIColor(red: 211/255, green: 101/255, blue: 104/255, alpha: 1)


extension UISegmentedControl {
    
    func removeBorders() {
        setBackgroundImage(imageWithColor(backgroundColor!), for: UIControlState(), barMetrics: .default)
        setBackgroundImage(imageWithColor(tintColor!), for: .selected, barMetrics: .default)
        setDividerImage(imageWithColor(UIColor.clear), forLeftSegmentState: UIControlState(), rightSegmentState: UIControlState(), barMetrics: .default)
    }
    
    // create a 1x1 image with this color
    fileprivate func imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}




class MapViewController: CCViewController, MKMapViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate, UITableViewDelegate, UITableViewDataSource, CustomLocationAlertControllerDelegate, EKEventEditViewDelegate, UINavigationControllerDelegate, EKCalendarChooserDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate {
    
    
    
    /*private static var __once2: () = {
                
                TutorialMethods.showSecondStepInTutorial(hostVC: self, presentedBy: addLocationAlert)
            }()
    
    private static var __once1: () = {
                
                TutorialMethods.showFirstStepInTutorial(hostVC: self)
            }()*/
    
    
    
    enum SearchOption {
        
        case address
        case places
    }
    
    
    let eventStore = EKEventStore()
    
    
    var searchOption: SearchOption = SearchOption.address
    
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var mapSelector: UISegmentedControl!
    
    @IBOutlet weak var searchBarLocations: UISearchBar!
    @IBOutlet weak var mapViewLocations: MKMapView!
    @IBOutlet weak var searchBarView: UIView!
    
    @IBOutlet weak var bottomContainerView: UIView!
    
    var resultSearchController = UISearchController()
    
    var createdLocationCoordinates: CLLocationCoordinate2D!
    
    var arrayLocations = [CCLocation]()
    var filteredArrayLocations = [CCLocation]()
    
    @IBOutlet weak var locationResultsTable: UITableView!    
    
    
    var locationTableResults: [NSObject] = []
    
    var isHashtagMode = false
    var isSearchUserMode = false
    
    var locationManager : CLLocationManager!
    
    var nearestSpot = false
    
    var setToUserRegion = false
    
    var selectedUser: CCUser!
    var selectedUserIsCurrentUser = false
    
    var regionChanged = false
    
    var events: [EKEvent] = [EKEvent]()
    
    
    var filterCategories: [Float]?
    
    lazy var googlePlaces = {
        
        return GMSPlacesClient.shared()
    }

    
    
    lazy var userQuery = CCUser.query()
    lazy var query = CCLocation.query()
    
    @IBOutlet weak var tableBottomConstraint: NSLayoutConstraint!
    
    //Constraint
    func keyboardWillShow(_ notification: Notification) {
        
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        self.tableBottomConstraint.constant = frame.height
        
        self.view.setNeedsLayout()
    }
    
    
    func getBoundingBox () -> GMSCoordinateBounds  {
        
        
        let region = self.mapViewLocations.visibleMapRect
        
        
        let northEast = MKMapPointMake(MKMapRectGetMaxX(region), region.origin.y)
        
        let southWest = MKMapPointMake(region.origin.x, MKMapRectGetMaxY(region))
        
        
        let neCoordinate = MKCoordinateForMapPoint(northEast)
        
        let swCoordinate = MKCoordinateForMapPoint(southWest)
        
        return GMSCoordinateBounds(coordinate: neCoordinate, coordinate: swCoordinate)
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        PFQuery.clearAllCachedResults()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PFUser.current() == nil {
            
            self.performSegue(withIdentifier: "logIn", sender: self)
        }
        
        for subview in searchBarLocations.subviews.first!.subviews {
            
            if let tf = subview as? UITextField {
                
                tf.layer.borderWidth = 1
                tf.layer.borderColor = UIColor.lightGray.cgColor
                tf.layer.cornerRadius = 15
            }
        }
        
        
        self.mapSelector.isHidden = false
        
        self.locationResultsTable.delegate = self
        self.locationResultsTable.dataSource = self
        
        self.locationResultsTable.isHidden = true
        
        locationManager = CLLocationManager()
        
        locationManager.startUpdatingLocation()
        
        locationManager.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.allowsBackgroundLocationUpdates = true
        
        locationManager.desiredAccuracy = 1
        locationManager.distanceFilter = 30
        //Time interval is mesured in seconds
        //locationManager.allowDeferredLocationUpdates(untilTraveled: 100, timeout: 500)
        
        mapViewLocations.showsUserLocation = true
        
        mapViewLocations.delegate = self
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress(_:)))
        
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        
        mapViewLocations.addGestureRecognizer(longPressGesture)
        
        SERVICE_MANAGER.locationChangeHandler = CLLocationCoordinate2D(latitude: Double(AREA_IN_MILES) * METERS_PER_MILE, longitude: Double(AREA_IN_MILES) * METERS_PER_MILE)
        
        self.searchBarLocations.delegate = self
        
        SERVICE_MANAGER.locationManager?.startUpdatingLocation()
        
        searchBarLocations.placeholder = "Search"
        
        self.mapViewLocations.showsCompass = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if PFUser.current() == nil {
            
            self.performSegue(withIdentifier: "logIn", sender: self)
        }
        
        self.navigationController?.isNavigationBarHidden = true
        
        searchBarView.layer.cornerRadius = 5
        
        searchBarView.layer.shadowOpacity = 0.3
        
        searchBarView.layer.shadowRadius = 1
        
        searchBarView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        searchBarView.layer.shadowColor = UIColor.darkGray.cgColor
        
        
        searchBarLocations.backgroundImage = UIColor.white.toImage()
        
        searchBarLocations.backgroundColor = .white
        
        mapSelector.layer.borderColor = UIColor.white.cgColor
        mapSelector.layer.borderWidth = 2
        mapSelector.removeBorders()
        
        bottomContainerView.layer.cornerRadius = 5
        bottomContainerView.layer.shadowOpacity = 0.3
        bottomContainerView.layer.shadowRadius = 1
        bottomContainerView.layer.shadowOffset = CGSize(width: 0, height: -2)
        
        //Remove blur with tag 99
        for subview in mapViewLocations.subviews {
            
            if subview.tag == 99 {
                
                subview.removeFromSuperview()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.frame = view.bounds
        
        mapViewLocations.addSubview(blurEffectView)
        
        mapViewLocations.bringSubview(toFront: blurEffectView)
        
        blurEffectView.tag = 99
    }
    
    
    /*func fetchGooglePlaces () {
     
     
     }*/
    
    
    func setUserRegionToUserOnce () {
        
        let _onceToken = NSUUID().uuidString
        
        DispatchQueue.once(token: _onceToken) {
            
            let location = self.mapViewLocations.userLocation.coordinate
            
            let point = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
            
            self.setUpLocationsOnMap(point, searchResult: nil, pinCoordinate: nil)
            
            self.setToUserRegion = true
        }
    }
    
    func setUpLocationsOnMap (_ geoPoint: PFGeoPoint, searchResult: MKPlacemark?, pinCoordinate: PFGeoPoint?) {
        
        mapViewLocations.removeAnnotations(mapViewLocations.annotations)
        
        SERVICE_MANAGER.getLocationsWithCompletion(self.filterCategories, geoPoint: geoPoint) { (success, locations) -> Void in
            
            if success {
                
                print("LOCATIONS: \(locations!.count)")
                
                if let locations = locations {
                    
                    self.arrayLocations.removeAll()
                    
                    self.arrayLocations = locations
                    
                    if locations.isEmpty {
                        
                        let alert = UIAlertController(title: "No locations near you, be the first one!", message: "Tap and hold map to create a new location", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok!", style: .default, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                        self.searchBarLocations.text = ""
                    }
                }
                
                self.setUpLocationsFromArray(self.arrayLocations, placemark: searchResult, pinCoordinate: pinCoordinate)
            }
        }
    }
    
    func setUpLocationsFromArray(_ arrLocations: [CCLocation], placemark: MKPlacemark?, pinCoordinate: PFGeoPoint?) {
        
        
        mapViewLocations.removeAnnotations(mapViewLocations.annotations)
        
        for location in arrLocations {
            
            let annToAdd = CCAnnotation(newLocation: location)
            
            if location.geoPointLocation != nil {
                
                annToAdd.coordinate = CLLocationCoordinate2DMake(location.getGeoPointLocation().latitude, location.getGeoPointLocation().longitude)
                
                annToAdd.name = "\(location.strLocationName!)"
                
                annToAdd.posterName = "\(location.uploaderUsername!)"
                
                annToAdd.poster = location.locationUploader
                
                annToAdd.startDate = location.startDate
                
                annToAdd.endDate = location.expiryDate
                
                if location.expiryDate != nil {
                    
                    if !location.expiryDate!.isGreaterThanDate(Date()) {
                        
                        location.deleteEventually()
                    }
                        
                    else {
                        
                        mapViewLocations.addAnnotation(annToAdd)
                    }
                }
                    
                else {
                    
                    mapViewLocations.addAnnotation(annToAdd)
                }
                
                print("ANNOTATIONS COUNT: \(mapViewLocations.annotations.count)")
            }
        }
        
        
        if placemark != nil {
            
            self.dropPinZoomIn(placemark!)
        }
            
        else if pinCoordinate != nil {
            
            self.dropPinForCoordinate(pinCoordinate!)
        }
        
        
        if setToUserRegion {
            
            let geoPoint = self.mapViewLocations.userLocation.coordinate
            
            let viewRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude), Double(AREA_IN_MILES) * METERS_PER_MILE, Double(AREA_IN_MILES) * METERS_PER_MILE)
            
            self.mapViewLocations.setRegion(viewRegion, animated: true)
            
            updateMapViewCamera(viewRegion.center)
            
            self.setToUserRegion = false
        }
        
        if !setToUserRegion {
            
            self.setUserRegionToUserOnce()
        }
        
        
        if !nearestSpot {
            
            return
        }
        
        //TAKE USER TO NEAREST SPOT
        if (arrLocations == self.arrayLocations && self.arrayLocations.count > 0) == true {
            
            if let geoPoint = arrayLocations.first?.getGeoPointLocation() {
                
                let viewRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude), Double(AREA_IN_MILES) * METERS_PER_MILE, Double(AREA_IN_MILES) * METERS_PER_MILE)
                
                
                self.mapViewLocations.setRegion(viewRegion, animated: true)
                
                //updateMapViewCamera(viewRegion.center)
                
                nearestSpot = false
            }
        }
    }
    
    func handleLongPress (_ gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state != UIGestureRecognizerState.began {
            
            return
        }
        
        //Convert touch point to geo point.
        let touchPoint = gestureRecognizer.location(in: mapViewLocations)
        
        let touchMapCoordinate = mapViewLocations.convert(touchPoint, toCoordinateFrom: self.mapViewLocations)
        
        self.createNewLocationToAdd(touchMapCoordinate)
    }
    
    
    
    func createNewLocationToAdd (_ coordinates: CLLocationCoordinate2D) {
        
        self.createdLocationCoordinates = coordinates
        
        self.presentCustomLocationCreator(nil)
    }
    
    
    func presentCustomLocationCreator(_ image: UIImage!) {
        
        //Finish off location creation by filling the text fields.
        let addLocationAlert = self.storyboard?.instantiateViewController(withIdentifier: "AddLocationAlertController") as! CustomLocationAlertController
        
        addLocationAlert.modalPresentationStyle = .overFullScreen
        
        addLocationAlert.view.backgroundColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 0.5)
        
        
        let nav = UINavigationController(rootViewController: addLocationAlert)
        
        nav.modalPresentationStyle = .overFullScreen
        
        nav.view.backgroundColor = UIColor.clear
        
        addLocationAlert.delegate = self
        addLocationAlert.preloadedImage = image
        
        self.present(nav, animated: true) { () -> Void in
            
            struct Tokens {
                
                static var token: Int = 0
            }
            
            //_ = MapViewController.__once2
        }
    }
    
    //Custom location alert delegate methods
    func customLocationAlertController(locationName name: String, locationActivities activities: [String], locationDescription description: String, locationCategory category: Float, locationImage image: UIImage?) {
        
        //Create new location.
        let locationToAdd = CCLocation()
        
        locationToAdd.locationUploader = CURRENT_USER!
        
        locationToAdd.uploaderUsername = CURRENT_USER!.username!
        
        locationToAdd.geoPointLocation = PFGeoPoint(latitude: self.createdLocationCoordinates.latitude, longitude: self.createdLocationCoordinates.longitude)
        
        locationToAdd.strLocationName = name
        locationToAdd.strLocationDescription = description
        locationToAdd.strLocationActivities = activities
        locationToAdd.srtLocationCategory = category
        locationToAdd.defaultImage = PFFile(data: NSData(data: UIImageJPEGRepresentation(image!, 1)!) as Data)
        
        SERVICE_MANAGER.addNewLocation(locationToAdd, withCompletion: { (success, error) -> Void in
            
            if success {
                
                let newPost = CCTimelinePost()
                
                newPost.location = locationToAdd
                newPost.poster = CCUser.current()!
                newPost.postType = 5
                newPost.targetUsers = [CCUser.current()!]
                
                newPost.saveInBackground()
                
                
                if image != nil {
                    
                    //ALERT USERS AROUND THAT SHARE INTERESTS
                    
                    let photo = CCPhoto()
                    
                    photo.photoFile = PFFile(data: NSData(data: UIImageJPEGRepresentation(image!, 1)!) as Data)
                    
                    photo.photoUploader = CCUser.current()!
                    
                    photo.photoLocation = locationToAdd
                    
                    photo.saveInBackground()
                }
                
                self.setUpLocationsOnMap(locationToAdd.getGeoPointLocation(), searchResult: nil, pinCoordinate: nil)
                
                if let activity = locationToAdd.strLocationActivities {
                    
                    SERVICE_MANAGER.addActivity(activity, toLocation: locationToAdd)
                }
            }
        })
        
        self.sendSMSForLocationCreation(location: locationToAdd)
    }
    
    
    func sendSMSForLocationCreation (location: CCLocation) {
        
        let query = CCUser.query()
        
        query?.whereKeyExists("strPhoneNumber")
        
        query?.whereKey("currentGeoPoint", nearGeoPoint: CCUser.current()!.currentGeoPoint, withinKilometers: 1)
        
        if location.startDate == nil && location.expiryDate == nil {
            
            query?.whereKey("userInterests", containsAllObjectsIn: [location.srtLocationCategory])
        }
        
        
        print("THE QUERY WAS CALLED")
        //I'm going add more arguments later. This is so you can test.
        
        query?.findObjectsInBackground(block: { (objects, error) in
            
            print("OBJECTS: \(String(describing: objects?.description))")
            
            guard objects != nil else {
                
                print("ERROR \(error.debugDescription)")
                
                return
            }
            
            var phoneNumbers = [(String, String)]()
            
            //var objectsToBeSaved = [CCUser]()
            
            for object in objects! {
                
                print("IS ADDING NUMBERS")
                
                let user = object as! CCUser
                
                phoneNumbers.append((user.strPhoneNumber[1], user.username!))
                
                //let lastMessage = user.lastMessageReceived
                //LIMIT
                /*if lastMessage.daysBetweenDate(toDate: Date()) > 0 {
                 
                 phoneNumbers.append(user.strPhoneNumber[0])
                 
                 objectsToBeSaved.append(user)
                 }*/
                
                //Else ignore
            }
            
            //PFObject.saveAll(inBackground: objectsToBeSaved, block: nil)
            
            let categories = CCCategories()
            
            for number in phoneNumbers {
                
                var string: String
                
                if location.startDate == nil && location.expiryDate == nil {
                    
                    string = "Hi+\(number.1).+The_location+\(location.strLocationName!)_was_added_near_you. This place matches your interest in \(categories.fetchCategoryFromFloat(location.srtLocationCategory)).+Go+to+Goojess+to+check+it+out.".replacingOccurrences(of: "_", with: "+").replacingOccurrences(of: " ", with: "+")
                }
                
                else {
                    
                    string = "Hi+\(number.1).+The_event+\(location.strLocationName!)_was_added_near_you.+Join the event in the Goojess app.".replacingOccurrences(of: "_", with: "+").replacingOccurrences(of: " ", with: "+")
                }
            
                
                print("IS SENDING SMS")
                
                if let url = URL(string: "https://www.shoescape.se/smsgateway/index.php?s=goj2345d&t=\(number.0.replacingOccurrences(of: "+", with: "00"))&m=\(string)") {
                    
                    print("SMS SENT")
                    
                    URLSession.shared.dataTask(with: url).resume()
                }
                
                else {
                    
                    appDelegate.showAlertWithMessage("https://www.shoescape.se/smsgateway/index.php?s=goxxxx&t=\(number.0.replacingOccurrences(of: "+", with: "00"))&m=\(location.strLocationName!)")
                    
                    break
                }
            }

        })
    }
    
    
    func customLocationAlertControllerDidCancel() {
        
        self.createdLocationCoordinates = nil
    }
    
    
    /*func filterLocations() {
        
        if searchBarLocations.text == "" || searchBarLocations.text == nil {
            
            return
        }
        
        if searchBarLocations.text!.characters.first! == "@" {
            
            return
        }
        
        if searchBarLocations.text!.characters.first != "#" {
            
            return
        }
        
        self.filteredArrayLocations.removeAll(keepCapacity: false)
        
        let searchPredicate = NSPredicate(format: "strLocationName CONTAINS[c] %@ OR ANY strLocationActivities CONTAINS[c] %@", searchBarLocations.text!.stringByReplacingOccurrencesOfString("#", withString: ""), self.searchBarLocations.text!.stringByReplacingOccurrencesOfString("#", withString: ""))
        
        let array = (self.arrayLocations as NSArray).filteredArrayUsingPredicate(searchPredicate)
        
        self.filteredArrayLocations = array as! [CCLocation]
        
        if searchBarLocations.text! == "#" {
            
            self.filteredArrayLocations = self.arrayLocations
        }
        
        self.mapViewLocations.removeAnnotations(self.mapViewLocations.annotations)
        
        for location in filteredArrayLocations {
            
            let annToAdd = CCAnnotation(newLocation: location)
            
            annToAdd.coordinate = CLLocationCoordinate2DMake(location.getGeoPointLocation().latitude, location.getGeoPointLocation().longitude)
            
            annToAdd.name = "\(location.strLocationName!)"
            
            annToAdd.posterName = "\(location.uploaderUsername)"
            
            mapViewLocations.addAnnotation(annToAdd)
        }
    }*/
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //Change text to blue
        /*let textField = searchBar.valueForKey("searchField") as? UITextField
         
         let font = UIFont.systemFontOfSize(14)*/
        
        
        if searchBar.text == nil || searchBar.text == "" {
            
            if !self.locationResultsTable.isHidden {
                
                self.locationResultsTable.isHidden = true
            }
            
            return
        }
        
        
        if self.locationResultsTable.isHidden {
            
            self.locationResultsTable.isHidden = false
        }
        
        
        self.locationTableResults.removeAll()
        
        let box = getBoundingBox()
        
        //START PLACES QUERY
        self.googlePlaces().autocompleteQuery(searchBar.text!, bounds: box, filter: nil, callback: { (places, error) in
            
            guard places != nil else {
                
                print("Autocomplete error \(String(describing: error))")
                
                return
            }
            
            //self.locationTableResults = self.locationTableResults.filter({$0 is GMSAutocompletePrediction})
            
            let firstThreeElements = [GMSAutocompletePrediction](places!.prefix(3))
            
            for i in firstThreeElements {
                
                self.locationTableResults.append(i)
            }
            
            //self.locationTableResults.append(contentsOf: firstThreeElements as [NSObject])
            
            self.locationResultsTable.reloadData()
        })
        
        
        //START LOCATION QUERY
        query?.cancel()
        
        query?.limit = 5
        
        query?.whereKey("strLocationName", matchesRegex: searchText, modifiers: "i")
        //query?.whereKey("geoPointLocation", withinGeoBoxFromSouthwest: PFGeoPoint(latitude: box.southWest.latitude, longitude: box.southWest.latitude), toNortheast: PFGeoPoint(latitude: box.northEast.latitude, longitude: box.northEast.latitude))
        
        query?.findObjectsInBackground(block: { (objects, error) in
            
            guard objects != nil else {
                
                print("ERROR \(error)")
                
                return
            }
            
            print("COUNT LOCATIONS \(objects!.count)")
            
            //self.locationTableResults = self.locationTableResults.filter({$0 is CCLocation})
            
            //self.locationTableResults.append(contentsOf: objects! as [NSObject])
            
            for i in objects! {
                
                self.locationTableResults.append(i as NSObject)
            }
            
            self.locationResultsTable.reloadData()
        })
        
        
        //START USER QUERY
        userQuery?.cancel()
        
        userQuery?.limit = 5
        
        userQuery?.whereKey("username", matchesRegex: searchText, modifiers: "i")
        
        userQuery?.findObjectsInBackground(block: { (objects, error) in
            
            guard objects != nil else {
                
                print("ERROR \(String(describing: error))")
                
                return
            }
            
            print("COUNT USERS \(objects!.count)")
            
            //self.locationTableResults = self.locationTableResults.filter({$0 is CCUser})
            
            for i in objects! {
                
                self.locationTableResults.append(i as NSObject)
            }
            
            //self.locationTableResults.append(objects! as [NSObject])
            
            self.locationResultsTable.reloadData()
        })
    }
    
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
        searchBar.text = ""
        
        self.setUpLocationsFromArray(self.arrayLocations, placemark: nil, pinCoordinate: nil)
    }
    
    
    
    /*func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
        if self.isHashtagMode {
            
            return
        }
        
        if self.isSearchUserMode {
            
            self.activityIndicator.startAnimating()
            
            let query = CCUser.query()
            
            let queryTextFormat = searchBar.text!.stringByReplacingOccurrencesOfString(" ", withString: "").stringByReplacingOccurrencesOfString("@", withString: "")
            
            query?.whereKey("username", equalTo: queryTextFormat)
            
            query?.getFirstObjectInBackgroundWithBlock({ (user, error) -> Void in
                
                if let foundUser = user as? CCUser {
                    
                    self.selectedUser = foundUser
                    
                    self.performSegueWithIdentifier("toUserProfile", sender: searchBar)
                }
                    
                else {
                    
                    searchBar.becomeFirstResponder()
                    
                    self.userNotFound()
                }
                
                self.activityIndicator.stopAnimating()
            })
            
            return
        }
        
        
        
        let box = getBoundingBox()
        
        let filter = GMSAutocompleteFilter()
        
        
        if self.searchOption == .Places {
            
            
            filter.type = .Establishment
            
            self.googlePlaces().autocompleteQuery(searchBar.text!, bounds: box, filter: filter, callback: { (places, error) in
                
                guard places != nil else {
                    
                    let alertController = UIAlertController(title: nil, message: "There was an error processing your request", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    print("Autocomplete error \(error)")
                    
                    return
                }
                
                if places?.isEmpty == true || error != nil {
                    
                    let alertController = UIAlertController(title: nil, message: "Establishment Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    appDelegate.stopLoadingView()
                    
                    return
                }
                
                self.locationTableResults = places!
                
                
                let firstPlace = places![0]
                
                self.searchBarLocations.text = firstPlace.attributedPrimaryText.string
                
                appDelegate.startLoadingView()
                
                
                self.googlePlaces().lookUpPlaceID(firstPlace.placeID!, callback: { (place, error) in
                    
                    guard place != nil else {
                        
                        let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        appDelegate.stopLoadingView()
                        
                        return
                    }
                    
                    
                    let coordinate = CLLocationCoordinate2D(latitude: place!.coordinate.latitude, longitude: place!.coordinate.longitude)
                    
                    let region = MKCoordinateRegionMake(coordinate, MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                    
                    self.mapViewLocations.setRegion(region, animated: true)
                    
                    let point = PFGeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    
                    self.setUpLocationsOnMap(point, searchResult: nil, pinCoordinate: point)
                    
                    
                    appDelegate.stopLoadingView()
                })
            })
        }
            
        else {
            
            filter.type = .Geocode
            
            self.googlePlaces().autocompleteQuery(searchBar.text!, bounds: box, filter: filter, callback: { (places, error) in
                
                guard places != nil else {
                    
                    let alertController = UIAlertController(title: nil, message: "There was an error processing your request", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    print("Autocomplete error \(error)")
                    
                    return
                }
                
                if places?.isEmpty == true || error != nil {
                    
                    let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    appDelegate.stopLoadingView()
                    
                    return
                }
                
                self.locationTableResults = places!
                
                
                let firstPlace = places![0]
                
                self.searchBarLocations.text = firstPlace.attributedPrimaryText.string
                
                
                appDelegate.startLoadingView()
                
                
                self.googlePlaces().lookUpPlaceID(firstPlace.placeID!, callback: { (place, error) in
                    
                    guard place != nil else {
                        
                        let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        appDelegate.stopLoadingView()
                        
                        return
                    }
                    
                    
                    let coordinate = CLLocationCoordinate2D(latitude: place!.coordinate.latitude, longitude: place!.coordinate.longitude)
                    
                    let region = MKCoordinateRegionMake(coordinate, MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                    
                    self.mapViewLocations.setRegion(region, animated: true)
                    
                    let point = PFGeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    
                    self.setUpLocationsOnMap(point, searchResult: nil, pinCoordinate: point)
                    
                    
                    appDelegate.stopLoadingView()
                })
            })
        }
        
        
        if !self.locationResultsTable.hidden {
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                
                self.locationResultsTableHeight.constant = 0
                
                }, completion: { (done) -> Void in
                    
                    if done {
                        
                        self.locationResultsTable.hidden = true
                    }
            })
        }
    }*/
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        //self.mapSelector.isHidden = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        //self.mapSelector.isHidden = false
    }
    
    
    func alertViewShouldEnableFirstOtherButton (_ alert: UIAlertController) -> Bool {
        
        return alert.textFields?[0].text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0
    }
    
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        if CLLocationManager.locationServicesEnabled() {
            
            self.setUserRegionToUserOnce()
        }
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let temp = mapView.subviews.first!
        
        let gestures = temp.gestureRecognizers!
        
        for gesture in gestures {
            
            if gesture.state == .ended {
                
                self.regionChanged = true
                
                break
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        if self.regionChanged {
            
            self.activityIndicator.startAnimating()
            
            self.regionChanged = true
            
            
            let query = CCLocation.query()
            
            let region = mapView.visibleMapRect
            
            
            let northEast = MKMapPointMake(MKMapRectGetMaxX(region), region.origin.y)
            
            let southWest = MKMapPointMake(region.origin.x, MKMapRectGetMaxY(region))
            
            
            let neCoordinate = MKCoordinateForMapPoint(northEast)
            
            let swCoordinate = MKCoordinateForMapPoint(southWest)
            
            
            let neGeoPoint = PFGeoPoint(latitude: neCoordinate.latitude, longitude: neCoordinate.longitude)
            
            let swGeoPoint = PFGeoPoint(latitude: swCoordinate.latitude, longitude: swCoordinate.longitude)
            
            
            query?.whereKey("geoPointLocation", withinGeoBoxFromSouthwest: swGeoPoint, toNortheast: neGeoPoint)
            
            var geoPoints = [PFGeoPoint]()
            
            for location in self.arrayLocations {
                
                geoPoints.append(location.getGeoPointLocation())
            }
            
            query?.whereKey("geoPointLocation", notContainedIn: geoPoints)
            
            query?.findObjectsInBackground(block: { (locations, error) -> Void in
                
                if let locations = locations as? [CCLocation] {
                    
                    self.arrayLocations.removeAll()
                    
                    self.arrayLocations = locations
                    
                    for location in self.arrayLocations {
                        
                        let annToAdd = CCAnnotation(newLocation: location)
                        
                        if location.geoPointLocation != nil {
                            
                            annToAdd.coordinate = CLLocationCoordinate2DMake(location.getGeoPointLocation().latitude, location.getGeoPointLocation().longitude)
                            
                            annToAdd.name = "\(location.strLocationName!)"
                            
                            annToAdd.posterName = "\(location.uploaderUsername!)"
                            
                            annToAdd.poster = location.locationUploader
                            
                            self.mapViewLocations.addAnnotation(annToAdd)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                                        
                    self.activityIndicator.stopAnimating()
                }
            })
        }
    }
    
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        
        for annotationView in views {
            
            if annotationView.annotation!.isEqual(mapView.userLocation) {
                
                if CCUser.current() == nil {
                    
                    return
                }
                
                mapView.userLocation.title = CCUser.current()!.username!
                
                mapView.userLocation.subtitle = "My current location"
                
                annotationView.detailCalloutAccessoryView = createViewForUserLocationCallout(annotationView.annotation!)
                
                let infoButton = UIButton(type: .detailDisclosure)
                
                annotationView.rightCalloutAccessoryView = infoButton
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        if !(annotation is CCAnnotation) && !(annotation is SearchPointAnnotation) {
            
            return nil
        }
        
        let identifier = "CCAnnotation"
        
        var annotationView = self.mapViewLocations.dequeueReusableAnnotationView(withIdentifier: identifier) as? CustomAnnotationView
        
        if annotationView == nil {
            
            annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
            
        else {
            
            annotationView?.annotation = annotation
        }
        
        
        if (annotation.isKind(of: SearchPointAnnotation.self)) {
            
            let a = annotation as! SearchPointAnnotation
            
            self.configureDetailView(annotationView!)
            
            annotationView?.rightCalloutAccessoryView = nil
            
            annotationView?.image = UIImage(named: "pinBlackNew.png")
            
            annotationView?.tintColor = a.pinColour
            
            return annotationView
        }
        
        
        let custom = annotation as! CCAnnotation
        
        annotationView?.isEnabled = true
        
        if custom.endDate == nil && custom.startDate == nil {
            
            annotationView?.image = UIImage(named: "pinRedNew")
        }
            
        else {
            
            annotationView?.image = UIImage(named: "MiniFavouriteButtonCINC")
        }
        
        annotationView?.canShowCallout = true
        
        annotationView?.detailCalloutAccessoryView = createViewForCallout(custom)
        
        
        custom.title = custom.name
        
        
        let infoButton = UIButton(type: .detailDisclosure)
        
        annotationView?.rightCalloutAccessoryView = infoButton
        
        return annotationView
    }
    
    
    func createViewForCallout(_ annotation: CCAnnotation) -> UIButton {
        
        let font = UIFont.systemFont(ofSize: 10)
        
        let posterName = AnnotationButton()
        
        posterName.tag = 1
        
        posterName.setTitle(annotation.posterName!, for: UIControlState())
        
        posterName.annotation = annotation
        
        posterName.titleLabel?.textColor = UIColor(red: 0, green: 204/255, blue: 1, alpha: 1)
        
        posterName.setTitleColor(UIColor(red: 0, green: 204/255, blue: 1, alpha: 1), for: UIControlState())
        
        posterName.titleLabel!.font = font
        
        posterName.addTarget(self, action: #selector(MapViewController.showUserProfile(_:)), for: .touchUpInside)
        
        
        return posterName
    }
    
    
    func createViewForUserLocationCallout(_ annotation: MKAnnotation) -> UIButton {
        
        let font = UIFont.systemFont(ofSize: 14)
        
        let button = UserAnnotationButton()
        
        button.tag = 1
        
        button.setTitle("Create new location here", for: UIControlState())
        
        button.annotation = mapViewLocations.userLocation
        
        button.titleLabel?.textColor = UIColor(red: 0, green: 204/255, blue: 1, alpha: 1)
        
        button.setTitleColor(UIColor(red: 0, green: 204/255, blue: 1, alpha: 1), for: UIControlState())
        
        button.titleLabel!.font = font
        
        button.addTarget(self, action: #selector(MapViewController.getTouchCoordinatesFromButton(_:)), for: .touchUpInside)
        
        
        return button
    }
    
    
    func getTouchCoordinatesFromButton (_ sender: UserAnnotationButton) {
        
        self.createNewLocationToAdd(sender.annotation!.coordinate)
    }
    
    
    func showUserProfile (_ sender: AnnotationButton) {
        
        self.selectedUser = sender.annotation.poster
        
        if sender.annotation.poster.objectId! == CCUser.current()!.objectId! {
            
            self.selectedUser = CCUser.current()!
            self.performSegue(withIdentifier: "toCurrentUserProfile", sender: self)
            
            return
        }
        
        self.performSegue(withIdentifier: "toUserProfile", sender: self)
    }
    
    class AnnotationButton: UIButton {
        
        var annotation: CCAnnotation = CCAnnotation(newLocation: CCLocation())
    }
    
    class UserAnnotationButton: UIButton {
        
        var annotation: MKUserLocation?
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let viewAnnotation: AnyObject? = view.annotation
        
        if viewAnnotation! is CCAnnotation {
            
            self.performSegue(withIdentifier: "toLocationDetailScreen", sender: (viewAnnotation as! CCAnnotation).location)
        }
            
        else if viewAnnotation!.isEqual(mapView.userLocation) {
            
            if view.detailCalloutAccessoryView != nil {
                
                guard let button = view.detailCalloutAccessoryView as? UserAnnotationButton else {
                    
                    return
                }
                
                self.getTouchCoordinatesFromButton(button)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toLocationDetailScreen" {
            
            let detailsVC = segue.destination as! LocationDetailViewController
            
            detailsVC.location = sender as? CCLocation
        }
            
        else if segue.identifier == "toUserProfile" {
            
            let vc = segue.destination as! ProfileView
            
            vc.user = self.selectedUser
        }
            
        else if segue.destination is MapCategoryFilter {
            
            let vc = segue.destination as! MapCategoryFilter
            
            if let cats = filterCategories {
                
                vc.selectedCategories = cats
            }
                
            else {
                
                vc.selectedCategories = [Float]()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        appDelegate.showAlertWithMessage(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if CCUser.current() == nil {
            
            return
        }
        
        //appDelegate.showAlertWithMessage("UPDATED LOCATIONS")
        
        //CREATE TIMELINE POST HERE
        
        manager.requestLocation()
        
        if let userLocation = locations.first?.coordinate {
            
            CCUser.current()?.currentGeoPoint = PFGeoPoint(latitude: userLocation.latitude, longitude: userLocation.longitude)
            
            //Check if any spots are nearby
            let locationQuery = CCLocation.query()
            locationQuery?.whereKey("geoPointLocation", nearGeoPoint: PFGeoPoint(latitude: userLocation.latitude, longitude: userLocation.longitude), withinKilometers: 0.1)
            
            if let interests = CCUser.current()?.userInterests {
                
                locationQuery?.whereKey("srtLocationCategory", containedIn: interests)
            }
            
            locationQuery?.getFirstObjectInBackground(block: { (object, error) in
                
                guard object != nil else {
                    
                    print("ERROR: \(error)")
                    
                    return
                }
                
                let location = object as! CCLocation
                
                let newPost = CCTimelinePost()
                
                newPost.location = location
                newPost.poster = CCUser.current()!
                newPost.postType = 1
                newPost.targetUsers = [CCUser.current()!]
                
                newPost.saveEventually()
                
                DispatchQueue.main.async(execute: { 
                    
                    appDelegate.showAlertWithMessage("YOU WERE NEAR A LOCATION. IT WAS ADDED TO YOUR TIMELINE: \(location.strLocationName!)")
                })
            })
        }
    }
    
    /*func locationManager(_ manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        
        
        //WHAT WAS I TRYING TO DO HERE?
        /*let location = locations.last as! CLLocation
         
         let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
         
         let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
         
         self.mapViewLocations.setRegion(region, animated: true)*/
    }*/
    
    
    
    var currentUserPosition: CLLocationCoordinate2D?
    
    
    @IBAction func buttonMoveToCurrentLocationPressed (_ sender: Any) {
        
        let current = CLLocationCoordinate2DMake(self.mapViewLocations.userLocation.coordinate.latitude, self.mapViewLocations.userLocation.coordinate.longitude)
        
        PFUser.current()!.setValue(PFGeoPoint(latitude: current.latitude, longitude: current.longitude), forKey: "currentGeoPoint")
        
        PFUser.current()?.saveInBackground()
        
        let viewRegion = MKCoordinateRegionMakeWithDistance(current, Double(AREA_IN_MILES) * Double(METERS_PER_MILE), Double(AREA_IN_MILES) * Double(METERS_PER_MILE))
        
        self.mapViewLocations.setRegion(viewRegion, animated: true)
        
        self.setUpLocationsOnMap(PFGeoPoint(latitude: current.latitude, longitude: current.longitude), searchResult: nil, pinCoordinate: nil)
    }
    
    
    @IBAction func goToNearestSpot(_ sender: Any) {
        
        nearestSpot = true
        
        let coordinate = self.mapViewLocations.region.center
        
        self.searchBarLocations.text = ""
        
        self.setUpLocationsOnMap(PFGeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude), searchResult: nil, pinCoordinate: nil)
    }
    
    
    func createGoojessCalendar () {
        
        if UserDefaults.standard.object(forKey: "GoojessPrimaryCalendar") as? String == nil {
            
            let id = "Goojess"
            
            let newCal = EKCalendar(for: .event, eventStore: self.eventStore)
            
            newCal.title = id
            
            newCal.source = eventStore.defaultCalendarForNewEvents.source
            
            do {
                
                try self.eventStore.saveCalendar(newCal, commit: true)
                
                UserDefaults.standard.set(newCal.calendarIdentifier, forKey: "GoojessPrimaryCalendar")
            } catch {
                
                
                let alert = UIAlertController(title: "Calendar could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func initiateGoojessCalImport () {
        
        var calendar: EKCalendar!
        
        if let id = UserDefaults.standard.object(forKey: "GoojessPrimaryCalendar") as? String {
            
            calendar = eventStore.calendar(withIdentifier: id)
        }
            
        else {
            
            createGoojessCalendar()
            
            calendar = eventStore.calendar(withIdentifier: UserDefaults.standard.object(forKey: "GoojessPrimaryCalendar") as! String)
        }
        
        let startDate = Date()
        
        var comp = DateComponents()
        
        comp.day = 10
        comp.month = 1
        
        let endDate = (Calendar.current as NSCalendar).date(byAdding: comp, to: startDate, options: NSCalendar.Options.matchFirst)
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate!, calendars: [calendar])
        
        self.events = eventStore.events(matching: predicate).sorted() { (e1: EKEvent, e2: EKEvent) -> Bool in
            
            return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
        }
        
        self.finaliseGoojessCalendarImport()
    }
    
    
    func finaliseGoojessCalendarImport () {
        
        if self.events.count == 0 {
            
            return
        }
        
        let filter = GMSAutocompleteFilter()
        
        filter.type = .geocode
        
        var filteredEventsList = [EKEvent]()
        
        for event in events {
            
            if event.location != nil || event.location != "" || event.structuredLocation == nil {
                
                filteredEventsList.append(event)
            }
        }
        
        let alert = UIAlertController(title: "Confirmation", message: "Events with no location can't be imported.\n\nEvents to be imported: \(filteredEventsList.count)/\(self.events.count)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
        
        
        for event in filteredEventsList {
            
            self.googlePlaces().autocompleteQuery(event.location!, bounds: nil, filter: filter, callback: { (prediction, error) in
                
                if let place = prediction?.first {
                    
                    self.googlePlaces().lookUpPlaceID(place.placeID!, callback: { (place, error) in
                        
                        if let place = place {
                            
                            let newEvent = CCLocation()
                            
                            newEvent.expiryDate = event.endDate
                            newEvent.startDate = event.startDate
                            newEvent.geoPointLocation = PFGeoPoint(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude) //[place.coordinate.longitude, place.coordinate.latitude]
                            newEvent.strLocationName = "\(event.title)"
                            
                            newEvent.strLocationDescription = "The event entitled \(event.title) was created by \(CCUser.current()!.username!)"
                            newEvent.locationUploader = CCUser.current()!
                            newEvent.uploaderUsername = CCUser.current()!.username!
                            newEvent.strLocationActivities = ["#Event"]
                            newEvent.srtLocationCategory = 0
                            
                            newEvent.saveEventually()
                            
                            self.sendSMSForLocationCreation(location: newEvent)
                        }
                    })
                }
            })
        }
    }
    
    //This actaully imports full calendar
    @IBAction func importCalendarEvent (_ sender: Any) {
        
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch status {
            
        case EKAuthorizationStatus.notDetermined:
            
            eventStore.requestAccess(to: .event, completion: { (success, error) in
                
                if success {
                    
                    self.createGoojessCalendar()
                    
                    self.initiateGoojessCalImport()
                }
                    
                else {
                    
                    self.calAccessDeniedAlert()
                }
            })
            
        case EKAuthorizationStatus.authorized:
            
            self.createGoojessCalendar()
            
            self.initiateGoojessCalImport()
            
        case .denied, .restricted:
            
            self.calAccessDeniedAlert()
        }
    }
    
    
    @IBAction func importEvent(_ sender: Any) {
        
        let eventPicker = EKEventEditViewController()
        
        eventPicker.delegate = self
        
        eventPicker.editViewDelegate = self
        
        eventPicker.event = EKEvent(eventStore: eventStore)
        
        eventPicker.eventStore = self.eventStore
        
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch status {
            
        case EKAuthorizationStatus.notDetermined:
            
            eventStore.requestAccess(to: .event, completion: { (success, error) in
                
                if success {
                    
                    self.createGoojessCalendar()
                    
                    self.present(eventPicker, animated: true, completion: nil)
                }
                    
                else {
                    
                    self.calAccessDeniedAlert()
                }
            })
            
        case EKAuthorizationStatus.authorized:
            
            self.createGoojessCalendar()
            
            self.present(eventPicker, animated: true, completion: nil)
            
        case .denied, .restricted:
            
            self.calAccessDeniedAlert()
        }
    }
    
    
    func calAccessDeniedAlert () {
        
        let alert = UIAlertController(title: "Please allow access to calendar in Settings app", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { (action) in
            
            let openSettings = URL(string: UIApplicationOpenSettingsURLString)
            
            UIApplication.shared.openURL(openSettings!)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        
    }
    
    
    func eventEditViewControllerDefaultCalendar(forNewEvents controller: EKEventEditViewController) -> EKCalendar {
        
        if let id = UserDefaults.standard.object(forKey: "GoojessPrimaryCalendar") as? String {
            
            if let cal = self.eventStore.calendar(withIdentifier: id) {
                
                return cal
            }
        }
        
        return self.eventStore.defaultCalendarForNewEvents
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        
        dismiss(animated: true, completion: nil)
        
        let event = controller.event
        
        let newEvent = CCLocation()
        
        
        
        if controller.event == nil {
            
            
        }
            
        else if event?.location == nil {
            
            let alert = UIAlertController(title: "Failed", message: "The event needs a valid location in order to be imported", preferredStyle: .alert)
            
            self.present(alert, animated: true, completion: nil)
        }
            
        else {
            
            let filter = GMSAutocompleteFilter()
            
            filter.type = .geocode
            
            self.googlePlaces().autocompleteQuery(event!.location!, bounds: nil, filter: filter, callback: { (predictions, error) in
                
                if let first = predictions?.first {
                    
                    self.googlePlaces().lookUpPlaceID(first.placeID!, callback: { (place, error) in
                        
                        if place?.coordinate != nil {
                            
                            newEvent.geoPointLocation = PFGeoPoint(latitude: place!.coordinate.latitude, longitude: place!.coordinate.longitude) //[place!.coordinate.longitude, place!.coordinate.latitude]
                            
                            self.finaliseEventCreation(event, newEvent: newEvent)
                            
                        }
                            
                        else {
                            
                            
                            let alert = UIAlertController(title: "Failed", message: "The event needs a valid location in order to be imported", preferredStyle: .alert)
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                    })
                }
            })
        }
    }
    
    
    //Got rid of the event alert
    func finaliseEventCreation (_ event: EKEvent?, newEvent: CCLocation) {
        
        newEvent.expiryDate = event?.endDate
        newEvent.startDate = event?.startDate
        newEvent.locationUploader = CCUser.current()
        newEvent.strLocationActivities = ["#Event", "\(event!.title)"]
        newEvent.uploaderUsername = CCUser.current()?.username
        newEvent.strLocationName = "\(event!.title)"
        newEvent.strLocationDescription = ""
        newEvent.srtLocationCategory = 0
        
        newEvent.saveInBackground()
        
        self.sendSMSForLocationCreation(location: newEvent)
        
        let newPost = CCTimelinePost()
        
        newPost.location = newEvent
        newPost.poster = CCUser.current()
        newPost.postType = 2
        newPost.targetUsers = [CCUser.current()!]
        
        newPost.saveInBackground()
    }
    
    
    /*@IBAction func placesSegmentedControlAction (sender: UISegmentedControl!) {
        
        switch sender.selectedSegmentIndex {
            
        case 0:
            
            self.searchOption = .Address
            
        case 1:
            
            self.searchOption = .Places
            
        default:
            
            self.searchOption = .Address
        }
    }*/
    
    
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl!) {
        
        switch (sender.selectedSegmentIndex) {
            
        case 0:
            self.mapViewLocations.mapType = .standard
            
            updateMapViewCamera(self.mapViewLocations.region.center)
            
        case 1:
            self.mapViewLocations.mapType = .satelliteFlyover
            
            
        case 2: // or case 2
            self.mapViewLocations.mapType = .hybridFlyover
            
        default:
            self.mapViewLocations.mapType = .standard
        }
    }
    
    
    func updateMapViewCamera (_ centerCoordinate: CLLocationCoordinate2D) {
        
        let distance: CLLocationDistance = self.setToUserRegion == true ? 650 : currentDistance()
        
        let pitch: CGFloat = 30
        let heading = 90.0
        
        let coordinate = centerCoordinate
        
        let camera = MKMapCamera(lookingAtCenter: coordinate,
                                 fromDistance: distance,
                                 pitch: pitch,
                                 heading: heading)
        
        mapViewLocations.camera = camera
    }
    
    func currentDistance () -> CLLocationDistance {
        
        let centerCoordinate = self.mapViewLocations.centerCoordinate
        
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        
        let topCenterCoordinate = self.mapViewLocations.convert(CGPoint(x: self.mapViewLocations.frame.size.width/2, y: 0), toCoordinateFrom: self.mapViewLocations)
        
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
        
        let radius = centerLocation.distance(from: topCenterLocation) + 200
        
        return radius
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.searchBarLocations.resignFirstResponder()
    }
    
    
    class CustomAnnotationView: MKAnnotationView {
        
        override func didAddSubview(_ subview: UIView) {
            
            if isSelected {
                
                setNeedsLayout()
            }
        }
        
        override func layoutSubviews() {
            
            // MKAnnotationViews only have subviews if they've been selected.
            // short-circuit if there's nothing to loop over
            
            if !isSelected {
                
                return
            }
            
            loopViewHierarchy({(view : UIView) -> Bool in
                
                if let label = view as? UILabel {
                    
                    if label.tag == 1 {
                        
                        return false
                    }
                    
                    label.font = UIFont.systemFont(ofSize: 16)
                    
                    return false
                }
                
                return true
            })
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationResultCell")!
        
        if indexPath.row > (self.locationTableResults.count - 1) {
            
            return UITableViewCell()
        }
        
        let selectedItem = self.locationTableResults[indexPath.row]
        
        if selectedItem is GMSAutocompletePrediction {
            
            cell.detailTextLabel?.isHidden = false
            
            let item = selectedItem as! GMSAutocompletePrediction
            
            cell.textLabel?.text = item.attributedPrimaryText.string
            
            cell.detailTextLabel?.text = item.attributedSecondaryText?.string
            
            return cell
        }
            
        else if selectedItem is CCLocation {
            
            cell.detailTextLabel?.isHidden = true
            
            let item = selectedItem as! CCLocation
            
            cell.textLabel?.text = item.strLocationName
            
            cell.detailTextLabel?.text = nil
            
            return cell
        }
            
            //IS CCUSER
        else {
            
            cell.detailTextLabel?.isHidden = true
            
            let item = selectedItem as! CCUser
            
            cell.textLabel?.text = item.username
            
            cell.detailTextLabel?.text = nil
            
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !self.locationResultsTable.isHidden {
            
            self.locationResultsTable.isHidden = true
        }
        
        
        let object = self.locationTableResults[indexPath.row]
        
        
        if object is GMSAutocompletePrediction {
            
            let placemark = object as! GMSAutocompletePrediction
            
            self.searchBarLocations.text = placemark.attributedPrimaryText.string
            
            
            appDelegate.startLoadingView()
            
            
            self.googlePlaces().lookUpPlaceID(placemark.placeID!) { (place, error) in
                
                guard place != nil else {
                    
                    let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                    appDelegate.stopLoadingView()
                    
                    return
                }
                
                
                let coordinate = CLLocationCoordinate2D(latitude: place!.coordinate.latitude, longitude: place!.coordinate.longitude)
                
                let region = MKCoordinateRegionMake(coordinate, MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                
                self.mapViewLocations.setRegion(region, animated: true)
                
                let point = PFGeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
                
                self.setUpLocationsOnMap(point, searchResult: nil, pinCoordinate: point)
                
                
                appDelegate.stopLoadingView()
            }
        }
            
        else if object is CCLocation {
            
            let place = object as! CCLocation
            
            let coordinate = CLLocationCoordinate2D(latitude: place.geoPointLocation.latitude, longitude: place.geoPointLocation.longitude)
            
            let region = MKCoordinateRegionMake(coordinate, MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            self.mapViewLocations.setRegion(region, animated: true)
            
            self.setUpLocationsOnMap(place.geoPointLocation, searchResult: nil, pinCoordinate: nil)
        }
            
            //IS CCUSER
        else {
            
            let user = object as! CCUser
            
            self.selectedUser = user
            self.performSegue(withIdentifier: "toUserProfile", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.locationTableResults.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    
    func dropPinZoomIn (_ placemark:MKPlacemark) {
        
        let annotation = SearchPointAnnotation()
        
        annotation.coordinate = placemark.coordinate
        
        annotation.title = placemark.name
        
        if let city = placemark.locality, let state = placemark.administrativeArea, let street = placemark.thoroughfare {
            
            annotation.subtitle = "\(street), \(city), \(state)"
        }
            
        else if let city = placemark.locality, let state = placemark.administrativeArea {
            
            annotation.subtitle = "\(city), \(state)"
        }
        
        mapViewLocations.addAnnotation(annotation)
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        
        mapViewLocations.setRegion(region, animated: true)
        
        updateMapViewCamera(region.center)
    }
    
    
    
    func dropPinForCoordinate(_ point: PFGeoPoint) {
        
        let annotation = SearchPointAnnotation()
        
        let coordinate = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
        
        annotation.coordinate = coordinate
        
        annotation.title = self.searchBarLocations.text!
        
        mapViewLocations.addAnnotation(annotation)
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        
        let region = MKCoordinateRegionMake(coordinate, span)
        
        mapViewLocations.setRegion(region, animated: true)
        
        updateMapViewCamera(region.center)        
    }
    
    
    func configureDetailView(_ annotationView: MKAnnotationView) {
        
        let width = 200
        let height = 200
        
        let snapshotView = UIView()
        
        let views = ["snapshotView": snapshotView]
        
        snapshotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[snapshotView(200)]", options: [], metrics: nil, views: views))
        snapshotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[snapshotView(200)]", options: [], metrics: nil, views: views))
        
        let options = MKMapSnapshotOptions()
        
        options.size = CGSize(width: width, height: height)
        
        options.mapType = .hybrid
        
        options.camera = MKMapCamera(lookingAtCenter: annotationView.annotation!.coordinate, fromDistance: 250, pitch: 65, heading: 0)
        
        let snapshotter = MKMapSnapshotter(options: options)
        
        snapshotter.start (completionHandler: { snapshot, error in
            
            if snapshot != nil {
                
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
                
                imageView.image = snapshot!.image
                
                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapViewController.showSnapshotImage(_:)))
                
                tapRecognizer.numberOfTapsRequired = 1
                
                tapRecognizer.delegate = self
                
                imageView.addGestureRecognizer(tapRecognizer)
                
                imageView.isUserInteractionEnabled = true
                
                snapshotView.addSubview(imageView)
            }
        })
        
        annotationView.detailCalloutAccessoryView = snapshotView
    }
    
    
    @IBAction func createSpotFromImage(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.cameraCaptureMode = .photo
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: false, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.dismiss(animated: false, completion: nil)
        
        if self.locationManager.location?.coordinate == nil {
            
            let alert = UIAlertController(title: "Please allow location updates in Settings to continue", message: nil, preferredStyle: .alert)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        let userLoc = self.mapViewLocations.userLocation.coordinate
        
        self.createdLocationCoordinates = CLLocationCoordinate2D(latitude: userLoc.latitude, longitude: userLoc.longitude)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.presentCustomLocationCreator(image)
    }
    
    
    //SWIFT 2.3
    /*func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.dismiss(animated: false, completion: nil)
        
        if self.locationManager.location?.coordinate == nil {
            
            let alert = UIAlertController(title: "Please allow location updates in Settings to continue", message: nil, preferredStyle: .alert)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        let userLoc = self.mapViewLocations.userLocation.coordinate
        
        self.createdLocationCoordinates = CLLocationCoordinate2D(latitude: userLoc.latitude, longitude: userLoc.longitude)
        
        let image = editingInfo![UIImagePickerControllerOriginalImage] as! UIImage
        
        self.presentCustomLocationCreator(image)
    }*/
    
    
    //CONFIGURE UNWIND SEGUE.
    @IBAction func filterMap (_ segue: UIStoryboardSegue) {
        
        setUpLocationsOnMap(PFGeoPoint(latitude: self.mapViewLocations.region.center.latitude, longitude: self.mapViewLocations.region.center.longitude), searchResult: nil, pinCoordinate: nil)
    }
    
    
    func showSnapshotImage(_ tap: UITapGestureRecognizer) {
        
        let superview = tap.view as! UIImageView
        
        if superview.image == nil {
            
            return
        }
        
        let info = JTSImageInfo()
        
        info.image = superview.image!
        
        info.referenceView = self.view
        
        info.referenceRect = superview.bounds
        
        
        
        let viewer = JTSImageViewController(imageInfo: info, mode: JTSImageViewControllerMode.image, backgroundStyle: .blurred)
        
        viewer?.show(from: self, transition: .fromOriginalPosition)
    }
    
    
    func userNotFound () {
        
        let alert = UIAlertController(title: "User not found", message: "Please enter a valid username", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    class SearchPointAnnotation: MKPointAnnotation {
        
        let pinColour = UIColor.black
        
        override init() {
            super.init()
            
        }
    }
}


//Customize callout view font

typealias ViewBlock = (_ view : UIView) -> Bool

extension UIView {
    
    func loopViewHierarchy(_ block : ViewBlock?) {
        
        if block?(self) ?? true {
            
            for subview in subviews {
                
                subview.loopViewHierarchy(block)
            }
        }
    }
}
