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
    private var dataArray: [SocialFeedObject] = []
    private var cachedDataArray: [Any] = []
    
    private var facebookProfileImage: UIImageView? = nil
    private var facebookEndTime: String? = nil
    private var facebookAppToken: String = ""
    private var facebookLimitParameter: String = "50" {
        
        didSet {
            
            self.fetchFacebookData(appToken: self.facebookAppToken)
        }
    }
    
    private var twitterEndTime: String? = nil
    private var twitterAppToken: String = ""
    private var twitterLimitParameter: String = "50" {
        
        didSet {
            
            self.fetchTwitterData(appToken: self.twitterAppToken)
        }
    }
    
    private var isFacebookAvailable = false
    
    private var isTwitterAvailable = false
    
    private var isFacebookDownloading = false {
        
        didSet {
            
            self.reloadCollectionView()
        }
    }
    
    private var isTwitterDownloading = false {
        
        didSet {
            
            self.reloadCollectionView()
        }
    }
    
    func filterSocialNetworksButtonAction(notification: NSNotification) {
        
        let alert = UIAlertController(title: "Filter by:", message: "", preferredStyle: .actionSheet)
        
        let facebookAction = UIAlertAction(title: "Facebook", style: .default, handler: { [unowned self](action) -> Void in
            
            self.dataArray.removeAll()
            
            if self.posts.count > 0 {
                
                for i in 0...self.posts.count - 1 {
                    
                    self.dataArray.append(self.posts[i])
                }
            }
            
            self.reloadCollectionView()
        })
        
        let twitterAction = UIAlertAction(title: "Twitter", style: .default, handler: { [unowned self](action) -> Void in
            
            self.dataArray.removeAll()
            
            if self.tweets.count > 0 {
                
                for i in 0...self.tweets.count - 1 {
                    
                    self.dataArray.append(self.tweets[i])
                }
            }
            
            self.reloadCollectionView()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
            return
        })
        
        alert.addAction(facebookAction)
        alert.addAction(twitterAction)
        alert.addAction(cancelAction)
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            
            alert.popoverPresentationController?.barButtonItem = self.navigationItem.leftBarButtonItem
            alert.popoverPresentationController?.sourceView = self.view;
        }
        
        self.navigationController!.present(alert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.showEptyLabelWith(text: "Checking data plugs...")
        
        // add notification observers
        NotificationCenter.default.addObserver(self, selector: #selector(filterSocialNetworksButtonAction), name: NSNotification.Name("filterSocialFeed"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.dataArray.removeAll()
        
        FacebookDataPlugService.getAppTokenForFacebook(successful: self.fetchFacebookData, failed: self.updateFacebookDataPlugStatus)
        
        self.isTwitterDownloading = true
        
        TwitterDataPlugService.getAppTokenForTwitter(successful: self.fetchTwitterData, failed: self.updateTwitterDataPlugStatus)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Facebook
    
    func showPosts(array: [JSON]) {
        
        DispatchQueue.global().async { [unowned self]
            () -> Void in
            
            var filteredArray = FacebookDataPlugService.removeDuplicatesFrom(array: array)
            
            func sorting(a: FacebookSocialFeedObject, b: FacebookSocialFeedObject) -> Bool {
                
                return a.tryingLastUpdate! > b.tryingLastUpdate!
            }
            
            filteredArray = filteredArray.sorted(by: sorting)
            
            // for each dictionary parse it and add it to the array
            for posts in filteredArray {
                
                self.posts.append(posts)
                self.dataArray.append(posts)
            }
            
            if array.count == Int(self.facebookLimitParameter) {
                
                let elapse = (filteredArray.last?.tryingLastUpdate)!.timeIntervalSince1970
                
                let temp = String(elapse)
                
                let array2 = temp.components(separatedBy: ".")
                
                self.facebookEndTime = array2[0]
                
                self.facebookLimitParameter = "500"
            } else {
                
                self.facebookEndTime = nil
            }
            
            DispatchQueue.main.async { [unowned self]
                () -> Void in
                
                print("Received " + String(array.count) + " posts")
                
                self.isFacebookDownloading = false
            }
        }
    }
    
    func fetchFacebookData(appToken: String) {
        
        self.isFacebookDownloading = true
        
        self.facebookAppToken = appToken
        
        self.showEptyLabelWith(text: "Fetching social feed...")
        
        var parameters: Dictionary<String, String> = ["limit" : self.facebookLimitParameter,
                                                      "starttime" : "0"]
        
        if self.facebookEndTime != nil {
            
            parameters = ["limit" : self.facebookLimitParameter,
                          "starttime" : "0",
                          "endtime" : self.facebookEndTime!]
        }
        
        FacebookDataPlugService.isFacebookDataPlugActive(token: appToken, successful: self.fetchPosts(parameters: parameters), failed: self.updateFacebookDataPlugStatus)
    }
    
    func fetchPosts(parameters: Dictionary<String, String>) -> (Void) -> Void {
        
        return { [unowned self](Void) -> Void in
            
            self.isFacebookAvailable = true
            
            let token = HatAccountService.getUsersTokenFromKeychain()
            FacebookDataPlugService.facebookDataPlug(authToken: token, parameters: parameters, success: self.showPosts)
            
//            if self.facebookProfileImage == nil {
//                
//                func success(array: [JSON]) -> Void {
//                    
//                    self.facebookProfileImage = UIImageView()
//                    
//                    let dict = array[0].dictionaryValue
//                    let object = FacebookSocialFeedObject(from: dict)
//                    self.facebookProfileImage?.downloadedFrom(url: URL(string:object.data.posts.picture)!)
//                }
//                FacebookDataPlugService.fetchProfileFacebookPhoto(authToken: token, parameters: ["X-Auth-Token" : token], success: success)
//            }
        }
    }
    
    func updateFacebookDataPlugStatus() {
        
        self.isFacebookAvailable = false
        self.isFacebookDownloading = false
    }
    
    // MARK - Twitter
    
    func updateTwitterDataPlugStatus() {
        
        self.isTwitterAvailable = false
        self.isTwitterDownloading = false
    }
    
    func fetchTwitterData(appToken: String) {
        
        self.twitterAppToken = appToken
        
        self.showEptyLabelWith(text: "Fetching social feed...")
        
        var parameters: Dictionary<String, String> = ["limit" : self.twitterLimitParameter,
                                                      "starttime" : "0"]
        
        if self.twitterEndTime != nil {
            
            parameters = ["limit" : self.twitterLimitParameter,
                          "starttime" : "0",
                          "endtime" : self.twitterEndTime!]
        }
        TwitterDataPlugService.isTwitterDataPlugActive(token: appToken, successful: self.fetchTweets(parameters: parameters), failed: self.updateTwitterDataPlugStatus)
    }
    
    func fetchTweets(parameters: Dictionary<String, String>) -> (Void) -> Void {
        
        return { [unowned self](Void) -> Void in
            
            self.isTwitterAvailable = true
            
            let token = HatAccountService.getUsersTokenFromKeychain()
            TwitterDataPlugService.twitterDataPlug(authToken: token, parameters: parameters, success: (self.showTweets))
        }
    }
    
    func showTweets(array: [JSON]) {
        
        DispatchQueue.global().async { [unowned self]
            () -> Void in
            
            var filteredArray = TwitterDataPlugService.removeDuplicatesFrom(array: array)
            
            func sorting(a: TwitterSocialFeedObject, b: TwitterSocialFeedObject) -> Bool { 
                
                return a.tryingLastUpdate! > b.tryingLastUpdate!
            }
            
            filteredArray = filteredArray.sorted(by: sorting)
            
            // for each dictionary parse it and add it to the array
            for tweets in filteredArray {
                
                self.tweets.append(tweets)
                self.dataArray.append(tweets)
            }
            
            if array.count == Int(self.twitterLimitParameter) {
                
                let elapse = (filteredArray.last?.tryingLastUpdate)!.timeIntervalSince1970
                
                let temp = String(elapse)
                
                let array2 = temp.components(separatedBy: ".")
                
                self.twitterEndTime = array2[0]
                
                self.twitterLimitParameter = "500"
            } else {
                
                self.twitterEndTime = nil
            }
            
            DispatchQueue.main.async { [unowned self]
                () -> Void in
                
                print("Received " + String(array.count) + " tweets")
                
                self.isTwitterDownloading = false
            }
        }
    }
    
    // MARK: - Collection View methods

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let post = self.cachedDataArray[indexPath.row] as? FacebookSocialFeedObject {
            
            var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "statusSocialFeedCell", for: indexPath) as! SocialFeedCollectionViewCell
            
            if post.data.posts.type == "photo" {
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageSocialFeedCell", for: indexPath) as! SocialFeedCollectionViewCell
            }
            
            cell.profileImage.image = self.facebookProfileImage?.image
            
            return SocialFeedCollectionViewCell.setUpCell(cell: cell, indexPath: indexPath, posts: post)
        } else {

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "statusSocialFeedCell", for: indexPath) as! SocialFeedCollectionViewCell
            
            return SocialFeedCollectionViewCell.setUpCell(cell: cell, indexPath: indexPath, posts: self.cachedDataArray[indexPath.row] as! TwitterSocialFeedObject)
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
        } else {
            
            let tweet = self.cachedDataArray[indexPath.row] as! TwitterSocialFeedObject
            
            let text = tweet.data.tweets.text
            let size = self.calculateCellHeight(text: text, width: self.collectionView.frame.width - 16)
            
            return CGSize(width: collectionView.frame.width, height: 95 + size.height)
        }
    }
    
    func calculateCellHeight(text: String, width: CGFloat) -> CGSize {
        
        let attributes: Dictionary<String, UIFont> = [NSFontAttributeName: UIFont(name: "Open Sans", size: 14)!]
        return text.boundingRect( with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil).size
    }
    
    func reloadCollectionView() {
        
       if !self.isFacebookDownloading && !isTwitterDownloading {
        
             if !self.isTwitterAvailable && !isFacebookAvailable {
                
                self.createClassicOKAlertWith(alertMessage: "Please enable at least one data plug in order to use social feed", alertTitle: "No data plugs found", okTitle: "OK", proceedCompletion: {self.showEptyLabelWith(text: "Please enable at least one data plug in order to use social feed")})
             }
        }
                
        DispatchQueue.global().async {[unowned self]
            () -> Void in
            
            self.sortFeed()
            
            self.cachedDataArray = self.dataArray.map {($0 as AnyObject)}
            
            print("tweets array " + String(self.tweets.count))
            print("posts array " + String(self.posts.count))
            print("data array " + String(self.dataArray.count))
            print("cached data array " + String(self.cachedDataArray.count))
            
            if self.cachedDataArray.count > 0 {
                
                DispatchQueue.main.async { [unowned self]
                    () -> Void in
                    
                    self.collectionView.reloadData()
                    
                    self.showEptyLabelWith(text: "")
                }
            }
        }
    }
    
    func showEptyLabelWith(text: String) {
        
        if text == "" {
            
            self.collectionView.isHidden = false
            self.emptyCollectionViewLabel.text = text
        } else {
            
            if self.cachedDataArray.count == 0 {
                
                self.collectionView.isHidden = true
                self.emptyCollectionViewLabel.text = text
            }
        }
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        self.collectionView.reloadData()
    }
    
    func sortFeed() {
        
        func sorting(a: SocialFeedObject, b: SocialFeedObject) -> Bool {
            
            return a.tryingLastUpdate! > b.tryingLastUpdate!
        }

        self.dataArray = self.dataArray.sorted(by: sorting)
    }

}
