//
//  ProfileView.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import UIKit
import Parse
import TOCropViewController
import EventKit
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

/*protocol FavouriteRefreshDelegate {
    
    func refreshFavourites()
}*/

class ProfileView: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, TOCropViewControllerDelegate {
    
    //var delegate: FavouriteRefreshDelegate!
    let locationCellIdentifier = "ProfileLocationCell"
    let eventCellIdentifier = "ProfileEventCell"
    
    var user: CCUser!
    
    var isCurrentUser = false
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var coverPicFilter: UIView!
    @IBOutlet weak var coverPicWhiteView: UIView!
    @IBOutlet weak var coverPic: UIImageView!
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var logOutButton: UIButton!
    
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var mySpotsTable: UITableView!
    
    @IBOutlet weak var phoneNumberButton: UIButton!
    
    let picker = UIImagePickerController()
    
    var mySpots = [CCLocation]()
    
    var refreshControl: UIRefreshControl!
    var timelineRefreshControl: UIRefreshControl!
    
    var location: CCLocation!
    
    var selectedEvent: CCLocation!
    
    enum ProfileImages {
        
        case CoverPic
        case ProfilePic
    }
    
    var currentProfileImage: ProfileImages!
    
    let dateFormatter = DateFormatter()
    
    let eventStore = EKEventStore()
    
    @IBOutlet weak var userCityCountry: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //FIX ME: If #number exists, confirm number button title is phone number otherwise leave unchanged.
        if let numbers = CCUser.current()?.strPhoneNumber {
            
            self.phoneNumberButton.setTitle(numbers.first!, for: .normal)
        }
        
        mySpotsTable.delegate = self
        mySpotsTable.dataSource = self
        
        refreshControl = UIRefreshControl()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        refreshControl.addTarget(self, action: #selector(ProfileView.refresh), for: .valueChanged)
        
        
        timelineRefreshControl = UIRefreshControl()
        
        timelineRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        timelineRefreshControl.addTarget(self, action: #selector(ProfileView.refresh), for: .valueChanged)
        
        
        self.scrollView.alwaysBounceVertical = true
        
        self.scrollView.addSubview(refreshControl)
        
        self.picker.delegate = self
        
        if self.user != nil {

            if self.user.objectId == CCUser.current()!.objectId! {
                
                self.isCurrentUser = true
            }
            
            else {
                
                self.isCurrentUser = false
                self.phoneNumberButton.isHidden = true
            }
            
            
            if self.user.isDataAvailable {
                
                self.user.fetchIfNeededInBackground(block: { (object, error) -> Void in
                    
                    if object != nil {
                        
                        if self.isCurrentUser == false {
                            
                            //self.uploadImage.isHidden = true
                            
                            self.logOutButton.isHidden = true
                        }
                        
                        self.setUpProfileForUser(object as! CCUser)
                        
                        self.getLocations(self.user)
                        
                        self.username.text = self.user.username
                        
                        self.title = self.user.username
                        
                        //self.getFavouriteLocations()
                    }
                })
            }
                
            else {
                
                self.user.fetchIfNeededInBackground(block: { (object, error) -> Void in
                    
                    if object != nil {
                        
                        if object!.objectId != CCUser.current()!.objectId! {
                            
                            //self.uploadImage.isHidden = true
                            
                            self.logOutButton.isHidden = true
                        }
                        
                        self.setUpProfileForUser(object as! CCUser)
                        
                        self.getLocations(self.user)
                        
                        self.username.text = self.user.username
                        
                        self.title = self.user.username
                        
                        //self.getFavouriteLocations()
                    }
                })
            }
            
        }
        
        else {
        
            self.user = CCUser.current()!
            
            self.isCurrentUser = true
            
            self.user.fetchIfNeededInBackground(block: { (object, error) -> Void in
                
                if object != nil {
                    
                    self.getLocations(self.user)
                    
                    self.setUpProfileForUser(object as! CCUser)
                    
                    self.username.text = self.user.username
                    
                    self.title = self.user.username
                }
            })
            
            //self.getFavouriteLocations()
        }
        
        setUserCity()
        
        //self.profilePic.layer.masksToBounds = true
        //self.profilePic.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        
        var fontSize: CGFloat = 18
        
        let attributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: fontSize)]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        self.navigationController?.navigationBar.barTintColor = cityInColorRed
        
