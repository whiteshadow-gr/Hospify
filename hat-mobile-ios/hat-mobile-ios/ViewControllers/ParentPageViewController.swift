//
//  ParentPageViewController.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 6/12/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import UIKit

class ParentPageViewController: UIPageViewController, UIPageViewControllerDataSource {

    // MARK: - Variables
    private var pageViewController: UIPageViewController?
    
    // Initialize it right away here
    private let numberOfPages = [0, 1, 2, 3, 4, 5, 6]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.createPageViewController()
        NotificationCenter.default.addObserver(self, selector: #selector(disablePageControll), name: Notification.Name("disablePageControll"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enablePageControll), name: Notification.Name("enablePageControll"), object: nil)
    }
    
    func disablePageControll(notification: Notification) {
        
        self.dataSource = nil
    }
    
    func enablePageControll(notification: Notification) {
        
        self.dataSource = self
    }
    
    private func createPageViewController() {
        
        self.dataSource = self
        
        if numberOfPages.count > 0 {
            
            let firstController = getItemController(itemIndex: 0)!
            let startingViewControllers = [firstController]
            self.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        }
    }
    
    private func getItemController(itemIndex: Int) -> PageViewController? {
        
        if itemIndex < numberOfPages.count {
            
            let pageItemController = self.storyboard!.instantiateViewController(withIdentifier: "ItemController") as! PageViewController
            pageItemController.itemIndex = itemIndex
            return pageItemController
        }
        
        return nil
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! PageViewController
        
        if itemController.itemIndex > 0 {
            
            return getItemController(itemIndex: itemController.itemIndex - 1)
        }
        
        return getItemController(itemIndex: 0)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! PageViewController
        
        if itemController.itemIndex + 1 < numberOfPages.count {
            
            return getItemController(itemIndex: itemController.itemIndex+1)
        }
        
        return getItemController(itemIndex: 6)
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
