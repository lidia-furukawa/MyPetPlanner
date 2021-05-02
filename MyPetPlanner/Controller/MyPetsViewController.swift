//
//  MyPetsViewController.swift
//  MyPetPlanner
//
//  Created by Lidia on 12/02/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class MyPetsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pet>!
    var selectedIndexPath = IndexPath()
    var keyPath = "type"
    var sectionNameKeyPath = "type"
    var selectedPet: Pet?
    var eventStore = EKEventStore()
    var dogBreeds: [String] = []
    var catBreeds: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLastKeyPaths()
        setupFetchedResultsController(keyPath, sectionNameKeyPath)
        initView()
    }

    func initView() {
        tableView.tableFooterView = UIView()
        tableView.sectionIndexBackgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func setupFetchedResultsController(_ keyPath: String, _ sectionNameKeyPath: String) {
        let fetchRequest: NSFetchRequest<Pet> = Pet.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: keyPath, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func refreshData() {
        loadLastKeyPaths()
        setupFetchedResultsController(keyPath, sectionNameKeyPath)
        tableView.reloadData()
        loadLastSelectedPet()
    }
    
    func loadLastKeyPaths() {
        if let lastKeyPath = UserDefaults.standard.string(forKey: UserDefaults.Keys.sortKeyPath), let lastSectionNameKeyPath = UserDefaults.standard.string(forKey: UserDefaults.Keys.sectionNameKeyPath) {
            keyPath = lastKeyPath
            sectionNameKeyPath = lastSectionNameKeyPath
        }
    }
    
    func loadLastSelectedPet() {
        if let indexPathData = UserDefaults.standard.data(forKey: UserDefaults.Keys.selectedIndexPath) {
            if let indexPath = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(indexPathData) as? IndexPath {
                selectedIndexPath = indexPath
                selectPet(at: selectedIndexPath)
            }
        } else {
            guard let selectedPet = selectedPet else { return }
            selectedIndexPath = fetchedResultsController.indexPath(forObject: selectedPet)!
            saveSelectedIndexPath(selectedIndexPath)
            selectPet(at: selectedIndexPath)
        }
        // Highlight the selected pet's row
        tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .top)
    }
    
    func selectPet(at indexPath: IndexPath) {
        selectedPet = fetchedResultsController.object(at: indexPath)
        postPetNotification(selectedPet)
        checkmarkCell(true, at: indexPath)
        configureNavigationTitle(selectedPet)
    }
    
    func saveSelectedIndexPath(_ indexPath: IndexPath) {
        let indexPathData = try? NSKeyedArchiver.archivedData(withRootObject: indexPath, requiringSecureCoding: false)
        UserDefaults.standard.set(indexPathData, forKey: UserDefaults.Keys.selectedIndexPath)
    }
    
    func postPetNotification(_ pet: Pet?) {
        NotificationCenter.default.post(name: .petWasSelected, object: nil, userInfo: ["pet": pet as Any])
    }
    
    func configureNavigationTitle(_ selectedPet: Pet?) {
        navigationItem.title = "Pet: \(selectedPet?.name ?? "None")"
    }
    
    func checkmarkCell(_ isCellSelected: Bool, at indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if isCellSelected {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
    }
    
    func saveKeyPaths(_ keyPath: String, _ sectionNameKeyPath: String) {
        UserDefaults.standard.set(keyPath, forKey: UserDefaults.Keys.sortKeyPath)
        UserDefaults.standard.set(sectionNameKeyPath, forKey: UserDefaults.Keys.sectionNameKeyPath)
    }
    
    /// Delete a pet at the specified index path
    func deletePet(at indexPath: IndexPath) {
        let petToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(petToDelete)
        try? dataController.viewContext.save()
    }
    
    @IBAction func addNewPet(_ sender: Any) {
        performSegue(withIdentifier: UIStoryboardSegue.Identifiers.createNewPet, sender: nil)
    }
    
    @IBAction func sortPets(_ sender: Any) {
        let sortPetsActions = [
            Action(buttonTitle: "Sort By Name (A - Z)", buttonStyle: .default, handler: {
                UserDefaults.standard.set(nil, forKey: UserDefaults.Keys.selectedIndexPath)
                self.saveKeyPaths("name", "initialName")
                DispatchQueue.main.async {
                    self.refreshData()
                }
            }),
            Action(buttonTitle: "Sort By Type (Cat - Dog)", buttonStyle: .default, handler: {
                UserDefaults.standard.set(nil, forKey: UserDefaults.Keys.selectedIndexPath)
                self.saveKeyPaths("type", "type")
                DispatchQueue.main.async {
                    self.refreshData()
                }
            })
        ]
        presentActionSheetDialog(with: sortPetsActions)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! PetViewController
        vc.dataController = dataController
        vc.dogBreeds = dogBreeds
        vc.catBreeds = catBreeds
        
        switch segue.identifier {
        case UIStoryboardSegue.Identifiers.createNewPet:
            vc.pet = nil
        case UIStoryboardSegue.Identifiers.editPet:
            vc.pet = fetchedResultsController.object(at: selectedIndexPath)
        default:
            fatalError("Unindentified Segue")
        }
    }
    
    @IBAction func unwindToMyPets(_ unwindSegue: UIStoryboardSegue) {
        guard let petViewController = unwindSegue.source as? PetViewController, let dogBreeds = petViewController.dogBreeds, let catBreeds = petViewController.catBreeds else { return }
        self.dogBreeds = dogBreeds
        self.catBreeds = catBreeds
    }
}

// -----------------------------------------------------------------------------
// MARK: - ActionSheetDialog

extension MyPetsViewController: ActionSheetDialog { }

// -----------------------------------------------------------------------------
// MARK: - TrailingSwipeActions

extension MyPetsViewController: TrailingSwipeActions {
    func setEditAction(at indexPath: IndexPath) {
        UserDefaults.standard.set(nil, forKey: UserDefaults.Keys.selectedIndexPath)
        selectedIndexPath = indexPath
        performSegue(withIdentifier: UIStoryboardSegue.Identifiers.editPet, sender: nil)
    }
    
    func setDeleteAction(at indexPath: IndexPath) {
        Healthcare.fetchAllEventIdentifiers(for: selectedPet, context: dataController.viewContext) { eventIdentifiers in
            guard !eventIdentifiers.isEmpty else { return }
            for eventIdentifier in eventIdentifiers {
                self.deleteEventFromStore(withIdentifier: eventIdentifier)
            }
        }
        deletePet(at: indexPath)
        UserDefaults.standard.set(nil, forKey: UserDefaults.Keys.selectedIndexPath)
        selectedPet = nil
        configureNavigationTitle(selectedPet)
        postPetNotification(selectedPet)
    }
    
    func deleteEventFromStore(withIdentifier identifier: String) {
        if let event = eventStore.event(withIdentifier: identifier) {
            do {
                try eventStore.remove(event, span: .futureEvents)
            } catch {
                fatalError("Delete event error")
            }
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
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = .backgroundColor
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "MyPetCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! PetCell
        
        let aPet = fetchedResultsController.object(at: indexPath)

        // Configure the cell
        cell.name?.text = aPet.name
        let ageInYears = Calendar.current.calculateAgeIn(.year, from: aPet.birthday!)
        let residualMonths = Calendar.current.calculateAgeResidualMonths(from: aPet.birthday!)
        cell.information?.text = "\(aPet.type ?? ""), Age: \(ageInYears)yr \(residualMonths)mo, \(aPet.gender ?? "")"
        if let photoData = aPet.photo {
            let image = UIImage(data: photoData)
            cell.photo.image = image
            cell.photo.roundImage()
        }
        cell.separatorInset = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !selectedIndexPath.isEmpty {
            tableView.deselectRow(at: selectedIndexPath, animated: false)
        }
        selectPet(at: indexPath)
        saveSelectedIndexPath(indexPath)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        checkmarkCell(false, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if !selectedIndexPath.isEmpty {
            checkmarkCell(false, at: selectedIndexPath)
        }
        selectPet(at: indexPath)
        saveSelectedIndexPath(indexPath)
        return configureSwipeActionsForRow(at: indexPath)
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
