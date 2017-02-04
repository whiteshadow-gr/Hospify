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

import SwiftyJSON
    
// MARK: Class

/// The social feed collection view cell class
class SocialFeedCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the profile image of the cell
    @IBOutlet weak var profileImage: UIImageView!
    /// An IBOutlet for handling the social network's image of the cell
    @IBOutlet weak var socialNetworkImage: UIImageView!
    
    /// An IBOutlet for handling the profile name label of the cell
    @IBOutlet weak var profileNameLabel: UILabel!
    /// An IBOutlet for handling the the post details label of the cell
    @IBOutlet weak var postInfoLabel: UILabel!
    /// An IBOutlet for handling the the post type, tweet, status, video etc of the cell
    @IBOutlet weak var postTypeLabel: UILabel!
    
    /// An IBOutlet for handling the message of the post of the cell
    @IBOutlet weak var messageTextView: UITextView!
    
    // MARK: - Set up cell
    
    /**
     Sets up a social feed cell according to our needs
     
     - parameter cell: The cell to set up
     - parameter indexPath: The index path of the currect cell
     - parameter posts: The post to display in this cell
     - returns: A formatted social feed cell of type SocialFeedCollectionViewCell
     */
    class func setUpCell(cell: SocialFeedCollectionViewCell, indexPath: IndexPath, posts: Any) -> SocialFeedCollectionViewCell {
        
        // Check if the post to show is from facebook
        if posts is FacebookSocialFeedObject {
            
            // convert the post to FacebookSocialFeedObject
            let post = posts as! FacebookSocialFeedObject
            
            // assign the values
            cell.profileNameLabel.text = post.data.posts.from.name
            cell.messageTextView.text = post.data.posts.message
            cell.postTypeLabel.text = post.data.posts.type
            
            // created the info string and assign it
            let date = post.data.posts.updatedTime
            let text = "Posted on " + FormatterHelper.formatDateStringToUsersDefinedDate(date: date!, dateStyle: .short, timeStyle: .short) + ", privacy set to " + post.data.posts.privacy.value.replacingOccurrences(of: "_", with: " ")
            cell.postInfoLabel.text = text
            
            // If the post is a photo, download it to the imageview
            if post.data.posts.type == "photo" {
                
                if let url = URL(string: post.data.posts.fullPicture) {
                    
                    cell.socialNetworkImage.downloadedFrom(url: url)
                }
            // if the pos is a link show the link as well
            } else if post.data.posts.type == "link" {
                
                cell.messageTextView.attributedText = NSAttributedString(string: post.data.posts.description + "\n" + post.data.posts.link)
            }
            
            // if nothing of above try to story and description
            if cell.messageTextView.text == "" {
                
                cell.messageTextView.text = post.data.posts.story
            }
            
            if cell.messageTextView.text == "" {
                
                cell.messageTextView.text = post.data.posts.description
            }
            
            return cell
        // else if the post is from twitter
        } else {
            
            // convert the post to TwitterSocialFeedObject
            let post = posts as! TwitterSocialFeedObject
            
            // assign the post values to cell values
            cell.profileNameLabel.text = post.data.tweets.user.name
            cell.messageTextView.text = post.data.tweets.text
            cell.postTypeLabel.text = "tweet"
            
            // if the post has a date create the info string label
            if post.data.tweets.createdAt != nil {
                
                let date = post.data.tweets.createdAt
                let text = "Posted on " + FormatterHelper.formatDateStringToUsersDefinedDate(date: date!, dateStyle: .short, timeStyle: .short)
                
                cell.postInfoLabel.text = text
            }
            
            // assign the twitter image as profile image
            cell.profileImage.image = UIImage(named: "Twitter")
                        
            return cell
        }
    }
}
