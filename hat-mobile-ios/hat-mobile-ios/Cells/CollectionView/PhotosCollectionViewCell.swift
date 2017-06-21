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

import HatForIOS

// MARK: Class

/// The collection view cell class for the photo viewer
class PhotosCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    /// The cell's imageView
    @IBOutlet weak var image: UIImageView!
    /// The ring progress bar of the image curently downloading
    @IBOutlet weak var ringProgressView: RingProgressCircle!
    
    // MARK: - Calculate Cell Size
    
    /**
     <#Function Details#>
     
     - parameter <#Parameter#>: <#Parameter description#>
     - returns: <#Returns#>
     */
    class func calculateCellSize(collectionViewWidth: CGFloat) -> CGSize {
        
        let approxWidth = CGFloat(100.0)
        let frameWidth = collectionViewWidth
        let width = CGFloat(frameWidth / CGFloat(Int(frameWidth / approxWidth))) - 5
        
        return CGSize(width: width, height: width)
    }
    
    // MARK: - Set up Cell
    
    func setUpCell(userDomain: String, userToken: String, files: [FileUploadObject], indexPath: IndexPath, completion: @escaping (UIImage) -> Void) -> UICollectionViewCell {
        
        let imageURL: String = "https://" + userDomain + "/api/v2/files/content/" + files[indexPath.row].fileID
        
        if self.image.image == UIImage(named: "Image Placeholder") && URL(string: imageURL) != nil {
            
            self.ringProgressView.isHidden = false
            self.ringProgressView?.ringRadius = 15
            self.ringProgressView?.animationDuration = 0
            self.ringProgressView?.ringLineWidth = 4
            self.ringProgressView?.ringColor = .white
            self.ringProgressView.animationDuration = 0.2
            
            self.image.downloadedFrom(url: URL(string: imageURL)!,
                                       userToken: userToken,
                                       progressUpdater: {progress in
                                        
                                            let completion = CGFloat(progress)
                                            self.ringProgressView.updateCircle(end: completion, animate: Float(self.ringProgressView.endPoint), to: Float(progress), removePreviousLayer: false)
                                        },
                                       completion: {[weak self] in
                                        
                                            if self != nil {
                                                
                                                self!.ringProgressView.isHidden = true
                                                
                                                completion(self!.image.image!)
                                            }
                                        })
        } else if self.ringProgressView.isHidden {
            
            self.image.image = files[indexPath.row].image
            
            completion(self.image.image!)
        }
        
        return self
    }
}
