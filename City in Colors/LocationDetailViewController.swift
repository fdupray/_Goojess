//
//  LocationDetailViewController.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import Accounts
import Parse
import EventKit
import GooglePlaces

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


class LocationDetailViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, JTSImageViewControllerInteractionsDelegate, UITextViewDelegate, ActivitiesTableDelegate, CustomAlertControllerDelegate {
    
    
    /*private static var __once: () = {
                
                TutorialMethods.showThirdStepInTutorial(hostVC: self)
            }()
    */
    
    enum AlertType {
        
        case activity
        case title
        case review
        case report
    }
    
    @IBOutlet weak var eventStartDate: UILabel!
    @IBOutlet weak var eventEndDate: UILabel!
    @IBOutlet weak var addToCalendarButton: UIButton!
    
    let currentUser = CCUser.current()!
    
    var alertType: AlertType!
    
    var imagePicker = UIImagePickerController()
    
    var shareImage: UIImage?
    
    let photoIdentifier = "PhotoCell"
    
    let descriptionPlaceholder = "No description yet!"
    
    var arrayActivities = [PFObject]()
    var arrayComments = [PFObject]()
    var arrayPhotos = [PFObject]()
    
    lazy var googlePlaces = {
        
        return GMSPlacesClient.shared()
    }
    
    @IBOutlet weak var eventNameLabel: UILabel!
    
    //@IBOutlet weak var noPhotosLabel: UILabel!
    
    @IBOutlet weak var activitiesCell: ActivitiesTableViewCell!
    
    @IBOutlet weak var locationDescription: UITextView!
    //@IBOutlet weak var labelLocationAddress: UILabel!
    @IBOutlet weak var collectionViewPhotos: UICollectionView!
    //@IBOutlet weak var buttonLeftArrow: UIButton!
    //@IBOutlet weak var buttonRightArrow: UIButton!
    @IBOutlet weak var creationDateLabel: UILabel!
    
    @IBOutlet weak var addActivityButton: UIButton!
    //@IBOutlet weak var writeReviewButton: UIButton!
    
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var participationButton: EventParticipationButton!
    var isGoingToEvent = false
    var participantObject: CCParticipant?
    
    @IBOutlet weak var amountOfParticipantsLabel: UILabel!
    
    @IBOutlet weak var locationAddressString: UILabel!
    //@IBOutlet weak var favouriteButton: FavouriteButton!
    
    //@IBOutlet weak var amountOfFavourites: UILabel!

    let titleText = UIButton()
    
    var location: CCLocation?
    
    var canEditLocation: Bool!
    
    let eventStore = EKEventStore()
    
    @IBOutlet weak var editAddressButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationAddressString.text = self.location!.geoPointLocationAddress
        
        self.eventNameLabel.text = self.location?.strLocationName
        
        //self.noPhotosLabel.text = "Loading..."
        
        if CURRENT_USER!.username == self.location!.uploaderUsername {
            
            self.canEditLocation = true
        }
            
        else {
            
            self.canEditLocation = false
            
            self.editAddressButton.isHidden = true
        }
        
        if CURRENT_USER!.username == self.location!.uploaderUsername {
            
                        self.canEditLocation = true
                    }
                        
                    else {
                        
                        self.canEditLocation = false
                    }
        
        
        let formatter = DateFormatter()
        
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        
        //Fetch Location then get dates.
        if self.location!.isDataAvailable && self.location!.startDate != nil && self.location!.expiryDate != nil  {
            
            self.eventStartDate.text = formatter.string(from: self.location!.startDate)
            
            self.eventEndDate.text = formatter.string(from: self.location!.expiryDate)
            
            self.fetchEventParticipationObject()
        }
            
        else if self.location!.startDate != nil && self.location!.expiryDate != nil {
            
            self.location?.fetchInBackground(block: { (location, error) in
                
                if let location = location as? CCLocation {
                    
                    
                    self.eventStartDate.text = formatter.string(from: location.startDate)
                    
                    self.eventEndDate.text = formatter.string(from: location.expiryDate)
                    
                    self.fetchEventParticipationObject()
                }
                    
                else if error != nil {
                    
                    let iP = IndexPath(row: 0, section: 0)
                    
                    self.tableView.deleteRows(at: [iP], with: UITableViewRowAnimation.none)
                }
                    
                else {
                    
                    let iP = IndexPath(row: 0, section: 0)
                    
                    self.tableView.deleteRows(at: [iP], with: UITableViewRowAnimation.none)
                }
            })
        }
            
