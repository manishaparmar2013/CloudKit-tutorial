//
//  AddListViewController.swift
//  testcloudkit
//
//  Created by Manisha Parmar on 7/02/2016.
//  Copyright © 2016 Manisha Parmar. All rights reserved.
//

import UIKit
import CloudKit
import SVProgressHUD

protocol AddListViewControllerDelegate {
    func controller(controller: AddListViewController, didAddList list: CKRecord)
    func controller(controller: AddListViewController, didUpdateList list: CKRecord)
}

class AddListViewController: UIViewController, UITextViewDelegate {
   
    @IBOutlet weak var saveButton: UIBarButtonItem!
    //@IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var nameTextField: UITextView!
    var delegate: AddListViewControllerDelegate?
    var newList: Bool = true
    
    var list: CKRecord?
    
    // MARK: -
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        // Update Helper
        newList = list == nil
        
        // Add Observer
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "textFieldTextDidChange:", name: UITextFieldTextDidChangeNotification, object: nameTextField)
    }
    
    override func viewDidAppear(animated: Bool) {
        nameTextField.becomeFirstResponder()
    }
    
    // MARK: -
    // MARK: View Methods
    private func setupView() {
        updateNameTextField()
        updateSaveButton()
    }
    
    // MARK: -
    private func updateNameTextField() {
        if let name = list?.objectForKey("name") as? String {
            nameTextField.text = name
        }
        updateSaveButton()
    }
    
    // MARK: -
    private func updateSaveButton() {
        let text = nameTextField.text
        
        if let name = text {
            saveButton.enabled = !name.isEmpty
        } else {
            saveButton.enabled = false
        }
    }
    
    @IBAction func save(sender: AnyObject) {
        // Helpers
        let name = nameTextField.text
        
        // Fetch Private Database
        let privateDatabase = CKContainer.defaultContainer().privateCloudDatabase
        
        if list == nil {
            list = CKRecord(recordType: RecordTypeLists)
        }
        
        // Configure Record
        list?.setObject(name, forKey: "name")
        
        // Show Progress HUD
        SVProgressHUD.show()
        
        // Save Record
        privateDatabase.saveRecord(list!) { (record, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // Dismiss Progress HUD
                SVProgressHUD.dismiss()
                
                // Process Response
                self.processResponse(record, error: error)
            })
        }
    }
   
    @IBAction func cancel(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: -
    // MARK: Helper Methods
    private func processResponse(record: CKRecord?, error: NSError?) {
        var message = ""
        
        if let error = error {
            print(error)
            message = "We were not able to save your list."
            
        } else if record == nil {
            message = "We were not able to save your list."
        }
        
        if !message.isEmpty {
            // Initialize Alert Controller
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
            
            // Present Alert Controller
            presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            // Notify Delegate
            if newList {
                delegate?.controller(self, didAddList: list!)
            } else {
                delegate?.controller(self, didUpdateList: list!)
            }
            
            // Pop View Controller
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // MARK: -
    // MARK: Notification Handling
    func textFieldTextDidChange(notification: NSNotification) {
        updateSaveButton()
    }
    
    
    func textViewDidChange(textView: UITextView) {
        updateSaveButton()
    }


}
