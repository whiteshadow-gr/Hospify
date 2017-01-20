//
//  TermsAndConditionsViewController.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 20/1/17.
//  Copyright © 2017 Green Custard Ltd. All rights reserved.
//

import UIKit

class TermsAndConditionsViewController: UIViewController {
    
    var filePathURL: String = ""

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let request = NSURLRequest(url: URL(string: filePathURL)! )
        webView.loadRequest(request as URLRequest)
        // You might want to scale the page to fit
        webView.scalesPageToFit = true
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
