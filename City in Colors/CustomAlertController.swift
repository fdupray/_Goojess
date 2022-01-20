//
//  CustomAlertController.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import UIKit

protocol CustomAlertControllerDelegate {
    
    func customAlertController(didCancelWithCompletion completed: Bool)
    func customAlertController(didConfirmEntry text: String)
}

class CustomAlertController: CCViewController {
    
    ///Select a colour that contrasts with white.
    var globalColour: UIColor?
    
    ///Title of the view controller.
    var viewTitle: String?
    
    ///Alerts text field placeholder.
    var textFieldPlaceHolder: String?
    
    ///Title of button that will confirm the alert action.
    var confirmButtonTitle: String?
    
    //Text within text field.
    var textFieldText: String?
    
    @IBOutlet weak var textField: TextField!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var confirmButtonConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var separatorLine: UIView!
    
    
    
    @IBAction func pressedConfirmButton (_ sender: Any) { self.dismiss(animated: true) { () -> Void in
        
            self.delegate.customAlertController(didConfirmEntry: self.textField.text!)
        }
    }
    
    
    var delegate: CustomAlertControllerDelegate!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CustomAlertController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        self.configureView(self.viewTitle, placeholder: self.textFieldPlaceHolder, buttonTitle: self.confirmButtonTitle, globalColor: self.globalColour, text: self.textFieldText)
        
        self.setUpNavigationBar()
        
        self.configureViewColours(self.globalColour == nil ? UIColor.white : self.globalColour!)
        
        self.textField.becomeFirstResponder()
    }
    
    
    func configureView (_ title: String?, placeholder: String?, buttonTitle: String?, globalColor: UIColor?, text: String?) {
        
        self.title = title
        
        self.textField.placeholder = placeholder
        
        self.confirmButton.setTitle(buttonTitle, for: UIControlState())
        
        self.globalColour = globalColor
        
        self.textField.text = text
    }
    
    
    func setUpNavigationBar () {
        
        self.navigationController?.navigationBar.barStyle = .black
        
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissView))
        
        self.navigationItem.leftBarButtonItem = cancel
    }
    
    
    func configureViewColours (_ globalColour: UIColor) {
        
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 13), NSBackgroundColorAttributeName: UIColor.lightGray], for: UIControlState())
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16), NSBackgroundColorAttributeName: UIColor.lightGray]
        
        self.navigationController?.navigationBar.barTintColor = globalColour
        
        self.navigationController?.navigationBar.tintColor = .white
        
        self.confirmButton.backgroundColor = globalColour
        
        self.separatorLine.backgroundColor = globalColour
    }
    
    
    func dismissView () {
        
        self.dismiss(animated: true) { () -> Void in
            
            self.delegate.customAlertController(didCancelWithCompletion: true)
        }
    }
    
    
    func keyboardWillShow(_ notification: Notification) {
        
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        self.confirmButtonConstraint.constant = frame.height
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            
            self.view.setNeedsLayout()
        }) 
    }
}
