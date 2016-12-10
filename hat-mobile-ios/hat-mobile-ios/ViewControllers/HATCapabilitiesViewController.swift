//
//  HATCapabilitiesViewController.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 9/12/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import UIKit

class HATCapabilitiesViewController: UIViewController {

    var pageIndex: Int = 0
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let dataObject = LearnMoreObject(pageNumber: pageIndex + 10)
        titleLabel.text = dataObject.title
        infoLabel.text = dataObject.info
        image.image = dataObject.image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        
        NotificationCenter.default.post(name: Notification.Name("enablePageControll"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("hidePageViewContoller"), object: nil)
    }
}
