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

/// The Page view controller child. Shows info about hat and what you can do
class PageViewController: UIViewController {
    
    // MARK: - Variables
    
    /// a variable to know the page number of the view
    var itemIndex: Int = 0
    /// the second PegeViewController that appears when user has tapped the learn more on the first screen
    private var pageViewController: HATCapabilitiesPageViewController? = nil
    
    // MARK: - IBOutlets

    /// An IBOutlet to handle the imageView
    @IBOutlet weak var imageView: UIImageView!
    
    /// An IBOutlet to handle the titleLabel
    @IBOutlet weak var titleLabel: UILabel!
    /// An IBOutlet to handle the mainLabel
    @IBOutlet weak var mainLabel: UILabel!
    
    /// An IBOutlet to handle the moreButton
    @IBOutlet weak var moreButton: UIButton!
    
    // MARK: - IBActions
    
    /**
     An IBAction executed when user has pressed the moreInfoButton and presents a second page view controller
     
     - parameter sender: The object that calls this method
     */
    @IBAction func moreInfoActionButton(_ sender: Any) {
     
        // create page view controller
        let pageItemController = self.storyboard!.instantiateViewController(withIdentifier: "CapabilitiesPageViewController") as! HATCapabilitiesPageViewController
        
        // set up the created page view controller
        self.pageViewController = pageItemController
        pageItemController.view.frame = CGRect(x: self.view.frame.origin.x + 15, y: self.view.frame.origin.x + 15, width: self.view.frame.width - 30, height: self.view.frame.height - 30)
        pageItemController.view.layer.cornerRadius = 15
        
        // add the page view controller to self
        self.addChildViewController(pageItemController)
        self.view.addSubview(pageItemController.view)
        pageItemController.didMove(toParentViewController: self)
        
        // notify parent page view controller for disabling the scrolling between pages
        NotificationCenter.default.post(name: NSNotification.Name("disablePageControll"), object: nil)
    }
    
    // MARK: - ViewController delegate methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // init a LearnMoreObject
        var pageObject: LearnMoreObject = LearnMoreObject()
        
        // check if we are out of bounds
        if (itemIndex >= 0 && itemIndex <= 6 ) {
            
            // create a LearnMoreObject according to page we are
            pageObject = LearnMoreObject(pageNumber: itemIndex)
        }
        
        if itemIndex == 6 {
            
            // format main label
            let textAttributesTitle = [
                NSForegroundColorAttributeName: UIColor.white,
                NSStrokeColorAttributeName: UIColor.white,
                NSFontAttributeName: UIFont(name: "OpenSans-CondensedLight", size: 36)!,
                NSStrokeWidthAttributeName: -1.0
                ] as [String : Any]
            
            let textAttributes = [
                NSForegroundColorAttributeName: UIColor.tealColor(),
                NSStrokeColorAttributeName: UIColor.tealColor(),
                NSFontAttributeName: UIFont(name: "Open Sans", size: 36)!,
                NSStrokeWidthAttributeName: -1.0
                ] as [String : Any]
            
            let partOne = NSAttributedString(string: "Because we think YOU should be at the ", attributes: textAttributesTitle)
            let partTwo = NSAttributedString(string: "hub of all things", attributes: textAttributes)
            let combination = NSMutableAttributedString()
            
            combination.append(partOne)
            combination.append(partTwo)
            mainLabel.attributedText = combination
        } else {
            
            mainLabel.text = pageObject.info
        }
        
        // assign the values of the object to the UIElements
        imageView.image = pageObject.image
        titleLabel.text = pageObject.title
        
        // if we are in the first page show the button, else hide it
        if (pageObject.buttonTitle != "") {
            
            moreButton.setTitle(pageObject.buttonTitle, for: .normal)
            moreButton.addBorderToButton(width: 1, color: .white)
        } else {
            
            moreButton.isHidden = true
        }
        
        // add a notification observer in order to hide the second page view controller
        NotificationCenter.default.addObserver(self, selector: #selector(removeSecondPageController), name: Notification.Name("hidePageViewContoller"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Remove second PageViewController

    /**
     Removes the second pageviewcontroller on demand when receivd the notification
     
     - parameter notification: The Notification object send with this notification
     */
    @objc private func removeSecondPageController(notification: Notification) {
        
        // if view is found remove it
        if let view = self.pageViewController {
            
            view.willMove(toParentViewController: nil)
            view.view.removeFromSuperview()
            view.removeFromParentViewController()
        }
    }
}
