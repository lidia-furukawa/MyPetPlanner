//
//  FoodViewController.swift
//  MyPetPlanner
//
//  Created by Lidia on 17/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

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
    var food: Food!
    
    var activeTextField = UITextField()

    var selectedObjectName = String()
    
    var eventStore = EKEventStore()

    let calendarKey = "MyPetPlanner"
    
    var reminder: EKReminder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
        if food != nil {
            // Edit Food - TO DO
        } else {
            setFieldsDefaultValues()
        }
    }
    
    func initView() {
        changeControlsTintColor(tintColor: tintColor)

        datesLabel.configureLabel(backgroundColor: backgroundColor, textColor: UIColor.white, cornerRadius: 3)
        expensesLabel.configureLabel(backgroundColor: backgroundColor, textColor: UIColor.white, cornerRadius: 3)
        
        for textField in textFields {
            textField.delegate = self
        }
    }
    
    func changeControlsTintColor(tintColor: UIColor) {
        saveButton.tintColor = tintColor
        cancelButton.tintColor = tintColor
        mealsStepper.tintColor = tintColor
        quantityUnitControl.tintColor = tintColor
        quantityPerMealOrDayControl.tintColor = tintColor
        bagWeightUnitControl.tintColor = tintColor
    }
    
    func setFieldsDefaultValues() {
        navigationBar.topItem?.title = "Add New Food"
        foodImageView.image = UIImage(named: selectedObjectName)
        foodTypeLabel.text = selectedObjectName
        startDateTextField.text = dateToString(from: Date())
        endDateTextField.text = dateToString(from: Date())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromNotifications()
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
        
        food.setValue(foodTypeLabel.text, forKey: "type")
        
        if brandTextField.text!.isEmpty {
            food.setValue("#", forKey: "brand")
        } else {
            food.setValue(brandTextField.text, forKey: "brand")
        }
        
        if let quantityText = quantityTextField.text {
            food.setValue(Int(quantityText) ?? 0, forKey: "quantity")
        }
        
        let quantityUnit = quantityUnitControl.selectedSegmentIndex
        food.setValue(quantityUnitControl.titleForSegment(at: quantityUnit), forKey: "quantityUnit")
        
        let quantityPerMealOrDay = quantityPerMealOrDayControl.selectedSegmentIndex
        food.setValue(quantityPerMealOrDayControl.titleForSegment(at: quantityPerMealOrDay), forKey: "quantityPerMealOrDay")
        
        if let mealsText = mealsTextField.text {
            food.setValue(Int(mealsText) ?? 0, forKey: "meals")
        }
        
        if let startDateText = startDateTextField.text {
            food.setValue(stringToDate(from: startDateText), forKey: "startDate")
        }
        
        if let endDateText = endDateTextField.text {
            food.setValue(stringToDate(from: endDateText), forKey: "endDate")
        }
        
        if let bagWeightText = bagWeightTextField.text {
            food.setValue(Double(bagWeightText) ?? 0, forKey: "costUnit")
        }
        
        let bagWeightUnit = bagWeightUnitControl.selectedSegmentIndex
        food.setValue(bagWeightUnitControl.titleForSegment(at: bagWeightUnit), forKey: "quantityUnit")
        
        if let bagPriceText = bagPriceTextField.text {
            food.setValue(Double(bagPriceText) ?? 0, forKey: "totalCost")
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
        activeTextField.text = dateToString(from: sender.date)
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
        
        let startDate = stringToDate(from: startDateTextField.text!)
        reminder?.startDateComponents = Calendar.current.dateComponents([.month, .day, .year], from: startDate)
        
        let dueDate = stringToDate(from: endDateTextField.text!)
        reminder?.dueDateComponents = Calendar.current.dateComponents([.month, .day, .year], from: dueDate)
        
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

extension FoodViewController: KeyboardNotifications {
    func keyboardWillShow(_ notification:Notification) {
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: getKeyboardHeight(notification), right: 0.0)
        setScrollViewInsets(scrollView, contentInsets)
        
        // If the active text field is hidden by keyboard, scroll it so it's visible
        var aRect = self.view.frame
        aRect.size.height = -getKeyboardHeight(notification)
        if !aRect.contains(activeTextField.frame.origin) {
            scrollView.scrollRectToVisible(activeTextField.frame, animated: true)
        }
    }
    
    func keyboardWillHide(_ notification:Notification) {
        let contentInsets = UIEdgeInsets.zero
        setScrollViewInsets(scrollView, contentInsets)
    }
}

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
            endDateTextField.inputView = datePickerView
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
