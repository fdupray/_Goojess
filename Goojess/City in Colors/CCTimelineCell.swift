//
//  CCTimelineCell.swift
//  Goojess
//
//  Created by Simon Blomqvist on 2017-04-15.
//  Copyright © 2017 Carman. All rights reserved.
//

import UIKit

class CCTimelineCell: UITableViewCell {
    
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var typeBasedIcon: UIImageView!
    @IBOutlet weak var amountOfLikesLabel: UILabel!
    @IBOutlet weak var likeButton: LikeButton!
    @IBOutlet weak var dateOfPostingLabel: UILabel!
    
    var timelinePost: CCTimelinePost! = CCTimelinePost()
    
    var likeObject: CCLike?
    
    let typeOneIconString = "TimelinePostMarker"
    let typeTwoIconString = "FavouriteButton2"
    let typeThreeIconString = "Ok Filled-100"
    let typeFourIconString = "TimelinePostMarker"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        likeButton.disableButton()
    }
    
    
    @IBAction func toggleLike(_ sender: Any) {
        
        likeButton.toggleState()
        
        likeButton.isEnabled = false
        
        //If liked then unlike
        if likeObject != nil {
            
            likeObject?.deleteInBackground(block: { (success, error) in
                
                if success {
                    
                    var likes = Int(self.amountOfLikesLabel.text!)!
                    
                    likes -= 1
                    
                    self.amountOfLikesLabel.text = "\(likes)"
                    
                    self.likeObject = nil
                }
                
                else {
                    //REVERT
                    self.likeButton.toggleState()
                }
                
                self.likeButton.isEnabled = true
            })
        }
            
            //If not liked then like
        else {
            
            let newLike = CCLike()
            
            newLike.post = timelinePost
            newLike.user = CCUser.current()!
            
            newLike.saveInBackground(block: { (success, error) in
                
                if success {
                    
                    var likes = Int(self.amountOfLikesLabel.text!)!
                    
                    likes += 1
                    
                    self.amountOfLikesLabel.text = "\(likes)"
                    
                    self.likeObject = newLike
                }
                
                else {
                    
                    self.likeButton.toggleState()
                }
                
                self.likeButton.isEnabled = true
            })
            
        }
    }
    
    func enterData (amountOfLikes likes: Int, currentUserHasLiked liked: Bool, ccTimelinePost post: CCTimelinePost) {
        
        self.timelinePost = post
        
        post.getTimelineString({ (result) in
            
            self.mainTextLabel.text = result
        })
        
        switch post.postType {
            
        case 1:
            
            typeBasedIcon.image = UIImage(named: typeOneIconString)
            
        case 2:
            
            typeBasedIcon.image = UIImage(named: typeTwoIconString)
            
        case 3:
            
            typeBasedIcon.image = UIImage(named: typeThreeIconString)
            
        case 4:
            
            typeBasedIcon.image = UIImage(named: typeFourIconString)
            
        default:
            
            typeBasedIcon.image = UIImage(named: typeOneIconString)
        }
        
        let formatter = DateFormatter()
        
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
        dateOfPostingLabel.text = formatter.string(from: post.createdAt!)
        
        if likes == 0 {
            
            amountOfLikesLabel.text = "0"
        }
            
        else {
            
            amountOfLikesLabel.text = "\(likes)"
        }
        
        if liked {
            
            likeButton.enableButton(toState: .liked)
        }
            
        else {
            
            likeButton.enableButton(toState: .notLiked)
        }
    }
    
    override func prepareForReuse() {
        
        mainTextLabel.text = nil
        typeBasedIcon.image = nil
        amountOfLikesLabel.text = "0"
        likeButton.disableButton()
        dateOfPostingLabel.text = nil
        timelinePost = nil
        likeObject = nil
    }
}
