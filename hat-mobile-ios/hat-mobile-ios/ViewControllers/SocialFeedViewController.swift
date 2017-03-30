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
import HatForIOS

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
    private var posts: [HATFacebookSocialFeedObject] = []
    
    /// An TwitterSocialFeedObject array to store all the tweets from twitter
    private var tweets: [HATTwitterSocialFeedObject] = []
    
    /// An SocialFeedObject array to store all the date from both twitter and facebook
    private var allData: [HATSocialFeedObject] = []
    
    /// An SocialFeedObject array to cache all the date from both twitter and facebook
    private var cachedDataArray: [HATSocialFeedObject] = []
    
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
            //self.reloadCollectionView(with: self.filterBy)
            
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
            //self.reloadCollectionView(with: self.filterBy)
            
            // fetch data from facebook with the saved token
            self.fetchFacebookData(appToken: self.facebookAppToken)
        }
    }

    // MARK: - View Controller methods
    
    /**
     Shows a pop up with the available settings
     
     - parameter sender: The object that called this method
     */
    @IBAction func settingsButtonAction(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Settings", message: nil, preferredStyle: .actionSheet)
        
        let filterByAction = UIAlertAction(title: "Filter by", style: .default, handler: {(alert: UIAlertAction) -> Void
            
            in
            self.filterSocialNetworksButtonAction()
        })
        
        let logOutAction = UIAlertAction(title: "Log out", style: .default, handler: {(alert: UIAlertAction) -> Void
            
            in
            TabBarViewController.logoutUser(from: self)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(filterByAction)
        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)
        
        // if user is on ipad show as a pop up
        if UI_USER_INTERFACE_IDIOM() == .pad {
            
            alertController.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            alertController.popoverPresentationController?.sourceView = self.view
        }
        
        // present alert controller
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // view controller title
        self.title = "Social Data"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // show empty label
        showEptyLabelWith(text: "Checking data plugs....")
        
        let userDomain = HATAccountService.TheUserHATDomain()
        let userToken = HATAccountService.getUsersTokenFromKeychain()
        
        // get Token for plugs
        HATFacebookService.getAppTokenForFacebook(token: userToken, userDomain: userDomain, successful: self.fetchFacebookData, failed: {_ in})
        
        HATTwitterService.getAppTokenForTwitter(userDomain: userDomain, token: userToken, successful: self.fetchTwitterData, failed: {_ in})
        
        // set datasource and delegate to self
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.hidesBottomBarWhenPushed = false
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        // reload collection view to adjust the cells to the new width
        self.collectionView.reloadData()
    }
    
    // MARK: - Fetch twitter data
    
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
        HATTwitterService.isTwitterDataPlugActive(token: appToken, successful: {_ in self.fetchTweets(parameters: parameters)}, failed: {_ in failed()})
    }
    
    /**
     Fetch tweets
     
     - parameter parameters: The url request parameters
     - returns: (Void) -> Void
     */
    private func fetchTweets(parameters: Dictionary<String, String>) -> Void {
        
        // try to access twitter plug
        let userToken = HATAccountService.getUsersTokenFromKeychain()
        let userDomain = HATAccountService.TheUserHATDomain()
        
        func twitterDataPlug(token: String?) {

            HATTwitterService.checkTwitterDataPlugTable(authToken: userToken, userDomain: userDomain, parameters: parameters, success: self.showTweets)
        }
        // show message that the social feed is downloading
        self.showEptyLabelWith(text: "Fetching social feed...")
        // change flag
        self.isTwitterAvailable = true
        
        func success(token: String) {
            
            // try to access twitter plug
            HATTwitterService.checkTwitterDataPlugTable(authToken: userToken, userDomain: userDomain, parameters: parameters, success: self.showTweets)
        }
        
        func failed(statusCode: Int) {
            
            if statusCode == 401 {
                
                let authoriseVC = AuthoriseUserViewController()
                authoriseVC.view.frame = CGRect(x: self.view.center.x - 50, y: self.view.center.y - 20, width: 100, height: 40)
                authoriseVC.view.layer.cornerRadius = 15
                authoriseVC.completionFunc = twitterDataPlug
                
                // add the page view controller to self
                self.addChildViewController(authoriseVC)
                self.view.addSubview(authoriseVC.view)
                authoriseVC.didMove(toParentViewController: self)
            }
        }
        
        // delete data from hat and remove from table
        HATAccountService.checkIfTokenIsActive(token: userToken, success: success, failed: failed)
    }
    
    /**
     Show the fetched tweets
     
     - parameter array: The array that the request returned
     */
    private func showTweets(array: [JSON]) {
        
        // check if the view is loaded and visible, else don't bother showing the data
        if self.isViewLoaded && (self.view.window != nil) {
            
            // switch to the background queue
            DispatchQueue.global().async { [weak self]
                () -> Void in
                
                if let weakSelf = self {
                    
                    // filter data from duplicates
                    var filteredArray = HATTwitterService.removeDuplicatesFrom(array: array)
                    
                    // sort array
                    filteredArray = weakSelf.sortArray(array: filteredArray) as! [HATTwitterSocialFeedObject]
                    
                    // for each dictionary parse it and add it to the array
                    for tweets in filteredArray {
                        
                        weakSelf.tweets.append(tweets)
                    }
                    
                    if weakSelf.twitterEndTime == nil {
                        
                        weakSelf.reloadCollectionView(with: weakSelf.filterBy)
                    }
                    
                    // if the returned array is equal or bigger than the defined limit make a new request with more data while this thread will continue to show that data
                    if array.count == Int(weakSelf.twitterLimitParameter) {
                        
                        // get the unix time stamp
                        let elapse = (filteredArray.last?.protocolLastUpdate)!.timeIntervalSince1970
                        
                        let temp = String(elapse)
                        
                        let array2 = temp.components(separatedBy: ".")
                        
                        // save the time stamp
                        weakSelf.twitterEndTime = array2[0]
                        
                        // increase the limit
                        weakSelf.twitterLimitParameter = "500"
                        
                        // removes duplicates
                        weakSelf.removeDuplicates()
                        
                        // rebuild data
                        weakSelf.rebuildDataArray(filter: weakSelf.filterBy)
                        // else nil the flags we use and reload collection view with the saved filter
                    } else {
                        
                        weakSelf.twitterEndTime = nil
                        weakSelf.reloadCollectionView(with: weakSelf.filterBy)
                    }
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
        HATFacebookService.isFacebookDataPlugActive(token: appToken,
                        successful:
                            {(result: Bool) in _ = self.fetchPosts(parameters: parameters)},
                        failed: {_ in failed()})
    }
    
    /**
     Fetch posts
     
     - parameter parameters: The url request parameters
     - returns: (Void) -> Void
     */
    private func fetchPosts(parameters: Dictionary<String, String>) -> Void {
        
        // get user's token
        let userToken = HATAccountService.getUsersTokenFromKeychain()
        let userDomain = HATAccountService.TheUserHATDomain()
        
        // show message that the social feed is downloading
        self.showEptyLabelWith(text: "Fetching social feed...")
        // change flag
        self.isFacebookAvailable = true
        
        func fetchPostsCurryingFunc(token: String?) {
            
            // try to access facebook plug
            HATFacebookService.facebookDataPlug(authToken: userToken, userDomain: userDomain, parameters: parameters, success: self.showPosts)
            
            // switch to another thread
            DispatchQueue.global().async { [weak self] () -> Void in
                
                if let weakSelf2 = self {
                    
                    // if no facebook profile image download onw
                    if weakSelf2.facebookProfileImage == nil {
                        
                        // the returned array for the request
                        func success(array: [JSON]) -> Void {
                            
                            if array.count > 0 {
                                
                                weakSelf2.facebookProfileImage = UIImageView()
                                
                                // extract image
                                if let url = URL(string: array[0]["data"]["profile_picture"]["url"].stringValue) {
                                    
                                    // download image
                                    weakSelf2.facebookProfileImage?.downloadedFrom(url: url, completion: nil)
                                } else {
                                    
                                    // set image to nil
                                    weakSelf2.facebookProfileImage = nil
                                }
                            }
                        }
                        // fetch facebook image
                        HATFacebookService.fetchProfileFacebookPhoto(authToken: userToken, userDomain: userDomain, parameters: [:], success: success)
                    }
                }
            }
        }
        
        func success(token: String) {
            
            fetchPostsCurryingFunc(token: "")
        }
        
        func failed(statusCode: Int) {
            
            if statusCode == 401 {
                
                let authoriseVC = AuthoriseUserViewController()
                authoriseVC.view.frame = CGRect(x: self.view.center.x - 50, y: self.view.center.y - 20, width: 100, height: 40)
                authoriseVC.view.layer.cornerRadius = 15
                authoriseVC.completionFunc = fetchPostsCurryingFunc
                
                // add the page view controller to self
                self.addChildViewController(authoriseVC)
                self.view.addSubview(authoriseVC.view)
                authoriseVC.didMove(toParentViewController: self)
            }
        }
        
        // delete data from hat and remove from table
        HATAccountService.checkIfTokenIsActive(token: userToken, success: success, failed: failed)
    }
    
    /**
     Show the fetched posts
     
     - parameter array: The array that the request returned
     */
    private func showPosts(array: [JSON]) {
        
        // check if the view is loaded and visible, else don't bother showing the data
         if self.isViewLoaded && (self.view.window != nil) {
            
            // switch to the background queue
            DispatchQueue.global().async { [weak self] () -> Void in
                
                if let weakSelf = self {
                    
                    // removes duplicates from parameter array
                    var filteredArray = HATFacebookService.removeDuplicatesFrom(array: array)
                    
                    // sort array
                    filteredArray = weakSelf.sortArray(array: filteredArray) as! [HATFacebookSocialFeedObject]
                        
                    // for each dictionary parse it and add it to the array
                    for posts in filteredArray {
                        
                        weakSelf.posts.append(posts)
                    }
                
                    if weakSelf.facebookEndTime == nil {
                        
                        // removes duplicates
                        weakSelf.reloadCollectionView(with: weakSelf.filterBy)
                    }
                    
                    // if the returned array is equal or bigger than the defined limit make a new request with more data while this thread will continue to show that data
                    if array.count == Int(weakSelf.facebookLimitParameter) {
                        
                        // get the unix time stamp
                        let elapse = (filteredArray.last?.data.posts.createdTime)!.timeIntervalSince1970
                        
                        let temp = String(elapse)
                        
                        let array2 = temp.components(separatedBy: ".")
                        
                        // save the time stamp
                        weakSelf.facebookEndTime = array2[0]
                        
                        // increase the limit
                        weakSelf.facebookLimitParameter = "500"
                        
                        // removes duplicates
                        weakSelf.removeDuplicates()
                        
                        // rebuild data
                        weakSelf.rebuildDataArray(filter: weakSelf.filterBy)
                        // else nil the flags we use and reload collection view with the saved filter
                    } else {
                        
                        weakSelf.facebookEndTime = nil
                        // removes duplicates
                        weakSelf.reloadCollectionView(with: weakSelf.filterBy)
                    }
                }
            }
        }
    }
    
    // MARK: - Collection View methods

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // if this index path is FacebookSocialFeedObject
        if let post = self.cachedDataArray[indexPath.row] as? HATFacebookSocialFeedObject {
            
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
            let tweet = self.cachedDataArray[indexPath.row] as? HATTwitterSocialFeedObject
            
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
        if let post = self.cachedDataArray[indexPath.row] as? HATFacebookSocialFeedObject{
            
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
                let size = self.calculateCellHeight(text: text, width: self.collectionView.frame.width - 20)
                
                // calculate size of image based on the image ratio
                let imageHeight = collectionView.frame.width / 2.46
                
                // return size
                return CGSize(width: collectionView.frame.width, height: 85 + size.height + imageHeight)
            }
            
            // else return size of text plus the cell
            let text = post.data.posts.description + "\n\n" + post.data.posts.link
            let size = self.calculateCellHeight(text: text, width: self.collectionView.frame.width - 20)
            
            return CGSize(width: collectionView.frame.width, height: 85 + size.height)
        } else {
            
            //return size of text plus the cell
            let tweet = self.cachedDataArray[indexPath.row] as! HATTwitterSocialFeedObject
            
            let text = tweet.data.tweets.text
            let size = self.calculateCellHeight(text: text, width: self.collectionView.frame.width - 20)
            
            return CGSize(width: collectionView.frame.width, height: 100 + size.height)
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
        
        return text.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: nil, context: nil).size
    }
    
    // MARK: - Sort array
    
    /**
     Sorts array based on crated times
     
     - parameter array: The array to sort
     - returns: A sorted SocialFeedObject array based on crated times
     */
    private func sortArray(array: [HATSocialFeedObject]) -> [HATSocialFeedObject] {
        
        // the method to sort the array
        func sorting(a: HATSocialFeedObject, b: HATSocialFeedObject) -> Bool {
            
            // if a is FacebookSocialFeedObject
            if let postA = a as? HATFacebookSocialFeedObject {
                
                // if b is FacebookSocialFeedObject
                if let postB = b as? HATFacebookSocialFeedObject {
                    
                    // return true of false based on this result
                    return (postA.data.posts.createdTime)! > (postB.data.posts.createdTime)!
                // else b is TwitterSocialFeedObject
                } else {
                    
                    let tweetB = b as? HATTwitterSocialFeedObject
                    // return true of false based on this result
                    return (postA.data.posts.createdTime)! > (tweetB!.data.tweets.createdAt)!
                }
            // else a is TwitterSocialFeedObject
            } else {
                
                let tweetA = a as? HATTwitterSocialFeedObject
                
                // if b is FacebookSocialFeedObject
                if let postB = b as? HATFacebookSocialFeedObject {
                    
                    // return true of false based on this result
                    return (tweetA!.data.tweets.createdAt)! > (postB.data.posts.createdTime)!
                // if b is TwitterSocialFeedObject
                } else {
                    
                    let tweetB = b as? HATTwitterSocialFeedObject
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
        
        self.posts = HATFacebookService.removeDuplicatesFrom(array: self.posts)
        self.tweets = HATTwitterService.removeDuplicatesFrom(array: self.tweets)
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
                
                self.allData.append(post as HATSocialFeedObject)
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
                
                self.allData.append(post as HATSocialFeedObject)
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
    @objc private func filterSocialNetworksButtonAction() {
        
        // create alert
        let alert = UIAlertController(title: "Filter by:", message: "", preferredStyle: .actionSheet)
        
        // create actions
        let facebookAction = UIAlertAction(title: "Facebook", style: .default, handler: { [weak self](action) -> Void in
            
            if let weakSelf = self {
                
                weakSelf.cachedDataArray.removeAll()
                
                if weakSelf.posts.count > 0 {
                    
                    for i in 0...weakSelf.posts.count - 1 {
                        
                        weakSelf.cachedDataArray.append(weakSelf.posts[i] as HATSocialFeedObject)
                    }
                }
                
                weakSelf.filterBy = "Facebook"
                
                weakSelf.reloadCollectionView(with: weakSelf.filterBy)
            }
        })
        
        let twitterAction = UIAlertAction(title: "Twitter", style: .default, handler: { [weak self](action) -> Void in
            
             if let weakSelf = self {
                
                weakSelf.cachedDataArray.removeAll()
                
                if weakSelf.tweets.count > 0 {
                    
                    for i in 0...weakSelf.tweets.count - 1 {
                        
                        weakSelf.cachedDataArray.append(weakSelf.tweets[i])
                    }
                }
                
                weakSelf.filterBy = "Twitter"
                
                weakSelf.reloadCollectionView(with: weakSelf.filterBy)
            }
        })
        
        let allNetworksAction = UIAlertAction(title: "All", style: .default, handler: { [weak self](action) -> Void in
            
            if let weakSelf = self {
                
                weakSelf.cachedDataArray.removeAll()
                
                if weakSelf.tweets.count > 0 {
                    
                    for i in 0...weakSelf.tweets.count - 1 {
                        
                        weakSelf.cachedDataArray.append(weakSelf.tweets[i])
                    }
                }
                
                if weakSelf.posts.count > 0 {
                    
                    for i in 0...weakSelf.posts.count - 1 {
                        
                        weakSelf.cachedDataArray.append(weakSelf.posts[i] as HATSocialFeedObject)
                    }
                }
                
                weakSelf.filterBy = "All"
                
                weakSelf.reloadCollectionView(with: weakSelf.filterBy)
            }
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
            
            alert.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            alert.popoverPresentationController?.sourceView = self.view
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
