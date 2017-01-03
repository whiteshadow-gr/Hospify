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

// MARK: Class

/// Get A hat view controller, used in onboarding of new users
class GetAHATViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARL: - Variables
    
    private var infoViewController: GetAHATInfoViewController? = nil
    
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
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hidePopUpView(notification: Notification) {
        
        // if view is found remove it
        if let view = self.infoViewController {
            
            view.willMove(toParentViewController: nil)
            view.view.removeFromSuperview()
            view.removeFromParentViewController()
        }
    }
    
    // MARK: - UICollectionView methods
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "onboardingTile", for: indexPath)
        
        if (indexPath.row % 4 == 0 || indexPath.row % 3 == 0) {
            
            cell.backgroundColor = UIColor.rumpelVeryLightGray()
        } else {
            
            cell.backgroundColor = UIColor.white
        }
        
        // Configure the cell
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // create page view controller
        let pageItemController = self.storyboard!.instantiateViewController(withIdentifier: "HATProviderInfo") as! GetAHATInfoViewController
        
        // set up the created page view controller
        self.infoViewController = pageItemController
        pageItemController.view.frame = CGRect(x: self.view.frame.origin.x + 15, y: self.view.frame.origin.x + 15, width: self.view.frame.width - 30, height: self.view.frame.height - 30)
        pageItemController.view.layer.cornerRadius = 15
        
        // add the page view controller to self
        self.addChildViewController(pageItemController)
        self.view.addSubview(pageItemController.view)
        pageItemController.didMove(toParentViewController: self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
