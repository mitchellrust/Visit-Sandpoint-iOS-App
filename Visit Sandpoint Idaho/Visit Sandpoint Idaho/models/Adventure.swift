//
//  Adventure.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/26/20.
//

import Foundation
import UIKit

class Adventure {
    var id: String!
    var name: String!
    var difficulty: Int!
    var elevationGain: Int!
    var elevationLoss: Int!
    var elevationHigh: Int!
    var elevationLow: Int!
    var imgUrl: String!
    var latitude: Double!
    var longitude: Double!
    var length: Double!
    var location: String!
    var rating: Double!
    var summary: String!
    var type: String!
    var url: String!
    
    init(data: [String: Any]) {
        self.id = data["id"] as? String
        self.name = data["name"] as? String
        self.difficulty = data["difficulty"] as? Int
        self.elevationGain = data["elevationGain"] as? Int
        self.elevationLoss = data["elevationLoss"] as? Int
        self.elevationHigh = data["elevationHigh"] as? Int
        self.elevationLow = data["elevationLow"] as? Int
        self.imgUrl = data["imgUrl"] as? String
        self.latitude = data["latitude"] as? Double
        self.longitude = data["longitude"] as? Double
        self.length = data["length"] as? Double
        self.location = data["location"] as? String
        self.rating = data["rating"] as? Double
        self.summary = data["summary"] as? String
        self.type = data["type"] as? String
        self.url = data["url"] as? String
    }
    
    static func toDictionary(adventure: Adventure) -> Dictionary<String, Any> {
        let mirroredObj = Mirror(reflecting: adventure)
        var dict: Dictionary<String, Any> = [:]
        for (_, attr) in mirroredObj.children.enumerated() {
            if let property_name = attr.label as String? {
                dict[property_name] = attr.value
            }
        }
        return dict
    }

    
}
