//
//  ViewControllerExtension.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 12/12/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import UIKit

// MARK: UIViewController Extension

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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name:.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name:.UIKeyboardWillHide, object: nil);
    }
    
    /**
     Function executed before the keyboard is shown to the user
     
     - parameter sender: The object that called this method
     */
    func keyboardWillShow(sender: NSNotification) {
        
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            if self.view.frame.origin.y == ((self.navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.height) {
                
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    /**
     Function executed before the keyboard hides from the user
     
     - parameter sender: The object that called this method
     */
    func keyboardWillHide(sender: NSNotification) {
        
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            if self.view.frame.origin.y != 0 {
                
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func hideKeyboardInScrollView(_ scrollView: UIScrollView) {
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    func showKeyboardInView(_ view: UIView, scrollView: UIScrollView, sender: NSNotification) {
        
        var userInfo = sender.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
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
