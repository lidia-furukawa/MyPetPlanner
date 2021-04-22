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
    var fetchedResultsController: NSFetchedResultsController<NSManagedObject>!
    
    /// The pet whose health section is being displayed
    var pet: Pet?
    var selectedObjectName = String()
    var selectedObjectSectionName = String()
    var selectedIndexPath = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController("Healthcare")
        initView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController("Healthcare")
        tableView.reloadData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
        self.navigationController?.popViewController(animated: false)
    }
    
    func initView() {
        tableView.tableFooterView = UIView()
        navigationItem.title = selectedObjectName
        setupRightBarButton()
    }
    
    fileprivate func setupRightBarButton() {
        let addHealthcareButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addHealthcareButton(_:)))
        navigationItem.rightBarButtonItem = addHealthcareButton
    }

    func setupFetchedResultsController(_ entity: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let petPredicate = NSPredicate(format: "pet == %@", pet ?? "")
        let subcategoryPredicate = NSPredicate(format: "subcategory == %@", selectedObjectName)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [petPredicate, subcategoryPredicate])
        let sortDescriptor = NSSortDescriptor(key: "subcategory", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil) as? NSFetchedResultsController<NSManagedObject>
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    @objc func addHealthcareButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: UIStoryboardSegue.Identifiers.createNewHealthcare, sender: nil)
    }
    
    /// Delete an object at the specified index path
    func deleteObject(at indexPath: IndexPath) {
        let objectToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(objectToDelete)
        try? dataController.viewContext.save()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! HealthcareViewController
        vc.selectedObjectSectionName = selectedObjectSectionName
        vc.selectedObjectName = selectedObjectName
        vc.pet = pet
        vc.dataController = dataController
        
        switch segue.identifier {
        case UIStoryboardSegue.Identifiers.createNewHealthcare:
            vc.healthcare = nil
        case UIStoryboardSegue.Identifiers.editHealthcare:
            vc.healthcare = fetchedResultsController.object(at: selectedIndexPath) as? Healthcare
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
        performSegue(withIdentifier: UIStoryboardSegue.Identifiers.editHealthcare, sender: nil)
    }
    
    func setDeleteAction(at indexPath: IndexPath) {
        deleteObject(at: indexPath)
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
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = .backgroundColor
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "HealthSectionCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! HealthSectionCell
        
        let aHealthcare = fetchedResultsController.object(at: indexPath) as! Healthcare

        // Configure the cell
        cell.separatorInset = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)
        cell.sectionNameLabel?.text = aHealthcare.subcategory
        cell.sectionInfoLabel?.text = aHealthcare.information
        cell.startDateLabel.text = aHealthcare.startDate!.stringFormat
        cell.endDateLabel.text = aHealthcare.endDate!.stringFormat
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
