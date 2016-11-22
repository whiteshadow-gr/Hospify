//
//  NotablesViewController.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 8/11/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

// MARK: UIViewController Extension

/// UIViewController extension
extension UIViewController {
    
    /**
     Hides keyboard when tap anywhere in the screen except keyboard
     */
    func hideKeyboardWhenTappedAround() {
        
        // create tap gesture
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        // add gesture to view
        view.addGestureRecognizer(tap)
    }
    
    /**
     Hides keyboard
     */
    func dismissKeyboard() {
        
        view.endEditing(true)
    }
    
    /**
     Adds keyboard handling to UIViewControllers via the common and standard Notifications
     */
    func addKeyboardHandling() {
        
        // create 2 notification observers for listening to the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
    }
    
    /**
     Function executed before the keyboard is shown to the user
     
     - parameter sender: The object that called this method
     */
    func keyboardWillShow(sender: NSNotification) {
        
//        let userInfo:NSDictionary = sender.userInfo! as NSDictionary
//        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
//        let keyboardRectangle = keyboardFrame.cgRectValue
//        let keyboardHeight = keyboardRectangle.height
//        let tabBarController = UITabBarController()
//        let tabBarHeight = tabBarController.tabBar.frame.size.height
//        self.view.frame.origin.y -= keyboardHeight - tabBarHeight
        
        // get keyboard size
        var info = sender.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        // create content insets
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        // init a scroll view
        let scrollView = UIScrollView(frame: self.view.frame)
        scrollView.isScrollEnabled = true
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        // create a rect in the screen
        var aRect: CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        
        // detect if the rect is behind the keyboard
        let flag = CGRect.contains(aRect)
        if flag(aRect) == true {
            
            // move the scroll view up
            let scrollPoint = CGPoint(x: 0.0, y: view.frame.origin.y - ((keyboardSize?.height)! - view.frame.size.height - 50));
            scrollView.setContentOffset(scrollPoint, animated: true)
        }
    }
    
    /**
     Function executed before the keyboard hides from the user
     
     - parameter sender: The object that called this method
     */
    func keyboardWillHide(sender: NSNotification) {
        
        self.view.frame.origin.y = 0
    }
    
    /**
     Function executed when the return key is pressed in order to hide the keyboard
     
     - parameter textField: The textfield that confronts to this function
     - returns: Bool
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return false
    }
}

// MARK: - Notables ViewController

/// The notables view controller
class NotablesViewController: UIViewController, UITabBarDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // MARK: - IBOutlets

    /// An IBOutlet for handling the table view
    @IBOutlet weak var tableView: UITableView!
    /// An IBOutlet for handling the create new notes green view at the bottom of the screen
    @IBOutlet weak var createNewNoteView: UIView!
    
    // MARK: - IBActions
    
    /**
     Go to New note and create a note
     
     - parameter sender: The object that calls this function
     */
    @IBAction func newNoteButton(_ sender: Any) {
        
        self.performSegue(withIdentifier: "optionsSegue", sender: self)
    }
    
    /**
     Go to New note and create a blog
     
     - parameter sender: The object that calls this function
     */
    @IBAction func newBlogButton(_ sender: Any) {
        
        self.performSegue(withIdentifier: "optionsSegue", sender: self)
    }
    
    /**
     Go to New note and create a list
     
     - parameter sender: The object that calls this function
     */
    @IBAction func newListButton(_ sender: Any) {
        
        self.performSegue(withIdentifier: "optionsSegue", sender: self)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // keep the green bar at the top
        self.view.bringSubview(toFront: createNewNoteView)
        
        // add keyboard handling
        self.hideKeyboardWhenTappedAround()
        self.addKeyboardHandling()
        
        HatAccountService.getUserToken(completion: self.checkNotableTableExists)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showReceivedNotes), name: NSNotification.Name(rawValue: "notesArray"), object: nil)
    }
    
    func showReceivedNotes(notification: Notification) {
        
        let test = notification.object as! [JSON]
        print(test)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table View Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // get cell from the reusable id
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellData") as! NotablesTableViewCell
        
        // create this zebra like color based on the index of the cell
        if (indexPath.row % 2 == 1) {
            
            cell.contentView.backgroundColor = UIColor.init(colorLiteralRed: 51/255, green: 74/255, blue: 79/255, alpha: 1)
        }
        
        // return cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2;
    }
    
    // MARK: - Network functions
    
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
                    
                    let tableID = result["fields"][0]["tableId"].number
                    print(tableID!)
                    //table found
                    if statusCode == 200 {
                        
                        // get notes
                        HatAccountService.getNotes(token: token, tableID: String(describing: tableID!))
                    //table not found
                    } else if statusCode == 404 {
                        
                        // create table
                        //HatAccountService.createNotablesTable(token: token)
                        // show no notes
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        
//    }
}
