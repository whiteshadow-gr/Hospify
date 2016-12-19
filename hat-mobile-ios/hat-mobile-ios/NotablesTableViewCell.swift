/** Copyright (C) 2016 HAT Data Exchange Ltd
 * SPDX-License-Identifier: AGPL-3.0
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * RumpelLite is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License
 * as published by the Free Software Foundation, version 3 of
 * the License.
 *
 * RumpelLite is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
 * the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General
 * Public License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
 */

import UIKit

// MARK: Class

/// the notables table view cell class
class NotablesTableViewCell: UITableViewCell, UICollectionViewDataSource {
    
    // MARK: - Variables
    
    /// an array to hold the social networks that this note is shared on
    var sharedOn: [String] = []
    
    // MARK: - IBOutlets

    /// An IBOutlet for handling the info of the post
    @IBOutlet weak var postInfoLabel: UILabel!
    /// An IBOutlet for handling the data of the post
    @IBOutlet weak var postDataLabel: UILabel!
    /// An IBOutlet for handling the username of the post
    @IBOutlet weak var usernameLabel: UILabel!
    /// An IBOutlet for handling the profile image of the post
    @IBOutlet weak var profileImage: UIImageView!
    /// An IBOutlet for handling the collection view
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Cell methods
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Setup cell
    
    /**
     Sets up the cell from the note
     
     - parameter cell: The cell to set up
     - parameter note: The data to show on the cell
     - parameter indexPath: The index path of the cell
     - returns: NotablesTableViewCell
     */
    func setUpCell(_ cell: NotablesTableViewCell, note: NotesData, indexPath: IndexPath) -> NotablesTableViewCell {
        
        let newCell = self.initCellToNil(cell: cell)
        
        // if the note is shared get the shared on string as well
        if note.data.shared {
            
            newCell.sharedOn = note.data.sharedOn.stringToArray()
            self.sharedOn = newCell.sharedOn
        }
        
        // get the notes data
        let notablesData = note.data
        // get the author data
        let authorData = notablesData.authorData
        // get the last updated date
        let date = FormatterHelper.formatDateStringToUsersDefinedDate(date: note.lastUpdated)
                
        // create this zebra like color based on the index of the cell
        if (indexPath.row % 2 == 1) {
            
            newCell.contentView.backgroundColor = UIColor.init(colorLiteralRed: 51/255, green: 74/255, blue: 79/255, alpha: 1)
        }
        
        // show the data in the cell's labels
        newCell.postDataLabel.text = notablesData.message
        newCell.usernameLabel.text = authorData.phata
        newCell.postInfoLabel.attributedText = self.formatInfoLabel(date: date, shared: notablesData.shared)
        
        // flip the view to appear from right to left
        newCell.collectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        // return the cell
        return newCell
    }
    
    // MARK: - CollectionView datasource methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // return the number of elements in the array
        return self.sharedOn.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // set up cell from the reuse identifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "socialCell", for: indexPath) as!SocialImageCollectionViewCell
        
        // update the image of the cell accordingly
        if self.sharedOn[indexPath.row] == "facebook" {
            
            cell.socialImage.image = UIImage(named: "Facebook")
        } else if self.sharedOn[indexPath.row] == "marketsquare" {
            
            cell.socialImage.image = UIImage(named: "Marketsquare")
        }
        
        // flip the image to appear correctly
        cell.socialImage.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        //return the cell
        return cell
    }
    
    // MARK: - Init Cell
    
    /**
     Initialises a cell to the default values
     
     - parameter cell: The cell to init to the default values
     - returns: NotablesTableViewCell with default values
     */
    private func initCellToNil(cell: NotablesTableViewCell) -> NotablesTableViewCell {
        
        cell.postDataLabel.text = ""
        cell.usernameLabel.text = ""
        cell.postInfoLabel.text = ""
        
        cell.sharedOn.removeAll()
        self.sharedOn.removeAll()
        
        cell.collectionView.reloadData()
        
        cell.contentView.backgroundColor = UIColor.init(colorLiteralRed: 29/255, green: 49/255, blue: 53/255, alpha: 1)

        return cell
    }
    
    // MARK: - Format Cell
    
    /**
     Formats the info label to date + Private if it's private. Also those two fields have different font color.
     
     - parameter date: The date to add to the string
     - parameter shared: A bool value defining if the note is shared
     - returns: An NSAttributesString with 2 different colors
     */
    private func formatInfoLabel(date: String, shared: Bool) -> NSAttributedString {
        
        // format the info label
        let textAttributes = [
            NSForegroundColorAttributeName: UIColor.init(colorLiteralRed: 0/255, green: 150/255, blue: 136/255, alpha: 1),
            NSStrokeColorAttributeName: UIColor.init(colorLiteralRed: 0/255, green: 150/255, blue: 136/255, alpha: 1),
            NSFontAttributeName: UIFont(name: "Open Sans", size: 11)!,
            NSStrokeWidthAttributeName: -1.0
            ] as [String : Any]
        
        let string = "Posted " + date
        var shareString: String = ""
        
        if !shared {
            
            shareString = " Private Note"
        }
        
        let partOne = NSAttributedString(string: string)
        let partTwo = NSAttributedString(string: shareString, attributes: textAttributes)
        let combination = NSMutableAttributedString()
        
        combination.append(partOne)
        combination.append(partTwo)
        
        return combination
    }
}
