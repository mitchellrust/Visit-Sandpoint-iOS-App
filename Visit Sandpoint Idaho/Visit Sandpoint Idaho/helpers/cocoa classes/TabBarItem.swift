//
//  TabBarItem.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/21/20.
//

import UIKit

class TabBarItem: UITabBarItem {

    //choose initial state fonts and weights here
    let normalTitleFont = UIFont(name: "Gotham-Light", size: 10.0)!
    let selectedTitleFont = UIFont(name: "Gotham-Bold", size: 10.0)!

    //choose initial state colors here
    let normalTitleColor = UIColor.gray
    let selectedTitleColor = UIColor.black

    //assigns the proper initial state logic when each tab instantiates
    override func awakeFromNib() {
        super.awakeFromNib()

        //this tag # should be your primary tab's Tag number
        if self.tag == 1 {
            self.setTitleTextAttributes([NSAttributedString.Key.font: selectedTitleFont, NSAttributedString.Key.foregroundColor: selectedTitleColor], for: .normal)
        } else {
            self.setTitleTextAttributes([NSAttributedString.Key.font: normalTitleFont, NSAttributedString.Key.foregroundColor: normalTitleColor], for: .normal)
        }

    }
    
}
