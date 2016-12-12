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
import KeychainSwift
import Crashlytics

// MARK: - Notables ViewController

/// The notables view controller
class NotablesViewController: BaseLocationViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    // MARK: - Variables
    
    /// an array of the notes to display
    var notesArray: [NotesData] = []
    /// the kind of the note to create
    var kind: String = ""
    /// the cells of the table
    var cells: [NotablesTableViewCell] = []

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
        
        // register for a notificaation to get the notes to the table
        NotificationCenter.default.addObserver(self, selector: #selector(self.showReceivedNotes), name: NSNotification.Name(rawValue: "notesArray"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshData), name: NSNotification.Name(rawValue: "refreshTable"), object: nil)
        
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

        // begin tracking
        //self.beginLocationTracking()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // connect to the server
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
    func showReceivedNotes(notification: Notification) {
        
        // delete the notes array
        self.notesArray.removeAll()
        // extract the dictionary from jdon
        let dictionary = notification.object as! [JSON]
        // for each dictionary parse it and add it to the array
        for dict in dictionary {
            
            self.notesArray.append(NotesData.init(dict: dict.dictionary!))
        }
        
        // reload table
        self.tableView.reloadData()
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

    // MARK: - Table View Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // get cell from the reusable id
        let controller = NotablesTableViewCell()
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellData", for: indexPath) as? NotablesTableViewCell
        cell = controller.setUpCell(cell!, note: notesArray[indexPath.row], indexPath: indexPath)
        
        cells.append(cell!)
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
            
            print(self.notesArray[indexPath.row].id)
            // delete data and row
            let token = HatAccountService.getUsersTokenFromKeychain()
            NotablesService.deleteNoteWithKeychain(id: self.notesArray[indexPath.row].id, tkn: token)
            self.notesArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
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
    
    func showNotables (array: [JSON]) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notesArray"), object: array)
    }
    
    // MARK: - Navigation

    //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.destination is ShareOptionsViewController {
            
            let destinationVC = segue.destination as! ShareOptionsViewController

            if segue.identifier == "editNoteSegue" {
                
                let cellIndexPath = self.tableView.indexPath(for: sender as! UITableViewCell)
                destinationVC.receivedNote = self.notesArray[(cellIndexPath?.row)!]
                destinationVC.isEditingExistingNote = true
            } else {
                
                destinationVC.kind = self.kind
            }
        }
    }
}
