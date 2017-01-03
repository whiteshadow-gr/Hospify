//
//  GetAHATViewController.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 3/1/17.
//  Copyright © 2017 Green Custard Ltd. All rights reserved.
//

import UIKit

// MARK: Class

class GetAHATViewController: UIViewController, UICollectionViewDataSource {
    
    // MARK: - IBOutlets

    @IBOutlet weak var arrowBarImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - UIViewController delegate methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        arrowBarImage.image = arrowBarImage.image!.withRenderingMode(.alwaysTemplate)
        arrowBarImage.tintColor = UIColor.rumpelDarkGray()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UICollectionView methods
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "onboardingTile", for: indexPath)
        cell.backgroundColor = UIColor.rumpelLightGray()
        // Configure the cell
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 6
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
