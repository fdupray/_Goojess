//
//  LocationAddressPicker.swift
//  Goojess
//
//  Created by Simon Blomqvist on 2017-04-21.
//  Copyright © 2017 Carman. All rights reserved.
//

import UIKit
import GooglePlaces

class LocationAddressPicker: UITableViewController,UISearchResultsUpdating {
    
    let reuseID =  "LocationCell"
    
    var searchController = UISearchController(searchResultsController: nil)
    
    var results = [GMSAutocompletePrediction]()
    
    lazy var googlePlaces = {
        
        return GMSPlacesClient.shared()
    }
    
    var location: CCLocation!
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
        self.googlePlaces().autocompleteQuery(searchController.searchBar.text!, bounds: nil, filter: nil) { (predictions, error) in
            
            guard predictions != nil else {
                
                return
            }
            
            self.results = predictions!
            
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        
        searchController.searchBar.placeholder = "Enter new address"
        
        if location.geoPointLocationAddress != nil {
            
            searchController.searchBar.text = location.geoPointLocationAddress!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return results.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)
        
        let item = self.results[indexPath.row]

        cell.textLabel?.text = item.attributedFullText.string

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let placemark = self.results[indexPath.row]
        
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

            
            let point = PFGeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            self.location.geoPointLocation = point
            self.location.geoPointLocationAddress = placemark.attributedFullText.string
            
            
            self.location.saveInBackground { (success, error) in
                
                appDelegate.stopLoadingView()
                
                if success {
                    
                    self.navigationController?.popViewController(animated: true)
                }
                    
                else {
                    
                    appDelegate.showAlertWithMessage("\(String(describing: error?.localizedDescription))")
                }
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
