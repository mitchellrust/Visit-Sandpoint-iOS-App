//
//  auth.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/21/20.
//

import Foundation
import FirebaseAuth

class Authentication {
    
    /**
     Create a new user in Firebase
     */
    static func createUser(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
            guard let _ = authResult?.user, error == nil else {
                completion(error)
                return
            }
            completion(nil)
        })
    }
    
    /**
     Log in user to Firebase
     */
    static func logIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { authResult, error in
            guard let _ = authResult?.user, error == nil else {
                completion(error)
                return
            }
            completion(nil)
        })
    }
    
    /**
     Log out user from Firebase
     */
    static func logOut() -> Error? {
        do {
            try Auth.auth().signOut()
        } catch {
            return error
        }
        
        return nil
    }
    
    /**
     Get the currently signed in Firebase user
     */
    static func getCurrentUser() -> FirebaseAuth.User? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        return currentUser
    }
    
}
