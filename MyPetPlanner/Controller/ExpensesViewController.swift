//
//  ExpensesViewController.swift
//  MyPetPlanner
//
//  Created by Lidia on 02/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit
import CoreData
import Charts

class ExpensesViewController: UIViewController {

    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var expensesLabel: UILabel!
    @IBOutlet weak var breakdownLabel: UILabel!
    
    var dataController: DataController!
    
    var fetchedResultsController: NSFetchedResultsController<Expense>!

    /// The pet posted by `MyPetsViewController` when a pet cell's selected
    var pet: Pet?
    
    var types: [String] = []
    
    var amounts: [Double] = []
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Pet: \(pet?.name ?? "None")"
        customizeChart(labels: fetchData(from: "type") as! [String], values: fetchData(from: "amount") as! [Double])
        tableView.reloadData()
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        fetchedResultsController = nil
    }
    
    func initView() {
        expensesLabel.configureTitle()
        breakdownLabel.configureTitle()
    }
    
    func fetchData(from attribute: String) -> [Any] {
        setupFetchedResultsController(attribute)
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        var array: [Any] = []
        for object in objects {
            switch attribute {
            case "type":
                array.append(object.type!)
            case "amount":
                array.append(object.amount!.doubleValue)
            default:
                fatalError()
            }
        }
        return array
    }
    
    func setupFetchedResultsController(_ keyPath: String) {
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        let predicate = NSPredicate(format: "pet == %@", pet ?? "")
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: keyPath, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func customizeChart(labels: [String], values: [Double]) {
        
        // Set ChartDataEntry
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<labels.count {
            let dataEntry = PieChartDataEntry(value: values[i], label: labels[i], data: labels[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        
        // Set ChartDataSet
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        pieChartDataSet.colors = colorsOfCharts(numbersOfColor: labels.count)
        
        // Set ChartData
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .currency
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
        pieChartData.setValueTextColor(.black)
        pieChartView.data = pieChartData
    }
    
    // Set random colors for each entry
    private func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
        var colors: [UIColor] = []
        for _ in 0..<numbersOfColor {
            colors.append(.randomColor)
        }
        return colors
    }
    
    @IBAction func sortExpenses(_ sender: Any) {
    }
}

// -----------------------------------------------------------------------------
// MARK: - PetNotification

extension ExpensesViewController: PetNotification { }

// -----------------------------------------------------------------------------
// MARK: - UITableViewDataSource, UITableViewDelegate

extension ExpensesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpensesCell")!

        let aExpense = fetchedResultsController.object(at: indexPath)
        
        // Configure the cell
        cell.separatorInset = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)
        cell.textLabel?.text = aExpense.type
        cell.detailTextLabel?.text = aExpense.amount?.stringFormat
        
        let sectionImage = UIImage(named: cell.textLabel?.text ?? "")
        let templateImage = sectionImage?.withRenderingMode(.alwaysTemplate)
        cell.imageView?.image = templateImage
        return cell
    }
}

// -----------------------------------------------------------------------------
// MARK: - NSFetchedResultsControllerDelegate

extension ExpensesViewController: NSFetchedResultsControllerDelegate {
    
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
