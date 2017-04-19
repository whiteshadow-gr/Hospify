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

import Alamofire
import HatForIOS

// MARK: Extension

extension UIImageView {
    
    // MARK: - Download image

    /**
     Downloads an Image from a url and shows it in the imageview that called this method
     
     - parameter url: The url to download the image from
     - parameter mode: The content mode of the image, default value = scaleAspectFit
     */
    public func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit, completion: ((Void) -> Void)?) {
        
        let userToken = HATAccountService.getUsersTokenFromKeychain()
        let headers = ["X-Auth-Token" : userToken]
        contentMode = mode
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: Alamofire.JSONEncoding.default, headers: headers).responseData(completionHandler: {[weak self] response in
            
            guard let data = response.result.value else { return }
            let image = UIImage(data: data)
            
            if let weakSelf = self {
                
                weakSelf.image = image
            }
            
            if completion != nil {
                
                completion!()
            }
        })

    }
}
