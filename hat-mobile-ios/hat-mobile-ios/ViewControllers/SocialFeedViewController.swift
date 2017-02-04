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

import UIKit
import SwiftyJSON

class SocialFeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var emptyCollectionViewLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var posts: [FacebookSocialFeedObject] = []
    private var tweets: [TwitterSocialFeedObject] = []
    private var allData: [SocialFeedObject] = []
    private var cachedDataArray: [SocialFeedObject] = []
    
    private var filterBy: String = "All"
    
    private var isTwitterAvailable: Bool = false
    private var twitterEndTime: String? = nil
    private var twitterAppToken: String = ""
    private var twitterLimitParameter: String = "50" {
        
        didSet {
            
            self.reloadCollectionView(with: self.filterBy)
            
            self.fetchTwitterData(appToken: self.twitterAppToken)
        }
    }
    
    private var isFacebookAvailable: Bool = false
    private var facebookProfileImage: UIImageView? = nil
    private var facebookEndTime: String? = nil
    private var facebookAppToken: String = ""
    private var facebookLimitParameter: String = "50" {
        
        didSet {
            
            self.reloadCollectionView(with: self.filterBy)
            
            self.fetchFacebookData(appToken: self.facebookAppToken)
        }
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // add notification observers
        NotificationCenter.default.addObserver(self, selector: #selector(filterSocialNetworksButtonAction), name: NSNotification.Name("filterSocialFeed"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        showEptyLabelWith(text: "Checking data plugs....")
        
        // get Token for plugs
        FacebookDataPlugService.getAppTokenForFacebook(successful: self.fetchFacebookData, failed: {() -> Void in return})
        
        TwitterDataPlugService.getAppTokenForTwitter(successful: self.fetchTwitterData, failed: {() -> Void in return})
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchTwitterData(appToken: String) {
        
        self.twitterAppToken = appToken
        
        var parameters: Dictionary<String, String> = ["limit" : self.twitterLimitParameter,
                                                      "starttime" : "0"]
        
        if self.twitterEndTime != nil {
            
            parameters = ["limit" : self.twitterLimitParameter,
                          "starttime" : "0",
                          "endtime" : self.twitterEndTime!]
        }
        
        func failed() {
            
            self.isTwitterAvailable = false
            self.showEptyLabelWith(text: "Please enable at least one data plug in order to use social feed")
        }
        
        TwitterDataPlugService.isTwitterDataPlugActive(token: appToken, successful: self.fetchTweets(parameters: parameters), failed: failed)
    }
    
    func fetchTweets(parameters: Dictionary<String, String>) -> (Void) -> Void {
        
        return { [unowned self](Void) -> Void in
            
            self.showEptyLabelWith(text: "Fetching social feed...")
            self.isTwitterAvailable = true
            
            let token = HatAccountService.getUsersTokenFromKeychain()
            TwitterDataPlugService.twitterDataPlug(authToken: token, parameters: parameters, success: (self.showTweets))
        }
    }
    
    func showTweets(array: [JSON]) {
        
        if self.isViewLoaded && (self.view.window != nil) {
            
            DispatchQueue.global().async { [unowned self]
                () -> Void in
                
                var filteredArray = TwitterDataPlugService.removeDuplicatesFrom(array: array)
                
                filteredArray = self.sortArray(array: filteredArray) as! [TwitterSocialFeedObject]
                
                // for each dictionary parse it and add it to the array
                for tweets in filteredArray {
                    
                    self.tweets.append(tweets)
                }
                                
                if array.count == Int(self.twitterLimitParameter) {
                    
                    let elapse = (filteredArray.last?.tryingLastUpdate)!.timeIntervalSince1970
                    
                    let temp = String(elapse)
                    
                    let array2 = temp.components(separatedBy: ".")
                    
                    self.twitterEndTime = array2[0]
                    
                    self.twitterLimitParameter = "500"
                } else {
                    
                    self.twitterEndTime = nil
                    self.reloadCollectionView(with: self.filterBy)
                }
            }
        }
    }
    
    func fetchFacebookData(appToken: String) {
        
        self.facebookAppToken = appToken
        
        var parameters: Dictionary<String, String> = ["limit" : self.facebookLimitParameter,
                                                      "starttime" : "0"]
        
        if self.facebookEndTime != nil {
            
            parameters = ["limit" : self.facebookLimitParameter,
                          "starttime" : "0",
                          "endtime" : self.facebookEndTime!]
        }
        
        func failed() {
            
            self.isFacebookAvailable = false
            self.showEptyLabelWith(text: "Please enable at least one data plug in order to use social feed")
        }
        
        FacebookDataPlugService.isFacebookDataPlugActive(token: appToken, successful: self.fetchPosts(parameters: parameters), failed: failed)
    }
    
    func fetchPosts(parameters: Dictionary<String, String>) -> (Void) -> Void {
        
        return { [unowned self](Void) -> Void in
            
            self.showEptyLabelWith(text: "Fetching social feed...")
            self.isFacebookAvailable = true
            
            let token = HatAccountService.getUsersTokenFromKeychain()
            FacebookDataPlugService.facebookDataPlug(authToken: token, parameters: parameters, success: self.showPosts)
            
            DispatchQueue.global().async { [unowned self] () -> Void in
                
                if self.facebookProfileImage == nil {
                    
                    func success(array: [JSON]) -> Void {
                        
                        if array.count > 0 {
                            
                            self.facebookProfileImage = UIImageView()
                            
                            if let url = URL(string: array[0]["data"]["profile_picture"]["url"].stringValue) {
                                
                                self.facebookProfileImage?.downloadedFrom(url: url)
                            } else {
                                
                                self.facebookProfileImage = nil
                            }
                        }
                    }
                    FacebookDataPlugService.fetchProfileFacebookPhoto(authToken: token, parameters: [:], success: success)
                }
            }
        }
    }
    
    func showPosts(array: [JSON]) {
        
         if self.isViewLoaded && (self.view.window != nil) {
            
            DispatchQueue.global().async { [unowned self] () -> Void in
                
                // removes duplicates from parameter array
                var filteredArray = FacebookDataPlugService.removeDuplicatesFrom(array: array)
                
                if let tempArray = self.sortArray(array: filteredArray) as? [FacebookSocialFeedObject] {
                    
                    filteredArray = tempArray
                    
                    // for each dictionary parse it and add it to the array
                    for posts in filteredArray {
                        
                        self.posts.append(posts)
                    }
                    
                    if array.count == Int(self.facebookLimitParameter) {
                        
                        let elapse = (filteredArray.last?.data.posts.createdTime)!.timeIntervalSince1970
                        
                        let temp = String(elapse)
                        
                        let array2 = temp.components(separatedBy: ".")
                        
                        self.facebookEndTime = array2[0]
                        
                        self.facebookLimitParameter = "500"
                    } else {
                        
                        self.facebookEndTime = nil
                        self.reloadCollectionView(with: self.filterBy)
                    }
                }
            }
        }
    }
    
    // MARK: - Collection View methods

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let post = self.cachedDataArray[indexPath.row] as? FacebookSocialFeedObject {
            
            var cell = SocialFeedCollectionViewCell()
            
            if post.data.posts.type == "photo" {
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageSocialFeedCell", for: indexPath) as! SocialFeedCollectionViewCell
            } else {
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "statusSocialFeedCell", for: indexPath) as! SocialFeedCollectionViewCell
            }
            
            if self.facebookProfileImage != nil {
                
                cell.profileImage.image = self.facebookProfileImage?.image
            }
            
            return SocialFeedCollectionViewCell.setUpCell(cell: cell, indexPath: indexPath, posts: post)
        } else {
            
            let tweet = self.cachedDataArray[indexPath.row] as? TwitterSocialFeedObject
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "statusSocialFeedCell", for: indexPath) as! SocialFeedCollectionViewCell
            
            return SocialFeedCollectionViewCell.setUpCell(cell: cell, indexPath: indexPath, posts: tweet!)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.cachedDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let post = self.cachedDataArray[indexPath.row] as? FacebookSocialFeedObject {
            
            if post.data.posts.type == "photo" {
                
                var text = post.data.posts.message
                
                if text == "" {
                    
                    text = post.data.posts.story
                }
                if text == "" {
                    
                    text = post.data.posts.description
                }
                
                let size = self.calculateCellHeight(text: text, width: self.collectionView.frame.width - 16)
                
                let imageHeight = collectionView.frame.width / 2.46
                
                return CGSize(width: collectionView.frame.width, height: 85 + size.height + imageHeight)
            }
            
            let text = post.data.posts.description + "\n\n" + post.data.posts.link
            let size = self.calculateCellHeight(text: text, width: self.collectionView.frame.width - 16)
            
            return CGSize(width: collectionView.frame.width, height: 85 + size.height)
        }else {
            
            let tweet = self.cachedDataArray[indexPath.row] as! TwitterSocialFeedObject
            
            let text = tweet.data.tweets.text
            let size = self.calculateCellHeight(text: text, width: self.collectionView.frame.width - 16)
            
            return CGSize(width: collectionView.frame.width, height: 95 + size.height)
        }
    }
    
    func calculateCellHeight(text: String, width: CGFloat) -> CGSize {
        
        return text.boundingRect( with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: nil, context: nil).size
    }
    
    func sortArray(array: [SocialFeedObject]) -> [SocialFeedObject] {
        
        func sorting(a: SocialFeedObject, b: SocialFeedObject) -> Bool {
            
            if let postA = a as? FacebookSocialFeedObject {
                
                if let postB = b as? FacebookSocialFeedObject {
                    
                    return (postA.data.posts.createdTime)! > (postB.data.posts.createdTime)!
                } else {
                    
                    let tweetB = b as? TwitterSocialFeedObject
                    return (postA.data.posts.createdTime)! > (tweetB!.data.tweets.createdAt)!
                }
            } else {
                
                let tweetA = a as? TwitterSocialFeedObject
                
                if let postB = b as? FacebookSocialFeedObject {
                    
                    return (tweetA!.data.tweets.createdAt)! > (postB.data.posts.createdTime)!
                } else {
                    
                    let tweetB = b as? TwitterSocialFeedObject
                    return (tweetA?.data.tweets.createdAt)! > (tweetB!.data.tweets.createdAt)!
                }
            }
        }
        
        return array.sorted(by: sorting)
    }
    
    func reloadCollectionView(with filter: String) {
        
        self.removeDuplicates()
        
        self.rebuildDataArray(filter: filter)
        
        DispatchQueue.main.async {
            
            self.showEptyLabelWith(text: "")
            self.collectionView.reloadData()
        }
    }
    
    func removeDuplicates() {
        
        self.posts = FacebookDataPlugService.removeDuplicatesFrom(array: self.posts)
        self.tweets = TwitterDataPlugService.removeDuplicatesFrom(array: self.tweets)
    }
    
    func rebuildDataArray(filter: String)  {
        
        if filter == "All" {
            
            for post in self.posts {
                
                self.allData.append(post)
            }
            for tweet in self.tweets {
                
                self.allData.append(tweet)
            }
        } else if filter == "Twitter" {
            
            for tweet in self.tweets {
                
                self.allData.append(tweet)
            }
        } else if filter == "Facebook" {
            
            for post in self.posts {
                
                self.allData.append(post)
            }
        }
        
        self.allData = self.sortArray(array: allData)
        
        self.cachedDataArray = self.allData
        
        self.allData.removeAll()
    }
    
    func filterSocialNetworksButtonAction(notification: NSNotification) {
        
        let alert = UIAlertController(title: "Filter by:", message: "", preferredStyle: .actionSheet)
        
        let facebookAction = UIAlertAction(title: "Facebook", style: .default, handler: { [unowned self](action) -> Void in
            
            self.cachedDataArray.removeAll()
            
            if self.posts.count > 0 {
                
                for i in 0...self.posts.count - 1 {
                    
                    self.cachedDataArray.append(self.posts[i])
                }
            }
            
            self.filterBy = "Facebook"
            
            self.reloadCollectionView(with: self.filterBy)
        })
        
        let twitterAction = UIAlertAction(title: "Twitter", style: .default, handler: { [unowned self](action) -> Void in
            
            self.cachedDataArray.removeAll()
            
            if self.tweets.count > 0 {
                
                for i in 0...self.tweets.count - 1 {
                    
                    self.cachedDataArray.append(self.tweets[i])
                }
            }
            
            self.filterBy = "Twitter"
            
            self.reloadCollectionView(with: self.filterBy)
        })
        
        let allNetworksAction = UIAlertAction(title: "All", style: .default, handler: { [unowned self](action) -> Void in
            
            self.cachedDataArray.removeAll()
            
            if self.tweets.count > 0 {
                
                for i in 0...self.tweets.count - 1 {
                    
                    self.cachedDataArray.append(self.tweets[i])
                }
            }
            
            if self.posts.count > 0 {
                
                for i in 0...self.posts.count - 1 {
                    
                    self.cachedDataArray.append(self.posts[i])
                }
            }
            
            self.filterBy = "All"
            
            self.reloadCollectionView(with: self.filterBy)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
            return
        })
        
        alert.addAction(facebookAction)
        alert.addAction(twitterAction)
        alert.addAction(allNetworksAction)
        alert.addAction(cancelAction)
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            
            alert.popoverPresentationController?.barButtonItem = self.navigationItem.leftBarButtonItem
            alert.popoverPresentationController?.sourceView = self.view;
        }
        
        self.navigationController!.present(alert, animated: true, completion: nil)
    }
    
    func showEptyLabelWith(text: String) {
        
        if !isTwitterAvailable && !isFacebookAvailable {
            
            self.collectionView.isHidden = true
            self.emptyCollectionViewLabel.text = text
        }
        if text == "" {
            
            self.collectionView.isHidden = false
            self.emptyCollectionViewLabel.text = text
        }
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        self.collectionView.reloadData()
    }

}
