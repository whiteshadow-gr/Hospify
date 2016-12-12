//
//  ShareOptionsViewController.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 8/11/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import UIKit
import Alamofire

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
    /// a bool value to determine if the user is editing an existing value
    var isEditingExistingNote: Bool = false
    /// a flag to define if the keyboard is visible
    var isKeyboardVisible: Bool = false
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the text field
    @IBOutlet weak var messageTextField: UITextField!
    /// An IBOutlet for handling the public/private label
    @IBOutlet weak var publicLabel: UILabel!
    /// An IBOutlet for handling the public/private switch
    @IBOutlet weak var publicSwitch: UISwitch!
    /// An IBOutlet for handling the cancel button
    @IBOutlet weak var cancelButton: UIButton!
    /// An IBOutlet for handling the delete button
    @IBOutlet weak var deleteButtonOutlet: UIButton!
    /// An IBOutlet for handling the action view
    @IBOutlet weak var actionsView: UIView!
    /// An IBOutlet for handling the public icon label
    @IBOutlet weak var publicImageLabel: UILabel!
    /// An IBOutlet for handling the share for... icon label
    @IBOutlet weak var shareImageLabel: UILabel!
    /// An IBOutlet for handling the share with label
    @IBOutlet weak var shareWithLabel: UILabel!
    /// An IBOutlet for handling the share for... label
    @IBOutlet weak var shareForLabel: UILabel!
    /// An IBOutlet for handling the facebook button
    @IBOutlet weak var facebookButton: UIButton!
    /// An IBOutlet for handling the marketsquare button
    @IBOutlet weak var marketsquareButton: UIButton!
    /// An IBOutlet for handling the publish button
    @IBOutlet weak var publishButton: UIButton!
    /// An IBOutlet for handling the scroll view
    @IBOutlet weak var scrollView: UIScrollView!
    /// An IBOutlet for handling the UITextView
    @IBOutlet weak var textView: UITextView!
    /// An IBOutlet for handling the textViewAspectRationConstraint NSLayoutConstraint
    @IBOutlet weak var textViewAspectRationConstraint: NSLayoutConstraint!
    
    // MARK: - IBActions
    
    /**
     This function is called when the user touches the cancel button
     
     - parameter sender: The object that called this function
     */
    @IBAction func cancelButton(_ sender: Any) {
        
        _ = super.navigationController?.popViewController(animated: true)
    }
    
    /**
     This function is called when the user touches the share button
     
     - parameter sender: The object that called this function
     */
    @IBAction func shareButton(_ sender: Any) {
        
        // save text
        receivedNote?.data.message = self.textView.text!
        
        if !(receivedNote!.data.shared) {
            
            receivedNote?.data.sharedOn = ""
        }
        
        // start the procedure to upload the note to the hat
        let token = HatAccountService.getUsersTokenFromKeychain()
        // if user is not editing an existing note, so it is a new note, check if table exists and post the note
        if !isEditingExistingNote {
            
            self.checkNotableTableExists(authToken: token)
        // else the user is editing a note, delete the note first a post a new one
        } else {
            
            NotablesService.deleteNoteWithKeychain(id: (receivedNote?.id)!, tkn: token)
            self.checkNotableTableExists(authToken: token)
        }
        
        _ = super.navigationController?.popViewController(animated: true)
    }
    
    /**
     This function is called when the user touches the delete button
     
     - parameter sender: The object that called this function
     */
    @IBAction func deleteButton(_ sender: Any) {
        
        // if not a previous note then nothing to delete
        if isEditingExistingNote {
            
            let token = HatAccountService.getUsersTokenFromKeychain()
            NotablesService.deleteNoteWithKeychain(id: (receivedNote?.id)!, tkn: token)
        }
        
        _ = super.navigationController?.popViewController(animated: true)
    }
    
    /**
     This function is called when the user switches the switch
     
     - parameter sender: The object that called this function
     */
    @IBAction func publicSwitchStateChanged(_ sender: Any) {
        
        if self.textView.isFirstResponder {
            
            self.textView.resignFirstResponder()
        }
        // based on the switch state change the label accordingly
        if publicSwitch.isOn {
            
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
        }
    }
    
    /**
     This function is called when the user touches the share now button
     
     - parameter sender: The object that called this function
     */
    @IBAction func shareNowButton(_ sender: Any) {
        
        // save text
        receivedNote?.data.message = self.textView.text!
        // start the procedure to upload the note to the hat
        let token = HatAccountService.getUsersTokenFromKeychain()
        // if user is note editing an existing note post as a new note
        if !isEditingExistingNote {
            
            self.checkNotableTableExists(authToken: token)
        // else delete the existing note a post a new one
        } else {
            
            NotablesService.deleteNoteWithKeychain(id: (receivedNote?.id)!, tkn: token)
            self.checkNotableTableExists(authToken: token)
        }
        
        _ = super.navigationController?.popViewController(animated: true)
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
    func removeFromArray(string: String) -> Void {
        
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
    func constructStringFromArray(array: [String]) -> String {
        
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
    
    // MARK: - Network methods
    
    /**
     Posts the note to the hat
     
     - parameter token: The token returned from the hat
     - parameter json: The json file as a Dictionary<String, Any>
     */
    func postNote(token: String, json: Dictionary<String, Any>) -> Void {
        
        // create JSON file for posting with default values
        let hatDataStructure = JSONHelper.createJSONForPostingOnNotables(hatTableStructure: json)
        // update JSON file with the values needed
        let hatData = JSONHelper.updateJSONFile(file: hatDataStructure, noteFile: self.receivedNote!)
        
        // create the headers
        let headers = Helper.ConstructRequestHeaders(token)
        
        let domain = HatAccountService.TheUserHATDomain()
        
        // make async request
        NetworkHelper.AsynchronousRequest("https://" + domain + "/data/record/values", method: HTTPMethod.post, encoding: Alamofire.JSONEncoding.default, contentType: Constants.ContentType.JSON, parameters: hatData, headers: headers, completion: { (r: Helper.ResultType) -> Void in
            
            // handle result
            switch r {
                
            case .isSuccess(let isSuccess, _, _):
                
                if isSuccess {
                    
                    // reload table
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
                }
                
            case .error(let error, _):
                
                print("error res: \(error)")
            }
        })
    }
    
    /**
     Checks if notables table exists
     
     - parameter authToken: The auth token from hat
     */
    func checkNotableTableExists(authToken: String) -> Void {
        
        // create the url
        let tableURL = Helper.TheUserHATCheckIfTableExistsURL(tableName: "notablesv1", sourceName: "rumpel")
        
        // create parameters and headers
        let parameters = ["": ""]
        let header = ["X-Auth-Token": authToken]
        
        let passToken = self.checkNotablesTableExistsCompletionFunction(
            createTable: HatAccountService.createHatTable(token: authToken, notablesTableStructure: JSONHelper.createNotablesTableJSON()),
            token: authToken)
        
        // make async request
        NetworkHelper.AsynchronousRequest(
            tableURL,
            method: HTTPMethod.get,
            encoding: Alamofire.URLEncoding.default,
            contentType: Constants.ContentType.JSON,
            parameters: parameters,
            headers: header,
            completion:passToken)
    }
    
    /**
     Checks if notables table exists completion handler
     
     - parameter token: A function variable of type, (String) -> (_ r: Helper.ResultType)
     */
    func checkNotablesTableExistsCompletionFunction(createTable: @escaping (_ callback: Void) -> Void , token: String) -> (_ r: Helper.ResultType) -> Void {
        
        return { [weak self](r: Helper.ResultType) -> Void in
            
            switch r {
                
            case .error( _, _): break
                
            case .isSuccess(let isSuccess, let statusCode, let result):
                
                if isSuccess {
                    
                    guard let weakSelf = self else { return }
                    let dictionary = result.dictionary!
                    //table found
                    if statusCode == 200 {
                        
                        weakSelf.postNote(token: token, json: dictionary)
                        //table not found
                    } else if statusCode == 404 {
                        
                        createTable(weakSelf.postNote(token: token, json: dictionary))
                    }
                }
            }
        }
    }
    
    // MARK: - Autogenerated

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // set title in the navigation bar
        //let char: UniChar = 0x2B07;
        let font = UIFont(name: "SSGlyphish-Outlined", size: 21)
        let attributedString = NSMutableAttributedString(string: "\u{2B07}", attributes: [NSFontAttributeName: font!])
        let combination = NSMutableAttributedString()
        combination.append(NSAttributedString(string: self.kind.capitalized))
        combination.append(attributedString)
        super.navigationItem.title = combination.string
        
        // set image fonts
        self.publicImageLabel.attributedText = NSAttributedString(string: "\u{1F512}", attributes: [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont(name: "SSGlyphish-Filled", size: 21)!])
        self.shareImageLabel.attributedText = NSAttributedString(string: "\u{23F2}", attributes: [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont(name: "SSGlyphish-Filled", size: 21)!])
        
        // setup text field
        self.textView.keyboardAppearance = .dark
        
        // create a button and add it to navigation bar
//        let button = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(shareNowButton))
//        self.navigationItem.rightBarButtonItem = button
        
        // add tap gesture to navigation bar title
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(navigationTitleTap))
        self.navigationController?.navigationBar.subviews[1].isUserInteractionEnabled = true
        self.navigationController?.navigationBar.subviews[1].addGestureRecognizer(tapGesture)
        
        // add borders to buttons
        self.cancelButton.addBorderToButton(width: 1, color: .white)
        self.deleteButtonOutlet.addBorderToButton(width: 1, color: .white)
        
        // change title in publish button
        self.publishButton.setTitle("Publish " + self.kind.capitalized, for: .normal)
        
        // keep the green bar at the top
        self.view.bringSubview(toFront: actionsView)
        
        // if user is editing existing note set up the values accordingly
        if isEditingExistingNote {
            
            self.setUpUIElementsFromReceivedNote(self.receivedNote!)
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
        
        // add keyboard handling to view
//        self.addKeyboardHandling()
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
        
        // set teal color
        let color = UIColor.init(colorLiteralRed: 0/255, green: 150/255, blue: 136/255, alpha: 1)
        
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
    }
    
    /**
     Turns off the ui elemets
     */
    private func turnUIElementsOff() {
        
        // set the text of the public label
        self.publicLabel.text = "Private"
        // set the colors of the labels
        self.shareWithLabel.textColor = .lightGray
        self.shareForLabel.textColor = .lightGray
        
        // disable social images
        self.facebookButton.isUserInteractionEnabled = false
        self.marketsquareButton.isUserInteractionEnabled = false
        
        // set image fonts
        self.publicImageLabel.attributedText = NSAttributedString(string: "\u{1F512}", attributes: [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont(name: "SSGlyphish-Filled", size: 21)!])
        self.shareImageLabel.attributedText = NSAttributedString(string: "\u{23F2}", attributes: [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont(name: "SSGlyphish-Filled", size: 21)!])
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
    func navigationTitleTap() {
        
        
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
}
