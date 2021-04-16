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
import EventKitUI

class FoodViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var foodSubcategoryLabel: UILabel!
    @IBOutlet weak var brandTextField: UITextField!
    @IBOutlet weak var mealsTextField: UITextField!
    @IBOutlet weak var mealsStepper: UIStepper!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var quantityUnitControl: UISegmentedControl!
    @IBOutlet weak var quantityPerMealOrDayControl: UISegmentedControl!
    @IBOutlet weak var calendarLabel: UILabel!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var expensesLabel: UILabel!
    @IBOutlet weak var calendarSwitch: UISwitch!
    @IBOutlet weak var bagWeightTextField: UITextField!
    @IBOutlet weak var bagWeightUnitControl: UISegmentedControl!
    @IBOutlet weak var bagPriceTextField: UITextField!
    @IBOutlet weak var expensesDateTextField: UITextField!
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
    var event: EKEvent?
    var eventIdentifier = String()

    var viewTitle: String {
        return food == nil ? "Add New Food" : "Edit Food"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        reloadFoodAttributes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        subscribeToTextFieldsNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromNotifications()
    }
    
    func initView() {
        navigationBar.topItem?.title = viewTitle
        calendarLabel.configureTitle()
        expensesLabel.configureTitle()
        saveButton.isEnabled = false
        for textField in textFields {
            textField.delegate = self
        }
    }
    
    /// Enable save button if any text field is changed
    func subscribeToTextFieldsNotifications() {
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: nil, queue: .main) { notification in
            self.saveButton.isEnabled = true
        }
    }
    
    func reloadFoodAttributes() {
        foodImageView.image = UIImage(named: selectedObjectName)
        foodSubcategoryLabel.text = selectedObjectName
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
        expensesDateTextField.text = food?.date?.stringFormat ?? Date().stringFormat
        if food?.eventIdentifier != nil {
            calendarSwitch.isOn = true
        }
    }
    
    func addNewFood() -> Food {
        let newFood = Food(context: dataController.viewContext)
        newFood.pet = pet
        return newFood
    }
    
    @objc func handleDatePicker(_ sender: UIDatePicker) {
        activeTextField.text = sender.date.stringFormat
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        presentActivityIndicator(true, forButton: sender)
        
        let food: Food
        if let foodToEdit = self.food {
            food = foodToEdit
        } else {
            food = addNewFood()
        }
        
        food.category = "Food"
        food.subcategory = selectedObjectName
        food.brand = brandTextField.text
        if let mealsText = mealsTextField.text {
            food.meals = Int16(mealsText)!
        }
        if let quantityText = quantityTextField.text {
            food.quantity = Int16(quantityText)!
        }
        food.quantityUnit = quantityUnitControl.selectedSegmentTitle
        food.quantityPerMealOrDay = quantityPerMealOrDayControl.selectedSegmentTitle
        food.startDate = startDateTextField.text?.dateFormat
        food.endDate = endDateTextField.text?.dateFormat
        if let bagWeightText = bagWeightTextField.text {
            food.bagWeight = Double(bagWeightText)!
        }
        food.bagWeightUnit = bagWeightUnitControl.selectedSegmentTitle
        if let bagPriceText = Double(bagPriceTextField.text ?? "") {
            food.amount = NSDecimalNumber(value: bagPriceText)
        }
        food.date = expensesDateTextField.text?.dateFormat
                
        try? dataController.viewContext.save()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func mealsStepper(_ sender: UIStepper) {
        mealsTextField.text = Int(sender.value).description
    }
    
    @IBAction func addCalendarTapped(_ sender: UISwitch) {
        if calendarSwitch.isOn {
            checkAuthorizationStatus(for: .event)
        } else {
            removeEvent()
        }
    }
    
    func removeEvent() {
        guard let eventIdentifier = food?.eventIdentifier else { return }
        let removeAlert = AlertInformation(
            title: "Are you sure you want to remove this event?",
            message: "This action cannot be undone",
            actions: [
                Action(buttonTitle: "Cancel", buttonStyle: .cancel, handler: {
                    self.calendarSwitch.isOn = true
                }),
                Action(buttonTitle: "Delete", buttonStyle: .destructive, handler: {
                    if let event = self.eventStore.event(withIdentifier: eventIdentifier) {
                        self.food?.eventIdentifier = nil
                        do {
                            try self.eventStore.remove(event, span: .futureEvents)
                            try self.dataController.viewContext.save()
                        } catch {
                            fatalError("Remove event error")
                        }
                    }
                })
            ]
        )
        presentAlertDialog(with: removeAlert)
    }

    func createEvent() {
        let eventViewController = EKEventEditViewController()
        eventViewController.editViewDelegate = self
        eventViewController.eventStore = eventStore
        event = EKEvent(eventStore: eventStore)
        event?.calendar = EKCalendar.loadCalendar(type: .event, from: eventStore, with: calendarKey)
        event?.title = foodSubcategoryLabel.text
        event?.startDate = food?.startDate
        event?.endDate = food?.endDate
        event?.notes = "Feed \(pet?.name ?? "#") with \(brandTextField.text ?? "#")"
        eventViewController.event = event
        present(eventViewController, animated: true, completion: nil)
    }
    
    func setEventIdentifier(_ identifier: String) {
        food?.eventIdentifier = identifier
        try? dataController.viewContext.save()
    }
}

// -----------------------------------------------------------------------------
// MARK: - EventStoreAuthorization

extension FoodViewController: CalendarAuthorization {
    func accessGranted() {
        createEvent()
    }
}

// -----------------------------------------------------------------------------
// MARK: - EKEventEditViewDelegate

extension FoodViewController: EKEventEditViewDelegate {
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        switch action {
        case .canceled:
            controller.dismiss(animated: true, completion: {
                self.calendarSwitch.isOn = false
            })
        case .saved:
            controller.dismiss(animated: true, completion: {
                self.setEventIdentifier(controller.event?.eventIdentifier ?? "")
            })
        default:
            fatalError("Invalid action")
        }
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
        case quantityTextField, bagWeightTextField, bagPriceTextField:
            activeTextField = textField
            textField.text = ""
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
