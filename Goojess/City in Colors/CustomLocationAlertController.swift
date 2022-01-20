//
//  CustomAlertController.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import UIKit
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


protocol CustomLocationAlertControllerDelegate {
    
    func customLocationAlertController(locationName name: String, locationActivities activities: [String], locationDescription description: String, locationCategory category: Float, locationImage image: UIImage?)
    
    func customLocationAlertControllerDidCancel()
}

class CustomLocationAlertController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let hashtagBlue = UIColor(red: 0, green: 128/255, blue: 1, alpha: 1)
    
    //Gives the heads up for the creation of location to take place by verifying text fields.
    var validated: Bool = false
    
    @IBOutlet weak var locationName: TextField!
    @IBOutlet weak var locationMainActivity: TextField!
    @IBOutlet weak var locationDescription: TextField!
    
    @IBOutlet weak var locationImage: UIImageView!
    
    @IBOutlet weak var createLocationButtonBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var selectCategoryButton: UIButton!
    
    @IBOutlet weak var selectImageButton: UIButton!
    
    var categoryButtonColor: UIColor!
    
    var hashtags = [String]()
    
    var imagePicker: UIImagePickerController!
    
    var delegate: CustomLocationAlertControllerDelegate!
    
    
    //NEW     
    let categoryUtility = CCCategories()
    
    var category: Float?
    
    var preloadedImage: UIImage!
    //
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categoryButtonColor = selectCategoryButton.titleLabel?.textColor
        
        imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        if preloadedImage != nil {
            
            self.locationImage.isHidden = true
            self.selectImageButton.isHidden = true
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? SelectLocationCategory {
            
            vc.selectedCategory = category
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CustomLocationAlertController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        self.setUpNavigationBar()
        
        self.configureTextFields()
        
        self.locationImage.layer.masksToBounds = true
        
        self.locationImage.layer.cornerRadius = self.locationImage.bounds.width/2
    }


    
    func dismissView () {
        
        delegate.customLocationAlertControllerDidCancel()
     
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func createLocation (_ sender: Any) {
        
        if !(self.locationName.text?.characters.count > 1) {
            
            let label = UILabel()
            
            let labelSize = self.locationName.frame.height
            
            label.frame = CGRect(x: 0, y: 0, width: labelSize, height: labelSize)
            
            label.text = "⚠️"
            
            self.locationName.rightViewMode = UITextFieldViewMode.always
            
            self.locationName.rightView = label
            
            self.locationName.placeholder = "Please enter a valid location name"
            
            self.validated = false
        }
        
        else if !(self.locationMainActivity.text?.characters.count > 2) {
            
            let label = UILabel()
            
            let labelSize = self.locationMainActivity.frame.height
            
            label.frame = CGRect(x: 0, y: 0, width: labelSize, height: labelSize)
            label.text = "⚠️"
            
            self.locationMainActivity.rightViewMode = UITextFieldViewMode.always
            self.locationMainActivity.rightView = label
            
            self.locationMainActivity.placeholder = "Please enter a valid activity"
            
            self.validated = false
        }
        
        else if !(self.locationDescription.text?.characters.count > 4) {
            
            let label = UILabel()
            
            let labelSize = self.locationMainActivity.frame.height
            
            label.frame = CGRect(x: 0, y: 0, width: labelSize, height: labelSize)
            label.text = "⚠️"
            
            self.locationDescription.rightViewMode = UITextFieldViewMode.always
            self.locationDescription.rightView = label
            
            self.locationDescription.placeholder = "Min. 4 characters"
            
            self.validated = false
        }
            
        else if self.category == nil {
            
            self.selectCategoryButton.setTitleColor(UIColor.red, for: UIControlState())
            
            self.validated = false
        }
            
        else {
            
            self.validated = true
        }
        
        
        
        if !validated {
            
            return
        }
        
        
        if self.locationMainActivity.text!.characters.last! == "#" {
         
            self.locationMainActivity.text!.remove(at: self.locationMainActivity.text!.characters.index(before: self.locationMainActivity.text!.characters.endIndex))
        }
        
        
        let array = self.locationMainActivity.text!.components(separatedBy: "#")
        
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
        
        var finalImage: UIImage!
        
        if preloadedImage != nil {
            
            finalImage = preloadedImage
        }
            
        else {
            
            finalImage = self.locationImage.image
        }
        
        delegate.customLocationAlertController(locationName: self.locationName.text!, locationActivities: self.hashtags, locationDescription: self.locationDescription.text!, locationCategory: self.category!, locationImage: finalImage)
        
        dismissView()
    }
    
    
    func setUpNavigationBar () {
        
        self.navigationController?.navigationBar.barStyle = .black
        
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissView))
        
        self.navigationItem.leftBarButtonItem = cancel
        
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 13), NSBackgroundColorAttributeName: UIColor.lightGray], for: UIControlState())
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16), NSBackgroundColorAttributeName: UIColor.lightGray]
        
        self.navigationController?.navigationBar.barTintColor = UIColor.lightGray
        
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    
    func configureTextFields () {
        
        self.locationMainActivity.addTarget(self, action: #selector(CustomLocationAlertController.hashtagFormat(_:)), for: .editingChanged)
        
        self.locationMainActivity.placeholder = "#Activities ex. #Sunset #Shopping"
        
        self.locationDescription.keyboardAppearance = .dark
        self.locationName.keyboardAppearance = .dark
        self.locationMainActivity.keyboardAppearance = .dark
        
        self.locationName.becomeFirstResponder()
    }
    
    
    func hashtagFormat (_ sender: UITextField) {
        
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
    
    
    @IBAction func uploadImage(_ sender: Any) {
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.locationImage.image = image
        
        self.imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.imagePicker.dismiss(animated: true, completion: nil)
    }

    
    
    
    
    func keyboardWillShow(_ notification: Notification) {
        
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        self.createLocationButtonBottomConstraint.constant = frame.height
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            
            self.view.setNeedsLayout()
        }) 
    }
    
    @IBAction func unwindFromCategorySelector (_ segue: UIStoryboardSegue) {
        
        if let c = category {
            
            selectCategoryButton.setTitleColor(categoryButtonColor, for: .normal)
            
            selectCategoryButton.setTitle(categoryUtility.fetchCategoryFromFloat(c), for: UIControlState())
        }
    }
}
