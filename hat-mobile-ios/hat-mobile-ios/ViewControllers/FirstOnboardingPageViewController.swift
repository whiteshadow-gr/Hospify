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

class FirstOnboardingPageViewController: UIPageViewController, UIPageViewControllerDataSource {

    /// the number of pages array.
    private let numberOfPages = [0, 1, 2]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.createPageViewController()
        // change the color of the pagination dots at the bottom of the screen
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.rumpelLightGray()
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.tealColor()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        
        //corrects scrollview frame to allow for full-screen view controller pages
        for subView in self.view.subviews {
            
            if subView is UIScrollView {
                
                subView.frame = self.view.bounds
            }
        }
        
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - Create page view controller
    
    /**
     Creates and adds the view controller to the page view controller
     */
    private func createPageViewController() {
        
        // set datasource to self
        self.dataSource = self
        
        // if we have pages to show init them and add them to the page view controller
        if numberOfPages.count > 0 {
            
            if let firstController = getItemController(itemIndex: 0) {
                
                let startingViewControllers = [firstController]
                self.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
            }
        }
    }
    
    /**
     Create the view controller to present
     
     - parameter itemIndex: The number of the page to create
     - returns: An optional HATCapabilitiesViewController
     */
    private func getItemController(itemIndex: Int) -> FirstOnboardingViewController? {
        
        // check if we are out of bounds
        if itemIndex < numberOfPages.count {
            
            // create the view controller and return it
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "firstOnboardingViewController") as? FirstOnboardingViewController {
                
                let pageItemController = viewController
                pageItemController.pageIndex = itemIndex
                return pageItemController
            }
        }
        
        return nil
    }
    
    // MARK: - Page view controlelr delegate methods
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        // create the view controller for the previous page
        let itemController = viewController as! FirstOnboardingViewController
        
        // check if we are out of bounds and return the view controller
        if itemController.pageIndex > 0 {
            
            return getItemController(itemIndex: itemController.pageIndex - 1)
        }
        
        // reached first page return nil
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        // create the view controller for the next page
        let itemController = viewController as! FirstOnboardingViewController
        
        // check if we are out of bounds and return the view controller
        if itemController.pageIndex + 1 < numberOfPages.count {
            
            return getItemController(itemIndex: itemController.pageIndex + 1)
        }
        
        // reached final page, return nil
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        
        return numberOfPages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        
        return 0
    }

}
