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

    @IBOutlet weak var ticketView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textField: UITextView!
    
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var offersRemainingLabel: UILabel!
    @IBOutlet weak var ppiEnabledLabel: UILabel!
    @IBOutlet weak var dataRequirementsLabel: UILabel!
    
    // MARK: - Variables
    
    var receivedOffer: DataOfferObject? = nil
    
    // MARK: - View controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if receivedOffer != nil {
            
            self.titleLabel.text = receivedOffer!.name
            self.detailsLabel.text = receivedOffer!.details
            self.imageView.image = receivedOffer?.image
            self.textField.text = receivedOffer?.offerDescription
            self.offersRemainingLabel.text = receivedOffer?.offersRemaining
            self.ppiEnabledLabel.text = String(describing: receivedOffer?.isPPIRequested)
            self.dataRequirementsLabel.text = receivedOffer?.requirements[0]
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)

        self.drawTicketView()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        self.drawTicketView()
    }
    
    // MARK: - Create half circles
    
    /**
     <#Function Details#>
     
     - parameter <#Parameter#>: <#Parameter description#>
     - parameter <#Parameter#>: <#Parameter description#>
     - parameter <#Parameter#>: <#Parameter description#>
     - parameter <#Parameter#>: <#Parameter description#>

     - returns: <#Returns#>
     */
    private func createOverlay(view: UIView, xOffset: CGFloat, yOffset: CGFloat, radius: CGFloat) -> CAShapeLayer {
        
        let path = CGMutablePath()
        path.addRect(view.bounds)
        path.addArc(center: CGPoint(x: xOffset, y: yOffset), radius: radius, startAngle: 0.0, endAngle: 2 * 3.14, clockwise: false)
        path.closeSubpath()
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path
        maskLayer.fillRule = kCAFillRuleEvenOdd
        
        // Release the path since it's not covered by ARC.
        view.layer.mask = maskLayer
        view.clipsToBounds = true
        
        return maskLayer
    }
    
    /**
     <#Function Details#>
     
     - parameter <#Parameter#>: <#Parameter description#>
     - parameter <#Parameter#>: <#Parameter description#>
     - parameter <#Parameter#>: <#Parameter description#>
     - parameter <#Parameter#>: <#Parameter description#>
     - parameter <#Parameter#>: <#Parameter description#>

     - returns: <#Returns#>
     */
    private func createOverlay(view: UIView, layer: CAShapeLayer, xOffset: CGFloat, yOffset: CGFloat, radius: CGFloat) -> CAShapeLayer {
        
        let path = CGMutablePath()
        path.addPath(layer.path!)
        path.addArc(center: CGPoint(x: xOffset, y: yOffset), radius: radius, startAngle: 0.0, endAngle: 2 * 3.14, clockwise: false)
        path.closeSubpath()
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path
        maskLayer.fillRule = kCAFillRuleEvenOdd
        
        // Release the path since it's not covered by ARC.
        view.layer.mask = maskLayer
        view.clipsToBounds = true
        
        return maskLayer
    }
    
    /**
     <#Function Details#>
     
     - parameter <#Parameter#>: <#Parameter description#>
     - parameter <#Parameter#>: <#Parameter description#>
     - parameter <#Parameter#>: <#Parameter description#>
     - parameter <#Parameter#>: <#Parameter description#>
     
     - returns: <#Returns#>
     */
    private func addDashedLine(color: UIColor = .lightGray, view: UIView, x: CGFloat, y: CGFloat) {
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: x + 30, y: y))
        path.addLine(to: CGPoint(x: view.frame.width - 20, y: y))
        path.closeSubpath()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "DashedTopLine"
        shapeLayer.bounds = view.bounds
        shapeLayer.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineDashPattern = [5, 5]
        shapeLayer.path = path
        
        view.layer.addSublayer(shapeLayer)
    }
    
    /**
     <#Function Details#>
     */
    private func drawTicketView() {
        
        self.ticketView.layer.mask = nil
        
        self.textField.sizeToFit()
        
        _ = self.ticketView.layer.sublayers?.filter({ $0.name == "DashedTopLine" }).map({ $0.removeFromSuperlayer() })
        
        let maskLayer = self.createOverlay(view: self.ticketView, xOffset: -5, yOffset: self.textField.frame.origin.y - 10, radius: 20)
        let maskLayer2 = self.createOverlay(view: self.ticketView, layer: maskLayer, xOffset: -5, yOffset: self.textField.frame.maxY + 10, radius: 20)
        
        self.addDashedLine(view: self.ticketView, x: -5, y: self.textField.frame.minY - 5)
        
        let maskLayer3 = self.createOverlay(view: self.ticketView, layer: maskLayer2, xOffset: self.ticketView.bounds.maxX + 5, yOffset: self.textField.frame.origin.y - 10, radius: 20)
        let _ = self.createOverlay(view: self.ticketView, layer: maskLayer3, xOffset: self.ticketView.bounds.maxX + 5, yOffset: self.textField.frame.maxY + 10, radius: 20)
        
        self.addDashedLine(view: self.ticketView, x: -5, y: self.textField.frame.maxY + 5)
        
        self.ticketView.layer.borderWidth = 2
        self.ticketView.layer.borderColor = UIColor(colorLiteralRed: 231/255, green: 231/255, blue: 231/255, alpha: 1.0).cgColor
    }

}
