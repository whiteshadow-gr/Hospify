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

/// The class responsible for the loading ring progress bar pop up view controller
class LoadingScreenWithProgressRingViewController: UIViewController {

    @IBOutlet weak var progressRing: RingProgressCircle!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!

    @IBAction func cancelButtonAction(_ sender: Any) {
        
        self.removeFromParentViewController()
        self.view.removeFromSuperview()
    }
    
    private var completionPercentage: Double?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.percentageLabel.text = String(describing: self.completionPercentage!) + " %"
        self.progressRing.ringRadius = 40
        self.progressRing.ringLineWidth = 5
        self.progressRing.ringColor = .white
        self.progressRing.backgroundRingColor = .rumpelDarkGray()
        let fullCircle = 2.0 * CGFloat(Double.pi)
        self.progressRing.startPoint = -0.25 * fullCircle
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        var frame = self.percentageLabel.frame
        
        frame.size.height = 21
        
        self.percentageLabel.frame = frame
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    func updateView(completion: Double) {
        
        self.progressRing.isHidden = false
        
        let end = (CGFloat(completion))
        
        print("completion: \(end)")
        
        let currentRatio = String(describing: floor(CGFloat(completion) * 100))
        self.percentageLabel.text = currentRatio + " %"
        print("currentRatio: \(currentRatio)")

        self.progressRing.update(end: end)
    }

    // MARK: - Init view
    
    /**
     Inits a TextPopUpViewController for immediate use
     
     - parameter stringToShow: The string to show to the pop up
     - parameter storyBoard: The storyboard to init the view from
     - returns: An optional instance of TextPopUpViewController ready to present from a view controller
     */
    class func customInit(completion: Double, from storyBoard: UIStoryboard) -> LoadingScreenWithProgressRingViewController? {
        
        let loadingViewController = storyBoard.instantiateViewController(withIdentifier: "loadingScreen") as? LoadingScreenWithProgressRingViewController
        
        loadingViewController?.completionPercentage = completion
        
        return loadingViewController
    }
}
