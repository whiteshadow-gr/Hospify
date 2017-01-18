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

/// The data plugs View in the tab bar view controller
class DataPlugsCollectionViewController: UICollectionViewController {
    
    // MARK: - Variables
    
    /// Cell's reuse identifier
    private let reuseIdentifier = "dataPlugCell"
    /// An array with the available data plugs
    private var dataPlugs: [DataPlugObject] = []
    
    // MARK: - View controller methods

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

    // MARK: - UICollectionView methods

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dataPlugs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) as? DataPlugCollectionViewCell
    
        return DataPlugCollectionViewCell.setUp(cell: cell!, indexPath: indexPath, dataPlug: self.dataPlugs[indexPath.row])
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        UIApplication.shared.openURL(URL(string: self.dataPlugs[indexPath.row].url)!)
    }

}
