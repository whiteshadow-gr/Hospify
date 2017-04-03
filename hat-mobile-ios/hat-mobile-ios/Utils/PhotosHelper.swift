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

import Photos

class PhotosHelper: NSObject {

    static let albumName = "HAT"
    static let sharedInstance = PhotosHelper()
    
    var assetCollection: PHAssetCollection!
    
    override init() {
        
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            
            self.assetCollection = assetCollection
            return
        }
        
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                
                //status
            })
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            
            self.createAlbum()
        } else {
            
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            
            // ideally this ensures the creation of the photo album even if authorization wasn't prompted till after init was done
            print("trying again to create the album")
            self.createAlbum()
        } else {
            
            print("should really prompt the user to let them know it's failed")
        }
    }
    
    func createAlbum() {
        
        PHPhotoLibrary.shared().performChanges({
            
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: PhotosHelper.albumName)   // create an asset collection with the album name
        }) { success, error in
            
            if success {
                
                self.assetCollection = self.fetchAssetCollectionForAlbum()
            } else {
                
                print("error \(String(describing: error))")
            }
        }
    }
    
    func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", PhotosHelper.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let firstObject: AnyObject = collection.firstObject {
            
            return firstObject as! PHAssetCollection
        }
        return nil
    }
    
    func saveImage(image: UIImage, metadata: NSDictionary) {
        
        if assetCollection == nil {
            
            return                          // if there was an error upstream, skip the save
        }
        
        PHPhotoLibrary.shared().performChanges({
            
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            albumChangeRequest?.addAssets([assetPlaceHolder!] as NSArray)
        }, completionHandler: nil)
    }
}
