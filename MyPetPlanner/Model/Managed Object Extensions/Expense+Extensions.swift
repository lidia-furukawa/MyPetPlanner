//
//  Expense+Extensions.swift
//  MyPetPlanner
//
//  Created by Lidia on 23/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import Foundation
import CoreData

extension Expense {
    
    static func fetchAllDataBy(_ attribute: String, for pet: Pet, fromDate: Date, toDate: Date, context: NSManagedObjectContext, completion: @escaping ([(totalAmount: Double, attribute: String)]) -> ()) {
        let keypathExp = NSExpression(forKeyPath: "amount")
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .decimalAttributeType
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Expense")
        let petPredicate = NSPredicate(format: "pet == %@", pet)
        let datePredicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", fromDate as CVarArg, toDate as CVarArg)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [petPredicate, datePredicate])
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        request.returnsObjectsAsFaults = false
        request.propertiesToGroupBy = [attribute]
        request.propertiesToFetch = [sumDesc, attribute]
        request.resultType = .dictionaryResultType
        
        context.perform {
            do {
                let results = try request.execute()
                let data = results.map { result -> (Double, String)? in
                    guard let resultDict = result as? [String: Any], let amount = resultDict["sum"] as? Double, let attribute = resultDict[attribute] as? String else { return nil }
                    return (amount, attribute)
                    }.compactMap { $0 }
                completion(data)
            } catch let error as NSError {
                print(error.localizedDescription)
                completion([])
            }
        }
    }
    
    static func deleteAllExpenses(for healthcare: Healthcare, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Expense")
        let predicate = NSPredicate(format: "healthcare == %@", healthcare)
        fetchRequest.predicate = predicate
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    static func fetchAllExpenses(for healthcare: Healthcare?, context: NSManagedObjectContext, completion: @escaping ([Expense]) -> ()) {
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        let predicate = NSPredicate(format: "healthcare == %@", healthcare ?? "")
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "amount", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
//        context.perform {
//            do {
//                let result = try fetchRequest.execute()
//                completion(result)
//            } catch let error as NSError {
//                fatalError("The fetch could not be performed: \(error.localizedDescription)")
//            }
//        }
        do {
            let result = try context.fetch(fetchRequest)
            completion(result)
        } catch let error as NSError {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
}
