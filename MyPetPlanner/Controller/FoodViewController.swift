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
    @IBOutlet var textFields: [UITextField]!
    
    var dataController: DataController!
    
    /// The food either passed by `HealthSectionViewController` or constructed when adding a new food
    var food: Food!
    
    let dateFormatter = DateFormatter()
    
    var activeTextField = UITextField()

    var selectedObjectName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for textField in textFields {
            textField.delegate = self
        }
        
        if food != nil {
            // Edit Food - TO DO
        } else {
            // Set fields default values
            navigationBar.topItem?.title = "Add New Food"
            foodImageView.image = UIImage(named: selectedObjectName)
            foodTypeLabel.text = selectedObjectName
            dateFormatter.dateFormat = "MM-dd-yyyy"
            startDateTextField.text = dateFormatter.string(from: Date())
            endDateTextField.text = dateFormatter.string(from: Date())
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
        
        food.setValue(foodTypeLabel.text, forKey: "type")
        
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
    
    @IBAction func mealsStepper(_ sender: UIStepper) {
        mealsTextField.text = Int(sender.value).description
    }
    
    @objc func handleDatePicker(_ sender: UIDatePicker) {
        dateFormatter.dateFormat = "MM-dd-yyyy"
        activeTextField.text = dateFormatter.string(from: sender.date)
    }
}

// -----------------------------------------------------------------------------
// MARK: - UITextFieldDelegate

extension FoodViewController: UITextFieldDelegate {
    
    /// Make the next textField the first responder when the user taps the return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case brandTextField:
            mealsTextField.becomeFirstResponder()
        case mealsTextField:
            quantityTextField.becomeFirstResponder()
        case quantityTextField:
            startDateTextField.becomeFirstResponder()
        case startDateTextField:
            endDateTextField.becomeFirstResponder()
        case endDateTextField:
            bagWeightTextField.becomeFirstResponder()
        case bagWeightTextField:
            bagPriceTextField.becomeFirstResponder()
        default:
            bagPriceTextField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case brandTextField:
            activeTextField = brandTextField
        case mealsTextField:
            activeTextField = mealsTextField
        case quantityTextField:
            activeTextField = quantityTextField
        case startDateTextField:
            activeTextField = startDateTextField
            let datePickerView = UIDatePicker()
            datePickerView.datePickerMode = .date
            datePickerView.backgroundColor = .white
            if food != nil {
                datePickerView.setDate(food.startDate!, animated: false)
            } else {
                datePickerView.setDate(Date(), animated: false)
            }
            startDateTextField.inputView = datePickerView
            datePickerView.addTarget(self, action: #selector(handleDatePicker(_:)), for: .valueChanged)
        case endDateTextField:
            activeTextField = endDateTextField
            let datePickerView = UIDatePicker()
            datePickerView.datePickerMode = .date
            datePickerView.backgroundColor = .white
            if food != nil {
                datePickerView.setDate(food.endDate!, animated: false)
            } else {
                datePickerView.setDate(Date(), animated: false)
            }
            startDateTextField.inputView = datePickerView
            datePickerView.addTarget(self, action: #selector(handleDatePicker(_:)), for: .valueChanged)
        case bagWeightTextField:
            activeTextField = bagWeightTextField
        case bagPriceTextField:
            activeTextField = bagPriceTextField
        default:
            break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string)
        
        switch textField {
        case bagWeightTextField, bagPriceTextField:
            let textArray = newText.components(separatedBy: ".")
            
            //Limit textfield entry to 2 decimals place
            if textArray.count > 2 {
                return false
            } else if textArray.count == 2 {
                let lastString = textArray.last
                if lastString!.count > 2 {
                    return false
                }
            }
        default:
            break
        }
        return true
    }
}
