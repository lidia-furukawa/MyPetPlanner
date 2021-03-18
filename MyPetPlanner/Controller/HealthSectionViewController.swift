//
//  HealthViewController.swift
//  MyPetPlanner
//
//  Created by Lidia on 15/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit
import CoreData

class HealthSectionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataController: DataController!
    
    /// The pet whose health section is being displayed
    var pet: Pet?
    
    /// The health object whose section is being displayed
    var selectedObjectName = String()
    
    var keyPath = String()
    
    var sectionNameKeyPath = String()
    
    let tintColor = #colorLiteral(red: 0.6509035826, green: 0.2576052547, blue: 0.8440084457, alpha: 1)
    let backgroundColor = #colorLiteral(red: 0.8941176471, green: 0.7176470588, blue: 0.8980392157, alpha: 1)
    
    let dateFormatter = DateFormatter()

    lazy var fetchedResultsController: NSFetchedResultsController<NSManagedObject> = {
        switch selectedObjectName {
        case "Food":
            let frc: NSFetchedResultsController<Food> = setupFetchedResultsController(keyPath, sectionNameKeyPath)!
            return frc as! NSFetchedResultsController<NSManagedObject>
        default:
            return fatalError() as! NSFetchedResultsController<NSManagedObject>
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addObjectButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addObjectButton(_:)))
        navigationItem.rightBarButtonItem = addObjectButton
        navigationItem.title = selectedObjectName
    }

    /// Generic FetchedResultsController builder
    func setupFetchedResultsController<T: NSManagedObject>(_ keyPath: String, _ sectionNameKeyPath: String) -> NSFetchedResultsController<T>? {
        let fetchRequest = T.fetchRequest() as! NSFetchRequest<T>
        let predicate = NSPredicate(format: "pet == %@", pet ?? "")
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: keyPath, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController<T>(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        return fetchedResultsController
    }
    
    @objc func addObjectButton(_ sender: UIBarButtonItem) {
        
    }
}

// -----------------------------------------------------------------------------
// MARK: - UITableViewDataSource, UITableViewDelegate

extension HealthSectionViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController.sections?[section].name
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = backgroundColor
        //        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "HealthSectionCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! HealthSectionCell
        
        // Configure the cell
        cell.separatorInset = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)

        switch selectedObjectName {
        case "Food":
            let frc = fetchedResultsController as! NSFetchedResultsController<Food>
            let aFood = frc.object(at: indexPath)
            cell.sectionNameLabel?.text = aFood.type
            cell.sectionInfoLabel?.text = aFood.brand
            dateFormatter.dateFormat = "MM-dd-yyyy"
            cell.startDateLabel.text = dateFormatter.string(from: aFood.startDate!)
            cell.endDateLabel.text = dateFormatter.string(from: aFood.endDate!)
            
            if let photoData = aFood.photo {
                let image = UIImage(data: photoData)
                cell.photoImageView.image = image
            }
        default:
          fatalError()
        }
        return cell
    }
}

// -----------------------------------------------------------------------------
// MARK: - NSFetchedResultsControllerDelegate

extension HealthSectionViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: tableView.insertSections(indexSet, with: .fade)
        case .delete: tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        @unknown default:
            break
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
