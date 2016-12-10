//
//  PageViewController.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 6/12/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import UIKit

class PageViewController: UIViewController {
    
    var itemIndex: Int = 0
    var pageObject: LearnMoreObject =  LearnMoreObject()
    var viewController: HATCapabilitiesPageViewController? = nil

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBAction func moreInfoActionButton(_ sender: Any) {
     
        let pageItemController = self.storyboard!.instantiateViewController(withIdentifier: "CapabilitiesPageViewController") as! HATCapabilitiesPageViewController
        self.viewController = pageItemController
        pageItemController.view.frame = CGRect(x: 15, y: 15, width: 290, height: 475)
        pageItemController.view.layer.cornerRadius = 15
        //pageItemController.pageIndex = 0
        self.addChildViewController(pageItemController)
        self.view.addSubview(pageItemController.view)
        pageItemController.didMove(toParentViewController: self)
        NotificationCenter.default.post(name: NSNotification.Name("disablePageControll"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if (itemIndex >= 0 && itemIndex <= 6 ) {
            
            pageObject = LearnMoreObject(pageNumber: itemIndex)
        }
        
        imageView.image = pageObject.image
        titleLabel.text = pageObject.title
        mainLabel.text = pageObject.info
        
        if (itemIndex == 0) {
            
            moreButton.setTitle(pageObject.buttonTitle, for: .normal)
            moreButton.addBorderToButton(width: 1, color: .white)
        } else {
            
            moreButton.isHidden = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(removeSecondPageController), name: Notification.Name("hidePageViewContoller"), object: nil)
    }

    func removeSecondPageController(notification: Notification) {
        
        if let view = self.viewController {
            
            view.willMove(toParentViewController: nil)
            view.view.removeFromSuperview()
            view.removeFromParentViewController()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
