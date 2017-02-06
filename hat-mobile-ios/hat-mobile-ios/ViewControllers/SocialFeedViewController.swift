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

// MARK: Class

/// The social feed view controller class
class SocialFeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the empty collection view label
    @IBOutlet weak var emptyCollectionViewLabel: UILabel!
    
    /// An IBOutlet for handling the collection view
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Variables
    
    /// An FacebookSocialFeedObject array to store all the posts from facebook
    private var posts: [FacebookSocialFeedObject] = []
    
    /// An TwitterSocialFeedObject array to store all the tweets from twitter
    private var tweets: [TwitterSocialFeedObject] = []
    
    /// An SocialFeedObject array to store all the date from both twitter and facebook
    private var allData: [SocialFeedObject] = []
    
    /// An SocialFeedObject array to cache all the date from both twitter and facebook
    private var cachedDataArray: [SocialFeedObject] = []
    
    /// A String to filter the social feed by, Twitter, Facebook and All
    private var filterBy: String = "All"
    
    /// A Bool to determine if twitter is available
    private var isTwitterAvailable: Bool = false
    /// A String to define the end time of the last tweet in order to request tweets before this time
    private var twitterEndTime: String? = nil
    /// A string to hold twitter app token for later use
    private var twitterAppToken: String = ""
    /// The number of items per request
    private var twitterLimitParameter: String = "50" {
        
        // every time this changes
        didSet {
            
            // reload collection view with the saved filter
            self.reloadCollectionView(with: self.filterBy)
            
            // fetch data from facebook with the saved token
            self.fetchTwitterData(appToken: self.twitterAppToken)
        }
    }
    
    /// A Bool to determine if facebook is available
    private var isFacebookAvailable: Bool = false
    private var facebookProfileImage: UIImageView? = nil
    /// A String to define the end time of the last post in order to request posts before this time
    private var facebookEndTime: String? = nil
    /// A string to hold facebook app token for later use
    private var facebookAppToken: String = ""
    /// The number of items per request
    private var facebookLimitParameter: String = "50" {
        
        // every time this changes
        didSet {
            
            // reload collection view with the saved filter
            self.reloadCollectionView(with: self.filterBy)
            
            // fetch data from facebook with the saved token
            self.fetchFacebookData(appToken: self.facebookAppToken)
        }
    }

    // MARK: - View Controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // add notification observers
        NotificationCenter.default.addObserver(self, selector: #selector(filterSocialNetworksButtonAction), name: NSNotification.Name("filterSocialFeed"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // show empty label
        showEptyLabelWith(text: "Checking data plugs....")
        
        // get Token for plugs
        FacebookDataPlugService.getAppTokenForFacebook(successful: self.fetchFacebookData, failed: {() -> Void in return})
        
        TwitterDataPlugService.getAppTokenForTwitter(successful: self.fetchTwitterData, failed: {() -> Void in return})
        
        // set datasource and delegate to self
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        // reload collection view to adjust the cells to the new width
        self.collectionView.reloadData()
    }
    
    // MARK: Fetch twitter data
    
    /**
     Fetch twitter data
     
     - parameter appToken: The twitter app token
     */
    private func fetchTwitterData(appToken: String) {
        
        // save twitter app token for later use
        self.twitterAppToken = appToken
        
        // construct the parameters for the request
        var parameters: Dictionary<String, String> = ["limit" : self.twitterLimitParameter,
                                                      "starttime" : "0"]
        
        // if twitter end time not nil add a new parameter
        if self.twitterEndTime != nil {
            
            parameters = ["limit" : self.twitterLimitParameter,
                          "starttime" : "0",
                          "endtime" : self.twitterEndTime!]
        }
        
        // if request failed show message
        func failed() {
            
            self.isTwitterAvailable = false
            self.showEptyLabelWith(text: "Please enable at least one data plug in order to use social feed")
        }
        
        // check if twitter is active
        TwitterDataPlugService.isTwitterDataPlugActive(token: appToken, successful: self.fetchTweets(parameters: parameters), failed: failed)
    }
    
    /**
     Fetch tweets
     
     - parameter parameters: The url request parameters
     - returns: (Void) -> Void
     */
    private func fetchTweets(parameters: Dictionary<String, String>) -> (Void) -> Void {
        
        return { [unowned self](Void) -> Void in
            
            // show message that the social feed is downloading
            self.showEptyLabelWith(text: "Fetching social feed...")
            // change flag
            self.isTwitterAvailable = true
            
            // get user's token
            let token = HatAccountService.getUsersTokenFromKeychain()
            // try to access twitter plug
            TwitterDataPlugService.twitterDataPlug(authToken: token, parameters: parameters, success: (self.showTweets))
        }
    }
    
    /**
     Show the fetched tweets
     
     - parameter array: The array that the request returned
     */
    private func showTweets(array: [JSON]) {
        
        // check if the view is loaded and visible, else don't bother showing the data
        if self.isViewLoaded && (self.view.window != nil) {
            
            // switch to the background queue
            DispatchQueue.global().async { [unowned self]
                () -> Void in
                
                // filter data from duplicates
                var filteredArray = TwitterDataPlugService.removeDuplicatesFrom(array: array)
                
                // sort array
                filteredArray = self.sortArray(array: filteredArray) as! [TwitterSocialFeedObject]
                
                // for each dictionary parse it and add it to the array
                for tweets in filteredArray {
                    
                    self.tweets.append(tweets)
                }
                
                // if the returned array is equal or bigger than the defined limit make a new request with more data while this thread will continue to show that data
                if array.count == Int(self.twitterLimitParameter) {
                    
                    // get the unix time stamp
                    let elapse = (filteredArray.last?.protocolLastUpdate)!.timeIntervalSince1970
                    
                    let temp = String(elapse)
                    
                    let array2 = temp.components(separatedBy: ".")
                    
                    // save the time stamp
                    self.twitterEndTime = array2[0]
                    
                    // increase the limit
                    self.twitterLimitParameter = "500"
                // else nil the flags we use and reload collection view with the saved filter
                } else {
                    
                    self.twitterEndTime = nil
                    self.reloadCollectionView(with: self.filterBy)
                }
            }
        }
    }
    
    // MARK: - Fetch facebook data
    
    /**
     Fetch facebook data
     
     - parameter appToken: The facebook app token
     */
    private func fetchFacebookData(appToken: String) {
        
        // save facebok app token for later use
        self.facebookAppToken = appToken
        
        // construct the parameters for the request
        var parameters: Dictionary<String, String> = ["limit" : self.facebookLimitParameter,
                                                      "starttime" : "0"]
        
        // if facebbok end time not nil add a new parameter
        if self.facebookEndTime != nil {
            
            parameters = ["limit" : self.facebookLimitParameter,
                          "starttime" : "0",
                          "endtime" : self.facebookEndTime!]
        }
        
        // if request failed show message
        func failed() {
            
            self.isFacebookAvailable = false
            self.showEptyLabelWith(text: "Please enable at least one data plug in order to use social feed")
        }
        
        // check if facebook is active
        FacebookDataPlugService.isFacebookDataPlugActive(token: appToken, successful: self.fetchPosts(parameters: parameters), failed: failed)
    }
    
    /**
     Fetch posts
     
     - parameter parameters: The url request parameters
     - returns: (Void) -> Void
     */
    private func fetchPosts(parameters: Dictionary<String, String>) -> (Void) -> Void {
        
        return { [unowned self](Void) -> Void in
            
            // show message that the social feed is downloading
            self.showEptyLabelWith(text: "Fetching social feed...")
            // change flag
            self.isFacebookAvailable = true
            
            // get user's token
            let token = HatAccountService.getUsersTokenFromKeychain()
            // try to access facebook plug
            FacebookDataPlugService.facebookDataPlug(authToken: token, parameters: parameters, success: self.showPosts)
            
            // switch to another thread
            DispatchQueue.global().async { [unowned self] () -> Void in
                
                // if no facebook profile image download onw
                if self.facebookProfileImage == nil {
                    
                    // the returned array for the request
                    func success(array: [JSON]) -> Void {
                        
                        if array.count > 0 {
                            
                            self.facebookProfileImage = UIImageView()
                            
                            // extract image
                            if let url = URL(string: array[0]["data"]["profile_picture"]["url"].stringValue) {
                                
                                // download image
                                self.facebookProfileImage?.downloadedFrom(url: url)
                            } else {
                                
                                // set image to nil
                                self.facebookProfileImage = nil
                            }
                        }
                    }
                    // fetch facebook image
                    FacebookDataPlugService.fetchProfileFacebookPhoto(authToken: token, parameters: [:], success: success)
                }
            }
        }
    }
    
    /**
     Show the fetched posts
     
     - parameter array: The array that the request returned
     */
    private func showPosts(array: [JSON]) {
        
        // check if the view is loaded and visible, else don't bother showing the data
         if self.isViewLoaded && (self.view.window != nil) {
            
            // switch to the background queue
            DispatchQueue.global().async { [unowned self] () -> Void in
                
                // removes duplicates from parameter array
                var filteredArray = FacebookDataPlugService.removeDuplicatesFrom(array: array)
                
                // sort array
                if let tempArray = self.sortArray(array: filteredArray) as? [FacebookSocialFeedObject] {
                    
                    filteredArray = tempArray
                    
                    // for each dictionary parse it and add it to the array
                    for posts in filteredArray {
                        
                        self.posts.append(posts)
                    }
                    
                    // if the returned array is equal or bigger than the defined limit make a new request with more data while this thread will continue to show that data
                    if array.count == Int(self.facebookLimitParameter) {
                        
                        // get the unix time stamp
                        let elapse = (filteredArray.last?.data.posts.createdTime)!.timeIntervalSince1970
                        
                        let temp = String(elapse)
                        
                        let array2 = temp.components(separatedBy: ".")
                        
                        // save the time stamp
                        self.facebookEndTime = array2[0]
                        
                        // increase the limit
                        self.facebookLimitParameter = "500"
                    // else nil the flags we use and reload collection view with the saved filter
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
        
        // if this index path is FacebookSocialFeedObject
        if let post = self.cachedDataArray[indexPath.row] as? FacebookSocialFeedObject {
            
            // create a cell
            var cell = SocialFeedCollectionViewCell()
            
            // if photo create a photo cell else create a status cell
            if post.data.posts.type == "photo" {
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageSocialFeedCell", for: indexPath) as! SocialFeedCollectionViewCell
            } else {
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "statusSocialFeedCell", for: indexPath) as! SocialFeedCollectionViewCell
            }
            
            // if we have a downloaded image show it
            if self.facebookProfileImage != nil {
                
                cell.profileImage.image = self.facebookProfileImage?.image
            }
            
            // return cell
            return SocialFeedCollectionViewCell.setUpCell(cell: cell, indexPath: indexPath, posts: post)
        // else this is a TwitterSocialFeedObject
        } else {
            
            // get TwitterSocialFeedObject
            let tweet = self.cachedDataArray[indexPath.row] as? TwitterSocialFeedObject
            
            // set up cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "statusSocialFeedCell", for: indexPath) as! SocialFeedCollectionViewCell
            
            // return cell
            return SocialFeedCollectionViewCell.setUpCell(cell: cell, indexPath: indexPath, posts: tweet!)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.cachedDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // if this index path is FacebookSocialFeedObject
        if let post = self.cachedDataArray[indexPath.row] as? FacebookSocialFeedObject {
            
            // if this is a photo post
            if post.data.posts.type == "photo" {
                
                // get message
                var text = post.data.posts.message
                
                // if text is empty get story
                if text == "" {
                    
                    text = post.data.posts.story
                }
                // if text is still empty get description
                if text == "" {
                    
                    text = post.data.posts.description
                }
                
                // calculate size of content
                let size = self.calculateCellHeight(text: text, width: self.collectionView.frame.width - 16)
                
                // calculate size of image based on the image ratio
                let imageHeight = collectionView.frame.width / 2.46
                
                // return size
                return CGSize(width: collectionView.frame.width, height: 85 + size.height + imageHeight)
            }
            
            // else return size of text plus the cell
            let text = post.data.posts.description + "\n\n" + post.data.posts.link
            let size = self.calculateCellHeight(text: text, width: self.collectionView.frame.width - 16)
            
            return CGSize(width: collectionView.frame.width, height: 85 + size.height)
        }else {
            
            //return size of text plus the cell
            let tweet = self.cachedDataArray[indexPath.row] as! TwitterSocialFeedObject
            
            let text = tweet.data.tweets.text
            let size = self.calculateCellHeight(text: text, width: self.collectionView.frame.width - 16)
            
            return CGSize(width: collectionView.frame.width, height: 95 + size.height)
        }
    }
    
    // MARK: - Calculate cell height
    
    /**
     Calculates the cell heigt
     
     - parameter text: The text we want to show
     - parameter width: The width of the field that will hold the text
     - returns: A CGSize object
     */
    private func calculateCellHeight(text: String, width: CGFloat) -> CGSize {
        
        return text.boundingRect( with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: nil, context: nil).size
    }
    
    // MARK: - Sort array
    
    /**
     Sorts array based on crated times
     
     - parameter array: The array to sort
     - returns: A sorted SocialFeedObject array based on crated times
     */
    private func sortArray(array: [SocialFeedObject]) -> [SocialFeedObject] {
        
        // the method to sort the array
        func sorting(a: SocialFeedObject, b: SocialFeedObject) -> Bool {
            
            // if a is FacebookSocialFeedObject
            if let postA = a as? FacebookSocialFeedObject {
                
                // if b is FacebookSocialFeedObject
                if let postB = b as? FacebookSocialFeedObject {
                    
                    // return true of false based on this result
                    return (postA.data.posts.createdTime)! > (postB.data.posts.createdTime)!
                // else b is TwitterSocialFeedObject
                } else {
                    
                    let tweetB = b as? TwitterSocialFeedObject
                    // return true of false based on this result
                    return (postA.data.posts.createdTime)! > (tweetB!.data.tweets.createdAt)!
                }
            // else a is TwitterSocialFeedObject
            } else {
                
                let tweetA = a as? TwitterSocialFeedObject
                
                // if b is FacebookSocialFeedObject
                if let postB = b as? FacebookSocialFeedObject {
                    
                    // return true of false based on this result
                    return (tweetA!.data.tweets.createdAt)! > (postB.data.posts.createdTime)!
                // if b is TwitterSocialFeedObject
                } else {
                    
                    let tweetB = b as? TwitterSocialFeedObject
                    // return true of false based on this result
                    return (tweetA?.data.tweets.createdAt)! > (tweetB!.data.tweets.createdAt)!
                }
            }
        }
        
        // sort array
        return array.sorted(by: sorting)
    }
    
    // MARK: - Reload collection view
    
    /**
     Reloads collection view based on a filter
     
     - parameter filter: The filter to reload the collection view with
     */
    private func reloadCollectionView(with filter: String) {
        
        // removes duplicates
        self.removeDuplicates()
        
        // rebuild data
        self.rebuildDataArray(filter: filter)
        
        // switch to the main thread to update stuff
        DispatchQueue.main.async {
            
            self.showEptyLabelWith(text: "")
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Remove duplicated
    
    /**
     Removes duplicates on twitter and facebook arrays
     */
    private func removeDuplicates() {
        
        self.posts = FacebookDataPlugService.removeDuplicatesFrom(array: self.posts)
        self.tweets = TwitterDataPlugService.removeDuplicatesFrom(array: self.tweets)
    }
    
    // MARK: - Rebuild data array
    
    /**
     Rebuild the data with the new filter
     
     - parameter filter: The filter to rebuild the data by
     */
    private func rebuildDataArray(filter: String)  {
        
        // check the filter type and reload the data array
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
        
        // sort data
        self.allData = self.sortArray(array: allData)
        
        // dump them in main array
        self.cachedDataArray = self.allData
        
        // remove data from data array
        self.allData.removeAll()
    }
    
    // MARK: - Filter social feed
    
    /**
     Creates an alert view controller to filter the social feed
     
     - parameter notification: The notification object
     */
    @objc private func filterSocialNetworksButtonAction(notification: NSNotification) {
        
        // create alert
        let alert = UIAlertController(title: "Filter by:", message: "", preferredStyle: .actionSheet)
        
        // create actions
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
        
        // add actions to alert
        alert.addAction(facebookAction)
        alert.addAction(twitterAction)
        alert.addAction(allNetworksAction)
        alert.addAction(cancelAction)
        
        // if user is on ipad present the alert as a pop up
        if UI_USER_INTERFACE_IDIOM() == .pad {
            
            alert.popoverPresentationController?.barButtonItem = self.navigationItem.leftBarButtonItem
            alert.popoverPresentationController?.sourceView = self.view;
        }
        
        // present alert view controller
        self.navigationController!.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Show empty label
    
    /**
     Shows a message in the emptyLabel if something is wrong
     
     - parameter text: The string to show to the empty label
     */
    private func showEptyLabelWith(text: String) {
        
        if !isTwitterAvailable && !isFacebookAvailable {
            
            self.collectionView.isHidden = true
            self.emptyCollectionViewLabel.text = text
        }
        if text == "" {
            
            self.collectionView.isHidden = false
            self.emptyCollectionViewLabel.text = text
        }
    }

}
