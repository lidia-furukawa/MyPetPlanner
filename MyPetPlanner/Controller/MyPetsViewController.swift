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

    var selectedIndexPath = IndexPath()
    
    var keyPath = "type"
    var sectionNameKeyPath = "type"
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFetchedResultsController(keyPath, sectionNameKeyPath)
        initializeView()
    }

    private func initializeView() {
        tableView.tableFooterView = UIView()
        tableView.sectionIndexColor = tintColor
        tableView.sectionIndexBackgroundColor = UIColor.white
        navigationItem.leftBarButtonItem?.tintColor = tintColor
        navigationItem.rightBarButtonItem?.tintColor = tintColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchedResultsController(keyPath, sectionNameKeyPath)

        if let indexPathData = UserDefaults.standard.data(forKey: "selectedIndexPath") {
            print("Selected pet")
            selectedIndexPath = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(indexPathData) as! IndexPath
            tableView.reloadData()
            tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .top)
            configureCellAcessory(selectedIndexPath)
            passSelectedPetToHealthVC(selectedIndexPath)
        } else {
            print("No selected pet")
            tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        fetchedResultsController = nil
    }
    
    func setupFetchedResultsController(_ keyPath: String, _ sectionNameKeyPath: String) {
        let fetchRequest:NSFetchRequest<Pet> = Pet.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: keyPath, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func configureCellAcessory(_ indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.tintColor = tintColor
            cell.accessoryType = .checkmark
            navigationItem.title = "Pet: \(cell.textLabel?.text ?? "None")"
        }
    }
    
    func passSelectedPetToHealthVC(_ indexPath: IndexPath) {
        let healthTab = self.tabBarController?.viewControllers![1] as! UINavigationController
        let healthViewController = healthTab.topViewController as! HealthViewController
        healthViewController.pet = fetchedResultsController.object(at: indexPath)
        healthViewController.dataController = dataController
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
    
    @IBAction func sortPets(_ sender: Any) {
        let sortPopup = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sortPopup.addAction(UIAlertAction(title: "Sort By Name (A - Z)", style: .default, handler: { _ in
            self.keyPath = "name"
            self.sectionNameKeyPath = "initialName"
            self.setupFetchedResultsController(self.keyPath, self.sectionNameKeyPath)
            self.tableView.reloadData()
        }))
        
        sortPopup.addAction(UIAlertAction(title: "Sort By Type (Cat - Dog)", style: .default, handler: { _ in
            self.keyPath = "type"
            self.sectionNameKeyPath = "type"
            self.setupFetchedResultsController(self.keyPath, self.sectionNameKeyPath)
            self.tableView.reloadData()
        }))
        
        sortPopup.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        sortPopup.view.tintColor = tintColor
        
        present(sortPopup, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createNewPet" {
            let vc = segue.destination as! PetViewController
            vc.dataController = dataController
        } else if segue.identifier == "editPet" {
            let vc = segue.destination as! PetViewController
            vc.pet = fetchedResultsController.object(at: selectedIndexPath)
            vc.dataController = dataController
        }
    }
}

// -----------------------------------------------------------------------------
// MARK: - UITableViewDataSource, UITableViewDelegate

extension MyPetsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController.sections?[section].name
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController.sectionIndexTitles
    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController.section(forSectionIndexTitle: title, at: index)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = backgroundColor
//        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "MyPetCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! PetCell
        
        let aPet = fetchedResultsController.object(at: indexPath)

        // Configure the cell
        cell.separatorInset = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)
        cell.name?.text = aPet.name
        
        let ageInYears = Calendar.current.dateComponents([.year], from: aPet.birthday!, to: Date()).year!
        let ageInMonths = Calendar.current.dateComponents([.month], from: aPet.birthday!, to: Date()).month!
        let residualMonths = ageInMonths - 12 * ageInYears
        
        cell.information?.text = "\(aPet.type ?? ""), Age: \(ageInYears)yr \(residualMonths)mo, \(aPet.gender ?? "")"
        cell.textLabel?.text = aPet.name
        cell.textLabel?.isHidden = true
        
        if let photoData = aPet.photo {
            let image = UIImage(data: photoData)
            cell.photo.image = image
            cell.photo.layer.borderWidth = 0.5
            cell.photo.layer.borderColor = UIColor.lightGray.cgColor
            cell.photo.layer.cornerRadius = cell.photo.bounds.width/2
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !selectedIndexPath.isEmpty {
            tableView.deselectRow(at: selectedIndexPath, animated: false)
        }
        
        configureCellAcessory(indexPath)
        passSelectedPetToHealthVC(indexPath)

        let indexPathData = try? NSKeyedArchiver.archivedData(withRootObject: indexPath, requiringSecureCoding: false)
        UserDefaults.standard.set(indexPathData, forKey: "selectedIndexPath")
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
            self.selectedIndexPath = indexPath
            self.performSegue(withIdentifier: "editPet", sender: nil)
            completion(true)
        })
        
        let deleteRowAction = UIContextualAction(style: UIContextualAction.Style.destructive, title: "Delete", handler: { (action, view, completion) in
            // Delete confirmation dialog
            let alert = UIAlertController(title: "Are you sure you want to delete this pet?", message: "This action cannot be undone", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                self.deletePet(at: indexPath)
                UserDefaults.standard.set(nil, forKey: "selectedIndexPath")
                self.navigationItem.title = "Pet: None"
                completion(true)
            })
            
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)
            self.present(alert, animated: true, completion: nil)
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
