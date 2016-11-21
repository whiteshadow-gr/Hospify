//
//  NotablesTableViewCell.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 8/11/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import UIKit

// MARK: Class

class NotablesTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets

    /// An IBOutlet for handling the info of the post
    @IBOutlet weak var postInfoLabel: UILabel!
    /// An IBOutlet for handling the data of the post
    @IBOutlet weak var postDataLabel: UILabel!
    /// An IBOutlet for handling the username of the post
    @IBOutlet weak var usernameLabel: UILabel!
    /// An IBOutlet for handling the profile image of the post
    @IBOutlet weak var profileImage: UIImageView!
    /// An IBOutlet for handling the rumpel image of the post
    @IBOutlet weak var rumpelImage: UIImageView!
    /// An IBOutlet for handling the twitter image of the post
    @IBOutlet weak var twitterImage: UIImageView!
    /// An IBOutlet for handling the facebook imag of the post
    @IBOutlet weak var facebookImage: UIImageView!
    
    // MARK: - Cell methods
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
