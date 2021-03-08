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

    @IBOutlet weak var tableView: UITableView!
    
    var dataController: DataController!
    
    var fetchedResultsController: NSFetchedResultsController<Pet>!

    var editedCellIndexPath = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFetchedResultsController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchedResultsController()
        tableView.reloadData()
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
    
    /// Delete a pet at the specified index path
    func deletePet(at indexPath: IndexPath) {
        let petToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(petToDelete)
        try? dataController.viewContext.save()
    }
    
    @IBAction func addNewPet(_ sender: Any) {
        performSegue(withIdentifier: "createNewPet", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createNewPet" {
            let vc = segue.destination as! PetViewController
            vc.dataController = dataController
        } else if segue.identifier == "editPet" {
            let vc = segue.destination as! PetViewController
            vc.pet = fetchedResultsController.object(at: editedCellIndexPath)
            vc.dataController = dataController
        }
    }
}

// -----------------------------------------------------------------------------
// MARK: - UITableViewDataSource, UITableViewDelegate

extension MyPetsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "MyPetCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)!
        
        let aPet = fetchedResultsController.object(at: indexPath)

        // Configure the cell
        cell.textLabel?.text = aPet.name
        
        if let photoData = aPet.photo {
            let image = UIImage(data: photoData)
            cell.imageView?.image = image
            cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.height)!/2
        }
        
        // If the cell has a detail label, it will show the type (dog or cat)
        if let detailTextLabel = cell.detailTextLabel {
            detailTextLabel.text = aPet.type
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deletePet(at: indexPath)
        default: ()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editRowAction = UIContextualAction(style: UIContextualAction.Style.normal, title: "Edit", handler: { (action, view, completion) in
            self.editedCellIndexPath = indexPath
            self.performSegue(withIdentifier: "editPet", sender: nil)
            completion(true)
        })
        
        let deleteRowAction = UIContextualAction(style: UIContextualAction.Style.destructive, title: "Delete", handler: { (action, view, completion) in
            self.deletePet(at: indexPath)
            completion(true)
        })
        
        editRowAction.backgroundColor = .green
        deleteRowAction.backgroundColor = .red

        let configuration = UISwipeActionsConfiguration(actions: [editRowAction, deleteRowAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}

// -----------------------------------------------------------------------------
// MARK: - NSFetchedResultsControllerDelegate

extension MyPetsViewController: NSFetchedResultsControllerDelegate {
    
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
