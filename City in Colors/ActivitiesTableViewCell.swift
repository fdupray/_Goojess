//
//  ActivitiesTableViewCell.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import UIKit

protocol ActivitiesTableDelegate {
    
    func activitiesShouldSave(_ activities: [String])
}

class ActivitiesTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    //var activitiesDelegate: ActivitiesTableDelegate!
    
    var location: CCLocation!
    
    let activityReuseIdentifier = "ActivityCell"
    
    var activities = [String]()
    
    var canEditTable: Bool!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: activityReuseIdentifier)
        
        if self.activities.isEmpty {
            
            cell?.textLabel?.text = "No activites"
        }
        
        else {
            
            cell?.textLabel?.text = self.activities[indexPath.row]
            
            cell?.textLabel?.textColor = UIColor(red: 0, green: 128/255, blue: 1, alpha: 1)
        }
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
        if activities.isEmpty {
            
            return .none
        }
        
        if activities.count == 1 {
            
            return .none
        }
        
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if activities.isEmpty {
            
            return 1
        }
        
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            self.activities.remove(at: indexPath.row)
            
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
            self.location.strLocationActivities = self.activities
            
            self.location.saveEventually()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if self.activities.isEmpty || self.activities.count == 1 {
            
            return false
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect.zero)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if self.canEditTable == true {
            
            return indexPath
        }
        
        return nil
    }
    
    
    @IBAction func editTableButtonPressed(_ sender: UIButton) {
        
        if self.tableView.isEditing {
            
            self.tableView.isEditing = false
            
            sender.setTitle("Edit", for: UIControlState())
            
            return
        }
        
        sender.setTitle("Done", for: UIControlState())
        
        self.tableView.isEditing = true
    }
}
