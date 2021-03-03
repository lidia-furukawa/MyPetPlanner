//
//  MyPetsViewController.swift
//  MyPetPlanner
//
//  Created by Lidia on 12/02/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit
import CoreData

class MyPetsViewController: UIViewController {

    var dataController: DataController!
    
    var fetchedResultsController: NSFetchedResultsController<Pet>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFetchedResultsController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        fetchedResultsController = nil
    }
    
    func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pet> = Pet.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
}

