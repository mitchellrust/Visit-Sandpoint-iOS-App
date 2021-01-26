//
//  LoginViewController.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/17/20.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPassButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var passButton: UIButton!
    
    var onDoneBlock : ((Bool) -> Void)? // used to check if user is logged in
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        emailTextField.borderStyle = UITextField.BorderStyle.roundedRect
        passTextField.borderStyle = UITextField.BorderStyle.roundedRect
        loginButton.layer.cornerRadius = 5
        
        // Set max size of scroll view
        self.scrollView.contentSize.height = CGFloat(self.contentView.frame.height * 1.5)
    }
    
    // Hide keyboard when return pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // Hide keyboard
        self.view.endEditing(true)
        
        let email = Validation.trimWhitespace(str: emailTextField.text!)
        let password = Validation.trimWhitespace(str: passTextField.text!)
        
        if email.count == 0 { // Email not provided
            let alert = UIAlertController(title: "Please enter your email", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else if password.count == 0 { // Password not provided
            let alert = UIAlertController(title: "Please enter your password", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else { // Attempt login
            self.showSpinner(onView: self.view)
            Authentication.logIn(email: email, password: password, completion: { [self] error in
                guard error == nil else {
                    self.removeSpinner()
                    let alert = UIAlertController(title: "Invalid email or password", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                let currentUser = Authentication.getCurrentUser()!
                CloudFS.getUserById(docId: currentUser.uid, completion: { [self] user in
                    self.removeSpinner()
                    guard user != nil else {
                        let alert = UIAlertController(title: "Could not log in", message: "This is an unexpected error. Please try again later.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        return
                    }
                    
                    let managedObjectContainer = CoreDataController.getInstance()
                    
                    // Save any favorites to core data
                    for favorite in user!.favorites {
                        let coreFavorite = Favorite(context: managedObjectContainer.viewContext)
                        coreFavorite.id = favorite["id"]
                        coreFavorite.collection = favorite["collection"]
                    }
                    
                    // Save user to core data
                    let coreUser = CoreUser(context: managedObjectContainer.viewContext)
                    coreUser.id = user!.id
                    coreUser.firstName = user!.firstName
                    coreUser.lastName = user!.lastName
                    coreUser.email = user!.email
                    
                    if user!.profilePhotoUrl! != "" {
                        FSStorage.getProfilePicture(url: user!.profilePhotoUrl, completion: { [self] data in
                            // Save user to core data
                            
                            coreUser.profileImage = data
                            CoreDataController.saveContext()
                            
                            self.dismiss(animated: true, completion: {
                                onDoneBlock!(true)
                            })
                        })
                    } else {
                        CoreDataController.saveContext()
                        self.dismiss(animated: true, completion: {
                            onDoneBlock!(true)
                        })
                    }
                })
            })
        }
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
    
    @IBAction func forgotPassButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Forgot Password", message: "Enter your email address to receive a password reset email.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Email"
        }
        alert.addAction(UIAlertAction(title: "Send Link", style: .default, handler: { [alert] (_) in
            let textField = alert.textFields![0]
            print("Text field: \(textField.text!)")
            Auth.auth().sendPasswordReset(withEmail: textField.text!, completion: { error in
                if let error = error {
                    print("Error sending password reset: \(error)")
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func passButtonTapped(_ sender: UIButton) {
        if passButton.titleLabel?.text! == "Show" {
            passTextField.isSecureTextEntry = false
            passButton.setTitle("Hide", for: .normal)
        } else {
            passTextField.isSecureTextEntry = true
            passButton.setTitle("Show", for: .normal)
        }
    }
    
    @IBAction func closeModalButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
