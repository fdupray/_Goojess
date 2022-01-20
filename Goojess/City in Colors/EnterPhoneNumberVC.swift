//
//  EnterPhoneNumberVC.swift
//  Goojess
//
//  Created by Simon Blomqvist on 2017-04-15.
//  Copyright © 2017 Carman. All rights reserved.
//

import UIKit
import libPhoneNumber_iOS.NBPhoneNumberUtil
import libPhoneNumber_iOS.NBPhoneNumber
import libPhoneNumber_iOS.NBAsYouTypeFormatter

class EnterPhoneNumberVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var countryTableView: UITableView!
    
    @IBOutlet weak var selectCountryButton: UIButton!
    
    var selectedRegion: String?
    
    let phoneUtil = NBPhoneNumberUtil()
    
    //[Country: Code]
    var regions = [String: String]()
    
    var sortedRegions: [(String, String)]!
    
    var phoneNumbers: [String]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countryTableView.delegate = self
        countryTableView.dataSource = self
        
        textField.becomeFirstResponder()
        textField.keyboardAppearance = .default
        
        let codes = Locale.isoRegionCodes
        
        for code in codes {
            
            let identifier = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            
            //Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            
            let country = (Locale.current as NSLocale).displayName(forKey: NSLocale.Key.identifier, value: identifier)
            
            //(Locale.current as NSLocale).displayName(forKey: NSLocale.Key.identifier, value: identifier)
            
            regions[country!] = code
        }
        
        sortedRegions = regions.sorted{$0.0 < $1.0}
        
        countryTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func cancelProcess(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    

    
    func invalidNumberAlert() {
        
        let alert = UIAlertController(title: "Please Select Country code", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func submitForVerfication(_ sender: Any) {
        
        guard selectedRegion != nil else {
            
            invalidNumberAlert()
            
            return
        }
        
        let userNumber = textField.text!.replacingOccurrences(of: " ", with: "")
        
        self.phoneNumbers = [String]()
        
        self.phoneNumbers.append(userNumber)
        
        let formats: [NBEPhoneNumberFormat] = [NBEPhoneNumberFormat.E164, NBEPhoneNumberFormat.INTERNATIONAL,NBEPhoneNumberFormat.NATIONAL, NBEPhoneNumberFormat.RFC3966]
        
        do {
            
            let number = try phoneUtil.parse(userNumber
                , defaultRegion: selectedRegion!)
            
            for format in formats {
                
                let formattedNumber = try phoneUtil.format(number, numberFormat: format)
                
                self.phoneNumbers.append(formattedNumber)
            }
            
            self.performSegue(withIdentifier: "ToConfirmation", sender: self)
            
        } catch _ {
            
        }
    }
    
    @IBAction func toCountrySelection(_ sender: Any) {
        
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sortedRegions.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = countryTableView.dequeueReusableCell(withIdentifier: "CountryCell")!
        
        cell.textLabel?.text = self.sortedRegions[indexPath.row].0
        
        if cell.isSelected == false {
            
            cell.accessoryType = .none
            
            cell.textLabel?.textColor = UIColor.black
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedRegion = self.sortedRegions[indexPath.row].1
        
        self.selectCountryButton.setTitle(self.sortedRegions[indexPath.row].0, for: UIControlState())
        
        self.countryTableView.reloadData()
        
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.accessoryType = .checkmark
        
        cell?.textLabel?.textColor = UIColor.green
        
        textField.becomeFirstResponder()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? PhoneNumberConfirmation {
            
            vc.phoneNumberFormats = phoneNumbers
        }
    }
}
