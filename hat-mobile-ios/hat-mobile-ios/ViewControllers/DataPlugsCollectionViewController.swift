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

class DataPlugsCollectionViewController: UICollectionViewController {
    
    private let reuseIdentifier = "dataPlugCell"
    private var dataPlugs: [DataPlugObject] = []

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)

        // Do any additional setup after loading the view.
        func successfullCallBack(data: [DataPlugObject]) {
            
            self.dataPlugs = data
            self.collectionView?.reloadData()
        }
        
        func failureCallBack() {
            
            
        }
        DataPlugsService.getAvailableDataPlugs(succesfulCallBack: successfullCallBack, failCallBack: failureCallBack)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dataPlugs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) as? DataPlugCollectionViewCell
    
        // Configure the cell
        cell!.dataPlugTitleLabel.text = self.dataPlugs[indexPath.row].name
        cell!.dataPlugDetailsLabel.text = self.dataPlugs[indexPath.row].description
        cell!.dataPlugImage.downloadedFrom(url: URL(string: self.dataPlugs[indexPath.row].illustrationUrl)!)
        
        return cell!
    }

    // MARK: - UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        UIApplication.shared.openURL(URL(string: self.dataPlugs[indexPath.row].url)!)
    }

}
