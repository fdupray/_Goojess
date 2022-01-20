//
//  MapCategoryFilter.swift
//  Goojess
//
//  Created by Simon Blomqvist on 2017-04-15.
//  Copyright © 2017 Carman. All rights reserved.
//

import UIKit

class MapCategoryFilter: UITableViewController {
    
    let categories = CCCategories()
    
    let cellReuseId = "CategoryCell"
    
    var selectedCategories: [Float]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = false
        
        self.navigationController?.isNavigationBarHidden = false
        
        let saveButton = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(saveFilters))
        
        self.navigationItem.leftBarButtonItem = saveButton
        
        self.tableView.allowsMultipleSelection = true
    }
    
    func saveFilters () {
        
        print("CALLED FUNCTION")
        
        self.performSegue(withIdentifier: "backToMap", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let map = segue.destination as? MapViewController {
            
            map.filterCategories = self.selectedCategories
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
        
        
        //Compare text to user interests
        if selectedCategories.contains(categoryTuple.0) {
            
            cell?.accessoryType = .checkmark
            cell?.setSelected(true, animated: false)
        }
            
        else {
            
            cell?.accessoryType = .none
            cell?.setSelected(false, animated: false)
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return categories.fetchCategoryNameForIndex(section)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        let category = categories.fetchCategories()[indexPath.section][indexPath.row].0
        
        let index = selectedCategories.index(where: {$0 == category})
        
        guard index == nil else {
            
            selectedCategories.remove(at: index!)
            
            cell?.accessoryType = .none
            
            cell?.setSelected(false, animated: true)
            
            return
        }
        
        cell?.accessoryType = .checkmark
        
        selectedCategories.append(category)
        
        print(selectedCategories)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.accessoryType = .none
        
        let category = categories.fetchCategories()[indexPath.section][indexPath.row].0
        
        let index = selectedCategories.index(where: {$0 == category})
        
        selectedCategories.remove(at: index!)
        
        print(selectedCategories)
    }
    
}
