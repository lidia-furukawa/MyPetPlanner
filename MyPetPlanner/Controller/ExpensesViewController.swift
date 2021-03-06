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
    @IBOutlet weak var totalExpensesLabel: UILabel!
    
    /// The pet posted by `MyPetsViewController` when a pet cell's selected
    var pet: Pet?
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Expense>!
    var sortKeyPath = "category"
    var totalExpensesSum: Double?
    var startDate = Date()
    var endDate = Date()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        subscribeToPetNotification()
    }
    
    deinit {
        unsubscribeFromNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLastKeyPath()
        loadLastDates()
        setupFetchedResultsController(sortKeyPath)
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Pet: \(pet?.name ?? "None")"
        refreshData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func initView() {
        expensesLabel.configureTitle()
        breakdownLabel.configureTitle()
        tableView.tableFooterView = UIView()
    }
    
    func loadLastKeyPath() {
        if let lastKeyPath = UserDefaults.standard.string(forKey: UserDefaults.Keys.expensesSortKeyPath) {
            sortKeyPath = lastKeyPath
        }
    }
    
    func loadLastDates() {
        if let lastStartDate = UserDefaults.standard.string(forKey: UserDefaults.Keys.startDateKey), let lastEndDate = UserDefaults.standard.string(forKey: UserDefaults.Keys.endDateKey) {
            startDate = lastStartDate.dateFormat
            endDate = lastEndDate.dateFormat
        }
    }
    
    func refreshData() {
        loadLastKeyPath()
        loadLastDates()
        setupFetchedResultsController(sortKeyPath)
        sortChartBy(sortKeyPath)

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func sortChartBy(_ attribute: String) {
        guard let pet = pet else { return }
        Expense.fetchAllDataBy(attribute, for: pet, fromDate: startDate, toDate: endDate, context: dataController.viewContext) { results in
            guard !results.isEmpty else {
                self.customizeChart(labels: [], values: [])
                self.totalExpensesLabel.text = ""
                return
            }
            let expensesLabels = results.map { $0.attribute }
            let expensesValues = results.map { $0.totalAmount }
            self.totalExpensesSum = results.map { $0.totalAmount }.reduce(0, +)
            
            self.customizeChart(labels: expensesLabels, values: expensesValues)
            self.totalExpensesLabel.text = self.totalExpensesSum?.stringCurrencyFormat
        }
    }
    
    func saveSortKeyPath(_ keyPath: String) {
        UserDefaults.standard.set(keyPath, forKey: UserDefaults.Keys.expensesSortKeyPath)
        self.sortKeyPath = keyPath
    }
    
    func setupFetchedResultsController(_ keyPath: String) {
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        let petPredicate = NSPredicate(format: "pet == %@", pet ?? "")
        let datePredicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startDate as CVarArg, endDate as CVarArg)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [petPredicate, datePredicate])

        let sortDescriptor = NSSortDescriptor(key: keyPath, ascending: true)
        let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor, dateSortDescriptor]
        
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
        let sortExpensesActions = [
            Action(buttonTitle: "Sort By Category", buttonStyle: .default, handler: {
                self.saveSortKeyPath("category")
                self.refreshData()
            }),
            Action(buttonTitle: "Sort By Subcategory", buttonStyle: .default, handler: {
                self.saveSortKeyPath("subcategory")
                self.refreshData()
            })
        ]
        presentActionSheetDialog(with: sortExpensesActions)
    }
    
    @IBAction func filterDate(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "DateFilterViewController") as! DateFilterViewController
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        vc.isSaved = { [weak self] in
            self?.refreshData()
        }
        present(vc, animated: true, completion: nil)
    }
}

// -----------------------------------------------------------------------------
// MARK: - PetNotification

extension ExpensesViewController: PetNotification { }

// -----------------------------------------------------------------------------
// MARK: - ActionSheetDialog

extension ExpensesViewController: ActionSheetDialog { }

// -----------------------------------------------------------------------------
// MARK: - UITableViewDataSource, UITableViewDelegate

extension ExpensesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "ExpensesCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ExpensesCell

        let aExpense = fetchedResultsController.object(at: indexPath)

        // Configure the cell
        switch sortKeyPath {
        case "subcategory":
            cell.sectionLabel?.text = aExpense.subcategory
        case "category":
            cell.sectionLabel?.text = aExpense.category
        default:
            fatalError("Unrecognized key path")
        }
        cell.amountLabel?.text = aExpense.amount?.stringFormat
        cell.subsectionLabel?.text = "Date: \(aExpense.date?.stringFormat ?? "")"
        let sectionImage = UIImage(named: aExpense.subcategory ?? "")
        cell.photoImageView?.image = sectionImage?.templateImage
        cell.separatorInset = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)
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

// -----------------------------------------------------------------------------
// MARK: - UIViewControllerTransitioningDelegate

extension ExpensesViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
}
