//
//  CCTimelineTableViewController.swift
//  Goojess
//
//  Created by Simon Blomqvist on 2017-04-15.
//  Copyright © 2017 Carman. All rights reserved.
//

import UIKit

class CCTimelineTableViewController: UITableViewController {
    
    let cellReuseIdentifier = "CCTimelineCell"
    
    var timelineOwner: CCUser!
    
    var timelinePosts = [CCTimelinePost]()
    
    var queryLimit = 10
    
    var amountToSkip = 0
    
    //Indicates whether a network operation is ongoing
    var isLoading = false
    
    //Table view Footer
    lazy var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if timelineOwner == nil {
            
            timelineOwner = CCUser.current()!
        }
        
        self.navigationController?.isNavigationBarHidden = false
        
        self.refreshControl?.isEnabled = true
        
        self.refreshControl?.addTarget(self, action: #selector(CCTimelineTableViewController.fetchPosts), for: .valueChanged)
        
        self.refreshControl?.beginRefreshing()
        
        self.fetchPosts()
        
        activityIndicator.hidesWhenStopped = true
        
        addTableFooter()
        
        activityIndicator.startAnimating()
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    
    func fetchPosts () {
        
        if isLoading {
            
            return
        }
        
        self.tableView.tableFooterView = activityIndicator
        
        self.activityIndicator.startAnimating()
        
        self.isLoading = true
        
        let query = CCTimelinePost.query()
        
        query?.order(byDescending: "createdAt")
        
        query?.limit = queryLimit
        
        query?.skip = amountToSkip
        
        query?.whereKey("poster", equalTo: timelineOwner)
        
        query?.whereKey("targetUsers", equalTo: CCUser.current()!)
        
        query?.cachePolicy = .networkOnly
        
        query?.findObjectsInBackground(block: { (objects, error) in
            
            guard objects != nil else {
                
                DispatchQueue.main.async {
                    
                    self.isLoading = false
                    
                    self.activityIndicator.stopAnimating()
                    
                    self.addTableFooter()
                    
                    let alert = UIAlertController(title: error?.localizedDescription, message: nil, preferredStyle: .alert)
                    
                    self.present(alert, animated: true, completion: nil)
                }
                
                return
            }
            
            if objects!.count > 0 {
                
                self.timelinePosts += objects! as! [CCTimelinePost]
                
                if objects!.count == self.queryLimit {
                    
                    self.amountToSkip += self.queryLimit
                }
                    
                else {
                    
                    self.amountToSkip += objects!.count
                }
                
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                }
            }
            
            DispatchQueue.main.async {
                
                self.isLoading = false
                
                self.activityIndicator.stopAnimating()
                
                self.addTableFooter()
            }
        })
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.timelinePosts.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        
        view.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 10)
        
        return view
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! CCTimelineCell
        
        //Load more posts
        if indexPath.section == (self.timelinePosts.count-1) {
            
            self.fetchPosts()
        }
        
        //Table view cells are placed in sections not rows (1 per section)
        let post = self.timelinePosts[indexPath.section]
        
        let query = CCTimelinePost.query()
        
        query?.whereKey("objectId", equalTo: post.objectId!)
        
        query?.findObjectsInBackground(block: { (objects, error) in
            
            DispatchQueue.main.async {
                
                if let cellToUpdate = self.tableView.cellForRow(at: indexPath) as? CCTimelineCell {
                    
                    var amountPassed: Int = 0
                    
                    if error == nil {
                        
                        amountPassed = objects!.count
                        
                        print("ERROR: \(String(describing: error))")
                    }
                        
                    else {
                        
                        amountPassed = 0
                    }
                    
                    let query = CCLike.query()
                    
                    query?.whereKey("user", equalTo: CCUser.current()!)
                    query?.whereKey("post", equalTo: post)
                    
                    query?.getFirstObjectInBackground(block: { (object, error) in
                        
                        var liked = true
                        
                        if object == nil {
                            
                            liked = false
                        }
                            
                        else {
                            
                            cell.likeObject = object as? CCLike
                        }
                        
                        DispatchQueue.main.async {
                            
                            cell.enterData(amountOfLikes: amountPassed, currentUserHasLiked: liked, ccTimelinePost: post)
                        }
                    })
                }
                    
                else {
                    
                    query?.cancel()
                }
            }
        })
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 144.67
    }
    
    func addTableFooter () {
        
        if self.timelinePosts.isEmpty {
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
            
            label.text = NSLocalizedString("NO_POSTS", comment: "").uppercased()
            
            label.textColor = UIColor.lightGray
            
            label.font = UIFont.boldSystemFont(ofSize: 10)
            
            label.textAlignment = .center
            
            self.tableView.tableFooterView = label
        }
            
        else {
            
            self.tableView.tableFooterView = activityIndicator
        }
    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
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

