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

//MARK: Class

///A custom UIView with a label and a ring around it
@IBDesignable open class RingProgressCircle: UIView {
    
    // MARK: - IBInspectable variables
    
    ///The ring radius
    @IBInspectable open var ringRadius: CGFloat = 55
    ///The ring color
    @IBInspectable open var ringColor: UIColor = UIColor.red
    ///The ring fill color
    @IBInspectable open var ringFillColor: UIColor = UIColor.clear
    ///The ring line width
    @IBInspectable open var ringLineWidth: CGFloat = 12.0
    ///The background ring color
    @IBInspectable open var backgroundRingColor: UIColor = UIColor.gray
    ///The background ring fill color
    @IBInspectable open var backgroundRingFillColor: UIColor = UIColor.clear
    ///The ring's start point
    @IBInspectable open var startPoint: CGFloat = CGFloat(-M_PI_2)
    ///The ring's end point
    @IBInspectable open var endPoint: CGFloat = CGFloat(M_PI_4 / 4)
    ///The ring's shadow radius
    @IBInspectable open var ringShadowRadius: CGFloat = 0.0
    ///The ring's shadow opacity
    @IBInspectable open var ringShadowOpacity: Float = 0.0
    ///The ring's shadow offset
    @IBInspectable open var ringShadowOffset: CGSize = CGSize.zero
    ///The animation duration.
    @IBInspectable open var animationDuration: CGFloat = 0.2
    
    // MARK: - Variables
    
    ///The UILabel in the middle of the UIView
    fileprivate var label: UILabel! = UILabel()
    
    // MARK: - Inits
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        //init circle
        self.initRingProgressCircle()
    }
    
    /**
     Initializes ring progress circle with the default values.
     
     - author: Marios-Andreas Tsekis
     - date: 15/7/16
     - version: 1.0
     - copyright: Copyright © 2016 Marios-Andreas Tsekis. All rights reserved.
     */
    func initRingProgressCircle() -> Void {
        
        //init ring progress bar
        ringRadius = 55
        ringColor = UIColor.red
        ringFillColor = UIColor.clear
        backgroundRingFillColor = UIColor.clear
        backgroundRingColor = UIColor.gray
        ringLineWidth = 12.0
        startPoint = CGFloat(-M_PI_2)
        endPoint = CGFloat(M_PI_4 / 4)
        ringShadowRadius = 0.0
        ringShadowOpacity = 0.0
        ringShadowOffset = CGSize.zero
        animationDuration = 0.2
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        //init circle
        self.initRingProgressCircle()
    }
    
    override open func awakeFromNib() {
        
        super.awakeFromNib()
        
        //init circle
        self.initRingProgressCircle()
    }
    
    // MARK: - Create circle
    
    /**
     Creates a circle
     
     - parameter lineWidth: The width of the ring
     - parameter path: The path of the circle
     - parameter strokeStart: The starting point of the circle
     - parameter strokeEnd: The ending point of the circle
     - parameter strokeColor: The color of the ring
     - parameter fillColor: The fill color of the circle
     - parameter shadowRadius: The shadow radius
     - parameter shadowOpacity: The shadow opacity
     - parameter shadowOffsset: The shadow offset
     
     - author: Marios-Andreas Tsekis
     - date: 15/7/16
     - version: 1.0
     - copyright: Copyright © 2016 Marios-Andreas Tsekis. All rights reserved.
     */
    func addOval(_ lineWidth: CGFloat, path: CGPath, strokeStart: CGFloat, strokeEnd: CGFloat, strokeColor: UIColor, fillColor: UIColor, shadowRadius: CGFloat, shadowOpacity: Float, shadowOffset: CGSize) -> CAShapeLayer {
        
        //create and setup the shape
        let arc = CAShapeLayer()
        arc.lineWidth = lineWidth
        arc.path = path
        //arc.lineCap = "round"
        arc.strokeStart = strokeStart
        arc.strokeEnd = strokeEnd
        arc.strokeColor = strokeColor.cgColor
        arc.fillColor = fillColor.cgColor
        arc.shadowColor = UIColor.black.cgColor
        arc.shadowRadius = shadowRadius
        arc.shadowOpacity = shadowOpacity
        arc.shadowOffset = shadowOffset
        
        //add shape as a sublayer
        layer.addSublayer(arc)
        return arc
    }
    
    // MARK: - Draw Rect
    
    override open func draw(_ rect: CGRect) {
        
        // TODO: Limit size of the ring, in some devices it might get squared!
        
        //get the mid position of the view
        let X = self.bounds.midX
        let Y = self.bounds.midY
        
        //create the background path of the circle
        let backgroundRingPath = UIBezierPath(arcCenter: CGPoint(x: X, y: Y), radius: self.ringRadius, startAngle: (CGFloat(-M_PI_2)), endAngle: CGFloat(3 * M_PI_2), clockwise: true).cgPath
        //create the background path of the circle
        let path = UIBezierPath(arcCenter: CGPoint(x: X, y: Y), radius: self.ringRadius, startAngle: self.startPoint, endAngle: self.endPoint, clockwise: true).cgPath
        //add a full background circle
        _ = self.addOval(self.ringLineWidth + 1, path: backgroundRingPath, strokeStart: 0, strokeEnd: 1, strokeColor: self.backgroundRingColor, fillColor: self.backgroundRingFillColor, shadowRadius: self.ringShadowRadius, shadowOpacity: self.ringShadowOpacity, shadowOffset: self.ringShadowOffset)
        //add a second cirlce representing the value we want
        let mainArc = self.addOval(self.ringLineWidth, path: path, strokeStart: self.startPoint, strokeEnd: self.endPoint, strokeColor: self.ringColor, fillColor: self.ringFillColor, shadowRadius: self.ringShadowRadius, shadowOpacity: self.ringShadowOpacity, shadowOffset: self.ringShadowOffset)
        
        //animate main circle
        AnimationHelper.animateCircle(TimeInterval(self.animationDuration), arc: mainArc)
    }
    
    func update() {
        
        self.draw(self.frame)
    }
}
