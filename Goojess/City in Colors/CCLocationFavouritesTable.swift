//
//  CCLocationFavouritesTable.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import UIKit
import MapKit

class CCLocationFavouritesTable: UITableViewController {//FavouriteRefreshDelegate {

    
    var viewTitle: String!
    
    var favourite = [CCLocation]()
    
    var isCurrentUser = false
    
    var location: CCLocation!
    
    var parentController: ProfileView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //parentController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "\(self.viewTitle)s favourites"
        
        tableView.reloadData()
        
        let fontSize: CGFloat = 18
        
        let attributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: fontSize)!]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        self.navigationController?.navigationBar.barTintColor = cityInColorRed
        
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 14)!], for: UIControlState())
    }
    
    
    func refreshFavourites() {
        
        tableView.reloadData()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationFavouritesTableCell")
        
        if self.favourite.isEmpty {
            
            cell?.accessoryType = .none
            
            cell?.textLabel?.text = "No Locations"
        }
        
        else {
            
            let location = favourite[indexPath.row]
            
            cell?.accessoryType = .disclosureIndicator
            
            cell?.textLabel?.text = location.strLocationName!
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.location = favourite[indexPath.row]
        self.performSegue(withIdentifier: "showLocationDetail", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.favourite.isEmpty {
            
            return 1
        }
        
        return self.favourite.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showLocationDetail" {
            
            let vc = segue.destination as! LocationDetailViewController
            
            vc.location = self.location
        }
    }
    
    @IBAction func back (_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
}
