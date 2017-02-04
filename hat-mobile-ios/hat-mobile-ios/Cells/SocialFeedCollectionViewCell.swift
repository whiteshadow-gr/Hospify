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
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var postInfoLabel: UILabel!
    @IBOutlet weak var messageLabel: UITextView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var postTypeLabel: UILabel!
    
    // MARK: - Set up cell
    
    class func setUpCell(cell: SocialFeedCollectionViewCell, indexPath: IndexPath, posts: Any) -> SocialFeedCollectionViewCell {
        
        if posts is FacebookSocialFeedObject {
            
            let post = posts as! FacebookSocialFeedObject
            
            cell.profileNameLabel.text = post.data.posts.from.name
            cell.messageLabel.text = post.data.posts.message
            cell.postTypeLabel.text = post.data.posts.type
            
            let date = post.data.posts.updatedTime
            let text = "Posted on " + FormatterHelper.formatDateStringToUsersDefinedDate(date: date!, dateStyle: .short, timeStyle: .short) + ", privacy set to " + post.data.posts.privacy.value.replacingOccurrences(of: "_", with: " ")
            cell.postInfoLabel.text = text
            
            if post.data.posts.type == "photo" {
                
                if let url = URL(string: post.data.posts.fullPicture) {
                    
                    cell.image.downloadedFrom(url: url)
                }
            } else if post.data.posts.type == "link" {
                
                cell.messageLabel.attributedText = NSAttributedString(string: post.data.posts.description + "\n" + post.data.posts.link)
            }
            
            if cell.messageLabel.text == "" {
                
                cell.messageLabel.text = post.data.posts.story
            }
            
            if cell.messageLabel.text == "" {
                
                cell.messageLabel.text = post.data.posts.description
            }
            
            return cell
        } else {
            
            let post = posts as! TwitterSocialFeedObject
            
            cell.profileNameLabel.text = post.data.tweets.user.name
            cell.messageLabel.text = post.data.tweets.text
            cell.postTypeLabel.text = "tweet"
            
            if post.data.tweets.createdAt != nil {
                
                let date = post.data.tweets.createdAt
                let text = "Posted on " + FormatterHelper.formatDateStringToUsersDefinedDate(date: date!, dateStyle: .short, timeStyle: .short)
                
                cell.postInfoLabel.text = text
            }
            
            cell.profileImage.image = UIImage(named: "Twitter")
                        
            return cell
        }
    }
}
