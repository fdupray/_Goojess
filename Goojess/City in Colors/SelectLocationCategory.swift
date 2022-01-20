//
//  SelectLocationCategory.swift
//  Goojess
//
//  Created by Simon Blomqvist on 2017-04-15.
//  Copyright © 2017 Carman. All rights reserved.
//

import UIKit

class SelectLocationCategory: UITableViewController {
    
    let categories = CCCategories()
    
    let cellReuseId = "LocationCategoryCell"
    
    var selectedCategory: Float!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let locAlert = segue.destination as? CustomLocationAlertController {
            
            locAlert.category = selectedCategory
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return categories.fetchCategories().count
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories.fetchCategories()[section].count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId)
        
        if cell == nil {
            
            cell = UITableViewCell(style: .default, reuseIdentifier: cellReuseId)
        }
        
        cell?.selectionStyle = .none
        
        let categoryTuple = categories.fetchCategories()[indexPath.section][indexPath.row]
        
        cell!.textLabel?.text = categoryTuple.1
        
        if let cat = selectedCategory {
            
            if categoryTuple.0 == cat {
                
                cell?.accessoryType = .checkmark
            }
        }
            
        else {
            
            cell?.accessoryType = .none
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return categories.fetchCategoryNameForIndex(section)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("SELECTED")
        
        let category = categories.fetchCategories()[indexPath.section][indexPath.row].0
        
        selectedCategory = category
        
        DispatchQueue.main.async {
            
            self.performSegue(withIdentifier: "backToLocationAlert", sender: self)
        }
    }
}
