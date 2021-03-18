//
//  FoodViewController.swift
//  MyPetPlanner
//
//  Created by Lidia on 17/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit
import CoreData

class FoodViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var foodTypeLabel: UILabel!
    @IBOutlet weak var brandTextField: UITextField!
    @IBOutlet weak var mealsTextField: UITextField!
    @IBOutlet weak var mealsStepper: UIStepper!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var quantityUnitControl: UISegmentedControl!
    @IBOutlet weak var quantityPerControl: UIStackView!
    @IBOutlet weak var datesLabel: UILabel!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var expensesLabel: UILabel!
    @IBOutlet weak var bagWeightTextField: UITextField!
    @IBOutlet weak var bagWeightUnitControl: UISegmentedControl!
    @IBOutlet weak var bagPriceTextField: UITextField!
    
    var dataController: DataController!
    
    /// The food either passed by `HealthSectionViewController` or constructed when adding a new food
    var food: Food!
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if food != nil {
            // Edit Food - TO DO
        } else {
            // Set fields default values
            navigationBar.topItem?.title = "Add New Food"
            foodImageView.image = UIImage(named: "placeholder")
            dateFormatter.dateFormat = "MM-dd-yyyy"
            startDateTextField.text = dateFormatter.string(from: Date())
        }
    }
    
    func addNewFood() {
        let newFood = Food(context: dataController.viewContext)
        try? dataController.viewContext.save()
        food = newFood
    }
    
    @IBAction func saveButton(_ sender: Any) {
        if food == nil {
            addNewFood()
        }
        
        if brandTextField.text!.isEmpty {
            food.setValue("#", forKey: "brand")
        } else {
            food.setValue(brandTextField.text, forKey: "brand")
        }
        
        if let quantityText = quantityTextField.text {
            food.setValue(Int(quantityText) ?? 0, forKey: "quantity")
        }
        
        if let mealsText = mealsTextField.text {
            food.setValue(Int(mealsText) ?? 0, forKey: "meals")
        }
        
        if let startDateText = startDateTextField.text {
            food.setValue(dateFormatter.date(from: startDateText), forKey: "startDate")
        }
        
        if let endDateText = endDateTextField.text {
            food.setValue(dateFormatter.date(from: endDateText), forKey: "endDate")
        }
        
        if let bagWeightText = bagWeightTextField.text {
            food.setValue(Double(bagWeightText) ?? 0, forKey: "costUnit")
        }
        
        if let bagPriceText = bagPriceTextField.text {
            food.setValue(Double(bagPriceText) ?? 0, forKey: "totalCost")
        }
                
        try? dataController.viewContext.save()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
