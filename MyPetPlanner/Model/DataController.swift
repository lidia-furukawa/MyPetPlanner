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
    let persistentContainer:NSPersistentContainer
    
    /// Property to access the context
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    /// Use the persistent container to load the persistent store
    func load(completion: (() -> Void)? = nil ) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
