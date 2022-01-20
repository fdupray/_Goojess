//
//  UserInterestsSelection.swift
//  Goojess
//
//  Created by Simon Blomqvist on 2017-04-15.
//  Copyright © 2017 Carman. All rights reserved.
//

import UIKit

class UserInterestsSelection: UITableViewController {
    
    let categories = CCCategories()
    
    let cellReuseId = "UserCategoryCell"
    
    //Avoid unnecessary network call
    let interests = CCUser.current()!.userInterests
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelection = true
        self.clearsSelectionOnViewWillAppear = true
        
        if CCUser.current()?.userInterests == nil {
            
            CCUser.current()?.userInterests = [Float]()
            
            CCUser.current()?.saveEventually()
        }
        
        self.navigationItem.title = "Categories"
        
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(UserInterestsSelection.saveInterests))
        
        self.navigationItem.leftBarButtonItem = saveButton
    }
    
    
    func saveInterests () {
        
        CCUser.current()?.saveEventually()
        
        self.navigationController?.popViewController(animated: true)
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
        
        
        if CCUser.current()!.userInterests == nil {
            
            cell?.accessoryType = .none
            cell?.setSelected(false, animated: false)
            
            return cell!
        }
        
        
        //Compare text to user interests
        if CCUser.current()!.userInterests.contains(categoryTuple.0) {
            
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
        
        let index = CCUser.current()!.userInterests.index(where: {$0 == category})
        
        guard index == nil else {
            
            CCUser.current()!.userInterests.remove(at: index!)
            
            cell?.accessoryType = .none
            
            cell?.setSelected(false, animated: true)
            
            return
        }
        
        cell?.accessoryType = .checkmark
        
        CCUser.current()!.userInterests.append(category)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.accessoryType = .none
        
        let category = categories.fetchCategories()[indexPath.section][indexPath.row].0
        
        let index = CCUser.current()!.userInterests.index(where: {$0 == category})
        
        CCUser.current()!.userInterests.remove(at: index!)
    }
    
    override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if CCUser.current()!.userInterests.count > 1 {
            
            return indexPath
        }
        
        return nil
    }
}
