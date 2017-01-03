/** Copyright (C) 2016 HAT Data Exchange Ltd
 * SPDX-License-Identifier: AGPL-3.0
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * RumpelLite is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License
 * as published by the Free Software Foundation, version 3 of
 * the License.
 *
 * RumpelLite is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
 * the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General
 * Public License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
 */

import UIKit

// MARK: Class

/// The share options view controller
class ShareOptionsViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Private variables
    
    /// An array of strings holding the selected social networks to share the note
    private var shareOnSocial: [String] = []
    
    /// A string passed from Notables view controller about the kind of the note
    var kind: String = "note"
    
    /// the received note to edit from notables view controller
    var receivedNote: NotesData? = nil
    
    /// the cached received note to edit from notables view controller
    private var cachedIsNoteShared: Bool = false
    /// a bool value to determine if the user is editing an existing value
    var isEditingExistingNote: Bool = false
    /// a flag to define if the keyboard is visible
    private var isKeyboardVisible: Bool = false
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the public/private label
    @IBOutlet weak var publicLabel: UILabel!
    /// An IBOutlet for handling the public icon label
    @IBOutlet weak var publicImageLabel: UILabel!
    /// An IBOutlet for handling the share for... icon label
    @IBOutlet weak var shareImageLabel: UILabel!
    /// An IBOutlet for handling the share with label
    @IBOutlet weak var shareWithLabel: UILabel!
    /// An IBOutlet for handling the share for... label
    @IBOutlet weak var shareForLabel: UILabel!
    /// An IBOutlet for handling the durationSharedLabel
    @IBOutlet weak var durationSharedForLabel: UILabel!
    
    /// An IBOutlet for handling the public/private switch
    @IBOutlet weak var publicSwitch: UISwitch!
    
    /// An IBOutlet for handling the cancel button
    @IBOutlet weak var cancelButton: UIButton!
    /// An IBOutlet for handling the delete button
    @IBOutlet weak var deleteButtonOutlet: UIButton!
    /// An IBOutlet for handling the facebook button
    @IBOutlet weak var facebookButton: UIButton!
    /// An IBOutlet for handling the marketsquare button
    @IBOutlet weak var marketsquareButton: UIButton!
    /// An IBOutlet for handling the publish button
    @IBOutlet weak var publishButton: UIButton!
    
    /// An IBOutlet for handling the action view
    @IBOutlet weak var actionsView: UIView!
    /// An IBOutlet for handling the shareForView
    @IBOutlet weak var shareForView: UIView!
    
    /// An IBOutlet for handling the scroll view
    @IBOutlet weak var scrollView: UIScrollView!
    
    /// An IBOutlet for handling the UITextView
    @IBOutlet weak var textView: UITextView!

    /// An IBOutlet for handling the textViewAspectRationConstraint NSLayoutConstraint
    @IBOutlet weak var textViewAspectRationConstraint: NSLayoutConstraint!
    
    // MARK: - IBActions
    
    @IBAction func shareForDurationAction(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Share for...", message: "Select the duration you want this note to be shared for", preferredStyle: .actionSheet)
        
        let oneDayAction = UIAlertAction(title: "1 day", style: .default, handler: { (action) -> Void in
            
            self.durationSharedForLabel.text = "1 day"
            self.receivedNote?.data.publicUntil = Calendar.current.date(byAdding:.day, value:1, to: Date())!
            self.shareForLabel.text = "Share for..."
        })
        
        let sevenDaysAction = UIAlertAction(title: "7 days", style: .default, handler: { (action) -> Void in
            
            self.durationSharedForLabel.text = "7 days"
            self.receivedNote?.data.publicUntil = Calendar.current.date(byAdding:.day, value:7, to: Date())!
            self.shareForLabel.text = "Share for..."
        })
        
        let fourteenDaysAction = UIAlertAction(title: "14 days", style: .default, handler: { (action) -> Void in
            
            self.durationSharedForLabel.text = "14 days"
            self.receivedNote?.data.publicUntil = Calendar.current.date(byAdding:.day, value:14, to: Date())!
            self.shareForLabel.text = "Share for..."
        })
        
        let oneMonthAction = UIAlertAction(title: "1 month", style: .default, handler: { (action) -> Void in
           
            self.durationSharedForLabel.text = "1 month"
            self.receivedNote?.data.publicUntil = Calendar.current.date(byAdding:.month, value:1, to: Date())!
            self.shareForLabel.text = "Share for..."
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(oneDayAction)
        alertController.addAction(sevenDaysAction)
        alertController.addAction(fourteenDaysAction)
        alertController.addAction(oneMonthAction)
        alertController.addAction(cancelButton)
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            
            alertController.popoverPresentationController?.sourceRect = self.durationSharedForLabel.frame
            alertController.popoverPresentationController?.sourceView = self.shareForView;
        }
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    /**
     This function is called when the user touches the cancel button
     
     - parameter sender: The object that called this function
     */
    @IBAction func cancelButton(_ sender: Any) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    /**
     This function is called when the user touches the share button
     
     - parameter sender: The object that called this function
     */
    @IBAction func shareButton(_ sender: Any) {
        
        // hide keyboard
        self.textView.resignFirstResponder()
        
        let previousButtonTitle = self.publishButton.titleLabel?.text
        
        // change button title to saving
        self.publishButton.setTitle("Saving....", for: .normal)
        self.publishButton.isUserInteractionEnabled = false
        self.publishButton.alpha = 0.5
        
        // start the procedure to upload the note to the hat
        let token = HatAccountService.getUsersTokenFromKeychain()
        // if user is note editing an existing note post as a new note
        
        func defaultCancelAction() {
            
            self.publishButton.setTitle(previousButtonTitle, for: .normal)
            self.publishButton.isUserInteractionEnabled = true
            self.publishButton.alpha = 1
        }
        
        if (self.receivedNote?.data.shared)! && ((self.receivedNote?.data.sharedOn)! == "") {
            
            self.createClassicOKAlertWith(alertMessage: "Please select at least one shared destination", alertTitle: "", okTitle: "OK", proceedCompletion: {() -> Void in defaultCancelAction()})
            return
        }
        
        // not editing note
        if !isEditingExistingNote {
            
            func proceedCompletion() {
                
                // save text
                self.receivedNote?.data.message = self.textView.text!
                
                NotablesService.postNote(token: token, note: self.receivedNote!, successCallBack: {() -> Void in
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
                    HatAccountService.triggerHatUpdate()
                    _ = self.navigationController?.popViewController(animated: true)
                })
            }
            
            if (receivedNote?.data.shared)! {
                
                self.createClassicAlertWith(alertMessage: "You are about to share your post. \n\nTip: to remove a note from the external site, edit the note and make it private.", alertTitle: "", cancelTitle: "Cancel", proceedTitle: "Share now", proceedCompletion: proceedCompletion, cancelCompletion: {() -> Void in defaultCancelAction()})
            } else {
                
                proceedCompletion()
            }
        // else delete the existing note and post a new one
        } else {
            
            func proceedCompletion() {
                
                // save text
                receivedNote?.data.message = self.textView.text!
                
                NotablesService.deleteNoteWithKeychain(id: (receivedNote?.id)!, tkn: token)
                NotablesService.postNote(token: token, note: self.receivedNote!, successCallBack: {() -> Void in
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
                    HatAccountService.triggerHatUpdate()
                    _ = self.navigationController?.popViewController(animated: true)
                })
            }
            
            if cachedIsNoteShared && (receivedNote?.data.message != self.textView.text!) {
                
                self.createClassicAlertWith(alertMessage: "Your post would not be edited at the destination.", alertTitle: "", cancelTitle: "Cancel", proceedTitle: "OK", proceedCompletion: proceedCompletion, cancelCompletion: {() -> Void in defaultCancelAction()})

            } else if (receivedNote?.data.shared)! {
                
                self.createClassicAlertWith(alertMessage: "You are about to share your post. \n\nTip: to remove a note from the external site, edit the note and make it private.", alertTitle: "", cancelTitle: "Cancel", proceedTitle: "Share now", proceedCompletion: proceedCompletion, cancelCompletion: {() -> Void in defaultCancelAction()})
            } else {
                
                proceedCompletion()
            }
        }
    }
    
    /**
     This function is called when the user touches the delete button
     
     - parameter sender: The object that called this function
     */
    @IBAction func deleteButton(_ sender: Any) {
        
        // if not a previous note then nothing to delete
        if isEditingExistingNote {
            
            func proceedCompletion() {
                
                let token = HatAccountService.getUsersTokenFromKeychain()
                NotablesService.deleteNoteWithKeychain(id: (receivedNote?.id)!, tkn: token)
                
                _ = self.navigationController?.popViewController(animated: true)
            }
            
            if cachedIsNoteShared {
                
                self.createClassicAlertWith(alertMessage: "Deleting a note that has already been shared will not delete it at the destination. \n\nTo remove a note from the external site, first make it private. You may then choose to delete it.", alertTitle: "", cancelTitle: "Cancel", proceedTitle: "Proceed", proceedCompletion: proceedCompletion, cancelCompletion: {() -> Void in return})
            } else {
                
                proceedCompletion()
            }
        }
    }
    
    /**
     This function is called when the user switches the switch
     
     - parameter sender: The object that called this function
     */
    @IBAction func publicSwitchStateChanged(_ sender: Any) {
        
        // hide keyboard if active
        if self.textView.isFirstResponder {
            
            self.textView.resignFirstResponder()
        }
        
        func proceedCompletion() {
            
            // based on the switch state change the label accordingly
            if self.publicSwitch.isOn {
                
                // update the ui accordingly
                self.turnUIElementsOn()
                self.turnImagesOn()
                self.facebookButton.isUserInteractionEnabled = true
                self.marketsquareButton.isUserInteractionEnabled = true
                self.receivedNote?.data.shared = true
            } else {
                
                // update the ui accordingly
                self.turnUIElementsOff()
                self.turnImagesOff()
                self.facebookButton.isUserInteractionEnabled = false
                self.marketsquareButton.isUserInteractionEnabled = false
                self.receivedNote?.data.shared = false
                self.durationSharedForLabel.text = "Forever"
            }
        }
        
        func cancelCompletion() {
            
            self.publicSwitch.isOn = true
        }
        
        if cachedIsNoteShared && !self.publicSwitch.isOn {
            
            self.createClassicAlertWith(alertMessage: "This will remove your post at the shared destinations. \n\nWarning: any comments at the destinations would also be deleted.", alertTitle: "", cancelTitle: "Cancel", proceedTitle: "Proceed", proceedCompletion: proceedCompletion, cancelCompletion: cancelCompletion)
        } else {
            
            proceedCompletion()
        }
    }
    
    /**
     This function is called when the user touches the facebook image
     
     - parameter sender: The object that called this function
     */
    @IBAction func facebookButton(_ sender: Any) {
        
        // if button is enabled
        if self.facebookButton.isUserInteractionEnabled {
            
            // if button was selected deselect it and remove the button from the array
            if self.facebookButton.alpha == 1{
                
                self.facebookButton.alpha = 0.4
                self.removeFromArray(string: "facebook")
            // else select it and add it to the array
            } else {
                
                self.facebookButton.alpha = 1
                shareOnSocial.append("facebook")
            }
            
            // construct string from the array and save it
            self.receivedNote?.data.sharedOn = self.constructStringFromArray(array: self.shareOnSocial)
        }
    }
    
    /**
     This function is called when the user touches the marketsquare image
     
     - parameter sender: The object that called this function
     */
    @IBAction func marketSquareButton(_ sender: Any) {
        
        // if button is enabled
        if self.marketsquareButton.isUserInteractionEnabled {
            
            // if button was selected deselect it and remove the button from the array
            if self.marketsquareButton.alpha == 1{
                
                self.marketsquareButton.alpha = 0.4
                self.removeFromArray(string: "marketsquare")
            // else select it and add it to the array
            } else {
                
                self.marketsquareButton.alpha = 1
                self.shareOnSocial.append("marketsquare")
            }
            
            // construct string from the array and save it
            self.receivedNote?.data.sharedOn = self.constructStringFromArray(array: self.shareOnSocial)
        }
    }
    
    // MARK: - Remove from array
    
    /**
     Removes from array the given string if found
     
     - parameter string: The string to remove from the array
     */
    private func removeFromArray(string: String) -> Void {
        
        // check in the array
        var found = false
        var index = 0
        
        repeat {
            
            if self.shareOnSocial[index] == string {
                
                // remove the string
                self.shareOnSocial.remove(at: index)
                found = true
            } else {
                
                index += 1
            }
        } while found == false
    }
    
    // MARK: - Construct string
    
    /**
     Combines an Array of strings in one string
     
     - parameter array: The array that has all the strings we want to combine
     - returns: A String
     */
    private func constructStringFromArray(array: [String]) -> String {
        
        // init a string
        var stringToReturn: String = ""
        
        // check if array is empty
        if array.count > 0 {
            
            // go through the array
            for item in 0...array.count - 1 {
                
                // add the string to the stringToReturn
                stringToReturn = stringToReturn.appending(array[item] + ",")
            }
        }
        
        // return the string
        return stringToReturn
    }
    
    // MARK: - Autogenerated

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // set title in the navigation bar
        let font = UIFont(name: "SSGlyphish-Outlined", size: 21)
        let attributedString = NSMutableAttributedString(string: "\u{2B07}", attributes: [NSFontAttributeName: font!])
        let combination = NSMutableAttributedString()
        combination.append(NSAttributedString(string: self.kind.capitalized))
        combination.append(attributedString)
        self.navigationItem.title = combination.string
        
        // set image fonts
        self.publicImageLabel.attributedText = NSAttributedString(string: "\u{1F512}", attributes: [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont(name: "SSGlyphish-Filled", size: 21)!])
        self.shareImageLabel.attributedText = NSAttributedString(string: "\u{23F2}", attributes: [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont(name: "SSGlyphish-Filled", size: 21)!])
        
        // setup text field
        self.textView.keyboardAppearance = .dark
        
        // add tap gesture to navigation bar title
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(navigationTitleTap))
        self.navigationController?.navigationBar.subviews[1].isUserInteractionEnabled = true
        self.navigationController?.navigationBar.subviews[1].addGestureRecognizer(tapGesture)
        
        // add gesture recognizer to share For view
        let tapGestureToShareForAction = UITapGestureRecognizer(target: self, action:  #selector (self.shareForDurationAction(_:)))
        self.shareForView.addGestureRecognizer(tapGestureToShareForAction)
        
        // add gesture recognizer to text view
        let tapGestureTextView = UITapGestureRecognizer(target: self, action:  #selector (self.enableEditingTextView))
        self.textView.addGestureRecognizer(tapGestureTextView)
        
        // add borders to buttons
        self.cancelButton.addBorderToButton(width: 1, color: .white)
        self.deleteButtonOutlet.addBorderToButton(width: 1, color: .white)
        
        // change title in publish button
        self.publishButton.titleLabel?.minimumScaleFactor = 0.5
        self.publishButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        // keep the green bar at the top
        self.view.bringSubview(toFront: actionsView)
        
        // if user is editing existing note set up the values accordingly
        if isEditingExistingNote {
            
            self.setUpUIElementsFromReceivedNote(self.receivedNote!)
            self.cachedIsNoteShared = (self.receivedNote?.data.shared)!
            if (self.receivedNote?.data.shared)! {
                
                self.publishButton.setTitle("Save", for: .normal)
            }
            if let unwrappedDate = self.receivedNote?.data.publicUntil {
                
                if unwrappedDate.compare(self.receivedNote!.data.updatedTime) == .orderedDescending && self.receivedNote!.data.shared {
                    
                    self.durationSharedForLabel.text = FormatterHelper.formatDateStringToUsersDefinedDate(date: unwrappedDate, dateStyle: .short, timeStyle: .none)
                    self.shareForLabel.text = "Shared until"
                }
            }
        // else init a new value
        } else {
            
            self.receivedNote = NotesData()
            self.deleteButtonOutlet.isHidden = true
        }
        
        self.receivedNote?.data.kind = self.kind
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow2), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide2), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.hideKeyboardWhenTappedAround()
        
        if (textView.text == "") {
            
            self.textView.textColor = .lightGray
            self.textView.text = "What's on your mind?"
        }
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        let contentSize = self.textView.sizeThatFits(self.textView.bounds.size)
        var frame = self.textView.frame
        frame.size.height = contentSize.height
        self.textView.frame = frame
        
        textViewAspectRationConstraint = NSLayoutConstraint(item: self.textView, attribute: .height, relatedBy: .equal, toItem: self.textView, attribute: .width, multiplier: textView.bounds.height/textView.bounds.width, constant: 1)
        self.textView.addConstraint(textViewAspectRationConstraint!)
        self.view.layoutSubviews()
        self.scrollView.setNeedsLayout()
    }
    
    // MARK: - Setup UI functins
    
    /**
     Update the ui from the received note
     */
    private func setUpUIElementsFromReceivedNote(_ receivedNote: NotesData) {
        
        // add message to the text field
        self.textView.text = receivedNote.data.message
        // set public switch state
        self.publicSwitch.setOn(receivedNote.data.shared, animated: false)
        // if switch is on update the ui accordingly
        if self.publicSwitch.isOn {
            
            self.shareOnSocial = receivedNote.data.sharedOn.stringToArray()
            self.turnUIElementsOn()
            self.turnImagesOn()
        }
    }
    
    /**
     Turns on the ui elemets
     */
    private func turnUIElementsOn() {
        
        // enable share for view
        self.shareForView.isUserInteractionEnabled = true
        
        // show the duration shared label
        self.durationSharedForLabel.isHidden = false
        
        // set teal color
        let color = UIColor.tealColor()
        
        // set the text of the public label
        self.publicLabel.text = "Shared"
        // set the colors of the labels
        self.shareWithLabel.textColor = .black
        self.shareForLabel.textColor = .black
        
        // enable social images
        self.facebookButton.isUserInteractionEnabled = true
        self.marketsquareButton.isUserInteractionEnabled = true
        
        // set image fonts
        self.publicImageLabel.attributedText = NSAttributedString(string: "\u{1F513}", attributes: [NSForegroundColorAttributeName: color, NSFontAttributeName: UIFont(name: "SSGlyphish-Filled", size: 21)!])
        self.shareImageLabel.attributedText = NSAttributedString(string: "\u{23F2}", attributes: [NSForegroundColorAttributeName: color, NSFontAttributeName: UIFont(name: "SSGlyphish-Filled", size: 21)!])
        
        if self.isEditingExistingNote {
            
            self.publishButton.setTitle("Save", for: .normal)
        } else {
            
            self.publishButton.setTitle("Share", for: .normal)
        }
    }
    
    /**
     Turns off the ui elemets
     */
    private func turnUIElementsOff() {
        
        // disable share for view
        self.shareForView.isUserInteractionEnabled = false
        
        // hide the duration shared label
        self.durationSharedForLabel.isHidden = true
        
        // set the text of the public label
        self.publicLabel.text = "Private"
        self.shareForLabel.text = "Share for..."
        // set the colors of the labels
        self.shareWithLabel.textColor = .lightGray
        self.shareForLabel.textColor = .lightGray
        
        // disable social images
        self.facebookButton.isUserInteractionEnabled = false
        self.marketsquareButton.isUserInteractionEnabled = false
        
        // set image fonts
        self.publicImageLabel.attributedText = NSAttributedString(string: "\u{1F512}", attributes: [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont(name: "SSGlyphish-Filled", size: 21)!])
        self.shareImageLabel.attributedText = NSAttributedString(string: "\u{23F2}", attributes: [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont(name: "SSGlyphish-Filled", size: 21)!])
        
        self.publishButton.setTitle("Save", for: .normal)
    }
    
    /**
     Turns on the images
     */
    private func turnImagesOn() {
        
        // check array for elements
        for socialName in self.shareOnSocial {
            
            // if facebook then enable facebook button
            if socialName == "facebook" {
                
                self.facebookButton.alpha = 1
            }
            //  enable marketsquare button
            if socialName == "marketsquare" {
                
                self.marketsquareButton.alpha = 1
            }
        }
    }
    
    /**
     Turns on the images
     */
    private func turnImagesOff() {
        
        // empty the array
        self.shareOnSocial.removeAll()
        // deselect buttons
        self.facebookButton.alpha = 0.4
        self.marketsquareButton.alpha = 0.4
    }

    /**
     A funtion executed on tap of the navigation title
     */
    @objc private func navigationTitleTap() {
        
        
    }
    
    // MARK: - Keyboard handling
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow2(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        self.scrollView.contentInset.bottom = keyboardFrame.size.height
        
        let desiredOffset = CGPoint(x: 0, y: self.scrollView.contentInset.top)
        self.scrollView.setContentOffset(desiredOffset, animated: true)
        self.actionsView.frame.origin.y = self.view.frame.height - keyboardFrame.size.height - self.actionsView.frame.size.height
        self.isKeyboardVisible = true
    }
    
    func keyboardWillHide2(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
        self.actionsView.frame.origin.y = self.view.frame.height - self.actionsView.frame.height
        self.isKeyboardVisible = false
    }
    
    // MARK: - TextView Delegate methods
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == "What's on your mind?" {
            
            textView.attributedText = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == "" {
            
            self.textView.textColor = .lightGray
            self.textView.text = "What's on your mind?"
        }
        
        self.textView.isEditable = false
    }
    
    @objc private func enableEditingTextView() {
        
        self.textView.isEditable = true
        
        textViewDidBeginEditing(self.textView)
        self.textView.becomeFirstResponder()
    }
}
