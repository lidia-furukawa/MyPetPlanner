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
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
    }
    
    static func fetchAllCategoriesData(for pet: Pet, fromDate: Date, toDate: Date, context: NSManagedObjectContext, completion: @escaping ([(totalAmount: Double, category: String)]) -> ()) {
        let keypathExp = NSExpression(forKeyPath: "expenseAmount")
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .decimalAttributeType
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Healthcare")
        let petPredicate = NSPredicate(format: "pet == %@", pet)
        let datePredicate = NSPredicate(format: "(expenseDate >= %@) AND (expenseDate <= %@)", fromDate as CVarArg, toDate as CVarArg)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [petPredicate, datePredicate])
        
        let sortDescriptor = NSSortDescriptor(key: "expenseAmount", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        request.returnsObjectsAsFaults = false
        request.propertiesToGroupBy = ["category"]
        request.propertiesToFetch = [sumDesc, "category"]
        request.resultType = .dictionaryResultType
        
        context.perform {
            do {
                let results = try request.execute()
                let data = results.map { result -> (Double, String)? in
                    guard let resultDict = result as? [String: Any], let amount = resultDict["sum"] as? Double, let category = resultDict["category"] as? String else { return nil }
                    return (amount, category)
                    }.compactMap { $0 }
                completion(data)
            } catch let error as NSError {
                print(error.localizedDescription)
                completion([])
            }
        }
    }
}
