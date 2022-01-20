//
//  CCLocationDetailReviews.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import UIKit

class CCLocationDetailReviews: UITableViewController, CustomAlertControllerDelegate {

    var canEditReviews: Bool!
    
    var reviews = [CCComment]()
    
    let commentCellIdentifier = "CommentCell"
    
    var selectedCellIndexPath: IndexPath!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: "CCCommentCell", bundle: nil), forCellReuseIdentifier: commentCellIdentifier)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        let done = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
        
        done.setTitle("Done", for: UIControlState())
        
        done.setTitleColor(cityInColorRed, for: UIControlState())
        
        done.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        done.addTarget(self, action: #selector(CCLocationDetailReviews.dismissView), for: .touchUpInside)
        
        self.navigationItem.titleView?.isUserInteractionEnabled = true
        
        self.navigationItem.titleView = done
        
        
        if canEditReviews == true && !self.reviews.isEmpty {
            
            let edit = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CCLocationDetailReviews.editTable(_:)))
            
            self.navigationItem.rightBarButtonItem = edit
            
            edit.tintColor = cityInColorRed
        }
    }
    
    
    func editTable(_ sender: UIBarButtonItem) {
        
        if self.tableView.isEditing {
            
            self.tableView.isEditing = false
            
            return
        }
        
        self.tableView.isEditing = true
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            let row = indexPath.row
            
            self.reviews[row].deleteEventually()
            
            self.reviews.remove(at: row)
            
            if self.reviews.count > 1 {
                
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
        if self.reviews.isEmpty {
            
            return .none
        }
        
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if self.reviews.isEmpty {
            
            return nil
        }
        
        if self.reviews[indexPath.row].commentor.objectId! == CCUser.current()!.objectId! {
            
            return indexPath
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Edit or Delete?", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { (action) -> Void in
            
            self.editComment(indexPath)
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
            
            let row = indexPath.row
            
            self.reviews[row].deleteEventually()
            
            self.reviews.remove(at: row)
            
            if self.reviews.count > 1 {
                
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            self.tableView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func customAlertController(didCancelWithCompletion completed: Bool) {
        
        
    }

    func customAlertController(didConfirmEntry text: String) {
        
        let review = self.reviews[selectedCellIndexPath.row]
        
        if text.characters.count > 0 {
            
            review.strCommentText = text
            
            review.saveEventually()
            
            self.tableView.reloadData()
        }
    }
    
    
    func editComment (_ indexPath: IndexPath) {
        
        let review = self.reviews[indexPath.row]
        
        self.selectedCellIndexPath = indexPath
        
        let alert = self.storyboard?.instantiateViewController(withIdentifier: "CustomAlertController") as! CustomAlertController
        
        alert.modalPresentationStyle = .overFullScreen
        
        alert.view.backgroundColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 0.75)
        
        let nav = UINavigationController(rootViewController: alert)
        
        nav.modalPresentationStyle = .overFullScreen
        
        nav.view.backgroundColor = UIColor.clear
        
        alert.delegate = self
        
        alert.globalColour = cityInColorRed
        alert.viewTitle = "Edit my comment"
        alert.textFieldPlaceHolder = "My comment..."
        alert.textFieldText = review.strCommentText
        alert.confirmButtonTitle = "Done"
        
        self.present(nav, animated: false, completion: nil)
    }
    
    
    func dismissView () {
        
        self.dismiss(animated: true, completion: nil)
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
        
        return self.reviews.isEmpty ? 1 : self.reviews.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.reviews.isEmpty {
            
            let cell = UITableViewCell()
            
            cell.textLabel?.text = "No Reviews"
            
            cell.textLabel?.textColor = UIColor.white
            
            cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 16)
            
            cell.contentView.backgroundColor = .clear
            
            cell.backgroundColor = .clear
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: commentCellIdentifier) as! CCCommentsCell
        
        let comment = self.reviews[indexPath.row]
        
        cell.setUpCellForComment(comment)
        
        cell.selectionStyle = .gray
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.reviews.isEmpty {
            
            return 50
        }
        
        let comment = self.reviews[indexPath.row]
        
        var heightToReturn = UIHelper.getHeightForText(comment.strCommentText, width: SCREEN_WIDTH-80, font: UIFont(name: "Avenir-Medium", size: 13)!)
        
        heightToReturn = heightToReturn + UIHelper.getHeightForText(comment.commentor.strFirstName, width: SCREEN_WIDTH-80, font: UIFont(name: "Avenir-Medium", size: 13)!)
        
        heightToReturn = max(70, heightToReturn)
        
        return heightToReturn
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return UIView()
    }
}
