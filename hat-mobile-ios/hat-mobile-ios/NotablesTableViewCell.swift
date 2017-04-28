/**
 * Copyright (C) 2017 HAT Data Exchange Ltd
 * 
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import HatForIOS

// MARK: Class

/// the notables table view cell class
class NotablesTableViewCell: UITableViewCell, UICollectionViewDataSource {
    
    // MARK: - Variables
    
    /// an array to hold the social networks that this note is shared on
    private var sharedOn: [String] = []
    
    // MARK: - IBOutlets

    /// An IBOutlet for handling the info of the post
    @IBOutlet weak var postInfoLabel: UILabel!
    /// An IBOutlet for handling the data of the post
    @IBOutlet weak var postDataLabel: UILabel!
    /// An IBOutlet for handling the username of the post
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var attachedImage: UIImageView!
    
    /// An IBOutlet for handling the profile image of the post
    @IBOutlet weak var profileImage: UIImageView!
    
    /// An IBOutlet for handling the collection view
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Setup cell
    
    /**
     Sets up the cell from the note
     
     - parameter cell: The cell to set up
     - parameter note: The data to show on the cell
     - parameter indexPath: The index path of the cell
     - returns: NotablesTableViewCell
     */
    func setUpCell(_ cell: NotablesTableViewCell, note: HATNotesData, indexPath: IndexPath) -> NotablesTableViewCell {
        
        let newCell = self.initCellToNil(cell: cell)
        
        if note.data.photoData.link != "" {
            
            if let url = URL(string: note.data.photoData.link) {
                
                newCell.attachedImage.downloadedFrom(url: url, completion: {
                    
                    newCell.attachedImage.cropImage(width: 143, height: 143)
                })
            }
        }
        
        // if the note is shared get the shared on string as well
        if note.data.shared {
            
            newCell.sharedOn = note.data.sharedOn.stringToArray().sorted()
            self.sharedOn = newCell.sharedOn
        }
        
        let locationData = note.data.locationData
        if locationData.longitude != nil && locationData.latitude != nil && (locationData.longitude != 0 && locationData.latitude != 0 && locationData.accuracy != 0) {
            
            newCell.sharedOn.append("location")
            self.sharedOn = newCell.sharedOn
        }
        
        // get the notes data
        let notablesData = note.data
        // get the author data
        let authorData = notablesData.authorData
        // get the last updated date
        let date = FormatterHelper.formatDateStringToUsersDefinedDate(date: note.data.createdTime, dateStyle: .short, timeStyle: .short)
                
        // create this zebra like color based on the index of the cell
        if (indexPath.row % 2 == 1) {
            
            newCell.contentView.backgroundColor = .rumpelLightGray()
        }
        
        // show the data in the cell's labels
        newCell.postDataLabel.text = notablesData.message
        newCell.usernameLabel.text = authorData.phata
        newCell.postInfoLabel.attributedText = self.formatInfoLabel(date: date, shared: notablesData.shared, publicUntil:  note.data.publicUntil)
        
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellReuseIDs.socialCell.rawValue, for: indexPath) as!SocialImageCollectionViewCell
        
        // update the image of the cell accordingly
        if self.sharedOn[indexPath.row] == "facebook" {
            
            cell.socialImage.image = UIImage(named: "Facebook")
        } else if self.sharedOn[indexPath.row] == "marketsquare" {
            
            cell.socialImage.image = UIImage(named: "Marketsquare")
        } else if self.sharedOn[indexPath.row] == "twitter" {
            
            cell.socialImage.image = UIImage(named: "Twitter")
        } else if self.sharedOn[indexPath.row] == "location" {
            
            cell.socialImage.image = UIImage(named: "gps filled")
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
        
        cell.contentView.backgroundColor = .rumpelDarkGray()

        return cell
    }
    
    // MARK: - Format Cell
    
    /**
     Formats the info label to date + Private if it's private. Also those two fields have different font color.
     
     - parameter date: The date to add to the string
     - parameter shared: A bool value defining if the note is shared
     - returns: An NSAttributesString with 2 different colors
     */
    private func formatInfoLabel(date: String, shared: Bool, publicUntil: Date?) -> NSAttributedString {
        
        // format the info label
        let string = "Posted " + date
        var shareString: String = " Private Note"
        
        if shared {
            
            shareString = " Shared"
        }
        
        if let unwrappedDate = publicUntil {
            
            if shared && (Date().compare(unwrappedDate) == .orderedDescending) {
                
                shareString = " Expired"
            }
        } 
        
        let partOne = NSAttributedString(string: string)
        let partTwo = shareString.createTextAttributes(foregroundColor: .tealColor(), strokeColor: .tealColor(), font: UIFont(name: Constants.fontNames.openSans.rawValue, size: 11)!)
        
        return partOne.combineWith(attributedText: partTwo)
    }
}
