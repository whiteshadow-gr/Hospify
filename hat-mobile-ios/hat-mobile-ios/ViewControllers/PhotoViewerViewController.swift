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
    
    /// An array of tuple with type (UIImage, Date) used to matching
    private var images: [(UIImage, Date)] = []
    /// The files, images, to show in the cells
    private var files: [FileUploadObject] = [] {
        
        didSet {
            
            self.collectionView.reloadData()
        }
    }
    
    /// A loading ring progress bar used while uploading a new image
    private var loadingScr: LoadingScreenWithProgressRingViewController?
    /// User's domain
    private let userDomain = HATAccountService.TheUserHATDomain()
    /// User's token
    private let userToken = HATAccountService.getUsersTokenFromKeychain()
    /// The reuse identifier of the cell
    private let reuseIdentifier = "photosCell"
    
    /// The Photo picker used to upload a new photo
    private let photoPicker = PhotosHelperViewController()
    
    /// The selected image file to view full screen
    private var selectedFileToView: FileUploadObject?
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the collection view
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// An IBOutlet for handling the imageView
    @IBOutlet weak var addFirstPhotoFileImageView: UIImageView!
    
    /// An IBOutlet for handling the add picture button
    @IBOutlet weak var addPictureButtonOutlet: UIButton!
    
    // MARK: - IBActions

    /**
     Upload picture to hat
     
     - parameter sender: The object that called this method
     */
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
        
        self.loadingScr?.view.frame = CGRect(x: self.view.frame.midX - 75, y: self.view.frame.midY - 80, width: 150, height: 160)
        self.collectionView.reloadData()
    }
    
    // MARK: - Show progress ring
    
    private func showProgressRing() {
        
        self.loadingScr = LoadingScreenWithProgressRingViewController.customInit(completion: 0, from: self.storyboard!)
        
        self.loadingScr!.view.createFloatingView(frame:CGRect(x: self.view.frame.midX - 75, y: self.view.frame.midY - 80, width: 150, height: 160), color: .tealColor(), cornerRadius: 15)
        
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
                
                self.loadingScr?.updateView(completion: progress, animateFrom: Float((self.loadingScr?.progressRing.endPoint)!), removePreviousRingLayer: false)
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
        
        self.images.append((UIImage(), (self.files[indexPath.row].lastUpdated)!))
        
        if cell?.image.image == UIImage(named: "Image Placeholder") && URL(string: imageURL) != nil {
            
            cell?.ringProgressView.isHidden = false
            cell?.ringProgressView?.ringRadius = 15
            cell?.ringProgressView?.animationDuration = 0
            cell?.ringProgressView?.ringLineWidth = 4
            cell?.ringProgressView?.ringColor = .white
            cell?.ringProgressView.animationDuration = 0.2

            cell!.image.downloadedFrom(url: URL(string: imageURL)!,
                    progressUpdater: {progress in
            
                        let completion = CGFloat(progress)
                        cell?.ringProgressView.updateCircle(end: completion, animate: Float((cell?.ringProgressView.endPoint)!), to: Float(progress), removePreviousLayer: false)
                    },
                    completion: {[weak self] in
            
                        if self != nil && cell?.image != nil && self?.files[indexPath.row].lastUpdated != nil  {
                        
                            cell?.image.cropImage(width: (cell?.image.frame.size.width)!, height: (cell?.image.frame.size.height)!)
                            self!.images[indexPath.row] = ((cell?.image.image)!, (self?.files[indexPath.row].lastUpdated)!)
                        }
                        
                        cell?.ringProgressView.isHidden = true
                })
        } else if indexPath.row <= self.images.count - 1 {
            
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
