/** Copyright (C) 2016 HAT Data Exchange Ltd
 * SPDX-License-Identifier: AGPL-3.0
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * RumpelLite is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License
 * as published by the Free Software Foundation, version 3 of
 * the License.
 *
 * RumpelLite is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
 * the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General
 * Public License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
 */

import UIKit

// MARK: Class

/// The first PageViewController in Learn More. Responsible for showing a view controller with info about the HAT
class ParentPageViewController: UIPageViewController, UIPageViewControllerDataSource {

    // MARK: - Variables
    
    /// the number of pages for this page view controller
    private let numberOfPages = [0, 1, 2, 3, 4, 5, 6]
    
    // MARK: - PageViewController delegate methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // create view controller
        self.createPageViewController()
        
        // change the color of the pagination dots at the bottom of the screen
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.tealColor()
        
        // add notification observers for disabling and enabling page controll
        NotificationCenter.default.addObserver(self, selector: #selector(disablePageControll), name: Notification.Name("disablePageControll"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enablePageControll), name: Notification.Name("enablePageControll"), object: nil)
        
        self.view.backgroundColor = UIColor.tealColor()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        // create the view controller for the previous page
        let itemController = viewController as! PageViewController
        
        // check if we are out of bounds and return the view controller
        if itemController.itemIndex > 0 {
            
            return getItemController(itemIndex: itemController.itemIndex - 1)
        }
        
        // reached first page return nil
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        // create the view controller for the next page
        let itemController = viewController as! PageViewController
        
        // check if we are out of bounds and return the view controller
        if itemController.itemIndex + 1 < numberOfPages.count {
            
            return getItemController(itemIndex: itemController.itemIndex+1)
        }
        
        // reached final page return nil
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        
        return numberOfPages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        
        return 0
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        //corrects scrollview frame to allow for full-screen view controller pages
        for subView in self.view.subviews {
            
            if subView is UIScrollView {
                
                subView.frame = self.view.bounds
            }
        }
    }
    
    // MARK: - Handle page control
    
    /**
     Disables page control
     
     - parameter notification: The Notification object send with this notification
     */
    @objc private func disablePageControll(notification: Notification) {
        
        self.dataSource = nil
    }
    
    /**
     Enables page control
     
     - parameter notification: The Notification object send with this notification
     */
    @objc private func enablePageControll(notification: Notification) {
        
        self.dataSource = self
        
        // change the color of the pagination dots at the bottom of the screen
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.tealColor()
    }
    
    // MARK: - Create view controller
    
    /**
     Creates and adds the view controller to the page view controller
     */
    private func createPageViewController() {
        
        // set datasource to self
        self.dataSource = self
        
        // if we have pages to show init them and add them to the page view controller
        if numberOfPages.count > 0 {
            
            let firstController = getItemController(itemIndex: 0)!
            let startingViewControllers = [firstController]
            self.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        }
    }
    
    /**
     Create the view controller to present
     
     - parameter itemIndex: The number of the page to create
     - returns: An optional HATCapabilitiesViewController
     */
    private func getItemController(itemIndex: Int) -> PageViewController? {
        
        // check if we are out of bounds
        if itemIndex < numberOfPages.count {
            
            // create the view controller and return it
            let pageItemController = self.storyboard!.instantiateViewController(withIdentifier: "ItemController") as! PageViewController
            pageItemController.itemIndex = itemIndex
            return pageItemController
        }
        
        return nil
    }
}
