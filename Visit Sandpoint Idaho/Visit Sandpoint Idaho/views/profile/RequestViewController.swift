//
//  RequestViewController.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 2/13/21.
//

import UIKit
import FirebaseAuth

class RequestViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var businessNameTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var isOwnerSwitch: UISwitch!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        businessNameTextField.delegate = self
        websiteTextField.delegate = self
        emailTextField.delegate = self
        
        // Round corners of text fields and buttons
        businessNameTextField.borderStyle = UITextField.BorderStyle.roundedRect
        websiteTextField.borderStyle = UITextField.BorderStyle.roundedRect
        emailTextField.borderStyle = UITextField.BorderStyle.roundedRect
        submitButton.layer.cornerRadius = 5
        
        emailTextField.isHidden = true
    }
    
    @IBAction func isOwnerSwitchTapped(_ sender: UISwitch) {
        emailTextField.isHidden = !sender.isOn
    }

    @IBAction func submitButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        let businessName = Validation.trimWhitespace(str: businessNameTextField.text!)
        let website = Validation.trimWhitespace(str: websiteTextField.text!)
        let email = Validation.trimWhitespace(str: emailTextField.text!)
        
        // Check for unpopulated fields
        if businessName.count == 0 ||
            isOwnerSwitch.isOn && email.count == 0 {
            let alert = UIAlertController(title: "Please enter all fields", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        self.showSpinner(onView: self.view)
        let currentUser = Auth.auth().currentUser
        let userId = currentUser?.uid ?? ""
        let timestamp = NSDate()
        var data: Dictionary<String, Any> = [
            "timestamp": timestamp,
            "userId": userId,
            "message": "business_request",
            "businessName": businessName as Any,
            "businessURL": website as Any,
            "requestedByOwner": isOwnerSwitch.isOn as Any
        ]
        
        if isOwnerSwitch.isOn {
            data["ownerEmail"] = email as Any
        }
        
        CloudFS.sendSupportDocument(data: data, completion: { [self] error in
            self.removeSpinner()
            guard error == nil else {
                let alert = UIAlertController(title: "An error occurred", message: "Your request could not be made at this time. Please try again later.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            let alert = UIAlertController(title: "Request received", message: "Thank you for your request. Be on the lookout for the addition!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true)
        })
    }
    
    // Hide keyboard when return pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
