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
import Alamofire
import SwiftyJSON
import KeychainSwift
import SafariServices

// MARK: - Notables ViewController

/// The notables view controller
class NotablesViewController: BaseLocationViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SFSafariViewControllerDelegate {
    
    // MARK: - Variables
    
    /// an array of the notes to display
    var notesArray: [NotesData] = []
    /// the kind of the note to create
    var kind: String = ""
    /// the cells of the table
    var cells: [NotablesTableViewCell] = []
    /// The safari view controller variable to hold reference for later use
    var safariDelegate: SFSafariViewController? = nil
    /// A message to display behind the table view if something is wrong
    var emptyTableLabel: UILabel = UILabel()

    // MARK: - IBOutlets

    /// An IBOutlet for handling the table view
    @IBOutlet weak var tableView: UITableView!
    /// An IBOutlet for handling the create new notes green view at the bottom of the screen
    @IBOutlet weak var createNewNoteView: UIView!
    /// An IBOutlet for handling the create new note button
    @IBOutlet weak var createNewNoteLabel: UILabel!
    /// An IBOutlet for handling the create new list button
    @IBOutlet weak var createNewListLabel: UILabel!
    /// An IBOutlet for handling the create new blog button
    @IBOutlet weak var createNewBlogLabel: UILabel!
    
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
        
        // register observers for a notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.showReceivedNotes), name: NSNotification.Name(rawValue: "notesArray"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshData), name: NSNotification.Name(rawValue: "refreshTable"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openSafari), name: NSNotification.Name(rawValue: "safari"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideTable), name: NSNotification.Name(rawValue: "NoInternet"), object: nil)
        
