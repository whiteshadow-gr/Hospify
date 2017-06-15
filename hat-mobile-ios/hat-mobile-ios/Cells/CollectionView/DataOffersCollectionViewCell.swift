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

/// A class responsible for handling the Data Offers Collection View cell
class DataOffersCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the imageView
    @IBOutlet weak var imageView: UIImageView!
    
    /// An IBOutlet for handling the title UILabel
    @IBOutlet weak var titleLabel: UILabel!
    /// An IBOutlet for handling the details UILabel
    @IBOutlet weak var detailsLabel: UILabel!
    
    // MARK: - Set up cell
    
    /**
     <#Function Details#>
     
     - parameter <#Parameter#>: <#Parameter description#>
     - parameter <#Parameter#>: <#Parameter description#>
     
     - returns: <#Returns#>
     */
    func setUpCell(cell: DataOffersCollectionViewCell, dataOffer: DataOfferObject) -> UICollectionViewCell {
        
        cell.titleLabel.text = dataOffer.title
        cell.detailsLabel.text = dataOffer.shortDescription
        cell.imageView.image = dataOffer.image
        
        cell.layer.cornerRadius = 5
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor(colorLiteralRed: 231/255, green: 231/255, blue: 231/255, alpha: 1.0).cgColor
        
        return cell
    }
    
    // MARK: - Download image
    
    /**
     <#Function Details#>
     
     - parameter <#Parameter#>: <#Parameter description#>
     - parameter <#Parameter#>: <#Parameter description#>
     - parameter <#Parameter#>: <#Parameter description#>
     - parameter <#Parameter#>: <#Parameter description#>
     - parameter <#Parameter#>: <#Parameter description#>
     */
    func downloadOfferImage(url: String, userToken: String, ringProgressBarToAnimate: RingProgressCircle? = nil, imageView: UIImageView, completion: @escaping (UIImage?) -> Void) {
        
        if let tempURL = URL(string: url) {
            
            imageView.downloadedFrom(url: tempURL,
                                     userToken: userToken,
                                     progressUpdater: {progress in
                                        
                                        if ringProgressBarToAnimate != nil {
                                            
                                            let completion = Float(progress)
                                            ringProgressBarToAnimate?.updateCircle(end: CGFloat(completion), animate: Float((ringProgressBarToAnimate?.endPoint)!), to: completion, removePreviousLayer: false)
                                        }
                                    },
                                     completion: {
                                        
                                        ringProgressBarToAnimate?.isHidden = false
                                        completion(imageView.image)
                                    }
            )
        }
    }
    
    // MARK: - Format Text
    
    func formatRequiredDataDefinitionText(requiredDataDefinition: [DataOfferRequiredDataDefinitionObject]) -> NSMutableAttributedString {
        
        let textToReturn = NSMutableAttributedString(string: "REQUIREMENTS:\n", attributes: [NSFontAttributeName : UIFont(name: "OpenSans", size: 12)!])
        
        for requiredData in requiredDataDefinition {
            
            let string = NSMutableAttributedString(string: "\(requiredData.source)\n", attributes: [NSFontAttributeName : UIFont(name: "OpenSans-Bold", size: 12)!])
            
            textToReturn.append(string)
            
            for dataSet in requiredData.dataSets {
                
                func reccuringFields(fieldsArray: [DataOfferRequiredDataDefinitionDataSetsFieldsObject], intend: String) -> NSMutableAttributedString {
                    
                    let tempText = NSMutableAttributedString(string: "", attributes: [NSFontAttributeName : UIFont(name: "OpenSans", size: 12)!])
                    
                    for field in fieldsArray {
                        
                        let fieldString = NSMutableAttributedString(string: "\(intend)\(field.name)\n", attributes: [NSFontAttributeName : UIFont(name: "OpenSans", size: 12)!])
                        
                        tempText.append(fieldString)
                        
                        if field.fields.count > 0 {
                            
                            tempText.append(reccuringFields(fieldsArray: field.fields, intend: intend + "\t"))
                        }
                    }
                    
                    return tempText
                }
                
                let dataName = NSMutableAttributedString(string: "\t\(dataSet.name)\n", attributes: [NSFontAttributeName : UIFont(name: "OpenSans", size: 12)!])
                
                textToReturn.append(dataName)
                textToReturn.append(reccuringFields(fieldsArray: dataSet.fields, intend: "\t\t"))
            }
        }
        
        return textToReturn
    }
    
    func formatOfferDescription(dataOffer: DataOfferObject) -> NSMutableAttributedString {
        
        return NSMutableAttributedString(string: "OFFER DESCRIPTION:\n\(dataOffer.longDescription)", attributes: [NSFontAttributeName : UIFont(name: "OpenSans", size: 12)!])
    }
}
