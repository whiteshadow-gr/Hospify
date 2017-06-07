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

class DataOffersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Variables
    
    private var offers: [DataOfferObject] = []
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - View controller functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        for _ in 0...10 {
            
            offers.append(DataOfferObject())
        }
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Collection View functions
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "offerCell", for: indexPath) as! DataOffersCollectionViewCell
        
        return self.setUpCell(cell: cell, dataOffer: offers[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.collectionView.frame.width, height: 340)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return offers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        self.performSegue(withIdentifier: "offerToOfferDetailsSegue", sender: cell)
    }
    
    // MARK: - Set up cell
    
    /**
     <#Function Details#>
     
     - parameter <#Parameter#>: <#Parameter description#>
     - parameter <#Parameter#>: <#Parameter description#>

     - returns: <#Returns#>
     */
    private func setUpCell(cell: DataOffersCollectionViewCell, dataOffer: DataOfferObject) -> UICollectionViewCell {
        
        cell.titleLabel.text = dataOffer.name
        cell.detailsLabel.text = dataOffer.details
        cell.imageView.image = dataOffer.image
        
        cell.layer.cornerRadius = 5
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor(colorLiteralRed: 231/255, green: 231/255, blue: 231/255, alpha: 1.0).cgColor
        
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.destination is DataOfferDetailsViewController {
            
            weak var destinationVC = segue.destination as? DataOfferDetailsViewController
            
            if segue.identifier == "offerToOfferDetailsSegue" {
                
                let cellIndexPath = self.collectionView.indexPath(for: sender as! UICollectionViewCell)
                destinationVC?.receivedOffer = self.offers[(cellIndexPath?.row)!]
            }
        }
    }

}
