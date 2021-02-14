//
//  firestore.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/21/20.
//

import Foundation
import FirebaseFirestore

class CloudFS {
    
    static func setUserDocument(docId: String, data: Dictionary<String, Any>, merge: Bool, completion: @escaping (Error?) -> Void) {
        Firestore.firestore().collection("users").document(docId).setData(data, merge: merge) { error in
            guard error == nil else {
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    static func getUserById(docId: String, completion: @escaping (User?) -> Void) {
        let docRef: DocumentReference = Firestore.firestore().collection("users").document(docId)
        docRef.getDocument(source: .default, completion: { (snapshot, error) in
            guard error == nil && snapshot!.exists else {
                completion(nil)
                return
            }
            let data = snapshot!.data()
            if data != nil {
                let user: User = User(id: data!["id"] as! String,
                                      firstName: data!["firstName"] as! String,
                                      lastName: data!["lastName"] as! String,
                                      email: data!["email"] as! String,
                                      favorites: data!["favorites"] as! [[String: String]],
                                      profilePhotoUrl: data!["profilePhotoUrl"] as! String)
                completion(user)
                return
            }
            completion(nil)
        })
    }
    
    static func sendSupportDocument(data: Dictionary<String, Any>, completion: @escaping (Error?) -> Void) {
        Firestore.firestore().collection("support").document().setData(data) { error in
            guard error == nil else {
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    /**
     Get home page config object for updating UI
     */
    static func getHomeConfig(completion: @escaping (HomeConfig?) -> Void) {
        let docRef: DocumentReference = Firestore.firestore().collection("home_config").document("home_config")
        docRef.getDocument(source: .default, completion: { (snapshot, error) in
            guard error == nil else {
                completion(nil)
                return
            }
            
            let data = snapshot!.data()
            if data != nil {
                let config: HomeConfig = HomeConfig(data: data!)
                completion(config)
                return
            }
            completion(nil)
        })
    }
    
    /**
     Get adventures
     */
    static func getAdventures(source: FirestoreSource, docIds: [String] = [], completion: @escaping (Array<Adventure>?) -> Void) {
        let adventuresRef: CollectionReference = Firestore.firestore().collection("adventures")
        var query: Query = adventuresRef
        if docIds.count != 0 {
            query = adventuresRef.whereField("id", in: docIds)
        }
        
        query.getDocuments(source: source, completion: { (snapshot, error) in
            guard error == nil && !snapshot!.isEmpty else {
                completion(nil)
                return
            }
            var adventures: Array<Adventure> = []
            for document in snapshot!.documents {
                let data = document.data()
                let adventure: Adventure = Adventure(data: data)
                adventures.append(adventure)
            }
            adventures.sort(by: { $0.rating > $1.rating })
            completion(adventures)
        })
    }
    
    /**
     Get details of a specific adventure
     */
    static func getAdventure(source: FirestoreSource, docId: String, completion: @escaping (Adventure?) -> Void) {
        let docRef: DocumentReference = Firestore.firestore().collection("adventures").document(docId)
        docRef.getDocument(source: source, completion: { (snapshot, error) in
            guard error == nil && snapshot!.exists else {
                completion(nil)
                return
            }
            let data = snapshot!.data()
            if data != nil {
                let adventure: Adventure = Adventure(data: data!)
                completion(adventure)
                return
            }
            completion(nil)
        })
    }
    
    /**
     Get all restaurants or shops
     */
    static func getBusinesses(source: FirestoreSource, collection: String, docIds: [String] = [], completion: @escaping (Array<Business>?) -> Void) {
        if collection != "restaurants" && collection != "shops" {
            print("CloudFS.getBusinesses - Invalid collection string")
            completion(nil)
            return
        }
        
        let businessesRef: CollectionReference = Firestore.firestore().collection(collection)
        var query: Query = businessesRef
        if docIds.count != 0 {
            query = businessesRef.whereField("id", in: docIds)
        }
        
        query.getDocuments(source: source, completion: { (snapshot, error) in
            guard error == nil && !snapshot!.isEmpty else {
                completion(nil)
                return
            }
            var businesses: Array<Business> = []
            for document in snapshot!.documents {
                let data = document.data()
                let business: Business = Business(data: data)
                businesses.append(business)
            }
            businesses.sort(by: { $0.imgUrl > $1.imgUrl })
            completion(businesses)
        })
    }
    
    /**
     Get  restaurants
     */
    static func getRestaurants(source: FirestoreSource, docIds: [String] = [], completion: @escaping (Array<Business>?) -> Void) {
        let restaurantsRef: CollectionReference = Firestore.firestore().collection("restaurants")
        var query: Query = restaurantsRef
        if docIds.count != 0 {
            query = restaurantsRef.whereField("id", in: docIds)
        }
        
        query.getDocuments(source: source, completion: { (snapshot, error) in
            guard error == nil && !snapshot!.isEmpty else {
                completion(nil)
                return
            }
            var restaurants: Array<Business> = []
            for document in snapshot!.documents {
                let data = document.data()
                let restaurant: Business = Business(data: data)
                restaurants.append(restaurant)
            }
            completion(restaurants)
        })
    }
    
    /**
     Get  shops
     */
    static func getShops(source: FirestoreSource, docIds: [String] = [], completion: @escaping (Array<Business>?) -> Void) {
        let shopsRef: CollectionReference = Firestore.firestore().collection("shops")
        var query: Query = shopsRef
        if docIds.count != 0 {
            query = shopsRef.whereField("id", in: docIds)
        }
        
        query.getDocuments(source: source, completion: { (snapshot, error) in
            guard error == nil && !snapshot!.isEmpty else {
                completion(nil)
                return
            }
            var shops: Array<Business> = []
            for document in snapshot!.documents {
                let data = document.data()
                let shop: Business = Business(data: data)
                shops.append(shop)
            }
            completion(shops)
        })
    }
    
    /**
     Get details of a specific business
     */
    static func getBusiness(source: FirestoreSource, collection: String, docId: String, completion: @escaping (Business?) -> Void) {
        let docRef: DocumentReference = Firestore.firestore().collection(collection).document(docId)
        docRef.getDocument(source: source, completion: { (snapshot, error) in
            guard error == nil && snapshot!.exists else {
                completion(nil)
                return
            }
            let data = snapshot!.data()
            if data != nil {
                let business: Business = Business(data: data!)
                completion(business)
                return
            }
            completion(nil)
        })
    }
    
    /**
     Add an adventure or business to favorites
     */
    static func addToFavorites(userId: String, favorite: [String: String], completion: @escaping (Error?) -> Void) {
        let userRef = Firestore.firestore().collection("users").document(userId)
        userRef.updateData(["favorites": FieldValue.arrayUnion([favorite])], completion: { error in
            guard error == nil else {
                completion(error)
                return
            }
            completion(nil)
        })
    }
    
    /**
     Remove an adventure or business from favorites
     */
    static func removeFromFavorites(userId: String, favorite: [String: String], completion: @escaping (Error?) -> Void) {
        let userRef = Firestore.firestore().collection("users").document(userId)
        userRef.updateData(["favorites": FieldValue.arrayRemove([favorite])], completion: { error in
            guard error == nil else {
                completion(error)
                return
            }
            completion(nil)
        })
    }
    
}