        else {
            
            let iP = IndexPath(row: 0, section: 0)
            
            self.tableView.deleteRows(at: [iP], with: UITableViewRowAnimation.none)
        }
        
        
        self.activitiesCell.canEditTable = self.canEditLocation
        self.activitiesCell.location = self.location
        
        self.navigationItem.hidesBackButton = true
        
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = false
                
        //let strLocation = NSString(format: "%g", self.location!.getGeoPointLocation().latitude).stringByAppendingFormat("%g", self.location!.getGeoPointLocation().longitude)
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LocationDetailViewController.copyCoordinates(_:)))
        
        gestureRecognizer.numberOfTapsRequired = 1
        
        gestureRecognizer.delegate = self
        
        /*self.labelLocationAddress.userInteractionEnabled = true
        self.labelLocationAddress.addGestureRecognizer(gestureRecognizer)
        self.labelLocationAddress.text = strLocation as String*/
        
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        
        self.collectionViewPhotos.isPagingEnabled = true
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.itemSize = CGSize(width: SCREEN_WIDTH, height: collectionViewPhotos.height)
        
        collectionViewPhotos.collectionViewLayout = flowLayout
        collectionViewPhotos.dataSource = self
        collectionViewPhotos.delegate = self
        collectionViewPhotos.backgroundColor = .clear
        
        //self.setUpArrowButtonsVisibility()
        
        self.fetchImages()
        
        self.activitiesCell.canEditTable = self.canEditLocation
        
        self.activitiesCell.editButton.isHidden = !self.canEditLocation
        
        //self.fetchComments()
        
        self.tableView.tableHeaderView = UIView(frame: CGRect.zero)
        
        
        self.creationDateLabel.text = "Created on " + formatter.string(from: self.location!.createdAt!)
        
        self.shareButton.setTitle("Share \(self.location!.strLocationName!)", for: UIControlState())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationAddressString.text = self.location!.geoPointLocationAddress
        
        if !self.canEditLocation {
            
            //Add non editable title
            self.title = self.location?.strLocationName
            
            let fontSize: CGFloat = 18
            
            let attributes = [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont.systemFont(ofSize: fontSize)]
            
            self.navigationController?.navigationBar.titleTextAttributes = attributes
            
            self.locationDescription.isEditable = false
            self.locationDescription.isSelectable = false
        }
        
        else {
            
            self.addRenameFunctionality()
            
            self.locationDescription.delegate = self
            self.locationDescription.isEditable = true
            self.locationDescription.isSelectable = true
        }
        
        
        self.locationDescription.returnKeyType = UIReturnKeyType.done
        self.locationDescription.tintColor = UIColor.blue
        
        self.navigationController?.isNavigationBarHidden = false
        
        self.navigationController?.navigationBar.barTintColor = cityInColorRed
        
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont.systemFont(ofSize: 14)], for: UIControlState())
        
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.lightGray
         
        //self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        
        if let exp = self.location?.strLocationDescription {
            
            self.locationDescription.text = exp
        }
        
        else {
            
            self.locationDescription.text = self.descriptionPlaceholder
        }
        
        if let activities = self.location?.strLocationActivities {
            
            self.activitiesCell.activities = activities
        }
        
        else {
            
            self.activitiesCell.activities = [String]()
        }
        
        self.activitiesCell.tableView.reloadData()
        
        self.imagePicker.navigationBar.barTintColor = cityInColorRed
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), atScrollPosition: .Top, animated: true)
    }
    
    func addRenameFunctionality() {
        
        titleText.addTarget(self, action: #selector(LocationDetailViewController.renameLocation(_:)), for: .touchUpInside)
        
        titleText.setTitle(self.location?.strLocationName, for: UIControlState())
        
        titleText.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        titleText.setTitleColor(UIColor.white, for: UIControlState())
        
        titleText.sizeToFit()
        
        self.navigationItem.titleView = titleText
    }
    
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        if textView.text == descriptionPlaceholder {
            
            textView.text = ""
        }
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        self.location?.strLocationDescription = textView.text
        
        self.location?.saveEventually()
        
        if textView.text == "" {
            
            textView.text = self.descriptionPlaceholder
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            
            textView.resignFirstResponder()
            
            return false
        }
        
        return true
    }
    
    func renameLocation(_ sender: UIButton) {
        
        let addTitleAlert = self.storyboard?.instantiateViewController(withIdentifier: "CustomAlertController") as! CustomAlertController
        
        addTitleAlert.modalPresentationStyle = .overFullScreen
        
        addTitleAlert.view.backgroundColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 0.75)
        
        
        let nav = UINavigationController(rootViewController: addTitleAlert)
        
        nav.modalPresentationStyle = .overFullScreen
        
        nav.view.backgroundColor = UIColor.clear
        
        addTitleAlert.delegate = self
        
        addTitleAlert.viewTitle = "Rename Location"
        
        addTitleAlert.textFieldPlaceHolder = "Location name..."
        
        addTitleAlert.confirmButtonTitle = "Done!"
        
        addTitleAlert.globalColour = UIColor.lightGray
        
        self.alertType = .title
        
        self.present(nav, animated: true, completion: nil)
    }
    
    
    
    func fetchImages () {
        
        let queryImages = CCPhoto.query()
        
        queryImages?.cachePolicy = .networkOnly
        
        queryImages?.whereKey("photoLocation", equalTo: self.location!)
        
        queryImages?.findObjectsInBackground(block: { (objects, error) -> Void in
            
            appDelegate.stopLoadingView()
            
            if objects != nil {
                
                self.arrayPhotos = objects!
                
                self.collectionViewPhotos.reloadData()
                
                if self.arrayPhotos.count > 0 {
                    
                    self.collectionViewPhotos.scrollToItem(at: IndexPath(item: self.arrayPhotos.count-1, section: 0), at: .right, animated: true)
                }
                
                else {
                    
                    //self.noPhotosLabel.text = "No Images"
                }
            }
            
            else {
                
                //self.noPhotosLabel.text = "No Images"
            }
        })
    }
    

    
    func activitiesShouldSave(_ activities: [String]) {
        
        self.location?.strLocationActivities = activities
        
        self.location?.saveEventually()
    }
    
    
    func fetchComments () {
        
        let queryComments = CCComment.query()
        
        queryComments?.whereKey("commentLocation", equalTo: self.location!)
        
        queryComments?.includeKey("commentor")
        
        queryComments?.findObjectsInBackground(block: { (objects, error) -> Void in
            
            appDelegate.stopLoadingView()
            
            if objects != nil {
                
                self.arrayComments = objects!
            }
            
            struct Tokens { static var token: Int = 0 }
            
            //_ = LocationDetailViewController.__once
        })
    }
    
    

    
    @IBAction func showCommentsTableView (_ sender: Any) {
        
        self.showCommentsTable(sender)
    }
    

    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.arrayPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoIdentifier, for: indexPath)
        
        let imageView = cell.viewWithTag(123) as?
        PFImageView
        
        if imageView != nil {
         
            let photo = self.arrayPhotos[indexPath.item] as! CCPhoto
            
            imageView?.file = photo.photoFile
            
            let progress = UIProgressView(progressViewStyle: .default)
            
            progress.progressTintColor = UIColor(red: 0, green: 204/255, blue: 1, alpha: 1)
            
            imageView?.addSubview(progress)
            
            progress.center = imageView!.center
            
            progress.bounds.size.width = imageView!.bounds.width
            
            imageView?.load(inBackground: { (image,  error) -> Void in
                
                if imageView != nil {
                    
                    imageView?.image = image
                    
                    self.shareImage = image
                    
                    progress.removeFromSuperview()
                }
                    
                else {
                    
                    imageView?.file?.cancel()
                    
                    progress.removeFromSuperview()
                }
                
                }, progressBlock: { (percentDone) -> Void in
                    
                    progress.progress = Float(percentDone)/100
                    
                    if percentDone == 100 {
                        
                        
                        progress.removeFromSuperview()
                    }
            })
            
            let gRec = UITapGestureRecognizer(target: self, action: #selector(LocationDetailViewController.showImage(_:)))
            
            gRec.numberOfTapsRequired = 1
            
            gRec.delegate = self
            
            imageView?.addGestureRecognizer(gRec)
            
            imageView?.isUserInteractionEnabled = true
        }
        
        else {
            
            if imageView?.gestureRecognizers != nil {
                
                for g in imageView!.gestureRecognizers! {
                    
                    imageView?.removeGestureRecognizer(g)
                }
            }
        }
        
        cell.tag = indexPath.item
        
        return cell
    }
    
    
    func showImage(_ sender: UIGestureRecognizer) {
        
        let imageInfo = JTSImageInfo()
        
        imageInfo.image = (sender.view as! PFImageView).image!
        
        imageInfo.referenceView = self.view
        
        imageInfo.referenceRect = sender.view!.bounds
        
        
        let view = sender.view!.superview!
        
        let cell = view.superview
        
        self.selectedCellTag = cell!.tag
        
        
        let viewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.image, backgroundStyle: .blurred)
        
        viewer?.interactionsDelegate = self
        
        viewer?.show(from: self, transition: .fromOriginalPosition)
    }
    
    
    var selectedCellTag: Int!
    
    
    func imageViewerDidLongPress(_ imageViewer: JTSImageViewController!, at rect: CGRect) {
        
        let alert = UIAlertController(title: "Delete", message: "Would you like to delete this image from this location?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
            
            self.dismiss(animated: true, completion: nil)
            
            let item = self.selectedCellTag
            
            self.arrayPhotos[item!].deleteInBackground()
            
            self.arrayPhotos.remove(at: item!)
            
            if self.arrayPhotos.isEmpty {
                
                self.collectionViewPhotos.reloadData()
            }
            
            else {
                
                self.collectionViewPhotos.deleteItems(at: [IndexPath(item: item!, section: 0)])
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        imageViewer.present(alert, animated: true, completion: nil)
    }

    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView.isEqual(self.tableView) {
            
            return
        }
        
        //self.setUpArrowButtonsVisibility()
    }
    
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        if scrollView.isEqual(self.tableView) {
            
            return
        }
        
        //self.setUpArrowButtonsVisibility()
    }
    
    func automaticHashtagForActivities (_ sender: UITextField) {
        
        var text = sender.text
        
        if text == nil {
            
            return
        }
        
        if text == "" {
            
            return
        }
        
        if text?.characters.first != "#" {
            
            text!.insert("#", at: text!.characters.startIndex)
        }
        
        text = text?.replacingOccurrences(of: " ", with: "#")
        text = text?.replacingOccurrences(of: "##", with: "#")
        
        sender.text = text
    }
    
    
    
    func alertViewShouldEnableFirstOtherButton (_ alert: UIAlertController) -> Bool {
        
        return alert.textFields?[0].text?.whiteSpaceTrimmedString.characters.count > 0
    }
    

    @IBAction func buttonAddActivityPressed (_ sender: UIButton) {
        
        let addActivityAlert = self.storyboard?.instantiateViewController(withIdentifier: "CustomAlertController") as! CustomAlertController
        
        addActivityAlert.modalPresentationStyle = .overFullScreen
        
        addActivityAlert.view.backgroundColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 0.75)
        
        
        let nav = UINavigationController(rootViewController: addActivityAlert)
        
        nav.modalPresentationStyle = .overFullScreen
        
        nav.view.backgroundColor = UIColor.clear
        
        addActivityAlert.delegate = self
        
        addActivityAlert.viewTitle = "Add Activity"
        
        addActivityAlert.textFieldPlaceHolder = "#Activity"
        
        addActivityAlert.confirmButtonTitle = "Post Activity!"
        
        addActivityAlert.globalColour = UIColor.lightGray
        
        addActivityAlert.textField.addTarget(self, action: #selector(LocationDetailViewController.automaticHashtagForActivities(_:)), for: .editingChanged)
        
        self.alertType = .activity
        
        self.present(nav, animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func buttonWriteReviewPressed (_ sender: Any) {
        
        let addReviewAlert = self.storyboard?.instantiateViewController(withIdentifier: "CustomAlertController") as! CustomAlertController
        
        addReviewAlert.modalPresentationStyle = .overFullScreen
        
        addReviewAlert.view.backgroundColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 0.75)

        
        let nav = UINavigationController(rootViewController: addReviewAlert)
        
        nav.modalPresentationStyle = .overFullScreen
        
        nav.view.backgroundColor = UIColor.clear
        
        addReviewAlert.delegate = self
        
        addReviewAlert.viewTitle = "Add Review"
        
        addReviewAlert.textFieldPlaceHolder = "Min 5 characters..."
        
        addReviewAlert.confirmButtonTitle = "Post Review!"
        
        addReviewAlert.globalColour = UIColor.lightGray
        
        self.alertType = .review
        
        self.present(nav, animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func buttonReportProblem (_ sender: Any) {
        
        let alert = self.storyboard?.instantiateViewController(withIdentifier: "CustomAlertController") as! CustomAlertController
        
        alert.modalPresentationStyle = .overFullScreen
        
        alert.view.backgroundColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 0.75)
        
        
        let nav = UINavigationController(rootViewController: alert)
        
        nav.modalPresentationStyle = .overFullScreen
        
        nav.view.backgroundColor = UIColor.clear
        
        alert.delegate = self
        
        alert.globalColour = UIColor.lightGray
        alert.viewTitle = "Report"
        alert.textFieldPlaceHolder = "Your issue"
        alert.confirmButtonTitle = "Send"
        
        self.alertType = .report
        
        self.present(nav, animated: true, completion: nil)
    }
    
    
    @IBAction func findAddressInMaps () {
        
        let latitute:CLLocationDegrees =  self.location!.getGeoPointLocation().latitude
        let longitute:CLLocationDegrees =  self.location!.getGeoPointLocation().longitude
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(self.title)"
        mapItem.openInMaps(launchOptions: options)
    }
    
    
    @IBAction func buttonAddPhotoPressed (_ sender: Any) {
        
        appDelegate.showActionSheetWithTitles(self)
    }
    
    @IBAction func buttonBackPressed (_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buttonLeftArrowPressed (_ sender: Any) {
        
        let iPath = collectionViewPhotos.indexPathForItem(at: CGPoint(x: SCREEN_WIDTH / 2,
            y: collectionViewPhotos.height / 2))
        
        if iPath != nil && iPath?.item != 0 {
            
            self.collectionViewPhotos.scrollToItem(at: IndexPath(item: -1, section: 0), at: .left, animated: true)
            
            //self.setUpArrowButtonsVisibility()
        }
    }
    
    @IBAction func buttonRightArrowPressed (_ sender: Any) {
     
        let iPath = collectionViewPhotos.indexPathForItem(at: CGPoint(x: SCREEN_WIDTH / 2,
            y: collectionViewPhotos.height / 2))
        
        if iPath != nil && iPath?.item != arrayPhotos.count - 1 {
            
            self.collectionViewPhotos.scrollToItem(at: IndexPath(item: iPath!.item + 1, section: 0), at: .left, animated: true)
            
            //self.setUpArrowButtonsVisibility()
        }
    }
    
    
    func customAlertController(didConfirmEntry text: String) {
        
        var strText = text.whiteSpaceTrimmedString
        
        if self.alertType == .review {
            
            if strText.characters.count > 0 {
                
                appDelegate.startLoadingView()
                
                let comment = CCComment()
                
                comment.commentLocation = self.location!
                comment.commentor = CURRENT_USER!
                comment.strCommentText = strText
                
                comment.saveInBackground(block: { (success, error) -> Void in
                    
                    self.fetchComments()
                })
            }
        }
        
        else if self.alertType == .activity {
            
            
            if strText.characters.count > 0 {
                
                
                if strText.characters.last! == "#" {
                    
                    strText.remove(at: strText.characters.index(before: strText.characters.endIndex))
                }
                
                var hashtags = [String]()
                
                let array = strText.components(separatedBy: "#")
                
                
                for word in array {
                    
                    var newWord = word
                    
                    var canAppend: Bool
                    
                    newWord = newWord.replacingOccurrences(of: "#", with: "")
                    
                    canAppend = newWord == "" ? false : true
                    
                    
                    if canAppend {
                        
                        newWord.insert("#", at: newWord.characters.startIndex)
                        
                        hashtags.append(newWord)
                    }
                }
                
                if self.location?.strLocationActivities != nil {
                    
                    self.location?.strLocationActivities.append(contentsOf: hashtags)
                }
                    
                else {
                    
                    self.location?.strLocationActivities = hashtags
                }
                
                self.location?.saveEventually()
                
                self.activitiesCell.activities.append(contentsOf: hashtags)
                
                self.activitiesCell.tableView.reloadData()
            }
        }
        
        else if self.alertType == .report {
            
            let report = PFObject(className: "CCReportLocation")
            
            report.setValue(self.location!, forKey: "location")
            
            report.setValue(CURRENT_USER!, forKey: "ReportedBy")
            
            report.setValue(text.whiteSpaceTrimmedString, forKey: "text")
            
            report.saveEventually()
            
            let alert = UIAlertController(title: "Thank you for reporting the issue. We will handle this problem as soon as possible", message: "", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
            
        else {
            
            if strText.characters.count > 0 {
                
                self.location?.strLocationName = strText
                
                self.location?.saveEventually()
                
                self.navigationItem.titleView?.setNeedsLayout()
                
                self.navigationItem.titleView?.setNeedsDisplay()
                
                self.titleText.setTitle(strText, for: UIControlState())
                
                self.navigationItem.titleView?.sizeToFit()
            }
        }
    }
    
    
    func customAlertController(didCancelWithCompletion completed: Bool) {
        
        
    }
    
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
            let chosenImage = info[UIImagePickerControllerOriginalImage]
            
            appDelegate.startLoadingView()
            
        do {
            
            let file = try PFFile(name: "image", data: UIImageJPEGRepresentation(chosenImage as! UIImage, 0.5)!, contentType: "image/jpeg")
            
            file.saveInBackground(block: { (success, error) -> Void in
                
                if success {
                    
                    let photo = CCPhoto()
                    
                    photo.photoFile = file
                    photo.photoUploader = CURRENT_USER!
                    photo.photoLocation = self.location!
                    
                    photo.saveInBackground(block: { (success, error) -> Void in
                        
                        if success {
                            
                            self.fetchImages()
                        }
                    })
                }
                    
                else {
                    
                    appDelegate.stopLoadingView()
                    appDelegate.showAlertWithMessage(error!.localizedDescription)
                }
            })
        }
        
        catch _ {}
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: nil)
    }

    
    /*func setUpArrowButtonsVisibility() {
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(LocationDetailViewController.changeVisibilityOfButtons), userInfo: nil, repeats: false)
        
        timer.fire()
    }
    
    func changeVisibilityOfButtons () {
        
        let iPath = self.collectionViewPhotos.indexPathForItemAtPoint(CGPoint(x: collectionViewPhotos.width / 2, y: collectionViewPhotos.height / 2))
        
        if iPath?.item == 0 {
         
            buttonLeftArrow.hidden = true
            buttonRightArrow.hidden = self.arrayPhotos.count <= 1
        }
        
        else if iPath?.item == self.arrayPhotos.count - 1 {
            
            buttonRightArrow.hidden = true
            buttonLeftArrow.hidden = self.arrayPhotos.count <= 1
        }
        
        if self.arrayPhotos.count <= 1 {
            
            buttonLeftArrow.hidden = true
            buttonRightArrow.hidden = true
        }
        
        buttonLeftArrow.hidden = false
        buttonRightArrow.hidden = false
        buttonLeftArrow.userInteractionEnabled = false
        buttonRightArrow.userInteractionEnabled = false
    }*/
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        
        view.backgroundColor = .clear
        
        view.frame = CGRect.zero
        
        return view
    }
    
    /*override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        if self.location?.expiryDate == nil && self.location?.startDate == nil {
            
            if indexPath.row == 0 {
                
                cell = super.tableView(tableView, cellForRowAt: IndexPath(row: indexPath.row + 3, section: 0))
            }
            
            else if indexPath.row == 1 {
                
                cell = super.tableView(tableView, cellForRowAt: IndexPath(row: indexPath.row + 2, section: 0))
            }
            
            else {
                
                cell = super.tableView(tableView, cellForRowAt: IndexPath(row: indexPath.row + 1, section: 0))
            }
            
            return cell
        }
        
        return super.tableView(tableView, cellForRowAt: indexPath)
    }*/
    
    func showCommentsTable (_ sender: Any) {
        
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "CCLocationDetailReviews") as! CCLocationDetailReviews
        
        popoverContent.modalPresentationStyle = .overFullScreen
        
        popoverContent.view.backgroundColor = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 0.85)
        
        popoverContent.reviews = self.arrayComments as! [CCComment]
        
        popoverContent.canEditReviews = self.canEditLocation
        
        let nav = UINavigationController(rootViewController: popoverContent)
        
        nav.view.backgroundColor = .clear
        
        nav.modalPresentationStyle = .overFullScreen
        
        self.present(nav, animated: true, completion: nil)
    }
    
    func showThirdStepInTutorial () {
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "ShowTutorial3") != true {
            
            userDefaults.set(true, forKey: "ShowTutorial3")
            
            userDefaults.synchronize()
            
            
            let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "StepFive") as! StepFourTutorialVC
            
            popoverContent.modalPresentationStyle = .overFullScreen
            
            popoverContent.view.backgroundColor = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 0.9)
            
            self.present(popoverContent, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func favouritesButtonPressed (_ sender: Any) {
        
        //This means the state will go from favourited to unfavourited. So remove 1
        /*if self.favouriteButton.currentState == FavouriteButtonState.Favourited {
            
            let text = self.amountOfFavourites.text!.stringByReplacingOccurrencesOfString(" ", withString: "")
            
            var amount = Int(text)!
            
            amount -= 1
            
            self.amountOfFavourites.text = String(amount)
        }
        
        //State will go from unfavourited to favourited. So increment
        else {
            
            let text = self.amountOfFavourites.text!.stringByReplacingOccurrencesOfString(" ", withString: "")
            
            var amount = Int(text)!
            
            amount += 1
            
            self.amountOfFavourites.text = String(amount)
        }
        
        self.favouriteButton.toggleState()
        
        let manager = CCLocationRatingsManager(location: self.location!)
        
        manager.toggleFavourites { (didAdd, error) -> Void in
            
            if didAdd {
                
                //self.favouriteButton.changeToState(toState: FavouriteButtonState.Favourited)
            }
            
            else {
                
                //self.favouriteButton.changeToState(toState: FavouriteButtonState.NotFavourited)
            }
        }*/
    }
    
    
    @IBAction func shareLocation (_ sender: Any) {
        
        let s = "Goojess app\n\nCheck out my location at coordinates \(self.location!.getGeoPointLocation().latitude, self.location!.getGeoPointLocation().longitude) in Goojess!"
        
        
        let image: UIImage? = self.shareImage != nil ? self.textToImage("Goojess", inImage: self.shareImage!, atPoint: CGPoint(x: 10, y: 10)) : nil
        
        let items:[AnyObject] = image == nil ? [s as AnyObject] : [image as AnyObject, s as AnyObject]
        
        appDelegate.startLoadingView()
        
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let queue = DispatchQueue.global(qos: qualityOfServiceClass)
        
        queue.async { () -> Void in
            
            let activityView = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            activityView.excludedActivityTypes = [UIActivityType.addToReadingList, UIActivityType.openInIBooks, UIActivityType.assignToContact, UIActivityType.postToTencentWeibo, UIActivityType.postToVimeo, UIActivityType.saveToCameraRoll, UIActivityType.postToFlickr, UIActivityType.print]
            
            DispatchQueue.main.async(execute: { () -> Void in
                
                appDelegate.stopLoadingView()
                
                self.present(activityView, animated: true, completion: nil)
            })
        }
    }
    
    
    func copyCoordinates (_ sender: Any) {
     
        let point = self.location?.getGeoPointLocation()
        
        let pasteboard = UIPasteboard.general
        
        pasteboard.string = "\(point!.latitude), \(point!.longitude)"
        
        let window = UIApplication.shared.keyWindow!
        
        let label = UILabel()
        
        label.text = "Copied!"
        
        label.textAlignment = .center
        
        label.textColor = UIColor.white
        
        label.backgroundColor = UIColor.darkGray
        
        label.font = UIFont.systemFont(ofSize: 15)
        
        label.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height)
        
        window.addSubview(label)
        
        window.bringSubview(toFront: label)
        
        UIView.animate(withDuration: 3, animations: { () -> Void in
            
            label.alpha = 0
            
            }, completion: { (done) -> Void in
                
                if done {
                    
                    label.removeFromSuperview()
                }
        }) 
    }
    
    
    @IBAction func addEventToCalendar(_ sender: Any) {
        
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
        
        event.title = self.location!.strLocationName
        event.startDate = self.location!.startDate
        event.endDate = self.location!.expiryDate
        event.calendar = calendar
        
        appDelegate.startLoadingView()
        
        let coder = CLGeocoder()
        let location = CLLocation(latitude: self.location!.geoPointLocation.latitude, longitude: self.location!.geoPointLocation.longitude)
        
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
            
            self.addToCalendarButton.setImage(nil, for: .normal)
            self.addToCalendarButton.setTitle("Added", for: .normal)
            self.addToCalendarButton.isEnabled = false
            
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
    
    
    @IBAction func toggleParticipation(_ sender: Any) {
        
        self.participationButton.toggleState()
        
        self.participationButton.isEnabled = false
        
        if self.participantObject != nil {
            
            self.isGoingToEvent = false
            
            PFObject.deleteAll(inBackground: [self.participantObject!.generatedPost, self.participantObject!], block: { (success, error) in
                
                if success {
                    
                    self.isGoingToEvent = true
                    
                    self.participantObject = nil
                    
                    self.participationButton.isEnabled = true
                    
                } else {
                    
                    self.participationButton.isEnabled = true
                    self.participationButton.toggleState()
                }
            })
            
        }
            
        else {
            
            let newPost = CCTimelinePost()
            
            newPost.location = self.location
            newPost.targetUsers = [CCUser.current()!]
            newPost.poster = CCUser.current()!
            newPost.postType = 3
            
            let newParticipant = CCParticipant()
            
            newParticipant.event = self.location
            newParticipant.user = CCUser.current()
            newParticipant.generatedPost = newPost
            
            PFObject.saveAll(inBackground: [newPost, newParticipant], block: { (success, error) in
                
                if success {
                    
                    self.isGoingToEvent = true
                    
                    self.participationButton.isEnabled = true
                    
                    self.participantObject = newParticipant
                    
                } else {
                    
                    self.participationButton.isEnabled = true
                    self.participationButton.toggleState()
                }
            })
        }
    }
    
    func fetchEventParticipationObject() {
        
        let query = CCParticipant.query()
        
        query?.whereKey("event", equalTo: self.location!)
        query?.whereKey("user", equalTo: CCUser.current()!)
        
        query?.getFirstObjectInBackground(block: { (object, error) in
            
            if object == nil {
                
                self.isGoingToEvent = false
                
                self.participationButton.enableButton(toState: .notParticipating)
                
                print("ERROR: \(error)")
            }
                
            else {
                
                self.isGoingToEvent = true
                
                self.participantObject = object as? CCParticipant
                
                self.participationButton.enableButton(toState: .participating)
            }
        })
        
        let newQuery = CCParticipant.query()
        
        newQuery?.whereKey("event", equalTo: self.location!)
        
        newQuery?.countObjectsInBackground(block: { (amount, error) in
            
            guard error == nil else {
                
                self.amountOfParticipantsLabel.text = "0 people are going"
                
                return
            }
            
            self.amountOfParticipantsLabel.text = "\(amount) people are going"
        })
    }
    

    
    
    func textToImage(_ drawText: NSString, inImage: UIImage, atPoint:CGPoint) -> UIImage{
        
        // Setup the font specific variables
        let textColor: UIColor = UIColor.white
        let textFont: UIFont = UIFont.systemFont(ofSize: 16)
        
        //Setup the image context using the passed image.
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)
        
        //Setups up the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
        ]
        
        //Put the image into a rectangle as large as the original image.
        inImage.draw(in: CGRect(x: 0, y: 0, width: inImage.size.width, height: inImage.size.height))
        
        // Creating a point within the space that is as bit as the image.
        let rect: CGRect = CGRect(x: atPoint.x, y: atPoint.y, width: inImage.size.width, height: inImage.size.height)
        
        //Now Draw the text into an image.
        drawText.draw(in: rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //And pass it back up to the caller.
        return newImage
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? LocationAddressPicker {
            
            vc.location = self.location!
        }
    }
}


