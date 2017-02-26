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
import SafariServices

// MARK: Class

/// The data plugs View in the tab bar view controller
class DataPlugsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Variables
    
    /// Cell's reuse identifier
    private let reuseIdentifier = "dataPlugCell"
    /// An array with the available data plugs
    private var dataPlugs: [DataPlugObject] = []
    /// Device's orientation, used to format the collection view cell according to width of the screen
    private var orientation: UIInterfaceOrientation = .portrait
    /// A view to show that app is loading, fetching data plugs
    private var loadingView: UIView = UIView()
    /// A reference to safari view controller in order to be able to show or hide it
    private var safariVC: SFSafariViewController? = nil
    
    // MARK: - View controller methods

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // add notification observer for response from server
        NotificationCenter.default.addObserver(self, selector: #selector(showAlertForDataPlug), name: Notification.Name("dataPlugMessage"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // check orientation
        self.orientation = UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue)!
        
        /// method to execute on a successful callback
        func successfullCallBack(data: [DataPlugObject]) {
            
            // remove the existing dataplugs from array
            self.dataPlugs.removeAll()
            
            // we want only facebook and twitter, so keep those
            for i in 0 ... data.count - 1 {
                
                if data[i].name == "twitter" {
                    
                    self.dataPlugs.append(data[i])
                }
                if data[i].name == "facebook" {
                    
                    self.dataPlugs.append(data[i])
                }
            }
            
            // check if dataplugs are active
            checkDataPlugsIfActive()
        }
        
        /// method to execute on a failed callback
        func failureCallBack() {
            
            // remove the loading screen from the view
            self.loadingView.removeFromSuperview()
        }
        
        // init loading view
        loadingView = UIView(frame: CGRect(x: (self.collectionView?.frame.midX)! - 60, y: (self.collectionView?.frame.midY)! - 15, width: 120, height: 30))
        loadingView.backgroundColor = UIColor.tealColor()
        loadingView.layer.cornerRadius = 15
        
        // create label to show in loading view
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
        label.text = "Getting data plugs..."
        label.textColor = .white
        label.font = UIFont(name: "OpenSans", size: 12)
        label.textAlignment = NSTextAlignment.center
        
        // add label to loading view
        loadingView.addSubview(label)
        
        // present loading view
        self.view.addSubview(loadingView)
        
        // get available data plugs from server
        DataPlugsService.getAvailableDataPlugs(succesfulCallBack: successfullCallBack, failCallBack: failureCallBack)
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        // save orientation
        self.orientation = toInterfaceOrientation
        
        // reload collection view
        self.collectionView?.reloadData()
    }
    
    // MARK: - Notification observer method
    
    /**
     Hides safari view controller
     
     - parameter notif: The notification object send
     */
    @objc private func showAlertForDataPlug(notif: Notification) {
        
        // check that safari is not nil, if it's not hide it
        if safariVC != nil {
            
            safariVC?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Check if data plugs are active

    /**
     Checks if both data plugs are active
     */
    private func checkDataPlugsIfActive() {
        
        /// Check if facebook is active
        func checkIfFacebookIsActive(appToken: String) {
            
            /// if facebook active, enable the checkmark
            func enableCheckMarkOnFacebook() {
                
                // search in data plugs array for facebook and enable the checkmark
                for i in 0 ... dataPlugs.count - 1 {
                    
                    if dataPlugs[i].name == "facebook" {
                        
                        self.dataPlugs[i].showCheckMark = true
                        self.collectionView?.reloadData()
                        self.loadingView.removeFromSuperview()
                    }
                }
            }
            
            /// if facebook inactive, disable the checkmark
            func disableCheckMarkOnFacebook() {
                
                // search in data plugs array for facebook and disable the checkmark
                for i in 0 ... dataPlugs.count - 1 {
                    
                    if dataPlugs[i].name == "facebook" {
                        
                        self.dataPlugs[i].showCheckMark = false
                        self.collectionView?.reloadData()
                        self.loadingView.removeFromSuperview()
                    }
                }
            }
            
            // check if facebook active
            FacebookDataPlugService.isFacebookDataPlugActive(token: appToken, successful: enableCheckMarkOnFacebook, failed: disableCheckMarkOnFacebook)
        }
        
        /// Check if twitter is active
        func checkIfTwitterIsActive(appToken: String) {
            
            /// if twitter active, enable the checkmark
            func enableCheckMarkOnTwitter() {
                
                // search in data plugs array for twitter and enable the checkmark
                for i in 0 ... dataPlugs.count - 1 {
                    
                    if dataPlugs[i].name == "twitter" {
                        
                        self.dataPlugs[i].showCheckMark = true
                        self.collectionView?.reloadData()
                        self.loadingView.removeFromSuperview()
                    }
                }
            }
            
            /// if twitter inactive, disable the checkmark
            func disableCheckMarkOnTwitter() {
                
                // search in data plugs array for twitter and disable the checkmark
                for i in 0 ... dataPlugs.count - 1 {
                    
                    if dataPlugs[i].name == "twitter" {
                        
                        self.dataPlugs[i].showCheckMark = false
                        self.collectionView?.reloadData()
                        self.loadingView.removeFromSuperview()
                    }
                }
            }
            
            // check if twitter active
            TwitterDataPlugService.isTwitterDataPlugActive(token: appToken, successful: enableCheckMarkOnTwitter, failed: disableCheckMarkOnTwitter)
        }
        
        // get token for facebook and twitter and check if they are active
        FacebookDataPlugService.getAppTokenForFacebook(successful: checkIfFacebookIsActive, failed: {() -> Void in return})

        TwitterDataPlugService.getAppTokenForTwitter(successful: checkIfTwitterIsActive, failed: {() -> Void in return})
    }

    // MARK: - UICollectionView methods

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dataPlugs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) as? DataPlugCollectionViewCell
    
        return DataPlugCollectionViewCell.setUp(cell: cell!, indexPath: indexPath, dataPlug: self.dataPlugs[indexPath.row], orientation: self.orientation)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // set up the url to open safari to
        let userDomain: String = HatAccountService.TheUserHATDomain()
        let name: String = self.dataPlugs[indexPath.row].name
        var url: String = ""
        
        if name == "twitter" {
            
            url = "https://" + userDomain + "/hatlogin?name=Twitter&redirect=" + self.dataPlugs[indexPath.row].url + "/authenticate/hat"
        } else if name == "facebook" {
            
            url = "https://" + userDomain + "/hatlogin?name=Facebook&redirect=" + self.dataPlugs[indexPath.row].url.replacingOccurrences(of: "dataplug", with: "hat/authenticate")
        }
        
        // open safari view controller
        self.safariVC = SFSafariViewController(url: URL(string: url)!)
        self.present(self.safariVC!, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // in case of landscape show 3 tiles instead of 2
        if self.orientation == .landscapeLeft || self.orientation == .landscapeRight {
            
            return CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
        }
        
        return CGSize(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 2)
    }
}
