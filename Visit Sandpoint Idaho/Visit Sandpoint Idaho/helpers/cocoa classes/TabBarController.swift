//
//  TabBarController.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/20/20.
//

import UIKit

class TabBarController: UITabBarController {
    
    //choose initial state fonts and weights here
    let normalTitleFont = UIFont(name: "Gotham-Light", size: 10.0)!
    let selectedTitleFont = UIFont(name: "Gotham-Bold", size: 10.0)!

    //choose initial state colors here
    let normalTitleColor = UIColor.gray
    let selectedTitleColor = UIColor.black

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //the following is a delegate method from the UITabBar protocol that's available
    //to UITabBarController automatically. It sends us information every
    //time a tab is pressed. Since we Tagged our tabs earlier, we'll know which one was pressed,
    //and pass that identifier into a function to set our button states for us
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        setButtonStates(itemTag: item.tag)
    }


    //the function takes the tabBar.tag as an Int
    func setButtonStates (itemTag: Int) {
        //making an array of all the tabs
        let tabs = self.tabBar.items

        //looping through and setting the states
        var x = 0
        while x < (tabs?.count)! {
            if tabs?[x].tag == itemTag {
                tabs?[x].setTitleTextAttributes([NSAttributedString.Key.font: selectedTitleFont, NSAttributedString.Key.foregroundColor: selectedTitleColor], for: .normal)
            } else {
                tabs?[x].setTitleTextAttributes([NSAttributedString.Key.font: normalTitleFont, NSAttributedString.Key.foregroundColor: normalTitleColor], for: .normal)
            }

            x += 1
        }
    }

}
