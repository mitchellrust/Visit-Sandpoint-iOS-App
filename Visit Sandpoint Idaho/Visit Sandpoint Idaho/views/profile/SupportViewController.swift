//
//  SupportViewController.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/22/20.
//

import UIKit
import FirebaseAuth

class SupportViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    
    let placeholderText: String = "What's the issue?"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        submitButton.layer.cornerRadius = 5 // round corners of button
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.layer.cornerRadius = 5
        
        // set temporary placeholder text
        textView.text = placeholderText
        textView.textColor = UIColor.lightGray
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.endEditing(true)
            return true
        }
        
        let currentText: String = textView.text
        let updatedText: String = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if updatedText.isEmpty {
            textView.text = placeholderText
            textView.textColor = UIColor.lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        } else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        }
        else {
            return true
        }
        
        return false
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        textView.endEditing(true)
        if textView.text != placeholderText {
            self.showSpinner(onView: self.view)
            let currentUser = Auth.auth().currentUser
            let userId = currentUser?.uid ?? ""
            let timestamp = NSDate()
            let data: Dictionary<String, Any> = [
                "timestamp": timestamp,
                "userId": userId,
                "message": textView.text as Any
            ]
            
            CloudFS.sendSupportDocument(data: data, completion: { [self] error in
                self.removeSpinner()
                guard error == nil else {
                    let alert = UIAlertController(title: "An error occurred", message: "A support ticket could not be made at this time. Please try again later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                let alert = UIAlertController(title: "Help ticket submitted!", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true)
            })
        } else {
            let alert = UIAlertController(title: "Please enter a message", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
}
