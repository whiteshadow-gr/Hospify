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

class DataOfferDetailsViewController: UIViewController {
    
    // MARK: - IBOutlets

    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var dataRequirmentTextView: UITextView!
    
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var offersRemainingLabel: UILabel!
    @IBOutlet weak var ppiEnabledLabel: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var infoView: UIView!
    
    // MARK: - Variables
    
    var receivedOffer: DataOfferObject? = nil
    
    // MARK: - View controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if receivedOffer != nil {
            
//            self.titleLabel.text = receivedOffer!.name
//            self.detailsLabel.text = receivedOffer!.details
//            self.imageView.image = receivedOffer?.image
//            self.textField.text = receivedOffer?.offerDescription
//            self.offersRemainingLabel.text = (receivedOffer?.offersRemaining)! + " REMAINING"
//            self.dataRequirmentTextView.text = receivedOffer?.requirements[0]
            
            if receivedOffer!.isPPIRequested {
                
                self.ppiEnabledLabel.text = "PPI ENABLED"
            } else {
                
                self.ppiEnabledLabel.text = "PPI DISABLED"
            }
        }
        
        self.stackView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.stackView.isHidden = false
        
        navigationController?.hidesBarsOnSwipe = false
        
        let view = self.stackView.arrangedSubviews[1]
        view.addLine(view: self.infoView, x: self.infoView.bounds.midX, y: 0)
        view.drawTicketView()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        let view = self.stackView.arrangedSubviews[1]
        view.drawTicketView()
        view.addLine(view: self.infoView, x: self.infoView.bounds.midX, y: 0)
    }

}
