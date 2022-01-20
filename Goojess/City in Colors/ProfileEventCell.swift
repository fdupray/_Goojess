//
//  ProfileEventCell.swift
//  Goojess
//
//  Created by Frederick Dupray on 08/05/17.
//  Copyright © 2017 Carman. All rights reserved.
//

import UIKit

class ProfileEventCell: UITableViewCell {

    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventDescriptionLabel: UILabel!
    @IBOutlet weak var eventDatesLabel: UILabel!
    @IBOutlet weak var eventDayLabel: UILabel!
    @IBOutlet weak var eventMonthLabel: UILabel!
    @IBOutlet weak var addToCalendarButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
