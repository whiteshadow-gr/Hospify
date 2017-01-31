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
import SwiftyJSON
import SafariServices

// MARK: - Notables ViewController

/// The notables view controller
class NotablesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SFSafariViewControllerDelegate {
    
    // MARK: - Variables
    
    /// an array of the notes to display
    private var notesArray: [NotesData] = []
    /// a cached array of the notes to display
    private var cachedNotesArray: [NotesData] = []
    /// the cells of the table
    private var cells: [NotablesTableViewCell] = []
    
    /// the kind of the note to create
    private var kind: String = ""
    
    /// The safari view controller variable to hold reference for later use
    private var safariDelegate: SFSafariViewController? = nil
    private var notablesFetchLimit: String = "50"
    private var notablesFetchEndDate: String? = nil
    private var token: String = ""

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
    /// An IBOutlet for handling the info label when table view is empty or an error has occured
    @IBOutlet weak var eptyTableInfoLabel: UILabel!
    
    /// An IBOutlet for handling the retry connecting button when an error has occured
    @IBOutlet weak var retryConnectingButton: UIButton!

    // MARK: - IBActions
    
    /**
     Try to reconnect to get notes
     
     - parameter sender: The object that calls this function
     */
    @IBAction func refreshTableButtonAction(_ sender: Any) {
        
        self.retryConnectingButton.isHidden = true
        self.connectToServerToGetNotes()
        // FIXME: Do I need the bool result??
        let boolResult = { (bool: String) -> Void in
            
            if bool == "true" {
                
                // refresh
            }
        }
        
        let failCallBack = { self.createClassicOKAlertWith(alertMessage: "There was an error enabling data plugs, please go to web rumpel to enable the data plugs", alertTitle: "Data Plug Error", okTitle: "OK", proceedCompletion: {() -> Void in return}) }
        
        DataPlugsService.ensureDataPlugReady(succesfulCallBack: boolResult, failCallBack: failCallBack)
    }
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshData), name: NSNotification.Name(rawValue: "refreshTable"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openSafari), name: NSNotification.Name(rawValue: "safari"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideTable), name: NSNotification.Name(rawValue: "NetworkMessage"), object: nil)
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.connectToServerToGetNotes()
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
    private func showReceivedNotesFrom(array: [JSON]) {
        
        // delete the notes array
        self.notesArray.removeAll()

        // for each dictionary parse it and add it to the array
        for dict in array {
            
            self.notesArray.append(NotesData.init(dict: dict.dictionary!))
        }
        
        if self.notesArray.count == 0 {
            
            self.showEmptyTableLabelWith(message: "No notables. Keep your words on your HAT. Create your first notable!")
        }
        
        self.cachedNotesArray = self.notesArray
        
        // update UI
        self.updateUI()
    }
    
    /**
     Refreshes the table per new data request
     
     - parameter notification: The notification object
     */
    @objc private func refreshData(notification: Notification) {
        
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
    private func showNotables(array: [JSON]) {
        
        if array.count >= Int(self.notablesFetchLimit)! {
            
            self.notablesFetchLimit = "500"

            let object = NotesData(dict: (array.last?.dictionaryValue)!)
            let elapse = object.data.createdTime.timeIntervalSince1970
            
            let temp = String(elapse)
            
            let array2 = temp.components(separatedBy: ".")
            
            self.notablesFetchEndDate = array2[0]
            
            let parameters: Dictionary<String, String> = ["starttime" : "0",
                                                          "endtime" : self.notablesFetchEndDate!,
                                                          "limit" : self.notablesFetchLimit]
            
            NotablesService.fetchNotables(authToken: self.token, parameters: parameters, success: self.showNotables, failure: {() -> Void in return})
        }
        
        self.showReceivedNotesFrom(array: array)
    }

    // MARK: - Table View Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // get cell from the reusable id
        let controller = NotablesTableViewCell()
        
        // setup cell
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellData", for: indexPath) as? NotablesTableViewCell
        cell = controller.setUpCell(cell!, note: self.cachedNotesArray[indexPath.row], indexPath: indexPath)
        
        // add cell to array
        cells.append(cell!)
        
        // return cell
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // return number of notes
        return self.cachedNotesArray.count
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
                NotablesService.deleteNoteWithKeychain(id: self.cachedNotesArray[indexPath.row].id, tkn: token)
                self.cachedNotesArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.updateUI()
            }
            
            // if it is shared show message else delete the row
            if self.cachedNotesArray[indexPath.row].data.shared {
                
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
    private func connectToServerToGetNotes() {
        
        // get token and refresh view
        self.token = HatAccountService.getUsersTokenFromKeychain()
        if token == "" {
            
            let loginPageView =  self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.navigationController?.pushViewController(loginPageView, animated: false)
        } else {
            
            self.showEmptyTableLabelWith(message: "Accessing your HAT...")
            let parameters: Dictionary<String, String> = ["starttime" : "0",
                                                          "limit" : "50"]
            NotablesService.fetchNotables(authToken: self.token, parameters: parameters, success: self.showNotables, failure: showNewbieScreens)
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
                destinationVC?.receivedNote = self.cachedNotesArray[(cellIndexPath?.row)!]
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
    @objc private func openSafari() -> Void {
        
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
    
    // MARK: - Update UI
    
    /**
     Hides table
     */
    @objc private func hideTable(_ notif: Notification) {
        
        guard let message = notif.object as? String else {
            
            self.showEmptyTableLabelWith(message: "There was an unknown error, please try again later.")
            return
        }
        self.showEmptyTableLabelWith(message: message)
    }
    
    /**
     Hides table and shows a label with the predifined label
     
     - parameter message: The message to show on the label
     */
    private func showEmptyTableLabelWith(message: String) {
        
        if self.notesArray.count == 0 {
            
            var stringMessage = message
            
            if stringMessage == "The Internet connection appears to be offline." {
                
                self.retryConnectingButton.isHidden = false
                stringMessage = "No Internet connection. Please retry"
            } else {
                
                self.retryConnectingButton.isHidden = true
            }
            
            self.eptyTableInfoLabel.isHidden = false
            
            self.eptyTableInfoLabel.text = stringMessage
            
            self.tableView.isHidden = true
        }
    }
    
    /**
     Updates the UI elements according the messages received from the HAT
     */
    private func updateUI() {
        
        if self.notesArray.count > 0 {
            
            self.eptyTableInfoLabel.isHidden = true

            self.tableView.isHidden = false
            
            // reload table
            self.tableView.reloadData()
        } else {
            
            self.eptyTableInfoLabel.isHidden = false
            
            self.tableView.isHidden = true
        }
    }
    
    private func showNewbieScreens() -> Void {
        
        let result = KeychainHelper.GetKeychainValue(key: "hasOnboardingCompleted")
        
        if result != "yes" {
            
            // set up the created page view controller
            let pageViewController = self.storyboard!.instantiateViewController(withIdentifier: "firstTimeOnboarding") as! FirstOnboardingPageViewController
            pageViewController.view.frame = CGRect(x: self.view.frame.origin.x + 15, y: self.view.frame.origin.x + 15, width: self.view.frame.width - 30, height: self.view.frame.height - 30)
            pageViewController.view.layer.cornerRadius = 15
            
            // add the page view controller to self
            self.addChildViewController(pageViewController)
            self.view.addSubview(pageViewController.view)
            pageViewController.didMove(toParentViewController: self)
        }
    }
}
