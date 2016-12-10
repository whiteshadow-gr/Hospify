//
//  HATCapabilitiesPageViewController.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 9/12/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import UIKit

class HATCapabilitiesPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    let numberOfPages = [0, 1, 2, 3, 4]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.createPageViewController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func createPageViewController() {
        
        self.dataSource = self
        
        if numberOfPages.count > 0 {
            
            let firstController = getItemController(itemIndex: 0)!
            let startingViewControllers = [firstController]
            self.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        }
    }
    
    private func getItemController(itemIndex: Int) -> HATCapabilitiesViewController? {
        
        if itemIndex < numberOfPages.count {
            
            let pageItemController = self.storyboard!.instantiateViewController(withIdentifier: "CapabilitiesViewController") as! HATCapabilitiesViewController
            pageItemController.pageIndex = itemIndex
            return pageItemController
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! HATCapabilitiesViewController
        
        if itemController.pageIndex > 0 {
            
            return getItemController(itemIndex: itemController.pageIndex - 1)
        }
        
        return getItemController(itemIndex: 0)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! HATCapabilitiesViewController
        
        if itemController.pageIndex + 1 < numberOfPages.count {
            
            return getItemController(itemIndex: itemController.pageIndex + 1)
        }
        
        return getItemController(itemIndex: 5)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        
        return numberOfPages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        
        return 0
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

}
