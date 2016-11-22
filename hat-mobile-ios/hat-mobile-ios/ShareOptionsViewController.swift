//
//  ShareOptionsViewController.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 8/11/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

// MARK: Class

/// The share options view controller
class ShareOptionsViewController: UIViewController {
    
    // MARK: - Private variables
    
    /// The json file received from HAT
    private var jsonReceivedFromHat: JSON = JSON.null
    /// An array of strings holding the selected social networks to share the note
    private var shareOnSocial: [String] = ["facebook"]
    /// A string passed from Notables view controller about the kind of the note
    private var kind: String = "note"
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the facebook button
    @IBOutlet weak var facebookButton: UIButton!
    /// An IBOutlet for handling the rumpel button
    @IBOutlet weak var rumpelButton: UIButton!
    /// An IBOutlet for handling the twitter button
    @IBOutlet weak var twitterButton: UIButton!
    /// An IBOutlet for handling the text field
    @IBOutlet weak var messageTextField: UITextField!
    /// An IBOutlet for handling the public/private label
    @IBOutlet weak var publicLabel: UILabel!
    /// An IBOutlet for handling the public/private switch
    @IBOutlet weak var publicSwitch: UISwitch!
    
    // MARK: - IBActions

    /**
     This function is called when the user touches the rumpel image
     
     - parameter sender: The object that called this function
     */
    @IBAction func shareOnRumpel(_ sender: Any) {
        
        // if alpha is equal to 1 that means it's active and the user wants to deactivate it so dim the icon
        if self.rumpelButton.alpha == 1 {
            
            self.rumpelButton.alpha = 0.4
        } else {
            
            self.rumpelButton.alpha = 1
        }
    }
    
    /**
     This function is called when the user switches the switch
     
     - parameter sender: The object that called this function
     */
    @IBAction func publicSwitchUpdate(_ sender: Any) {
        
        // based on the switch state change the label accordingly
        if publicSwitch.isOn {
            
            self.publicLabel.text = "Public"
        } else {
            
            self.publicLabel.text = "Private"
        }
    }
    
    /**
     This function is called when the user touches the twitter image
     
     - parameter sender: The object that called this function
     */
    @IBAction func twitterButton(_ sender: Any) {
        
        // if alpha is equal to 1 that means it's active and the user wants to deactivate it so dim the icon
        if self.twitterButton.alpha == 1 {
            
            self.twitterButton.alpha = 0.4
        } else {
            
            self.twitterButton.alpha = 1
        }
    }
    
    /**
     This function is called when the user touches the share now button
     
     - parameter sender: The object that called this function
     */
    @IBAction func shareNowButton(_ sender: Any) {
        
        // start the procedure to upload the note to the hat
        HatAccountService.getUserToken(completion: self.checkNotableTableExists)
    }
    
    /**
     This function is called when the user touches the facebook image
     
     - parameter sender: The object that called this function
     */
    @IBAction func facebookButton(_ sender: Any) {
        
        // if alpha is equal to 1 that means it's active and the user wants to deactivate it so dim the icon
        if self.facebookButton.alpha == 1 {
            
            self.facebookButton.alpha = 0.4
            self.removeFromArray(string: "facebook")
        } else {
            
            self.facebookButton.alpha = 1
            self.shareOnSocial.append("facebook")
        }
    }
    
    // MARK: - Remove from array
    
    /**
     Removes from array the given string if found
     
     - parameter string: The string to remove from the array
     */
    func removeFromArray(string: String) -> Void {
        
        // check in the array
        for index in 0...self.shareOnSocial.count - 1 {
            
            // if the given string exists
            if self.shareOnSocial[index] == string {
                
                // remove the string
                self.shareOnSocial.remove(at: index)
            }
        }
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
        
        // go through the array
        for item in 0...array.count - 1 {
            
            // add the string to the stringToReturn
            stringToReturn += array[item]
        }
        
        // return the string
        return stringToReturn
    }
    
    // MARK: - Network methods
    
    /**
     Adds all the info about the note we want to add to the JSON file
     
     - parameter file: The JSON file in a Dictionary<String, Any>
     - returns: Dictionary<String, Any>
     */
    func updateJSONFile(file: Dictionary<String, Any>) -> Dictionary<String, Any> {
        
        var jsonFile = JSON(file)
        
        //update message
        jsonFile = JSONHelper.updateMessageOnJSON(file: jsonFile, message: self.messageTextField.text!)
        //update kind
        jsonFile = JSONHelper.updateKindOfNoteOnJSON(file: jsonFile, messageKind: self.kind)
        //update created time
        jsonFile = JSONHelper.updateCreatedOnDateOfNoteOnJSON(file: jsonFile)
        //update updated time
        jsonFile = JSONHelper.updateUpdatedOnDateOfNoteOnJSON(file: jsonFile)
        //update public
        jsonFile = JSONHelper.updateVisibilityOfNoteOnJSON(file: jsonFile, isShared: self.publicSwitch.isOn)
        //update share on
        jsonFile = JSONHelper.updateSharedOnDateOfNoteOnJSON(file: jsonFile, socialString: self.constructStringFromArray(array: self.shareOnSocial))
        //update phata
        jsonFile = JSONHelper.updatePhataOnDateOfNoteOnJSON(file: jsonFile, phata: Helper.TheUserHATDomain())
        
        return jsonFile.dictionaryObject!
    }
    
    /**
     Posts the note to the hat
     
     - parameter token: The token returned from the hat
     - parameter json: The json file as a Dictionary<String, Any>
     */
    func postNote(token: String, json: Dictionary<String, Any>) -> Void {
        
        // create JSON file for posting with default values
        let hatDataStructure = JSONHelper.createJSONForPostingOnNotables(textToPost: self.messageTextField.text!, hatTableStructure: json)
        // update JSON file with the values needed
        let hatData = self.updateJSONFile(file: hatDataStructure)

        // create the headers
        let headers = Helper.ConstructRequestHeaders(token)
        
        // make async request
        NetworkHelper.AsynchronousRequest("https://mariostsekis.hubofallthings.net/data/record/values", method: HTTPMethod.post, encoding: Alamofire.JSONEncoding.default, contentType: Constants.ContentType.JSON, parameters: hatData, headers: headers, completion: { (r: Helper.ResultType) -> Void in
            
            // handle result
            switch r {
                
            case .isSuccess(let isSuccess, _, _):
                
                if isSuccess {
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
            createTable: HatAccountService.createNotablesTable(token: authToken),
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
        
        return { (r: Helper.ResultType) -> Void in
            
            switch r {
                
            case .error( _, _): break
                
            case .isSuccess(let isSuccess, let statusCode, let result):
                
                if isSuccess {
                    
                    let dictionary = result.dictionary!
                    //table found
                    if statusCode == 200 {
                        
                        self.postNote(token: token, json: dictionary)
                        //table not found
                    } else if statusCode == 404 {
                        
                        createTable(self.postNote(token: token, json: dictionary))
                        //postNote
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
        self.title = "Create Notable"
        
        // setup text field
        self.messageTextField.keyboardAppearance = .dark
        self.messageTextField.borderStyle = .none
        self.messageTextField.attributedPlaceholder =
            NSAttributedString(string: "What's on your mind?", attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
        
        // create a button and add it to navigation bar
        let button = UIBarButtonItem(title: "Share", style: .done, target: self, action: #selector(shareNowButton))
        self.navigationItem.rightBarButtonItem = button
        
        // add keyboard handling to view
        self.addKeyboardHandling()
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
