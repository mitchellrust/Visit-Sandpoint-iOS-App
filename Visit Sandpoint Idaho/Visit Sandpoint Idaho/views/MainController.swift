//
//  MainController.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/17/20.
//

import UIKit
import FirebaseAuth

class MainController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    var adventureCacheReady: Bool = false
    var restaurantCacheReady: Bool = false
    var shopCacheReady: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Check firestore for updates before launching views
        CloudFS.getHomeConfig(completion: { [self] config in
            let defaults = UserDefaults.standard
            // Get previous last updates
            let lastAdventureUpdate = defaults.string(forKey: "lastAdventureUpdate")
            let lastRestaurantUpdate = defaults.string(forKey: "lastRestaurantUpdate")
            let lastShopUpdate = defaults.string(forKey: "lastShopUpdate")
            
            guard config != nil || lastAdventureUpdate != nil else {
                let alert = UIAlertController(title: "An error occurred", message: "It looks like you may not be connected to the internet. This app requires an internet connection on its very first launch. Please check your connection and try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in exit(0)}))
                self.present(alert, animated: true)
                return
            }
            
            if config == nil {
                self.navigate()
            } else {
                // Set updated defaults
                defaults.set(config?.topAdventures, forKey: "topAdventures")
                defaults.set(config?.topRestaurants, forKey: "topRestaurants")
                defaults.set(config?.topShops, forKey: "topShops")
                defaults.set(config?.homePhoto, forKey: "homePhoto")
                            
                // update caches
                
                if config!.lastAdventureUpdate != lastAdventureUpdate {
                    CloudFS.getAdventures(source: .server, completion: { [self, defaults] adventures in
                        if adventures == nil {
                            print("Could not update adventures cache")
                        } else {
                            print("Adventures cache successfully updated")
                            defaults.set(config?.lastAdventureUpdate, forKey: "lastAdventureUpdate")
                        }
                        adventureCacheReady = true
                        self.isReadyToNavigate()
                    }) // attempt a cache update
                } else {
                    adventureCacheReady = true
                    self.isReadyToNavigate()
                }
                
                if config!.lastRestaurantUpdate != lastRestaurantUpdate {
                    // update restaurant cache
                    CloudFS.getRestaurants(source: .server, completion: { [self, defaults] restaurants in
                        if restaurants == nil {
                            print("Could not update restaurants cache")
                        } else {
                            print("Restaurants cache successfully updated")
                            defaults.set(config?.lastRestaurantUpdate, forKey: "lastRestaurantUpdate")
                        }
                        restaurantCacheReady = true
                        self.isReadyToNavigate()
                    })
                } else {
                    restaurantCacheReady = true
                    self.isReadyToNavigate()
                }
                
                if config!.lastShopUpdate != lastShopUpdate {
                    // update shop cache
                    CloudFS.getShops(source: .server, completion: { [self, defaults] shops in
                        if shops == nil {
                            print("Could not update shops cache")
                        } else {
                            print("Shops cache successfully updated")
                            defaults.set(config?.lastShopUpdate, forKey: "lastShopUpdate")
                        }
                        shopCacheReady = true
                        self.isReadyToNavigate()
                    })
                    self.isReadyToNavigate()
                } else {
                    shopCacheReady = true
                    self.isReadyToNavigate()
                }
            }
        })
    }
    
    func isReadyToNavigate() {
        if adventureCacheReady && restaurantCacheReady && shopCacheReady {
            self.navigate()
        }
    }
    
    func navigate() {
        if(!appDelegate.hasAlreadyLaunched) {
            // set hasAlreadyLaunched to false
            appDelegate.sethasAlreadyLaunched()
            
            // navigate to WelcomeViewController
            let welcomeViewController = storyBoard.instantiateViewController(withIdentifier: "WelcomeViewController")
            welcomeViewController.modalPresentationStyle = .fullScreen
            self.present(welcomeViewController, animated: false, completion: nil)
        } else {
            // navigate to home view controller
            let tabBarController = storyBoard.instantiateViewController(withIdentifier: "TabBarController")
            tabBarController.modalPresentationStyle = .fullScreen
            self.present(tabBarController, animated: false, completion: nil)
        }
    }

}

