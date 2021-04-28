//
//  Healthcare+Extensions.swift
//  MyPetPlanner
//
//  Created by Lidia on 20/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import Foundation
import CoreData

extension Healthcare {

    static func fetchAllEventIdentifiers(for pet: Pet?, context: NSManagedObjectContext, completion: @escaping ([String]) -> ()) {
        let fetchRequest: NSFetchRequest<Healthcare> = Healthcare.fetchRequest()
        let petPredicate = NSPredicate(format: "pet == %@", pet ?? "")
        fetchRequest.predicate = petPredicate
        let sortDescriptor = NSSortDescriptor(key: "eventIdentifier", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let result = try context.fetch(fetchRequest)
            let eventIdentifier = result.compactMap { $0.eventIdentifier }
            completion(eventIdentifier)
        } catch let error as NSError {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
}
