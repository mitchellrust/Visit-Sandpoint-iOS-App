//
//  storage.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/22/20.
//

import Foundation
import FirebaseStorage

class FSStorage {
    
    /**
     Add profile picture to Firebase Storage and return the download URL
     */
    static func addProfilePicture(userId: String, data: Data, completion: @escaping (String?) -> Void) {
        let pathName = "profile-pictures/\(userId).png"
        let photoRef = Storage.storage().reference().child(pathName)
        let uploadTask = photoRef.putData(data, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
                completion(nil)
                return
            }
            
            photoRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    completion(nil)
                    return
                }
                
                completion(downloadURL.absoluteString)
            }
        }
        
        uploadTask.resume() // start the upload
    }
    
    /**
     Get a user's profile picture from Storage.ß
     */
    static func getProfilePicture(url: String, completion: @escaping (Data?) -> Void) {
        let httpsReference = Storage.storage().reference(forURL: url)
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        httpsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            guard error == nil else {
                print(error as Any)
                completion(nil)
                return
            }
            completion(data!)
        }
    }
    
    static func getHomeHeaderPhoto(url: String, completion: @escaping (Data?) -> Void) {
        let httpsReference = Storage.storage().reference(forURL: url)
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        httpsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            guard error == nil else {
                print(error as Any)
                completion(nil)
                return
            }
            completion(data!)
        }
    }
    
}
