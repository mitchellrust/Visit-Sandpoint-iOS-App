//
//  SignupViewController.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/19/20.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CoreData

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var passButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    var onDoneBlock : ((Bool) -> Void)? // used to check if user is logged in
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passTextField.delegate = self
        
        // Get notified when keyboard shows/hides
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    // Adjust visual components
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Do any additional setup after the view appears
        
        // Round corners of text fields and buttons
        firstNameTextField.borderStyle = UITextField.BorderStyle.roundedRect
        lastNameTextField.borderStyle = UITextField.BorderStyle.roundedRect
        emailTextField.borderStyle = UITextField.BorderStyle.roundedRect
        passTextField.borderStyle = UITextField.BorderStyle.roundedRect
        signupButton.layer.cornerRadius = 5
        
        // Set max size of scroll view
        self.scrollView.contentSize.height = CGFloat(self.contentView.frame.height * 1.5)
    }
    
    // Attempt to create user and account
    @IBAction func signupButtonTapped(_ sender: UIButton) {
        let firstName = Validation.trimWhitespace(str: firstNameTextField.text!)
        let lastName = Validation.trimWhitespace(str: lastNameTextField.text!)
        let email = Validation.trimWhitespace(str: emailTextField.text!)
        let password = Validation.trimWhitespace(str: passTextField.text!)
        
        // Check for unpopulated fields
        if firstName.count == 0 ||
            lastName.count == 0 ||
            email.count == 0 ||
            password.count == 0 {
            let alert = UIAlertController(title: "Please enter all fields", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        // Create account
        self.showSpinner(onView: self.view)
        Authentication.createUser(email: email, password: password, completion: { [self] error in
            guard error == nil else {
                self.removeSpinner()
                let alert = UIAlertController(title: "Could not create account", message: error!.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            
            let currentUser = Authentication.getCurrentUser()! // We can force unwrape this because the above step succeeded
            
            let user = User(id: currentUser.uid, firstName: firstName, lastName: lastName, email: email)
            
            CloudFS.setUserDocument(docId: user.id, data: user.toDictionary(), merge: false, completion: { [self] error in
                self.removeSpinner()
                guard error == nil else {
                    let alert = UIAlertController(title: "Could not create account", message: "This is an unexpected error. Please try again later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                
                // Save new user to core data
                let managedObjectContainer = CoreDataController.getInstance()
                let coreUser = CoreUser(context: managedObjectContainer.viewContext)
                coreUser.id = user.id
                coreUser.firstName = user.firstName
                coreUser.lastName = user.lastName
                coreUser.email = user.email
                CoreDataController.saveContext()
                
                self.dismiss(animated: true, completion: {
                    onDoneBlock!(true)
                })
            })
        })
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    // Hide keyboard when return pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // Toggle secure text entry on password field
    @IBAction func passButtonTapped(_ sender: UIButton) {
        if passButton.titleLabel?.text! == "Show" {
            passTextField.isSecureTextEntry = false
            passButton.setTitle("Hide", for: .normal)
        } else {
            passTextField.isSecureTextEntry = true
            passButton.setTitle("Show", for: .normal)
        }
    }
    
    // Navigate to login page
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController")
        loginViewController.modalPresentationStyle = .fullScreen
        self.present(loginViewController, animated: false, completion: nil)
    }

    @IBAction func closeModalButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
