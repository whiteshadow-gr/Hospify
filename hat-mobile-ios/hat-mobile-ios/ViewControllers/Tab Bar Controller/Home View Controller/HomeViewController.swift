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

/// The class responsible for the landing screen
class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    /// The tiles to show
    private var tiles: [HomeScreenObject] = []
    
    /// A dark view covering the collection view cell
    private var darkView: UIVisualEffectView? = nil
    
    private var authoriseVC: AuthoriseUserViewController? = nil
    
    private let location = UpdateLocations.shared
    
    // MARK: - IBOutlets

    /// An IBOutlet for handling the circle progress bar view
    @IBOutlet weak var ringProgressBar: RingProgressCircle!
    
    /// An IBOutlet for handling the collection view
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// An IBOutlet for handling the hello label on the top of the screen
    @IBOutlet weak var helloLabel: UILabel!
    
    // MARK: - IBActions
    
    /**
     Shows a pop up info about the data services
     
     - parameter sender: The object that called this method
     */
    @IBAction func showInfoButtonAction(_ sender: Any) {
        
        self.showInfoViewController(text: "Rumpel Lite's Data Services are all the neat things you can do with your HAT data. Pull your data in with Data Plugs, and make it useful to you with Data Services.")
    }
    
    // MARK: - Collection View methods
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeScreenCell", for: indexPath) as? HomeCollectionViewCell
        
        let orientation = UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue)!
        return HomeCollectionViewCell.setUp(cell: cell!, indexPath: indexPath, object: self.tiles[indexPath.row], orientation: orientation)
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.tiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let orientation = UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue)!
        // in case of landscape show 3 tiles instead of 2
        if orientation == .landscapeLeft || orientation == .landscapeRight {
            
            return CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
        }
        
        return CGSize(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.CellReuseIDs.homeHeader.rawValue, for: indexPath) as! HomeHeaderCollectionReusableView
        
        headerView.headerTitle.text = "Data Services"
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.tiles[indexPath.row].serviceName == "Notes" {
            
            self.performSegue(withIdentifier: "notesSegue", sender: self)
        } else if self.tiles[indexPath.row].serviceName == "Locations" {
            
            self.performSegue(withIdentifier: "locationsSegue", sender: self)
        } else if self.tiles[indexPath.row].serviceName == "Social Data" {
            
            self.performSegue(withIdentifier: "socialDataSegue", sender: self)
        } else if self.tiles[indexPath.row].serviceName == "Photo Viewer" {
            
            self.performSegue(withIdentifier: "photoViewerSegue", sender: self)
        }
    }
    
    // MARK: - View controller methods

    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.tiles = HomeScreenObject.setUpTilesForHomeScreen()
        
        self.ringProgressBar.ringColor = .white
        self.ringProgressBar.ringRadius = 45
        self.ringProgressBar.ringLineWidth = 4
        self.ringProgressBar.animationDuration = 0.2

        NotificationCenter.default.addObserver(self, selector: #selector(hidePopUp), name: NSNotification.Name("hideDataServicesInfo"), object: nil)
        
        // pin header view of collection view to the top while scrolling
        (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).sectionHeadersPinToVisibleBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.ringProgressBar.isHidden = true
        
        func success(token: String?) {
            
            if token != "" && token != nil {
                
                _ = KeychainHelper.SetKeychainValue(key: "UserToken", value: token!)
                _ = KeychainHelper.SetKeychainValue(key: "logedIn", value: "true")
                
                self.authoriseVC?.removeViewController()
                self.authoriseVC = nil
            }
        }
        
        func failed() {
            
            NotificationCenter.default.post(name: NSNotification.Name("NetworkMessage"), object: "Unauthorized. Please sign out and try again.")
            _ = KeychainHelper.SetKeychainValue(key: "logedIn", value: "expired")
            
            self.authoriseVC = AuthoriseUserViewController.setupAuthoriseViewController(view: self.view)
            self.authoriseVC?.completionFunc = success
            // addauthoriseVCthe page view controller to self
            self.addViewController(self.authoriseVC!)
        }
        
        // reset the stack to avoid allowing back
        let result = KeychainHelper.GetKeychainValue(key: "logedIn")
        
        if result == "false" || userDomain == "" || userToken == "" {
            
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.navigationController?.pushViewController(loginViewController, animated: false)
        // user logged in, set up view
        } else {
            
            self.location.setUpLocationObject(self.location, delegate: UpdateLocations.shared)
            self.location.locationManager?.requestAlwaysAuthorization()
            
            // set up elements
            let usersHAT = userDomain.components(separatedBy: ".")[0]
            self.helloLabel.text = "Hello " + usersHAT + "!"
            
            // check if the token has expired
            HATAccountService.checkIfTokenExpired(token: userToken,
                                                  expiredCallBack: failed,
                                                  tokenValidCallBack: success,
                                                  errorCallBack: self.createClassicOKAlertWith)
            
            self.collectionView?.reloadData()
        }
        
        HATService.getSystemStatus(userDomain: userDomain, authToken: userToken, completion: updateRingProgressBar, failCallBack: CrashLoggerHelper.JSONParsingErrorLogWithoutAlert)
        
        self.collectionView.reloadData()
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        // reload collection view
        self.collectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Show pop up screens
    
    /**
     Shows newbie screens
     */
    private func showNewbieScreens() -> Void {
        
        // set up the created page view controller
        let pageViewController = self.storyboard!.instantiateViewController(withIdentifier: "firstTimeOnboarding") as! FirstOnboardingPageViewController
        pageViewController.view.createFloatingView(frame: CGRect(x: self.view.frame.origin.x + 15, y: self.view.frame.origin.x + 15, width: self.view.frame.width - 30, height: self.view.frame.height - 30), color: .teal, cornerRadius: 15)
        
        // add the page view controller to self
        self.addViewController(pageViewController)
        self.addBlurToView()
    }
    
    /**
     Shows the pop up view controller with the info passed on
     
     - parameter text: A String to show in the view controller
     */
    private func showInfoViewController(text: String) {
        
        // set up page controller
        let textPopUpViewController = TextPopUpViewController.customInit(stringToShow: text, from: self.storyboard!)
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        
        textPopUpViewController?.view.createFloatingView(frame: CGRect(x: self.view.frame.origin.x + 15, y: self.collectionView.frame.maxY, width: self.view.frame.width - 30, height: self.view.frame.height), color: .teal, cornerRadius: 15)
        
        DispatchQueue.main.async { [weak self] () -> Void in
            
            if let weakSelf = self {
                
                // add the page view controller to self
                weakSelf.addBlurToView()
                weakSelf.addViewController(textPopUpViewController!)
                AnimationHelper.animateView(textPopUpViewController?.view, duration: 0.2, animations: {() -> Void in
                    
                    textPopUpViewController?.view.frame = CGRect(x: weakSelf.view.frame.origin.x + 15, y: weakSelf.collectionView.frame.origin.y, width: weakSelf.view.frame.width - 30, height: weakSelf.view.frame.height)
                }, completion: {_ in return})
            }
        }
    }

    // MARK: - Remove pop up
    
    /**
     Hides pop up presented currently
     */
    @objc private func hidePopUp() {
        
        self.darkView?.removeFromSuperview()
        self.tabBarController?.tabBar.isUserInteractionEnabled = true
    }
    
    // MARK: - Add blur View 
    
    /**
     Adds blur to the view before presenting the pop up
     */
    private func addBlurToView() {
        
        self.darkView = AnimationHelper.addBlurToView(self.view)
    }
    
    // MARK: - Update ring progress bar
    
    /**
     Updates the system info on the top of the home screen view controller
     
     - parameter data: The objects received from the server
     */
    private func updateRingProgressBar(from data: [HATSystemStatusObject], renewedUserToken: String?) {
        
        if data.count > 0 {
            
            self.helloLabel.text = "Hello " + userDomain.components(separatedBy: ".")[0] + "!"
            
            self.ringProgressBar.isHidden = false

            var attributedString: NSAttributedString = NSAttributedString(string: self.helloLabel.text! + "\n")
            self.helloLabel.text = attributedString.combineWith(attributedText: NSAttributedString(string: "Total space " + data[2].kind.metric + " " + data[2].kind.units!)).string
            attributedString = NSAttributedString(string: self.helloLabel.text! + "\n")
            self.helloLabel.text = attributedString.combineWith(attributedText: NSAttributedString(string: "Used space " + String(describing: Int(Float(data[4].kind.metric)!.rounded())) + " " + data[4].kind.units!)).string
            
            let fullCircle = 2.0 * CGFloat(Double.pi)
            self.ringProgressBar.startPoint = -0.25 * fullCircle
            self.ringProgressBar.animationDuration = 0.2
            
            let endPoint = CGFloat(max(Float(data[6].kind.metric)!, 1.0)) / 100
            
            self.ringProgressBar.endPoint = (endPoint * fullCircle) + self.ringProgressBar.startPoint
            
            self.ringProgressBar.updateCircle(end: endPoint, animate: 0, to: Float(self.ringProgressBar.endPoint), removePreviousLayer: true)
        }
        
        // refresh user token
        _ = KeychainHelper.SetKeychainValue(key: "UserToken", value: renewedUserToken)
    }
    
}
