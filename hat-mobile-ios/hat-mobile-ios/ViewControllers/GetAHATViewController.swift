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

import Stripe
import Alamofire

// MARK: Class

/// Get A hat view controller, used in onboarding of new users
class GetAHATViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, STPAddCardViewControllerDelegate {
    
    // MARK: - Variables
    
    /// the SKU determining the product user wants to buy
    private var sku: String = ""
    /// Stripe token for this purchase
    private var token: String = ""
    /// The hat domain
    private var hatDomain: String = ""
    
    /// The hat image
    private var hatImage: UIImage? = nil

    /// Device's orientation
    private var orientation: UIInterfaceOrientation = .portrait
    
    /// the available HAT providers fetched from HAT
    private var hatProviders: [HATProviderObject] = []
    
    /// the pop up info view controller
    private var infoViewController: GetAHATInfoViewController? = nil
    
    /// the pop up for hat info view controller
    private var hatInfoViewController: InfoHatProvidersViewController? = nil
    
    /// a dark view pop up to hide the background
    private var darkView: UIView? = nil

    // MARK: - IBOutlets

    /// An IBOutlet for handling the learn more button
    @IBOutlet weak var learnMoreButton: UIButton!
    
    /// An IBOutlet for handling the arrow bar on top of the view
    @IBOutlet weak var arrowBarImage: UIImageView!
    
    /// An IBOutlet for handling the collection view
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - IBActions
    
    /**
     Presents a pop up view showing the user more information about HAT
     
     - parameter sender: The object that called this method
     */
    @IBAction func learnMoreInfoButtonAction(_ sender: Any) {
        
        // set up page controller
        self.hatInfoViewController = self.storyboard!.instantiateViewController(withIdentifier: "HATInfo") as? InfoHatProvidersViewController
        
        // present a dark pop up view
        if self.darkView == nil {
            
            self.darkView = UIView()
        }
        self.darkView?.createFloatingView(frame: CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height), color: .darkGray, cornerRadius: 0)
        self.darkView?.alpha = 0.6
        self.view.addSubview((self.darkView)!)
        
        // set up the created page view controller
        if self.hatInfoViewController == nil {
            
            self.hatInfoViewController = InfoHatProvidersViewController()
        }
        self.hatInfoViewController?.view.createFloatingView(frame: CGRect(x: self.view.frame.origin.x + 15, y: self.view.bounds.origin.y + 15, width: self.view.frame.width - 30, height: self.view.bounds.height - 30), color: .white, cornerRadius: 15)
        
        // add the page view controller to self
        self.addViewController(self.hatInfoViewController!)
    }
    
    // MARK: - UIViewController delegate methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.orientation = UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue)!
        
        // config the arrowBar
        self.arrowBarImage.image = self.arrowBarImage.image!.withRenderingMode(.alwaysTemplate)
        self.arrowBarImage.tintColor = .rumpelDarkGray()
        
        self.learnMoreButton.addBorderToButton(width: 1, color: UIColor.tealColor())
        
        // add notification observers
        NotificationCenter.default.addObserver(self, selector: #selector(hidePopUpView), name: NSNotification.Name(Constants.NotificationNames.hideFirstOnboardingView.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCollectionView), name: NSNotification.Name(Constants.NotificationNames.hatProviders.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideInfoViewController), name: NSNotification.Name(Constants.NotificationNames.hideInfoHATProvider.rawValue), object: nil)
        
        // fetch available hat providers
        HATService.getAvailableHATProviders()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        // save device orientation
        self.orientation = toInterfaceOrientation
        
        // reload collection view controller to adjust to the new width of the screen
        self.collectionView?.reloadData()
    }
    
    // MARK: - Hide info view controller
    
    /**
     Hide the pop up info view controller
     */
    @objc private func hideInfoViewController() {
        
        self.hatInfoViewController?.removeViewController()
        self.darkView?.removeFromSuperview()
    }
    
    // MARK: - Refresh collection view
    
    /**
     Refreshes the collection view when the right notification is received
     
     - parameter notification: The norification object that called this method
     */
    @objc private func refreshCollectionView(notification: Notification) {
        
        self.hatProviders = notification.object as! [HATProviderObject]
        self.collectionView.reloadData()
    }
    
    // MARK: - Hide pop up
    
    /**
     Hides the pop up view controller when the right notification is received
     
     - parameter notification: The norification object that called this method
     */
    @objc private func hidePopUpView(notification: Notification) {
        
        // if view is found remove it
        if let view = self.infoViewController {
            
            view.removeViewController()
            
            // check if we have an object
            if (notification.object != nil) {
                
                // config the STPPaymentConfiguration accordingly
                let config = STPPaymentConfiguration.shared()
                config.requiredBillingAddressFields = .full
                config.smsAutofillDisabled = true
                
                // config the STPAddCardViewController in order to present it to the user
                let addCardViewController = STPAddCardViewController(configuration: config, theme: .default())
                addCardViewController.delegate = self
                
                // STPAddCardViewController must be shown inside a UINavigationController.
                // show the STPAddCardViewController
                let navigationController = UINavigationController(rootViewController: addCardViewController)
                self.present(navigationController, animated: true, completion: nil)
            }
            
            // remove the dark view pop up
            self.darkView?.removeFromSuperview()
        }
    }
    
    // MARK: - UICollectionView methods
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // create cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellReuseIDs.onboardingTile.rawValue, for: indexPath) as? OnboardingTileCollectionViewCell
        
        // format cell
        return OnboardingTileCollectionViewCell.setUp(cell: cell!, indexPath: indexPath, hatProvider: hatProviders[indexPath.row], orientation: self.orientation)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return hatProviders.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
        // create page view controller
        let cell = collectionView.cellForItem(at: indexPath) as! OnboardingTileCollectionViewCell
        
        // set up page controller
        let pageItemController = self.storyboard!.instantiateViewController(withIdentifier: "HATProviderInfo") as! GetAHATInfoViewController
        self.hatProviders[indexPath.row].hatProviderImage = cell.hatProviderImage.image
        pageItemController.hatProvider = self.hatProviders[indexPath.row]
        
        // present a dark pop up view to darken the background view controller
        self.darkView = UIView()
        self.darkView?.createFloatingView(frame: CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height), color: .darkGray, cornerRadius: 0)
        self.darkView?.alpha = 0.6

        self.view.addSubview((self.darkView)!)
        
        // set up the created page view controller
        self.infoViewController = pageItemController
        pageItemController.view.createFloatingView(frame: CGRect(x: self.view.frame.origin.x + 15, y: self.view.bounds.origin.y + 15, width: self.view.frame.width - 30, height: self.view.bounds.height - 30), color: .white, cornerRadius: 15)
        
        // add the page view controller to self
        self.addViewController(pageItemController)
        
        // save the data we need for later use
        self.sku = hatProviders[indexPath.row].sku
        self.hatImage = cell.hatProviderImage.image
        self.hatDomain = hatProviders[indexPath.row].kind.domain
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // if device in landscape show 3 tiles instead of 2
        if self.orientation == .landscapeLeft || self.orientation == .landscapeRight {
            
            return CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
        }
        
        return CGSize(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 2)
    }
    
    // MARK: - Stripe methods
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        
        self.token = token.tokenId
        self.dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "stripeSegue", sender: self)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "stripeSegue" {
            
            let controller = segue.destination as? StripeViewController
            
            controller?.sku = self.sku
            controller?.token = self.token
            controller?.hatImage = self.hatImage
            controller?.domain = "." + self.hatDomain
        }
    }
}
