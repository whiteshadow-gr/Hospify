//
//  UIImageViewExtension.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 4/1/17.
//  Copyright © 2017 Green Custard Ltd. All rights reserved.
//

import UIKit

extension UIImageView {

    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data2 = data, error == nil,
                let image = UIImage(data: data2)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
        }.resume()
    }
}
