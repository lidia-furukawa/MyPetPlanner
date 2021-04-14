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
    
    var selectedObjectSectionName = String()
    
    var keyPath = String()
    
    var sectionNameKeyPath = String()
    
    var selectedIndexPath = IndexPath()
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSManagedObject> = {
        switch selectedObjectSectionName {
        case "Food":
            let frc: NSFetchedResultsController<Food> = setupFetchedResultsController(keyPath, sectionNameKeyPath)!
            return frc as! NSFetchedResultsController<NSManagedObject>
        default:
            return fatalError() as! NSFetchedResultsController<NSManagedObject>
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeView()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.popViewController(animated: false)
    }
    
    fileprivate func initializeView() {
        tableView.tableFooterView = UIView()
        navigationItem.title = selectedObjectName
        setupRightBarButton()
    }
    
    fileprivate func setupRightBarButton() {
        let addObjectButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addObjectButton(_:)))
        navigationItem.rightBarButtonItem = addObjectButton
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
        switch selectedObjectSectionName {
        case "Food":
            performSegue(withIdentifier: UIStoryboardSegue.Identifiers.createNewFood, sender: nil)
        default:
            fatalError("Unindentified Segue")
        }
    }
    
    /// Delete a section object at the specified index path
    func deleteSectionObject(at indexPath: IndexPath) {
        let sectionObjectToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(sectionObjectToDelete)
        try? dataController.viewContext.save()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case UIStoryboardSegue.Identifiers.createNewFood:
            let vc = segue.destination as! FoodViewController
            vc.selectedObjectName = selectedObjectName
            vc.pet = pet
            vc.dataController = dataController
        case UIStoryboardSegue.Identifiers.editFood:
            let vc = segue.destination as! FoodViewController
            vc.selectedObjectName = selectedObjectName
            vc.pet = pet
            vc.food = fetchedResultsController.object(at: selectedIndexPath) as? Food
            vc.dataController = dataController
        default:
            fatalError("Unindentified Segue")
        }
    }
}

// -----------------------------------------------------------------------------
// MARK: - TrailingSwipeActions

extension HealthSectionViewController: TrailingSwipeActions {
    func setEditAction(at indexPath: IndexPath) {
        selectedIndexPath = indexPath
        performSegue(withIdentifier: UIStoryboardSegue.Identifiers.editFood, sender: nil)
    }
    
    func setDeleteAction(at indexPath: IndexPath) {
        deleteSectionObject(at: indexPath)
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
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor.backgroundColor
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "HealthSectionCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! HealthSectionCell
        
        // Configure the cell
        cell.separatorInset = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)

        switch selectedObjectSectionName {
        case "Food":
            let frc = fetchedResultsController as! NSFetchedResultsController<Food>
            let aFood = frc.object(at: indexPath)
            cell.sectionNameLabel?.text = aFood.subcategory
            cell.sectionInfoLabel?.text = aFood.brand
            cell.startDateLabel.text = aFood.startDate!.stringFormat
            cell.endDateLabel.text = aFood.endDate!.stringFormat
        default:
          fatalError()
        }
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)
        let sectionImage = UIImage(named: cell.sectionNameLabel.text!)
        let templateImage = sectionImage?.withRenderingMode(.alwaysTemplate)
        cell.photoImageView.image = templateImage
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return configureSwipeActionsForRow(at: indexPath)
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
