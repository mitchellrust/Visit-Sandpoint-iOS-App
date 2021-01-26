//
//  CoreDataController.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/17/20.
//

import Foundation
import CoreData

/*
 * Singleton class design for accessing/modifying Core Data
 */
class CoreDataController: NSObject {
    
    // Singleton container variable
    static var container: NSPersistentContainer? = nil
    
    // Returns an instance of container singleton
    class func getInstance() -> NSPersistentContainer {
        if container == nil {
            container = NSPersistentContainer(name: "Visit_Sandpoint_Idaho")
            
            container!.loadPersistentStores { (storeDescription, error) in
                
                if let error = error as NSError? {
                    // TODO: graceful error handling
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
        }
        return container!
    }

    static func saveContext () {
        let context = container?.viewContext
        if context != nil && context!.hasChanges {
            do {
                try context?.save()
            } catch {
                // TODO: graceful error handling
                
                // handle error
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
