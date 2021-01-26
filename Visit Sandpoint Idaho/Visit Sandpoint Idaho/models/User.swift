//
//  User.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/19/20.
//

import Foundation
import UIKit

class User {
    var id: String!
    var firstName: String!
    var lastName: String!
    var email: String!
    var favorites: [[String: String]]!
    var profilePhotoUrl: String!
    
    init(id: String, firstName: String, lastName: String, email: String, favorites: [[String: String]] = [], profilePhotoUrl: String = "") {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.favorites = favorites
        self.profilePhotoUrl = profilePhotoUrl
    }
    
    func toDictionary() -> Dictionary<String, Any> {
        return [
            "id": self.id!,
            "firstName": self.firstName!,
            "lastName": self.lastName!,
            "email": self.email!,
            "favorites": self.favorites!,
            "profilePhotoUrl": self.profilePhotoUrl!
        ]
    }
    
}
