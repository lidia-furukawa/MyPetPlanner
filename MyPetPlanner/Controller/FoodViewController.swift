//
//  FoodViewController.swift
//  MyPetPlanner
//
//  Created by Lidia on 17/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import EventKit

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
    @IBOutlet weak var quantityPerMealOrDayControl: UISegmentedControl!
    @IBOutlet weak var datesLabel: UILabel!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var expensesLabel: UILabel!
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var bagWeightTextField: UITextField!
    @IBOutlet weak var bagWeightUnitControl: UISegmentedControl!
    @IBOutlet weak var bagPriceTextField: UITextField!
    @IBOutlet var textFields: [UITextField]!
    
    var dataController: DataController!
    
    /// The pet whose food is being displayed/edited
    var pet: Pet?
    
    /// The food either passed by `HealthSectionViewController` or constructed when adding a new food
    var food: Food?
    
    var activeTextField = UITextField()

    var selectedObjectName = String()
    
    var eventStore = EKEventStore()

    let calendarKey = "MyPetPlanner"
    
    var reminder: EKReminder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
        reloadFoodAttributes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromNotifications()
    }
    
    func initView() {
        navigationBar.topItem?.title = "Add New Food"
        datesLabel.configureTitle()
        expensesLabel.configureTitle()
        
        for textField in textFields {
            textField.delegate = self
        }
    }
    
    func reloadFoodAttributes() {
        foodImageView.image = UIImage(named: selectedObjectName)
        foodTypeLabel.text = selectedObjectName
        brandTextField.text = food?.brand
        mealsTextField.text = String(food?.meals ?? 0)
        quantityTextField.text = String(food?.quantity ?? 0)
        quantityUnitControl.getSegmentedControlSelectedIndex(from: food?.quantityUnit)
        quantityPerMealOrDayControl.getSegmentedControlSelectedIndex(from: food?.quantityPerMealOrDay)
        startDateTextField.text = food?.startDate?.stringFormat ?? Date().stringFormat
        endDateTextField.text = food?.endDate?.stringFormat ?? Date().stringFormat
        bagWeightTextField.text = String(food?.bagWeight ?? 0)
        bagWeightUnitControl.getSegmentedControlSelectedIndex(from: food?.bagWeightUnit)
        bagPriceTextField.text = food?.amount?.stringFormat ?? ""
    }
    
    func addNewFood() {
        let newFood = Food(context: dataController.viewContext)
        newFood.pet = pet
        try? dataController.viewContext.save()
        food = newFood
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        presentActivityIndicator(true, forButton: sender)

        if food == nil {
            addNewFood()
        }
        
        food?.setValue(foodTypeLabel.text, forKey: "type")
        
        if brandTextField.text!.isEmpty {
            food?.setValue("#", forKey: "brand")
        } else {
            food?.setValue(brandTextField.text, forKey: "brand")
        }
        
        if let mealsText = mealsTextField.text {
            food?.setValue(Int(mealsText) ?? 0, forKey: "meals")
        }
        
        if let quantityText = quantityTextField.text {
            food?.setValue(Int(quantityText) ?? 0, forKey: "quantity")
        }
        
        let quantityUnit = quantityUnitControl.selectedSegmentIndex
        food?.setValue(quantityUnitControl.titleForSegment(at: quantityUnit), forKey: "quantityUnit")
        
        let quantityPerMealOrDay = quantityPerMealOrDayControl.selectedSegmentIndex
        food?.setValue(quantityPerMealOrDayControl.titleForSegment(at: quantityPerMealOrDay), forKey: "quantityPerMealOrDay")
        
        if let startDateText = startDateTextField.text {
            food?.setValue(startDateText.dateFormat, forKey: "startDate")
        }
        
        if let endDateText = endDateTextField.text {
            food?.setValue(endDateText.dateFormat, forKey: "endDate")
        }
        
        if let bagWeightText = bagWeightTextField.text {
            food?.setValue(Double(bagWeightText) ?? 0, forKey: "bagWeight")
        }
        
        let bagWeightUnit = bagWeightUnitControl.selectedSegmentIndex
        food?.setValue(bagWeightUnitControl.titleForSegment(at: bagWeightUnit), forKey: "bagWeightUnit")
        
        if let bagPriceText = bagPriceTextField.text {
            food?.setValue(Double(bagPriceText) ?? 0, forKey: "amount")
        }
                
        try? dataController.viewContext.save()
        
        if let reminder = reminder {
            try? eventStore.save(reminder, commit: true)
            print("Reminder saved")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func mealsStepper(_ sender: UIStepper) {
        mealsTextField.text = Int(sender.value).description
    }
    
    @objc func handleDatePicker(_ sender: UIDatePicker) {
        activeTextField.text = sender.date.stringFormat
    }
    
    @IBAction func addReminderTapped(_ sender: UISwitch) {
        if reminderSwitch.isOn {
            checkAuthorizationStatus(for: .reminder)
        }
    }
    
    func createReminder() {
        reminder = EKReminder(eventStore: eventStore)
        
        reminder?.title = self.foodTypeLabel.text
        reminder?.calendar = EKCalendar.loadCalendar(type: .reminder, from: eventStore, with: calendarKey)
        reminder?.notes = "Feed \(self.pet?.name ?? "#") with \(self.brandTextField.text ?? "#")"
        
        let startDate = startDateTextField.text?.dateFormat
        reminder?.startDateComponents = Calendar.current.dateComponents([.month, .day, .year], from: startDate!)
        
        let dueDate = endDateTextField.text?.dateFormat
        reminder?.dueDateComponents = Calendar.current.dateComponents([.month, .day, .year], from: dueDate!)
        
        // Configure the recurrence rule
        let recurrenceRule = EKRecurrenceRule(
            recurrenceWith: .weekly,
            interval: 1,
            daysOfTheWeek: [EKRecurrenceDayOfWeek(.monday)],
            daysOfTheMonth: nil,
            monthsOfTheYear: nil,
            weeksOfTheYear: nil,
            daysOfTheYear: nil,
            setPositions: nil,
            end: nil)
        
        reminder?.addRecurrenceRule(recurrenceRule)
    }
}

// -----------------------------------------------------------------------------
// MARK: - EventStoreAuthorization

extension FoodViewController: CalendarReminderAuthorization {
    func accessGranted() {
        createReminder()
    }
}

// -----------------------------------------------------------------------------
// MARK: - KeyboardNotifications

extension FoodViewController: KeyboardNotifications { }

// -----------------------------------------------------------------------------
// MARK: - SaveActivityIndicator

extension FoodViewController: SaveActivityIndicator { }

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
        case startDateTextField:
            activeTextField = startDateTextField
            startDateTextField.inputView = .customizedDatePickerView(setDate: food?.startDate ?? Date(), withTarget: self, action: #selector(handleDatePicker(_:)))
        case endDateTextField:
            activeTextField = endDateTextField
            endDateTextField.inputView = .customizedDatePickerView(setDate: food?.endDate ?? Date(), withTarget: self, action: #selector(handleDatePicker(_:)))
        default:
            activeTextField = textField
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
