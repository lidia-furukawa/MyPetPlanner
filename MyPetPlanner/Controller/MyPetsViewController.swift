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
        
        loadLastKeyPaths()
        setupFetchedResultsController(keyPath, sectionNameKeyPath)
        tableView.reloadData()
        loadLastSelectedPet()
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
    
    func configureNavigationTitle(_ indexPath: IndexPath) {
        let selectedPet = fetchedResultsController.object(at: indexPath)
        navigationItem.title = "Pet: \(selectedPet.name ?? "None")"
    }

    func configureCellAcessory(_ indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.tintColor = tintColor
            cell.accessoryType = .checkmark
        }
    }
    
    func passSelectedPetToHealthVC(_ indexPath: IndexPath) {
        let healthTab = self.tabBarController?.viewControllers![1] as! UINavigationController
        let healthViewController = healthTab.topViewController as! HealthViewController
        healthViewController.pet = fetchedResultsController.object(at: indexPath)
        healthViewController.dataController = dataController
    }
    
    func loadLastSelectedPet() {
        if let indexPathData = UserDefaults.standard.data(forKey: UserDefaultsKeys.selectedIndexPathKey) {
            if let indexPath = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(indexPathData) as? IndexPath {
                print("There is a selected pet")
                selectedIndexPath = indexPath
                
                // Highlight and checkmark the selected pet's row
                tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .top)
                configureCellAcessory(selectedIndexPath)
                configureNavigationTitle(selectedIndexPath)
                
                passSelectedPetToHealthVC(selectedIndexPath)
            }
        }
    }
    
    func loadLastKeyPaths() {
        if let lastKeyPath = UserDefaults.standard.string(forKey: UserDefaultsKeys.sortKeyPathKey), let lastSectionNameKeyPath = UserDefaults.standard.string(forKey: UserDefaultsKeys.sectionNameKeyPathKey) {
            keyPath = lastKeyPath
            sectionNameKeyPath = lastSectionNameKeyPath
        }
    }
    
    /// Delete a pet at the specified index path
    func deletePet(at indexPath: IndexPath) {
        let petToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(petToDelete)
        try? dataController.viewContext.save()
    }
    
    @IBAction func addNewPet(_ sender: Any) {
        performSegue(withIdentifier: SegueIdentifiers.createNewPet, sender: nil)
    }
    
    @IBAction func sortPets(_ sender: Any) {
        let sortPopup = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        sortPopup.addAction(UIAlertAction(title: "Sort By Name (A - Z)", style: .default, handler: { _ in
            self.keyPath = "name"
            self.sectionNameKeyPath = "initialName"
            UserDefaults.standard.set(self.keyPath, forKey: UserDefaultsKeys.sortKeyPathKey)
            UserDefaults.standard.set(self.sectionNameKeyPath, forKey: UserDefaultsKeys.sectionNameKeyPathKey)
            self.setupFetchedResultsController(self.keyPath, self.sectionNameKeyPath)
            self.tableView.reloadData()
        }))
        
        sortPopup.addAction(UIAlertAction(title: "Sort By Type (Cat - Dog)", style: .default, handler: { _ in
            self.keyPath = "type"
            self.sectionNameKeyPath = "type"
            UserDefaults.standard.set(self.keyPath, forKey: UserDefaultsKeys.sortKeyPathKey)
            UserDefaults.standard.set(self.sectionNameKeyPath, forKey: UserDefaultsKeys.sectionNameKeyPathKey)
            self.setupFetchedResultsController(self.keyPath, self.sectionNameKeyPath)
            self.tableView.reloadData()
        }))
        
        sortPopup.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        sortPopup.view.tintColor = tintColor
        
        present(sortPopup, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! PetViewController
        vc.dataController = dataController

        switch segue.identifier {
        case SegueIdentifiers.createNewPet:
            vc.pet = nil
        case SegueIdentifiers.editPet:
            vc.pet = fetchedResultsController.object(at: selectedIndexPath)
        default:
            fatalError("Unindentified Segue")
        }
    }
}

// -----------------------------------------------------------------------------
// MARK: - Age Calculator

extension MyPetsViewController {
    public func calculateAgeIn(component: Calendar.Component, from birthday: Date) -> Int {
        let age = Calendar.current.dateComponents([component], from: birthday, to: Date())
        switch component {
        case .year:
            return age.year ?? 0
        case .month:
            return age.month ?? 0
        default:
            fatalError("Age component should be in .year or .month")
        }
    }
    
    public func calculateAgeResidualMonths(from birthday: Date) -> Int {
        let residualMonths = calculateAgeIn(component: .month, from: birthday) % 12
        return residualMonths
    }
}

// -----------------------------------------------------------------------------
// MARK: - TrailingSwipeActions

extension MyPetsViewController: TrailingSwipeActions {
    func setEditAction(at indexPath: IndexPath) {
        selectedIndexPath = indexPath
        performSegue(withIdentifier: SegueIdentifiers.editPet, sender: nil)
    }
    
    func setDeleteAction(at indexPath: IndexPath) {
        deletePet(at: indexPath)
        UserDefaults.standard.set(nil, forKey: UserDefaultsKeys.selectedIndexPathKey)
        navigationItem.title = "Pet: None"
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
        
        let ageInYears = calculateAgeIn(component: .year, from: aPet.birthday!)
        let residualMonths = calculateAgeResidualMonths(from: aPet.birthday!)
        
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
        configureNavigationTitle(indexPath)
        
        passSelectedPetToHealthVC(indexPath)

        let indexPathData = try? NSKeyedArchiver.archivedData(withRootObject: indexPath, requiringSecureCoding: false)
        UserDefaults.standard.set(indexPathData, forKey: UserDefaultsKeys.selectedIndexPathKey)
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
