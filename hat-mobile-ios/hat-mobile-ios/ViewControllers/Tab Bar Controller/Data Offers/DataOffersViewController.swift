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
    
    @IBOutlet weak var availableDataOffersView: UIView!
    @IBOutlet weak var redeemedDataOffersView: UIView!
    @IBOutlet weak var rejectedDataOffersView: UIView!
    @IBOutlet weak var selectionIndicatorView: UIView!
    
    // MARK: - View controller functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        for _ in 0...10 {
            
            var offer = DataOfferObject()
            offer.title = "Starbucks"
            offer.shortDescription = "Expired"
            offer.isPPIRequested = true
            offer.image = UIImage(named: "Image Placeholder")
            
            offers.append(offer)
        }
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.reloadData()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(filterCollectionView(gesture:)))
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(filterCollectionView(gesture:)))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(filterCollectionView(gesture:)))
        
        self.availableDataOffersView.addGestureRecognizer(tapGesture)
        self.redeemedDataOffersView.addGestureRecognizer(tapGesture1)
        self.rejectedDataOffersView.addGestureRecognizer(tapGesture2)
    }
    
    func filterCollectionView(gesture: UITapGestureRecognizer) {
        
        func animation(index: Int) {
            
            if index == 0 {
                
                self.selectionIndicatorView.frame = CGRect(x: self.availableDataOffersView.frame.origin.x, y: self.selectionIndicatorView.frame.origin.y, width: self.selectionIndicatorView.frame.width, height: self.selectionIndicatorView.frame.height)
            } else if index == 1{
                
                self.selectionIndicatorView.frame = CGRect(x: self.redeemedDataOffersView.frame.origin.x, y: self.selectionIndicatorView.frame.origin.y, width: self.selectionIndicatorView.frame.width, height: self.selectionIndicatorView.frame.height)
            } else {
                
                self.selectionIndicatorView.frame = CGRect(x: self.rejectedDataOffersView.frame.origin.x, y: self.selectionIndicatorView.frame.origin.y, width: self.selectionIndicatorView.frame.width, height: self.selectionIndicatorView.frame.height)
            }
        }
        
        AnimationHelper.animateView(self.selectionIndicatorView,
                                    duration: 0.25,
                                    animations: {
                                        
                                        animation(index: (gesture.view?.tag)!)
                                    },
                                    completion: { result in
        
                                        print(result)
                                    })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.navigationController?.hidesBarsOnSwipe = true
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "Teal Image"), for: .any, barMetrics: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview!)
        if translation.y < 0 {
            // swipes from top to bottom of screen -> down
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            // swipes from bottom to top of screen -> up
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Collection View functions
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "offerCell", for: indexPath) as! DataOffersCollectionViewCell
        
        return cell.setUpCell(cell: cell, dataOffer: offers[indexPath.row])
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.destination is DataOfferDetailsViewController {
            
            navigationController?.isNavigationBarHidden = false

            weak var destinationVC = segue.destination as? DataOfferDetailsViewController
            
            if segue.identifier == "offerToOfferDetailsSegue" {
                
                let cellIndexPath = self.collectionView.indexPath(for: sender as! UICollectionViewCell)
                destinationVC?.receivedOffer = self.offers[(cellIndexPath?.row)!]
            }
        }
    }

}
