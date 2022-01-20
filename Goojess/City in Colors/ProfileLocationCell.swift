//
//  ProfileLocationCell.swift
//  Goojess
//
//  Created by Frederick Dupray on 09/05/17.
//  Copyright © 2017 Carman. All rights reserved.
//

import UIKit

class ProfileLocationCell: UITableViewCell {

    @IBOutlet weak var locationImageView: PFImageView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationDescriptionLabel: UILabel!
    @IBOutlet weak var locationPageButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        
        locationImageView.file?.cancel()
        locationNameLabel.text = ""
        locationDescriptionLabel.text = ""
    }
}