        self.picker.navigationBar.barTintColor = cityInColorRed
        
        fontSize = 14
        
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(attributes, for: UIControlState())
    }
    
    func setUserCity () {
        
        if let _ = user.currentGeoPoint {
            
            let geocoder = CLGeocoder()
            
            let location = CLLocation(latitude: user.currentGeoPoint.latitude, longitude: user.currentGeoPoint.longitude)
            
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                
                guard placemarks != nil else {
                    
                    self.userCityCountry.isHidden = true
                    
                    return
                }
                
                let currentPlacemark: CLPlacemark! = placemarks![0]
                
                if currentPlacemark.locality != nil && currentPlacemark.country != nil {
                    
                    self.userCityCountry.text = "\(currentPlacemark.locality!), \(currentPlacemark.country!)"
                }
                    
                else {
                    
                    self.userCityCountry.isHidden = true
                }
            })
        }
            
        else {
            
            userCityCountry.isHidden = true
        }
    }

    
    func setUpProfileForUser (_ user: CCUser) {
        
        self.userEmailLabel.text = user.email
        
        print(profilePic.frame)
        
        self.profilePic.layer.cornerRadius = self.profilePic.frame.width/2
        self.profilePic.layer.masksToBounds = true
        
        self.profilePic.layer.borderWidth = 1
        self.profilePic.layer.borderColor = UIColor.gray.cgColor
        
        self.coverPicWhiteView.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.coverPicWhiteView.layer.masksToBounds = false
        self.coverPicWhiteView.layer.shadowOpacity = 0.75
        self.coverPicWhiteView.layer.shadowPath = UIBezierPath(rect: coverPicWhiteView.bounds).cgPath
        self.coverPicWhiteView.layer.shadowColor = UIColor.lightGray.cgColor
        self.coverPicWhiteView.layer.shadowRadius = 5
        
        let coverTap = UITapGestureRecognizer(target: self, action: #selector(uploadPic))
        
        let profileTap = UITapGestureRecognizer(target: self, action: #selector(uploadPic))
        
        coverTap.numberOfTapsRequired = 1
        profileTap.numberOfTapsRequired = 1
        
        self.coverPicFilter.addGestureRecognizer(coverTap)
        self.profilePic.addGestureRecognizer(profileTap)
        
        self.coverPicFilter.isUserInteractionEnabled = true
        self.profilePic.isUserInteractionEnabled = true
            
        let grayImage = UIColor.gray.toImage()
        let lightGrayImage = UIColor.lightGray.toImage()
        
        self.profilePic.image = grayImage
        self.coverPic.image = lightGrayImage
        
        if let d = user.userProfilePicture {
            

            let progress = UIProgressView(progressViewStyle: .default)
            
            progress.progressTintColor = UIColor(red: 0, green: 204/255, blue: 1, alpha: 1)
            
            self.view.addSubview(progress)
            
            progress.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 5)
            
            
            d.getDataInBackground({ (data, error) -> Void in
                
                
                if data != nil {
                    
                    self.profilePic.image = UIImage(data: data!)
                }
                
                progress.isHidden = true
                
                progress.removeFromSuperview()
                
                
                }, progressBlock: { (percentDone) -> Void in
                    
                    progress.progress = Float(percentDone)/100
                    
                    if percentDone == 100 {
                        
                        progress.isHidden = true
                        
                        progress.removeFromSuperview()
                    }
            })
        }
        
        if let c = user.userCoverPicture {
            
            c.getDataInBackground(block: { (data, error) in
                
                if data != nil {
                    
                    self.coverPic.image = UIImage(data: data!)
                }
            })
        }
    }
    
    func refresh () {
        
        if self.user.isDataAvailable {
            
            self.getLocations(self.user)
        }
    }
    
    func getLocations(_ user: CCUser) {
        
        if self.refreshControl.isRefreshing {
            
            self.setUpProfileForUser(user)
        }
     
        let query = CCLocation.query()
        
        query?.whereKey("locationUploader", equalTo: user)
        
        query?.addDescendingOrder("createdAt")
        
        query?.limit = 1000
        
        query?.cachePolicy = .networkOnly
        
        query?.findObjectsInBackground(block: { (objects, error) -> Void in
            
            if error == nil && objects?.count > 0 {
                
                self.mySpots = objects as! [CCLocation]
                
                DispatchQueue.main.async {
                    
                    self.mySpotsTable.reloadData()
                    
                    self.refreshControl.endRefreshing()
                }
            }
        })
    }
    
    
    
    func uploadPic(_ sender: Any) {
        
        let gesture = sender as? UIGestureRecognizer
        
        if gesture?.view?.tag == 1 {
            
            self.currentProfileImage = .CoverPic
        }
        
        else {
            
            self.currentProfileImage = .ProfilePic
        }
        
        let alert = UIAlertController(title: "Please Select", message: "Camera or Library?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) -> Void in
            
            self.picker.sourceType = .camera
            
            self.present(self.picker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) -> Void in
            
            self.picker.sourceType = .photoLibrary
            
            self.present(self.picker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func logout(_ sender: Any) {
        
        PFUser.logOutInBackground()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
    }
    
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        
        appDelegate.startLoadingView()
        
        if self.currentProfileImage == .CoverPic {
            
            self.coverPic.image = image
            
            do {
                
                let file = try PFFile(name: "\(CCUser.current()!.username!)CoverPic", data: UIImageJPEGRepresentation(image, 1)!, contentType: "image/jpeg")
                
                CCUser.current()!.userCoverPicture = file
                
            } catch _ {
                
                appDelegate.showAlertWithMessage("Upload failed")
                
                appDelegate.stopLoadingView()
                
                return
            }
        }
        
        else {
            
            self.profilePic.image = image
            
            do {
                
                let file = try PFFile(name: "\(CCUser.current()!.username!)ProfilePic", data: UIImageJPEGRepresentation(image, 1)!, contentType: "image/jpeg")
                
                CCUser.current()!.userProfilePicture = file
                
            } catch _ {
                
                appDelegate.showAlertWithMessage("Upload failed")
                
                appDelegate.stopLoadingView()
                
                return
            }
        }
        
        CCUser.current()!.saveInBackground { (success, error) -> Void in
            
            appDelegate.stopLoadingView()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let cropper = TOCropViewController(image: chosenImage)
        
        cropper.delegate = self
        
        picker.dismiss(animated: true, completion: nil)
        
        present(cropper, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.mySpots.isEmpty {
            
            let cell = self.mySpotsTable.dequeueReusableCell(withIdentifier: "NoLocationsCell")!
            
            cell.contentView.layer.cornerRadius = 5
            
            return cell
        }
        
        let location = self.mySpots[indexPath.section]
        
        //Then location is an event
        if location.startDate != nil && location.expiryDate != nil  {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: eventCellIdentifier) as! ProfileEventCell
            
            cell.contentView.layer.cornerRadius = 5
            cell.backgroundColor = UIColor.clear
            
            cell.contentView.layer.shadowRadius = 2
            cell.contentView.layer.shadowOffset = CGSize(width: 1, height: 1)
            cell.contentView.layer.shadowOpacity = 0.75
            cell.contentView.layer.shadowColor = UIColor.gray.cgColor
            
            if indexPath.section % 2 == 0 {
                
                //COLOUR 1 RGB VALUE/255
                cell.contentView.backgroundColor = UIColor(red: 216/255, green: 231/255, blue: 243/255, alpha: 1)
            }
                
            else {
                
                //COLOUR 2 RGB VALUE/255
                // TODO SIMON FIXME.
                cell.contentView.backgroundColor = UIColor(red: 236/255, green: 244/255, blue: 249/255, alpha: 1)
            }
            
            let startDay = Calendar.current.component(.day, from: location.startDate)
            
            let endDay = Calendar.current.component(.day, from: location.expiryDate)
            
            let startWeekday = self.dateFormatter.weekdaySymbols[Calendar.current.component(.weekday, from: location.startDate)-1].capitalized
            
            let endWeekday = self.dateFormatter.weekdaySymbols[Calendar.current.component(.weekday, from: location.expiryDate)-1].capitalized
            
            let startMonth = self.dateFormatter.monthSymbols[Calendar.current.component(.month, from: location.startDate)-1].capitalized
            
            cell.eventNameLabel.text = location.strLocationName
            cell.eventDescriptionLabel.text = location.strLocationDescription
            cell.eventMonthLabel.text = startMonth
            cell.eventDayLabel.text = "\(startDay)"
            
            self.dateFormatter.dateFormat = "hh:mm"
            
            let startTime = self.dateFormatter.string(from: location.startDate)
            
            let endTime = self.dateFormatter.string(from: location.expiryDate)
            
            if startDay == endDay && startWeekday == endWeekday {
                
                cell.eventDatesLabel.text = "\(startWeekday) \(startTime) - \(endTime)"
            }
            
            else {
                
                cell.eventDatesLabel.text = "\(startWeekday) \(startTime) - \(endWeekday) \(endTime)"
            }
            
            cell.addToCalendarButton.addTarget(self, action:#selector(addEventToCalendar(_:)), for: UIControlEvents.touchUpInside)
            
            return cell
        }
            
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: locationCellIdentifier) as! ProfileLocationCell
            
            cell.contentView.layer.cornerRadius = 5
            
            cell.contentView.layer.cornerRadius = 5
            cell.backgroundColor = UIColor.clear
            
            cell.contentView.layer.shadowRadius = 2
            cell.contentView.layer.shadowOffset = CGSize(width: 1, height: 1)
            cell.contentView.layer.shadowOpacity = 0.75
            cell.contentView.layer.shadowColor = UIColor.gray.cgColor
            
            if indexPath.section % 2 == 0 {
                
                //COLOUR 1 RGB VALUE/255
                cell.contentView.backgroundColor = UIColor(red: 216/255, green: 231/255, blue: 243/255, alpha: 1)
            }
                
            else {
                
                //COLOUR 2 RGB VALUE/255
                // TODO SIMON FIXME.
                cell.contentView.backgroundColor = UIColor(red: 236/255, green: 244/255, blue: 249/255, alpha: 1)
            }
            
            cell.locationNameLabel.text = location.strLocationName
            cell.locationDescriptionLabel.text = location.strLocationDescription
            
            cell.locationPageButton.addTarget(self, action: #selector(showLocationDetailView(_:)), for: .touchUpInside)
            
            cell.locationImageView.image = UIColor.lightGray.toImage()
            
            cell.locationImageView.file = location.defaultImage
            
            cell.locationImageView.loadInBackground()
            
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 81
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.mySpots.isEmpty ? 1 : self.mySpots.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        
        view.backgroundColor = .clear
        
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if ((tableView.cellForRow(at: indexPath)?.isKind(of: MyLocationsCell.self)) == nil) {
         
            return
        }
        
        let alert = UIAlertController(title: "Please Select", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "View", style: .default, handler: { (action) -> Void in
            

            self.location = self.mySpots[indexPath.section]
            self.performSegue(withIdentifier: "showLocationView", sender: self)
            
        }))
        
        if isCurrentUser {
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                
                self.mySpots[indexPath.section].deleteInBackground()
                
                self.mySpots.remove(at: indexPath.section)
                
                if self.mySpots.isEmpty {
                    
                    tableView.reloadData()
                }
                    
                else {
                    
                    let indexSet: IndexSet = [indexPath.section]
                    
                    tableView.deleteSections(indexSet, with: .automatic)
                    
                    //tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                }
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func showLocationDetailView (_ sender: UIButton) {
        
        let pointInTable: CGPoint = sender.convert(sender.bounds.origin, to: self.mySpotsTable)
        
        let cellIndexPath = self.mySpotsTable.indexPathForRow(at: pointInTable)
        
        self.location = self.mySpots[cellIndexPath!.section]
        
        self.performSegue(withIdentifier: "showLocationView", sender: self)
    }
    
    func addEventToCalendar(_ sender: UIButton) {
        
        let pointInTable: CGPoint = sender.convert(sender.bounds.origin, to: self.mySpotsTable)
        
        let cellIndexPath = self.mySpotsTable.indexPathForRow(at: pointInTable)
        
        self.mySpotsTable.scrollToRow(at: cellIndexPath!, at: .bottom, animated: true)
        
        self.selectedEvent = self.mySpots[cellIndexPath!.section]
        
        sender.setImage(nil, for: .normal)
        sender.setTitle("Added", for: .normal)
        sender.isEnabled = false
        
        
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch status {
            
        case EKAuthorizationStatus.notDetermined:
            
            eventStore.requestAccess(to: .event, completion: { (success, error) in
                
                if success {
                    
                    self.createEventFromLocation()
                }
                    
                else {
                    
                    self.calAccessDeniedAlert()
                }
            })
            
        case EKAuthorizationStatus.authorized:
            
            self.createEventFromLocation()
            
        case .denied, .restricted:
            
            self.calAccessDeniedAlert()
        }
    }
    
    
    
    func createEventFromLocation() {
        
        var calendar: EKCalendar!
        
        if let id = UserDefaults.standard.object(forKey: "GoojessPrimaryCalendar") as? String {
            
            if let cal = self.eventStore.calendar(withIdentifier: id) {
                
                calendar = cal
            }
        }
            
        else {
            
            calendar = self.eventStore.defaultCalendarForNewEvents
        }
        
        let event = EKEvent(eventStore: self.eventStore)
        
        event.title = self.selectedEvent.strLocationName
        event.startDate = self.selectedEvent.startDate
        event.endDate = self.selectedEvent.expiryDate
        event.calendar = calendar
        
        appDelegate.startLoadingView()
        
        let coder = CLGeocoder()
        let location = CLLocation(latitude: self.selectedEvent.geoPointLocation.latitude, longitude: self.selectedEvent.geoPointLocation.longitude)
        
        coder.reverseGeocodeLocation(location) { (placemarks, error) in
            
            appDelegate.stopLoadingView()
            
            guard placemarks != nil else {
                
                appDelegate.showAlertWithMessage("Location doesn't exist")
                
                return
            }
            
            if let placemark = placemarks?.last {
                
                event.location = "\(String(describing: placemark.thoroughfare)) \(String(describing: placemark.postalCode)) \(String(describing: placemark.locality)) \(String(describing: placemark.country))"
            }
        }
        
        do {
            
            
            try self.eventStore.save(event, span: .thisEvent, commit: true)
            
            appDelegate.showAlertWithTitle("Success", message: "The event was successfully added to your Goojess calendar in the Calendar app")
            
            
        } catch _ {
            
            appDelegate.showAlertWithMessage("Location doesn't exist")
        }
    }
    
    //If calendar doesn't exist create new one
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
    
    func calAccessDeniedAlert() {
        
        let alert = UIAlertController(title: "Please allow access to calendar in Settings app", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { (action) in
            
            let openSettings = URL(string: UIApplicationOpenSettingsURLString)
            
            UIApplication.shared.openURL(openSettings!)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showLocationView" {
            
            let vc = segue.destination as! LocationDetailViewController
            
            vc.location = self.location
        }
        
        /*else if segue.identifier == "ToFavourites" {
            
            let vc = segue.destinationViewController as! CCLocationFavouritesTable
            
            if let locations = user.cachedFavouriteLocations {
                
                vc.favourite = locations
            }
            
            else {
                
                vc.favourite = [CCLocation]()
            }
            
            vc.location = self.location
            
            vc.isCurrentUser = self.isCurrentUser
            
            vc.parentController = self
            
            vc.viewTitle = self.title
        }*/
    }
}
