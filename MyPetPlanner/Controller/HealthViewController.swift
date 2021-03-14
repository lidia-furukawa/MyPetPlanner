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
    
    let tintColor = #colorLiteral(red: 0.6509035826, green: 0.2576052547, blue: 0.8440084457, alpha: 1)
    let backgroundColor = #colorLiteral(red: 0.8941176471, green: 0.7176470588, blue: 0.8980392157, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Selected Pet: \(pet?.name ?? "None")"
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
        cell.titleLabel?.text = sectionDataSource[indexPath.section][indexPath.row]
        let sectionImage = UIImage(named: cell.titleLabel.text!)
        let templateImage = sectionImage?.withRenderingMode(.alwaysTemplate)
        cell.photoImageView.image = templateImage
        cell.photoImageView.tintColor = tintColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

    }
}
