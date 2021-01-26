//
//  HomeConfig.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/26/20.
//

import Foundation
import FirebaseFirestore

class HomeConfig {
    
    var lastAdventureUpdate: String!
    var lastRestaurantUpdate: String!
    var lastShopUpdate: String!
    var topAdventures: Array<String>!
    var topRestaurants: Array<String>!
    var topShops: Array<String>!
    
    init(data: [String: Any]) {
        let lastAdventureUpdate = data["lastAdventureUpdate"] as? Timestamp
        let lastRestaurantUpdate = data["lastRestaurantUpdate"] as? Timestamp
        let lastShopUpdate = data["lastShopUpdate"] as? Timestamp
        
        self.lastAdventureUpdate = lastAdventureUpdate?.dateValue().description
        self.lastRestaurantUpdate = lastRestaurantUpdate?.dateValue().description
        self.lastShopUpdate = lastShopUpdate?.dateValue().description
        self.topAdventures = data["topAdventures"] as? Array<String>
        self.topRestaurants = data["topRestaurants"] as? Array<String>
        self.topShops = data["topShops"] as? Array<String>
    }
    
}