        // add gesture recognizer in the labels
        let newNoteTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(newNoteButton(_:)))
        self.createNewNoteLabel.addGestureRecognizer(newNoteTapGestureRecognizer)
        self.createNewNoteLabel.isUserInteractionEnabled = true
        
        let newListTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(newListButton(_:)))
        self.createNewListLabel.addGestureRecognizer(newListTapGestureRecognizer)
        self.createNewListLabel.isUserInteractionEnabled = true
        
        let newBlogTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(newBlogButton(_:)))
        self.createNewBlogLabel.addGestureRecognizer(newBlogTapGestureRecognizer)
        self.createNewBlogLabel.isUserInteractionEnabled = true
        
        // connect to the server
        self.connectToServerToGetNotes()
        let boolResult = { (bool: String) -> Void in
            
            if bool == "true" {
                
                // refresh
            }
        }
        
        DataPlugsService.ensureDataPlugReady(succesfulCallBack: boolResult, failCallBack: self.clearErrorDisplay)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.refreshData(notification: Notification(name: Notification.Name("refreshTable")))
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Show Notes
    
    /**
     Shows the received notes
     
     - parameter notification: The notification object
     */
    func showReceivedNotes(notification: Notification) {
        
        // delete the notes array
        self.notesArray.removeAll()
        // extract the dictionary from jdon
        let dictionary = notification.object as! [JSON]
        // for each dictionary parse it and add it to the array
        for dict in dictionary {
            
            self.notesArray.append(NotesData.init(dict: dict.dictionary!))
        }
        
        // if no data show message
        if notesArray.count == 0 {
            
            self.showEmptyTableLabelWith(message: "No notables. Please create your first Note!")
        // else setup UI
        } else {
            
            self.tableView.isHidden = false
            self.emptyTableLabel.removeFromSuperview()
            // reload table
            self.tableView.reloadData()
        }
    }
    
    /**
     Refreshes the table per new data request
     
     - parameter notification: The notification object
     */
    func refreshData(notification: Notification) {
        
        // delete the notes array
        self.notesArray.removeAll()
        
        // get notes
        self.connectToServerToGetNotes()
        
        // reload table
        self.tableView.reloadData()
    }
    
    /**
     Shows notables fetched from HAT
     
     - parameter array: The fetched notables
     */
    func showNotables(array: [JSON]) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notesArray"), object: array)
    }

    // MARK: - Table View Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // get cell from the reusable id
        let controller = NotablesTableViewCell()
        
        // setup cell
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellData", for: indexPath) as? NotablesTableViewCell
        cell = controller.setUpCell(cell!, note: notesArray[indexPath.row], indexPath: indexPath)
        
        // add cell to array
        cells.append(cell!)
        
        // return cell
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // return number of notes
        return notesArray.count;
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        // enable swipte to delete
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            func proceedCompletion() {
                
                // delete data from hat and remove from table
                let token = HatAccountService.getUsersTokenFromKeychain()
                NotablesService.deleteNoteWithKeychain(id: self.notesArray[indexPath.row].id, tkn: token)
                self.notesArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // if it is shared show message else delete the row
            if self.notesArray[indexPath.row].data.shared {
                
                self.createClassicAlertWith(alertMessage: "Deleting a note that has already been shared will not delete it at the destination. \n\nTo remove a note from the external site, first make it private. You may then choose to delete it.", alertTitle: "", cancelTitle: "Cancel", proceedTitle: "Proceed", proceedCompletion: proceedCompletion, cancelCompletion: {() -> Void in return})
            } else {
                
                proceedCompletion()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // deselect selected row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Network functions
    
    /**
     Connects to the server to get the notes
     */
    func connectToServerToGetNotes() {
        
        // get token and refresh view
        let token = HatAccountService.getUsersTokenFromKeychain()
        if token == "" {
            
            let loginPageView =  self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.navigationController?.pushViewController(loginPageView, animated: false)
        } else {
            
            NotablesService.fetchNotables(authToken: token, success: self.showNotables)
        }
    }
    
    // MARK: - Navigation

    //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.destination is ShareOptionsViewController {
            
            weak var destinationVC = segue.destination as? ShareOptionsViewController

            if segue.identifier == "editNoteSegue" {
                
                let cellIndexPath = self.tableView.indexPath(for: sender as! UITableViewCell)
                destinationVC?.receivedNote = self.notesArray[(cellIndexPath?.row)!]
                destinationVC?.isEditingExistingNote = true
            } else {
                
                destinationVC?.kind = self.kind
            }
        }
    }
    
    // MARK: - Safari View Controller delegate
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    /**
     Opens safari view controller to authorize facebook
     */
    func openSafari() -> Void {
        
        let userDomain = HatAccountService.TheUserHATDomain()
        let link = "https://" + userDomain + "/hatlogin?name=Facebook&redirect=https://social-plug.hubofallthings.com/hat/authenticate"
        
        guard let urlLink = URL(string: link) else {
            
            return
        }
        // open the log in procedure in safari
        self.safariDelegate = SFSafariViewController(url: urlLink)
        safariDelegate?.delegate = self
        
        // present safari view controller
        self.present(self.safariDelegate!, animated: true, completion: nil)
    }
    
    // MARK: - Hide table
    
    /**
     Hides table
     */
    func hideTable() {
        
        self.showEmptyTableLabelWith(message: "No Internet connection. Please connect and retry.")
    }
    
    /**
     Hides table and shows a label with the predifined label
     
     - parameter message: The message to show on the label
     */
    func showEmptyTableLabelWith(message: String) {
        
        self.emptyTableLabel = UILabel(frame: CGRect(x: self.view.center.x - 150, y: self.view.center.y - 100, width: 300, height: 80))
        self.emptyTableLabel.text = message
        self.emptyTableLabel.textAlignment = .center
        self.emptyTableLabel.textColor = .white
        self.emptyTableLabel.numberOfLines = 0
        
        self.view.backgroundColor = UIColor.init(colorLiteralRed: 29/255, green: 49/255, blue: 53/255, alpha: 1)
        self.tableView.isHidden = true
        
        self.view.addSubview(self.emptyTableLabel)
    }
}
