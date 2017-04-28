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

import HatForIOS

// MARK: Class

class PhotoViewerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PhotoPickerDelegate {
    
    // MARK: - Variables
    
    private var images: [(UIImage, Date)] = []
    /// The files, images, to show in the cells
    private var files: [FileUploadObject] = [] {
        
        didSet {
            
            self.collectionView.reloadData()
        }
    }
    
    private var loadingScr: LoadingScreenWithProgressRingViewController?
    private let userDomain = HATAccountService.TheUserHATDomain()
    
    private let userToken = HATAccountService.getUsersTokenFromKeychain()
    /// The reuse identifier of the cell
    private let reuseIdentifier = "photosCell"
    
    private let photoPicker = PhotosHelperViewController()
    
    private var selectedFileToView: FileUploadObject?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var addFirstPhotoFileImageView: UIImageView!
    
    @IBOutlet weak var addPictureButtonOutlet: UIButton!
    
    // MARK: - IBActions

    @IBAction func addPictureButtonAction(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Select options", message: "Select from where to upload image", preferredStyle: .actionSheet)
        
        // create alert actions
        let cameraAction = UIAlertAction(title: "Take photo", style: .default, handler: { [unowned self] (action) -> Void in
            
            let photoPickerContorller = self.photoPicker.presentPicker(sourceType: .camera)
            self.present(photoPickerContorller, animated: true, completion: nil)
        })
        
        let libraryAction = UIAlertAction(title: "Choose from library", style: .default, handler: { [unowned self] (action) -> Void in
            
            let photoPickerContorller = self.photoPicker.presentPicker(sourceType: .photoLibrary)
            self.present(photoPickerContorller, animated: true, completion: nil)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addActions(actions: [cameraAction, libraryAction, cancel])
        alertController.addiPadSupport(sourceRect: self.addPictureButtonOutlet.frame, sourceView: self.addPictureButtonOutlet)
        
        // present alert controller
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - View controller methods

    override func viewDidLoad() {
        
        super.viewDidLoad()

        photoPicker.delegate = self
        self.addPictureButtonOutlet.addBorderToButton(width: 1, color: .white)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        func success(filesReceived: [FileUploadObject], userToken: String?) {
            
            if filesReceived.count > 0 {
                
                self.collectionView.isHidden = false
                
                // save the files received
                if self.files != filesReceived {
                    
                    self.files = filesReceived
                }
            } else {
                
                self.files = []
                self.collectionView.isHidden = true
            }
            
            if userToken != nil {
                
                _ = KeychainHelper.SetKeychainValue(key: "UserToken", value: userToken!)
            }
        }
        
        func failed(error: HATError) {
            
            // log error
            _ = CrashLoggerHelper.hatErrorLog(error: error)
            self.collectionView.isHidden = true
        }
        
        // search for available files on hat
        HATFileService.searchFiles(userDomain: userDomain, token: userToken, successCallback: success, errorCallBack: failed)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        self.loadingScr?.view.frame = CGRect(x: self.view.frame.midX - 75, y: self.view.frame.midY - 160, width: 150, height: 160)
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        self.loadingScr?.view.frame = CGRect(x: self.view.frame.midX - 75, y: self.view.frame.midY - 160, width: 150, height: 160)
    }
    
    // MARK: - Show progress ring
    
    private func showProgressRing() {
        
        self.loadingScr = LoadingScreenWithProgressRingViewController.customInit(completion: 0, from: self.storyboard!)
        
        self.loadingScr!.view.createFloatingView(frame:CGRect(x: self.view.frame.midX - 75, y: self.view.frame.midY - 160, width: 150, height: 160), color: .tealColor(), cornerRadius: 15)
        
        self.addViewController(self.loadingScr!)
    }
    
    // MARK: - Image picker methods
    
    func didFinishWithError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        
    }
    
    func didChooseImageWithInfo(_ info: [String : Any]) {
        
        let image = (info[UIImagePickerControllerOriginalImage] as! UIImage)
        
        self.showProgressRing()
        
        HATAccountService.uploadFileToHATWrapper(token: self.userToken, userDomain: self.userDomain, fileToUpload: image,
            progressUpdater: {progress in
                
                self.loadingScr?.updateView(completion: progress)
            },
            completion: {[weak self] (file, renewedUserToken) in
        
                if self?.loadingScr != nil {
                    
                    self?.loadingScr?.removeFromParentViewController()
                    self?.loadingScr?.view.removeFromSuperview()
                    self?.loadingScr = nil
                }
                
                if let weakSelf = self {
                    
                    weakSelf.files.append(file)
                }
                
                // refresh user token
                if renewedUserToken != nil {
                    
                    _ = KeychainHelper.SetKeychainValue(key: "UserToken", value: renewedUserToken!)
                }
            },
            errorCallBack: {error in
                
                _ = CrashLoggerHelper.hatTableErrorLog(error: error)
            }
        )
    }
    
    // MARK: - UICollectionView methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.files.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotosCollectionViewCell
        
        let imageURL: String = "https://" + self.userDomain + "/api/v2/files/content/" + self.files[indexPath.row].fileID
        
        if cell?.image.image == UIImage(named: "Image Placeholder") {
            
            cell!.image.downloadedFrom(url: URL(string: imageURL)!, completion: {[weak self] in
            
                if self != nil {
                    
                    cell?.image.cropImage(width: (cell?.image.frame.size.width)!, height: (cell?.image.frame.size.height)!)
                    self!.images.append(((cell?.image.image)!, (self?.files[indexPath.row].lastUpdated)!))
                }
            })
        } else {
            
            cell?.image.image = self.images[indexPath.row].0
        }
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedFileToView = self.files[indexPath.row]
        self.performSegue(withIdentifier: "fullScreenPhotoViewerSegue", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is PhotoFullScreenViewerViewController {
            
            weak var destinationVC = segue.destination as? PhotoFullScreenViewerViewController
            
            destinationVC?.file = self.selectedFileToView
        }
    }

}
