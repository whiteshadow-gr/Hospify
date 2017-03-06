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

// MARK: Extension

extension UIImageView {
    
    // MARK: - Download image

    /**
     Downloads an Image from a url and shows it in the imageview that called this method
     
     - parameter url: The url to download the image from
     - parameter mode: The content mode of the image, default value = scaleAspectFit
     */
    public func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            // check that the response is valid and we have the data we want
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data2 = data, error == nil,
                let image = UIImage(data: data2)
                else { return }
            
            // set image on the main thread
            DispatchQueue.main.async() { [weak self]
                () -> Void in
                
                if let weakSelf = self {
                    
                    weakSelf.image = image
                }
            }
        }.resume()
    }
}
