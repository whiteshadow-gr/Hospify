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

import SafariServices

// MARK: Class

/// The data plugs View in the tab bar view controller
class DataPlugsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Variables
    
    /// An array with the available data plugs
    private var dataPlugs: [DataPlugObject] = []
    /// Device's orientation, used to format the collection view cell according to width of the screen
    private var orientation: UIInterfaceOrientation = .portrait
    /// A view to show that app is loading, fetching data plugs
    private var loadingView: UIView = UIView()
    /// A reference to safari view controller in order to be able to show or hide it
    private var safariVC: SFSafariViewController? = nil
    
    // MARK: - IBActions
    
    /**
     Shows a pop up with the available settings
     
     - parameter sender: The object that calls this function
     */
    @IBAction func settingsButtonAction(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Settings", message: nil, preferredStyle: .actionSheet)
        
        let logOutAction = UIAlertAction(title: "Log out", style: .default, handler: {(alert: UIAlertAction) -> Void
            
            in
            TabBarViewController.logoutUser(from: self)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
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
    
    // MARK: - View controller methods

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // add notification observer for response from server
        NotificationCenter.default.addObserver(self, selector: #selector(showAlertForDataPlug), name: Notification.Name(Constants.NotificationNames.dataPlug.rawValue), object: nil)
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
                
                if data[i].name == "twitter" || data[i].name == "facebook" {
                    
                    self.dataPlugs.append(data[i])
                }
            }
            
            // check if dataplugs are active
            self.checkDataPlugsIfActive()
        }
        
        /// method to execute on a failed callback
        func failureCallBack() {
            
            // remove the loading screen from the view
            self.loadingView.removeFromSuperview()
        }
        
        self.createLoadingView()
        
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
        
        func setupCheckMark(on: String, value: Bool) {
            
            // search in data plugs array for facebook and enable the checkmark
            for i in 0 ... dataPlugs.count - 1 {
                
                if dataPlugs[i].name == on {
                    
                    self.dataPlugs[i].showCheckMark = value
                    self.collectionView?.reloadData()
                    self.loadingView.removeFromSuperview()
                }
            }
        }
        
        /// Check if facebook is active
        func checkIfFacebookIsActive(appToken: String) {
            
            /// if facebook active, enable the checkmark
            func enableCheckMarkOnFacebook() {
                
                setupCheckMark(on: "facebook", value: true)
            }
            
            /// if facebook inactive, disable the checkmark
            func disableCheckMarkOnFacebook() {
                
                setupCheckMark(on: "facebook", value: false)
            }
            
            // check if facebook active
            FacebookDataPlugService.isFacebookDataPlugActive(token: appToken, successful: enableCheckMarkOnFacebook, failed: disableCheckMarkOnFacebook)
        }
        
        /// Check if twitter is active
        func checkIfTwitterIsActive(appToken: String) {
            
            /// if twitter active, enable the checkmark
            func enableCheckMarkOnTwitter() {
                
                setupCheckMark(on: "twitter", value: true)
            }
            
            /// if twitter inactive, disable the checkmark
            func disableCheckMarkOnTwitter() {
                
                setupCheckMark(on: "twitter", value: false)
            }
            
            // check if twitter active
            TwitterDataPlugService.isTwitterDataPlugActive(token: appToken, successful: enableCheckMarkOnTwitter, failed: disableCheckMarkOnTwitter)
        }
        
        // get token for facebook and twitter and check if they are active
        FacebookDataPlugService.getAppTokenForFacebook(successful: checkIfFacebookIsActive, failed: {})

        TwitterDataPlugService.getAppTokenForTwitter(successful: checkIfTwitterIsActive, failed: {})
    }

    // MARK: - UICollectionView methods

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.dataPlugs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellReuseIDs.dataplug.rawValue, for: indexPath) as? DataPlugCollectionViewCell
    
        return DataPlugCollectionViewCell.setUp(cell: cell!, indexPath: indexPath, dataPlug: self.dataPlugs[indexPath.row], orientation: self.orientation)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let url = self.createURLBasedOn(row: indexPath.row)
        
        if url != nil && self.safariVC != nil {
            
            // open safari view controller
            self.safariVC = SFSafariViewController(url: url!)
            self.present(self.safariVC!, animated: true, completion: nil)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // in case of landscape show 3 tiles instead of 2
        if self.orientation == .landscapeLeft || self.orientation == .landscapeRight {
            
            return CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
        }
        
        return CGSize(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 2)
    }
    
    // MARK: - Create URL
    
    /**
     Creates the url to connect to
     
     - parameter row: The row of the index path
     - returns: A ready URL if everything ok else nil
     */
    private func createURLBasedOn(row: Int) -> URL? {
        
        // set up the url to open safari to
        let userDomain: String = HatAccountService.TheUserHATDomain()
        let name: String = self.dataPlugs[row].name
        var url: String = ""
        
        if name == "twitter" {
            
            url = "https://" + userDomain + "/hatlogin?name=Twitter&redirect=" + self.dataPlugs[row].url + "/authenticate/hat"
        } else if name == "facebook" {
            
            url = "https://" + userDomain + "/hatlogin?name=Facebook&redirect=" + self.dataPlugs[row].url.replacingOccurrences(of: "dataplug", with: "hat/authenticate")
        }
        
        return URL(string: url)
    }
    
    // MARK: - Create floating view
    
    /**
     Adds a floating view while fetching the data plugs
     */
    private func createLoadingView() {
        
        // init loading view
        self.loadingView.createFloatingView(frame: CGRect(x: (self.collectionView?.frame.midX)! - 60, y: (self.collectionView?.frame.midY)! - 15, width: 120, height: 30), color: .tealColor(), cornerRadius: 15)
        
        let label = UILabel().createLabel(frame: CGRect(x: 0, y: 0, width: 120, height: 30), text: "Getting data plugs...", textColor: .white, textAlignment: .center, font: UIFont(name: "OpenSans", size: 12))
        
        // add label to loading view
        self.loadingView.addSubview(label)
        
        // present loading view
        self.view.addSubview(self.loadingView)
    }
}
