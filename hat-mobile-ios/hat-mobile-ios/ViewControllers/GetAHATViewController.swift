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
    private var hatImage: UIImage? = nil
    private var hatDomain: String = ""
    private var orientation: UIInterfaceOrientation = .portrait
    
    /// the available HAT providers fetched from HAT
    private var hatProviders: [HATProviderObject] = []
    /// the pop up info view controller
    private var infoViewController: GetAHATInfoViewController? = nil
    
    /// a dark view pop up holding title and stuff
    private var darkView: UIView? = nil

    // MARK: - IBOutlets

    /// An IBOutlet for handling the arrow bar on top of the view
    @IBOutlet weak var arrowBarImage: UIImageView!
    
    /// An IBOutlet for handling the collection view
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - UIViewController delegate methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.orientation = UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue)!
        
        // config the arrowBar
        arrowBarImage.image = arrowBarImage.image!.withRenderingMode(.alwaysTemplate)
        arrowBarImage.tintColor = UIColor.rumpelDarkGray()
        
        // add notification observers
        NotificationCenter.default.addObserver(self, selector: #selector(hidePopUpView), name: NSNotification.Name("hideView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCollectionView), name: NSNotification.Name("hatProviders"), object: nil)
        
        // getch available hat providers
        HATService.getAvailableHATProviders()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Refresh collection view
    
    /**
     Refreshes the collection view when the right notification is received
     
     - parameter notification: The norification object that called this method
     */
    func refreshCollectionView(notification: Notification) {
        
        self.hatProviders = notification.object as! [HATProviderObject]
        self.collectionView.reloadData()
    }
    
    // MARK: - Hide pop up
    
    /**
     Hides the pop up view controller when the right notification is received
     
     - parameter notification: The norification object that called this method
     */
    func hidePopUpView(notification: Notification) {
        
        // if view is found remove it
        if let view = self.infoViewController {
            
            view.willMove(toParentViewController: nil)
            view.view.removeFromSuperview()
            view.removeFromParentViewController()
            
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
            darkView?.removeFromSuperview()
        }
    }
    
    // MARK: - UICollectionView methods
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "onboardingTile", for: indexPath) as? OnboardingTileCollectionViewCell
        
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
        hatProviders[indexPath.row].hatProviderImage = cell.hatProviderImage.image
        pageItemController.hatProvider = hatProviders[indexPath.row]
        
        // present a dark pop up view
        darkView = UIView(frame: CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height))
        darkView?.backgroundColor = UIColor.darkGray
        darkView?.alpha = 0.6
        self.view.addSubview((darkView)!)
        
        // set up the created page view controller
        self.infoViewController = pageItemController
        pageItemController.view.frame = CGRect(x: self.view.frame.origin.x + 15, y: self.view.bounds.origin.y + 15, width: self.view.frame.width - 30, height: self.view.bounds.height - 30)
        pageItemController.view.layer.cornerRadius = 15
        
        // add the page view controller to self
        self.addChildViewController(pageItemController)
        self.view.addSubview(pageItemController.view)
        pageItemController.didMove(toParentViewController: self)
        
        // save the sku
        sku = hatProviders[indexPath.row].sku
        hatImage = cell.hatProviderImage.image
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
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "stripeSegue" {
            
            let controller = segue.destination as? StripeViewController
            
            controller?.sku = self.sku
            controller?.token = self.token
            controller?.hatImage = self.hatImage
            controller?.domain = "." + self.hatDomain
        }
    }
}
