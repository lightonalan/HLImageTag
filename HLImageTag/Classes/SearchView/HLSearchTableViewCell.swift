//
//  HLSearchTableViewCell.swift
//  HLImageTag
//
//  Created by Nguyen Xuan Hieu on 6/13/18.
//  Copyright © 2018 Nguyen Xuan Hieu. All rights reserved.
//

import UIKit

class HLSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        imgAvatar.layer.cornerRadius = imgAvatar.frame.size.height/2
        imgAvatar.layer.masksToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
