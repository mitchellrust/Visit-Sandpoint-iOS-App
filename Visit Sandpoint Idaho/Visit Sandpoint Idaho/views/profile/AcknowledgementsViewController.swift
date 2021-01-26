//
//  AcknowledgementsViewController.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/22/20.
//

import UIKit

class AcknowledgementsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func freepikUrlTapped(_ sender: UIButton) {
        if let url = URL(string: "https://www.freepik.com/vectors/background"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func icons8UrlTapped(_ sender: UIButton) {
        if let url = URL(string: "https://icons8.com"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

}
