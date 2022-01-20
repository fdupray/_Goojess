//
//  CCCommentsCell.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import UIKit

class CCCommentsCell: UITableViewCell {
    
    @IBOutlet weak var imageViewCommentor: UIImageView!
    @IBOutlet weak var labelCommentorName: UILabel!
    @IBOutlet weak var labelCommentorText: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        imageViewCommentor.layer.cornerRadius = imageViewCommentor.frame.height/2
        imageViewCommentor.layer.borderColor = UIColor.black.cgColor
        imageViewCommentor.layer.borderWidth = 1
        
        imageViewCommentor.translatesAutoresizingMaskIntoConstraints = false
        labelCommentorName.translatesAutoresizingMaskIntoConstraints = false
        labelCommentorText.translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCellForComment(_ comment: CCComment) {
        
        labelCommentorName.text = comment.commentor.username
        
        labelCommentorText.text = comment.strCommentText
        
        if comment.commentor.userProfilePicture == nil {
            
            return
        }
        
        if comment.commentor.userProfilePicture.isDataAvailable {
            
            comment.commentor.userProfilePicture.getDataInBackground(block: { (data, error) -> Void in
                
                if data != nil {
                    
                    self.imageViewCommentor.image = UIImage(data: data!)
                    
                    self.imageViewCommentor.layer.borderColor = UIColor.clear.cgColor
                }
            })
        }
        
        else {
            
            comment.commentor.fetchIfNeededInBackground(block: { (object, error) -> Void in
                
                if let user = object as? CCUser {
                    
                    if user.userProfilePicture != nil {
                        
                        user.userProfilePicture.getDataInBackground(block: { (data, error) -> Void in
                            
                            if data != nil {
                                
                                self.imageViewCommentor.image = UIImage(data: data!)
                                
                                self.imageViewCommentor.layer.borderColor = UIColor.clear.cgColor
                            }
                        })
                    }
                }
            })
        }
    }
}
