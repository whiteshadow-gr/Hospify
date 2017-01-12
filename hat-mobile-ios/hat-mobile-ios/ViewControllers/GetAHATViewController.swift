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
class GetAHATViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, STPAddCardViewControllerDelegate {
//    @available(iOS 8.0, *)
//    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
//        
//    }
//
//    @available(iOS 8.0, *)
//    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
//        
//    }
//
//    
//    /**
//     *  This is called when the user selects a shipping method. If no shipping methods are given, or if the shipping type doesn't require a shipping method, this will be called after the user has a shipping address and your validation has succeeded. After updating your app with the user's shipping info, you should dismiss (or pop) the view controller. Note that if `shippingMethod` is non-nil, there will be an additional shipping methods view controller on the navigation controller's stack.
//     *
//     *  @param addressViewController the view controller where the address was entered
//     *  @param address               the address that was entered. @see STPAddress
//     *  @param shippingMethod        the shipping method that was selected.
//     */
//    @available(iOS 8.0, *)
//    public func shippingAddressViewController(_ addressViewController: STPShippingAddressViewController, didFinishWith address: STPAddress, shippingMethod method: PKShippingMethod?) {
//        
//    }
//
//    /**
//     *  This is called when the user enters a shipping address and taps next. You should validate the address and determine what shipping methods are available, and call the `completion` block when finished. If an error occurrs, call the `completion` block with the error. Otherwise, call the `completion` block with a nil error and an array of available shipping methods. If you don't need to collect a shipping method, you may pass an empty array.
//     *
//     *  @param addressViewController the view controller where the address was entered
//     *  @param address               the address that was entered. @see STPAddress
//     *  @param completion            call this callback when you're done validating the address and determining available shipping methods.
//     */
//    public func shippingAddressViewController(_ addressViewController: STPShippingAddressViewController, didEnter address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
//        
//        self.dismiss(animated: true, completion: nil)
//        let config = STPPaymentConfiguration.shared()
//        config.requiredBillingAddressFields = .full
//        config.smsAutofillDisabled = false
//        
//        let addCardViewController = STPAddCardViewController(configuration: config, theme: .default())
//        addCardViewController.delegate = self
//        //addCardViewController.prefilledInformation.email = "a@google.com"
//        
//        // STPAddCardViewController must be shown inside a UINavigationController.
//        let navigationController = UINavigationController(rootViewController: addCardViewController)
//        self.present(navigationController, animated: true, completion: nil)
//    }
//
//    /**
//     *  Called when the user cancels entering a shipping address. You should dismiss (or pop) the view controller at this point.
//     *
//     *  @param addressViewController the view controller that has been cancelled
//     */
//    public func shippingAddressViewControllerDidCancel(_ addressViewController: STPShippingAddressViewController) {
//        
//        self.dismiss(animated: true, completion: nil)
//    }

    
    // MARL: - Variables
    private var sku: String = ""
    private var hatProviders: [HATProviderObject] = []
    private var infoViewController: GetAHATInfoViewController? = nil
    private var darkView: UIView? = nil
    private var stripeModel = StripeModel()

    // MARK: - IBOutlets

    /// An IBOutlet for handling the arrow bar on top of the view
    @IBOutlet weak var arrowBarImage: UIImageView!
    
    /// An IBOutlet for handling the collection view
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - UIViewController delegate methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        arrowBarImage.image = arrowBarImage.image!.withRenderingMode(.alwaysTemplate)
        arrowBarImage.tintColor = UIColor.rumpelDarkGray()
        NotificationCenter.default.addObserver(self, selector: #selector(hidePopUpView), name: NSNotification.Name("hideView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCollectionView), name: NSNotification.Name("hatProviders"), object: nil)
        
        HATService.getAvailableHATProviders() 
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshCollectionView(notification: Notification) {
        
        self.hatProviders = notification.object as! [HATProviderObject]
        self.collectionView.reloadData()
    }
    
    func hidePopUpView(notification: Notification) {
        
        // if view is found remove it
        if let view = self.infoViewController {
            
            view.willMove(toParentViewController: nil)
            view.view.removeFromSuperview()
            view.removeFromParentViewController()
            
            if (notification.object != nil) {
                
                //self.performSegue(withIdentifier: "stripeSegue", sender: self)
                
                let config = STPPaymentConfiguration.shared()
                config.requiredBillingAddressFields = .full
                config.requiredShippingAddressFields = .email
                //config.smsAutofillDisabled = false
                
                let addCardViewController = STPAddCardViewController(configuration: config, theme: .default())
                addCardViewController.delegate = self
                addCardViewController.prefilledInformation.email = "a@google.com"
                
                // STPAddCardViewController must be shown inside a UINavigationController.
                let navigationController = UINavigationController(rootViewController: addCardViewController)
                self.present(navigationController, animated: true, completion: nil)
            }
            
            darkView?.removeFromSuperview()
        }
    }
    
    // MARK: - UICollectionView methods
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "onboardingTile", for: indexPath) as? OnboardingTileCollectionViewCell
        
        if (indexPath.row % 4 == 0 || indexPath.row % 3 == 0) {
            
            cell!.backgroundColor = UIColor.rumpelVeryLightGray()
        } else {
            
            cell!.backgroundColor = UIColor.white
        }
        
        cell?.titleLabel.text = hatProviders[indexPath.row].name
        
        if hatProviders[indexPath.row].price == 0 {
            
            cell?.infoLabel.text = String(hatProviders[indexPath.row].purchased) + " of " + String(hatProviders[indexPath.row].available) + " remaining"
        } else {
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale.current
            let price: Double = Double(hatProviders[indexPath.row].price / 100)
            cell?.infoLabel.text = formatter.string(from: NSNumber(value: price))
        }
        
        let url: URL = URL(string: "https://hatters.hubofallthings.com/assets" + hatProviders[indexPath.row].illustration)!
        cell?.hatProviderImage.downloadedFrom(url: url)
        // Configure the cell
        return cell!
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return hatProviders.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // create page view controller
        let cell = collectionView.cellForItem(at: indexPath) as! OnboardingTileCollectionViewCell
        
        let pageItemController = self.storyboard!.instantiateViewController(withIdentifier: "HATProviderInfo") as! GetAHATInfoViewController
        hatProviders[indexPath.row].hatProviderImage = cell.hatProviderImage.image
        pageItemController.hatProvider = hatProviders[indexPath.row]
        
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
        sku = hatProviders[indexPath.row].sku
    }
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        
        let email = addCardViewController
        print(email)
        
        self.submitToken(token, completion: { (error: Error?) in
            
            if let error = error {
                
                completion(error)
            } else {
                
                self.dismiss(animated: true, completion: {
                    
                    //self.showReceiptPage()
                    completion(nil)
                })
            }
        })
    }
    
    func submitToken(_ token: STPToken, completion: @escaping (Error?) -> Void) {
        
        let json = JSONHelper.createPurchaseJSONFrom(stripeModel: stripeModel)
        let url = "https://hatters.hubofallthings.com/api/products/hat/purchase"
        
        Alamofire.request(url, method: .post, parameters: json, encoding: Alamofire.JSONEncoding.default, headers: [:]).responseJSON(completionHandler: {(data: DataResponse<Any>) -> Void in
            
            completion(nil)
        })
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "stripeSegue" {
            
            let controller = segue.destination as? StripeViewController
            controller?.sku = sku
        }
    }
}
