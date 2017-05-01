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

/// A class responsible for handling the photo picker
class PhotosHelperViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Variables
    
    /// The photo picker delegate
    weak var delegate: PhotoPickerDelegate?
    /// The source type of the photo picker
    private var sourceType: UIImagePickerControllerSourceType?
    
    /// A variable holding a reference to the image picker view used to present the photo library or camera
    private var imagePicker: UIImagePickerController!
    
    // MARK: - View controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Image picker Controller
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.imagePicker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        delegate?.didChooseImageWithInfo(info)
        
        if image != nil && self.sourceType == .camera {
            
            PhotosHelper.sharedInstance.saveImage(image: image!)
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func presentPicker(sourceType: UIImagePickerControllerSourceType) -> UIImagePickerController {
        
        self.imagePicker = UIImagePickerController()
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = sourceType
        self.sourceType = sourceType
        
        if sourceType == .photoLibrary {
            
            self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: UIImagePickerControllerSourceType.photoLibrary)!
        }
        
        return self.imagePicker
    }

}
