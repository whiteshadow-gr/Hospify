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
class NotablesViewController: BaseLocationViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    // MARK: - Variables
    
    var notesArray: [NotesData] = []
    var kind: String = ""

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
        
        kind = "note"
        self.performSegue(withIdentifier: "optionsSegue", sender: self)
    }
    
    /**
     Go to New note and create a blog
     
     - parameter sender: The object that calls this function
     */
    @IBAction func newBlogButton(_ sender: Any) {
        
        kind = "blog"
        self.performSegue(withIdentifier: "optionsSegue", sender: self)
    }
    
    /**
     Go to New note and create a list
     
     - parameter sender: The object that calls this function
     */
    @IBAction func newListButton(_ sender: Any) {
        
        kind = "list"
        self.performSegue(withIdentifier: "optionsSegue", sender: self)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // keep the green bar at the top
        self.view.bringSubview(toFront: createNewNoteView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showReceivedNotes), name: NSNotification.Name(rawValue: "notesArray"), object: nil)
        
        // begin tracking
        self.beginLocationTracking()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        HatAccountService.getUserToken(completion: self.checkNotableTableExists)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Show Notes
    
    func showReceivedNotes(notification: Notification) {
        
        self.notesArray.removeAll()
        let dictionary = notification.object as! [JSON]
        for dict in dictionary {
            
            self.notesArray.append(NotesData.init(dict: dict.dictionary!))
        }
        
        self.tableView.reloadData()
    }

    // MARK: - Table View Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // get cell from the reusable id
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellData") as! NotablesTableViewCell
        
        // return cell
        return NotablesTableViewCell.setUpCell(cell, note: notesArray[indexPath.row], indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notesArray.count;
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            print(self.notesArray[indexPath.row].id)
            // delete data and row
            HatAccountService.getUserToken(completion: HatAccountService.deleteNote(id: self.notesArray[indexPath.row].id))
            self.notesArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
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
                        _ = HatAccountService.createNotablesTable(token: token)
                        // show no notes
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation

    //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.destination is ShareOptionsViewController {
            
            let destinationVC = segue.destination as! ShareOptionsViewController

            if segue.identifier == "editNoteSegue" {
                
                let test = self.tableView.indexPath(for: sender as! UITableViewCell)
                destinationVC.receivedNote = self.notesArray[(test?.row)!]
            } else {
                
                destinationVC.kind = self.kind
            }
        }
    }
}
