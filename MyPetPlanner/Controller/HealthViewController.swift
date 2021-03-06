//
//  HealthViewController.swift
//  MyPetPlanner
//
//  Created by Lidia on 02/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit
import CoreData

class HealthViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var dataController: DataController!
    
    /// The pet posted by `MyPetsViewController` when a pet cell's selected
    var pet: Pet?
    let healthSections = HealthcareCategory.healthSections
    var selectedObjectName = String()
    var selectedSectionName = String()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        subscribeToPetNotification()
    }
    
    deinit {
        unsubscribeFromNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    fileprivate func initView() {
        tableView.tableFooterView = UIView()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Pet: \(pet?.name ?? "None")"
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! HealthSectionViewController
        vc.dataController = dataController
        vc.pet = pet
        vc.selectedObjectName = selectedObjectName
        vc.selectedObjectSectionName = selectedSectionName
    }
}

// -----------------------------------------------------------------------------
// MARK: - SingleButtonAlertDialog

extension HealthViewController: AlertDialog { }

// -----------------------------------------------------------------------------
// MARK: - PetNotification

extension HealthViewController: PetNotification { }

// -----------------------------------------------------------------------------
// MARK: - UITableViewDataSource, UITableViewDelegate

extension HealthViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return healthSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return healthSections[section].subcategories.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return healthSections[section].title
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor.backgroundColor
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryType = .disclosureIndicator
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HealthCell")!
        
        // Configure the cell
        let section = healthSections[indexPath.section]
        let row = section.subcategories[indexPath.row]
        cell.textLabel?.text = row.subcategory
        let sectionImage = UIImage(named: row.image)
        cell.imageView?.image = sectionImage?.templateImage
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedObjectName = healthSections[indexPath.section].subcategories[indexPath.row].subcategory
        selectedSectionName = healthSections[indexPath.section].title
        
        if pet != nil {
            performSegue(withIdentifier: UIStoryboardSegue.Identifiers.showSection, sender: nil)
        } else {
            let errorAlert = AlertInformation(
                title: "No Pet Selected",
                message: "Create/select a pet in \"My Pets\" and try again",
                actions: [Action(buttonTitle: "OK", buttonStyle: .default, handler: nil)]
            )
            presentAlertDialog(with: errorAlert)
        }
    }
}
