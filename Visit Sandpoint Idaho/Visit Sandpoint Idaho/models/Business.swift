//
//  Business.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 12/5/20.
//

import Foundation

class Business {
    var id: String!
    var name: String!
    var imgUrl: String!
    var latitude: Double!
    var longitude: Double!
    var rating: Double!
    var summary: String!
    var type: String!
    var url: String!
    var streetAddress: String!
    var city: String!
    var state: String!
    var zipCode: String!
    var phone: String!
    
    
    init(data: [String: Any]) {
        self.id = data["id"] as? String
        self.name = data["name"] as? String
        self.imgUrl = data["imgUrl"] as? String
        self.latitude = data["latitude"] as? Double
        self.longitude = data["longitude"] as? Double
        self.rating = data["rating"] as? Double
        self.summary = data["summary"] as? String
        self.type = data["type"] as? String
        self.url = data["url"] as? String
        self.streetAddress = data["streetAddress"] as? String
        self.city = data["city"] as? String
        self.state = data["state"] as? String
        self.zipCode = data["zipCode"] as? String
        self.phone = data["phone"] as? String
    }
    
    static func toDictionary(business: Business) -> Dictionary<String, Any> {
        let mirroredObj = Mirror(reflecting: business)
        var dict: Dictionary<String, Any> = [:]
        for (_, attr) in mirroredObj.children.enumerated() {
            if let property_name = attr.label as String? {
                dict[property_name] = attr.value
            }
        }
        return dict
    }

    
}
