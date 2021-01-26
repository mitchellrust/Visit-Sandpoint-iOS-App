//
//  WelcomeViewController.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/17/20.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    var storyBoard: UIStoryboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.        
        storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        // Round corners of text fields and buttons
        signupButton.layer.cornerRadius = 5
        loginButton.layer.cornerRadius = 5
        
        let error = Authentication.logOut()
        if error != nil {
            print("User previously signed in, but can't be signed out")
        }
    }
    
    func checkLoggedIn() {
        let currentUser = Authentication.getCurrentUser()
        if currentUser != nil {
            let homeViewController = self.storyBoard.instantiateViewController(withIdentifier: "TabBarController")
            homeViewController.modalPresentationStyle = .fullScreen
            self.present(homeViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func signupButtonTapped(_ sender: UIButton) {
        let signupViewController = self.storyBoard.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        signupViewController.modalPresentationStyle = .fullScreen
        signupViewController.onDoneBlock = { result in
            guard result == true else {
                return
            }
            self.checkLoggedIn()
        }
        self.present(signupViewController, animated: true, completion: nil)
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let loginViewController = self.storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginViewController.modalPresentationStyle = .fullScreen
        loginViewController.onDoneBlock = { result in
            guard result == true else {
                return
            }
            self.checkLoggedIn()
        }
        self.present(loginViewController, animated: true, completion: nil)
    }
    
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        let homeViewController = self.storyBoard.instantiateViewController(withIdentifier: "TabBarController")
        homeViewController.modalPresentationStyle = .fullScreen
        self.present(homeViewController, animated: true, completion: nil)
    }
}
