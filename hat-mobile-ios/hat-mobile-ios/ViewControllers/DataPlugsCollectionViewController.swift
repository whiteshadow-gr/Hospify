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
    private var orientation: UIInterfaceOrientation = .portrait
    private var loadingView: UIView = UIView()
    private var safariVC: SFSafariViewController? = nil
    
    // MARK: - View controller methods

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(showAlertForDataPlug), name: Notification.Name("dataPlugMessage"), object: nil)
    }
    
    func showAlertForDataPlug(notif: Notification) {
                
        if safariVC != nil {
            
            safariVC?.dismiss(animated: true, completion: nil)
        }
    }

    func checkDataPlugsIfActive() {
        
        func checkIfFacebookIsActive(appToken: String) {
            
            func enableCheckMarkOnFacebook() {
                
                for i in 0 ... dataPlugs.count - 1 {
                    
                    if dataPlugs[i].name == "facebook" {
                        
                        self.dataPlugs[i].showCheckMark = true
                        self.collectionView?.reloadData()
                        self.loadingView.removeFromSuperview()
                    }
                }
            }
            
            func disableCheckMarkOnFacebook() {
                
                for i in 0 ... dataPlugs.count - 1 {
                    
                    if dataPlugs[i].name == "facebook" {
                        
                        self.dataPlugs[i].showCheckMark = false
                        self.collectionView?.reloadData()
                        self.loadingView.removeFromSuperview()
                    }
                }
            }
            
            FacebookDataPlugService.isFacebookDataPlugActive(token: appToken, successful: enableCheckMarkOnFacebook, failed: disableCheckMarkOnFacebook)
        }
        
        func checkIfTwitterIsActive(appToken: String) {
            
            func enableCheckMarkOnTwitter() {
                
                for i in 0 ... dataPlugs.count - 1 {
                    
                    if dataPlugs[i].name == "twitter" {
                        
                        self.dataPlugs[i].showCheckMark = true
                        self.collectionView?.reloadData()
                        self.loadingView.removeFromSuperview()
                    }
                }
            }
            
            func disableCheckMarkOnTwitter() {
                
                for i in 0 ... dataPlugs.count - 1 {
                    
                    if dataPlugs[i].name == "twitter" {
                        
                        self.dataPlugs[i].showCheckMark = false
                        self.collectionView?.reloadData()
                        self.loadingView.removeFromSuperview()
                    }
                }
            }
            
            TwitterDataPlugService.isTwitterDataPlugActive(token: appToken, successful: enableCheckMarkOnTwitter, failed: disableCheckMarkOnTwitter)
        }
        
    
        FacebookDataPlugService.getAppTokenForFacebook(successful: checkIfFacebookIsActive, failed: {() -> Void in return})

        TwitterDataPlugService.getAppTokenForTwitter(successful: checkIfTwitterIsActive, failed: {() -> Void in return})
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.orientation = UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue)!
        
        func successfullCallBack(data: [DataPlugObject]) {
            
            self.dataPlugs.removeAll()
            
            for i in 0 ... data.count - 1 {
                
                if data[i].name == "twitter" {
                    
                    self.dataPlugs.append(data[i])
                }
                if data[i].name == "facebook" {
                    
                    self.dataPlugs.append(data[i])
                }
            }
            
            checkDataPlugsIfActive()
        }
        
        func failureCallBack() {
            
           self.loadingView.removeFromSuperview()
        }
        
        loadingView = UIView(frame: CGRect(x: (self.collectionView?.frame.midX)! - 60, y: (self.collectionView?.frame.midY)! - 15, width: 120, height: 30))
        loadingView.backgroundColor = UIColor.tealColor()
        loadingView.layer.cornerRadius = 15
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
        label.text = "Getting data plugs..."
        label.textColor = .white
        label.font = UIFont(name: "OpenSans", size: 12)
        label.textAlignment = NSTextAlignment.center
        
        loadingView.addSubview(label)
        
        self.view.addSubview(loadingView)
        DataPlugsService.getAvailableDataPlugs(succesfulCallBack: successfullCallBack, failCallBack: failureCallBack)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        let userDomain: String = HatAccountService.TheUserHATDomain()
        let name: String = self.dataPlugs[indexPath.row].name
        var url: String = ""
        
        if name == "twitter" {
            
            url = "https://" + userDomain + "/hatlogin?name=Twitter&redirect=" + self.dataPlugs[indexPath.row].url + "/authenticate/hat"
        } else if name == "facebook" {
            
            url = "https://" + userDomain + "/hatlogin?name=Facebook&redirect=" + self.dataPlugs[indexPath.row].url.replacingOccurrences(of: "dataplug", with: "hat/authenticate")
        }
        
        self.safariVC = SFSafariViewController(url: URL(string: url)!)
        //self.safariVC?.delegate = self
        self.present(self.safariVC!, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if self.orientation == .landscapeLeft || self.orientation == .landscapeRight {
            
            return CGSize(width: UIScreen.main.bounds.width/3, height: UIScreen.main.bounds.width/3)
        }
        
        return CGSize(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        self.orientation = toInterfaceOrientation
        
        self.collectionView?.reloadData()
    }
}
