//
//  DataController.swift
//  MyPetPlanner
//
//  Created by Lidia on 03/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    /// Create a persistent container instance
    let persistentContainer: NSPersistentContainer
    
    /// Property to access the context
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    /// Create a background context
    let backgroundContext: NSManagedObjectContext!

    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
        backgroundContext = persistentContainer.newBackgroundContext()
    }
    
    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    /// Use the persistent container to load the persistent store
    func load(completion: (() -> Void)? = nil ) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.configureContexts()
            completion?()
        }
    }
}
