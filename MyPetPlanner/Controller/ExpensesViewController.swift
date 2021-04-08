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
    
    var dataController: DataController!
    
    var fetchedResultsController: NSFetchedResultsController<Expense>!

    /// The pet passed by `MyPetsViewController` when a pet cell's selected
    var pet: Pet?
    
    let mockLabels = ["Ozil", "Ramsey", "Laca", "Auba", "Xhaka", "Torreira"]
    let mockValues = [6, 8, 26, 30, 8, 10]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegate()
        setupFetchedResultsController()
        let expenses = fetchedResultsController.fetchedObjects
        customizeChart(dataPoints: mockLabels, values: mockValues.map{ Double($0) })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchedResultsController()
        navigationItem.title = "Pet: \(pet?.name ?? "None")"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        fetchedResultsController = nil
    }
    
    fileprivate func setupDelegate() {
        let myPetsTab = self.tabBarController?.viewControllers![0] as! UINavigationController
        let myPetsViewController = myPetsTab.topViewController as! MyPetsViewController
        myPetsViewController.delegate = self
    }
    
    func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        let predicate = NSPredicate(format: "pet == %@", pet ?? "")
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func customizeChart(dataPoints: [String], values: [Double]) {
        
        // Set ChartDataEntry
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data:  dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        
        // Set ChartDataSet
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        pieChartDataSet.colors = colorsOfCharts(numbersOfColor: dataPoints.count)
        
        // Set ChartData
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
        
        // Assign it to the chart's data
        pieChartView.data = pieChartData
    }
    
    // Choose random colors for each entry. The number of colors = number of items
    private func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
        var colors: [UIColor] = []
        for _ in 0..<numbersOfColor {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        return colors
    }
}

// -----------------------------------------------------------------------------
// MARK: - PetDelegate

extension ExpensesViewController: PetDelegate {
    func petWasSelected(pet: Pet?) {
        self.pet = pet
    }
}
