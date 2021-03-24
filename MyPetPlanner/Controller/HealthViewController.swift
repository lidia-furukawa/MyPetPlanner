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
    
    /// The pet passed by `MyPetsViewController` when a pet cell's selected
    var pet: Pet?
    
    let sectionTitles = ["Food", "Grooming", "Parasite Control", "Medication"]
    let sectionDataSource = [["Kibble or Dry Food", "Fresh or Raw Food"], ["Bathing", "Fur", "Teeth", "Nails", "Ears"], ["Internal", "External"], ["Medications", "Supplements"]]
    
    var selectedObjectName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Pet: \(pet?.name ?? "None")"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! HealthSectionViewController
        vc.dataController = dataController
        vc.pet = pet
        vc.selectedObjectName = selectedObjectName
        vc.selectedObjectSectionName = segue.identifier ?? "Error"
        
        switch segue.identifier {
        case "Food":
            vc.keyPath = "type"
            vc.sectionNameKeyPath = "type"
        default:
            fatalError("Unindentified Segue")
        }

    }
}

// -----------------------------------------------------------------------------
// MARK: - UITableViewDataSource, UITableViewDelegate

extension HealthViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionDataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = backgroundColor
//        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.tintColor = tintColor
        cell.accessoryType = .disclosureIndicator
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "HealthCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! HealthCell
        
        // Configure the cell
        cell.separatorInset = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)
        cell.titleLabel?.text = sectionDataSource[indexPath.section][indexPath.row]
        let sectionImage = UIImage(named: cell.titleLabel.text!)
        let templateImage = sectionImage?.withRenderingMode(.alwaysTemplate)
        cell.photoImageView.image = templateImage
        cell.photoImageView.tintColor = tintColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedObjectName = sectionDataSource[indexPath.section][indexPath.row]
        let selectedCellSection = sectionTitles[indexPath.section]
        performSegue(withIdentifier: selectedCellSection, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

    }
}
