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

/// The second PageViewController. Responsible for showing a view controller with info about the HAT
class HATCapabilitiesPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    // MARK: - Variables
    
    /// the number of pages array.
    private let numberOfPages = [0, 1, 2, 3, 4]

    // MARK: - View controller delegate methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // create page view controller
        self.createPageViewController()
        
        // change the color of the pagination dots at the bottom of the screen
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
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
    private func getItemController(itemIndex: Int) -> HATCapabilitiesViewController? {
        
        // check if we are out of bounds
        if itemIndex < numberOfPages.count {
            
            // create the view controller and return it
            let pageItemController = self.storyboard!.instantiateViewController(withIdentifier: "CapabilitiesViewController") as! HATCapabilitiesViewController
            pageItemController.pageIndex = itemIndex
            return pageItemController
        }
        
        return nil
    }
    
    // MARK: - Page view controlelr delegate methods
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        // create the view controller for the previous page
        let itemController = viewController as! HATCapabilitiesViewController
        
        // check if we are out of bounds and return the view controller
        if itemController.pageIndex > 0 {
            
            return getItemController(itemIndex: itemController.pageIndex - 1)
        }
        
        // reached first page return nil
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        // create the view controller for the next page
        let itemController = viewController as! HATCapabilitiesViewController
        
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
