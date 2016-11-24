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
    
    class func setUpCell(_ cell: NotablesTableViewCell, note: NotesData, indexPath: IndexPath) -> NotablesTableViewCell {
        
        let notablesData = note.data
        let authorData = notablesData.authorData
        _ = notablesData.locationData
        _ = notablesData.photoData
        
        let date = FormatterHelper.formatDateStringToUsersDefinedDate(date: note.lastUpdated)

        let textAttributes = [
            NSForegroundColorAttributeName: UIColor.init(colorLiteralRed: 0/255, green: 150/255, blue: 136/255, alpha: 1),
            NSStrokeColorAttributeName: UIColor.init(colorLiteralRed: 0/255, green: 150/255, blue: 136/255, alpha: 1),
            NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 11)!,
            NSStrokeWidthAttributeName: -1.0
            ] as [String : Any]
        
//        let textAttributes2 = [
//            NSForegroundColorAttributeName: UIColor.init(colorLiteralRed: 0/255, green: 150/255, blue: 136/255, alpha: 1),
//            NSStrokeColorAttributeName: UIColor.init(colorLiteralRed: 0/255, green: 150/255, blue: 136/255, alpha: 1),
//            NSFontAttributeName: UIFont(name: "SSGlyphish-Filled", size: 12)!,
//            NSStrokeWidthAttributeName: -1.0
//            ] as [String : Any]
        
        let string = "Posted "+date
//        var lockChar: UniChar = 0
        var shareString: String = ""
        if !notablesData.shared {
            
//            lockChar = 0xE6D0
            shareString = " Private Note"
        }
        
        let partOne = NSAttributedString(string: string)
        let partTwo = NSAttributedString(string: shareString, attributes: textAttributes)
//        let partOneAndHalf = NSAttributedString(string: String(format: "%C", lockChar), attributes: textAttributes2)
        let combination = NSMutableAttributedString()
        
        combination.append(partOne)
        combination.append(partTwo)
        
        if authorData.photoURL != "" {
            
            //fetch image and assign it
        }
        
        //cell.locationImageFont.font = UIFont(name: "SSGlyphish-Outlined", size: 15) //SS Glyphish
        
        // create this zebra like color based on the index of the cell
        if (indexPath.row % 2 == 1) {
            
            cell.contentView.backgroundColor = UIColor.init(colorLiteralRed: 51/255, green: 74/255, blue: 79/255, alpha: 1)
        }
        
        cell.postDataLabel.text = notablesData.message
        cell.usernameLabel.text = authorData.phata
        cell.postInfoLabel.attributedText = combination
        
        return cell
    }
}
