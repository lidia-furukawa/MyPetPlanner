//
//  HealthcareViewController.swift
//  MyPetPlanner
//
//  Created by Lidia on 20/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit
import CoreData
import EventKit
import EventKitUI

class HealthcareViewController: UIViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var sectionImageView: UIImageView!
    @IBOutlet var sectionSubcategoryLabel: UILabel!
    @IBOutlet var sectionTextField: UITextField!
    @IBOutlet var sectionLabel: UILabel!
    @IBOutlet var frequencyControl: UISegmentedControl!
    @IBOutlet var expensesLabel: UILabel!
    @IBOutlet var costTextField: UITextField!
    @IBOutlet var startDateTextField: UITextField!
    @IBOutlet var expensesSwitch: UISwitch!
    @IBOutlet var calendarLabel: UILabel!
    @IBOutlet var endDateTextField: UITextField!
    @IBOutlet var calendarSwitch: UISwitch!
    @IBOutlet var textFields: [UITextField]!
    @IBOutlet var quantityStackView: UIStackView!
    @IBOutlet var quantityTextField: UITextField!
    @IBOutlet var quantityControl: UISegmentedControl!
    @IBOutlet var bagStackView: UIStackView!
    @IBOutlet var bagTextField: UITextField!
    @IBOutlet var bagControl: UISegmentedControl!
    @IBOutlet var endDateStackView: UIStackView!
    @IBOutlet var frequencyStackView: UIStackView!
    
    var dataController: DataController!
    
    /// The pet whose healthcare is being created/edited
    var pet: Pet?
    var healthcare: Healthcare?
    var activeTextField = UITextField()
    var selectedObjectName = String()
    var selectedObjectSectionName = String()
    let localSubcategoryData = HealthcareCategory.localHealthcareSubcategoryData
    var eventStore = EKEventStore()
    let calendarKey = "MyPetPlanner"
    var event: EKEvent?
    var eventIdentifier: String?
    var savedExpenses = Bool()

    var viewTitle: String {
        return healthcare == nil ? "Add New \(selectedObjectSectionName)" : "Edit \(selectedObjectSectionName)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Expense.fetchAllExpenses(for: healthcare, context: dataController.viewContext) { expenses in
            self.savedExpenses = !expenses.isEmpty
        }
        initView()
        reloadAttributes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        subscribeToKeyboardNotifications()
        subscribeToTextFieldsNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
    
    func showFoodSpecificFields(_ isVisible: Bool) {
        quantityStackView.isHidden  = !isVisible
        bagStackView.isHidden = !isVisible
    }
    
    /// Enable save button if any text field is changed
    func subscribeToTextFieldsNotifications() {
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: nil, queue: .main) { notification in
            self.saveButton.isEnabled = true
        }
    }
    
    func reloadAttributes() {
        sectionImageView.image = UIImage(named: selectedObjectName)
        sectionSubcategoryLabel.text = selectedObjectName
        let subcategory = localSubcategoryData.filter {
            (data: HealthcareSubcategory) -> Bool in
            data.subcategory == selectedObjectName
            }.first!
        sectionLabel.text = subcategory.requiredInformation
        sectionTextField.placeholder = subcategory.informationPlaceholder
        sectionTextField.text = healthcare?.information
        frequencyControl.getSegmentedControlSelectedIndex(from: healthcare?.frequencyUnit)
        costTextField.text = healthcare?.cost?.stringFormat ?? ""
        startDateTextField.text = healthcare?.startDate?.stringFormat ?? Date().stringFormat
        endDateTextField.text = healthcare?.endDate?.stringFormat ?? Date().stringFormat
        if healthcare?.eventIdentifier != nil {
            calendarSwitch.isOn = true
        }
        expensesSwitch.isOn = savedExpenses
        endDateStackView.isHidden = !savedExpenses
        if selectedObjectSectionName == "Food" {
            showFoodSpecificFields(true)
            frequencyStackView.isHidden = true
            quantityTextField.text = healthcare?.quantity.stringFormat
            quantityControl.getSegmentedControlSelectedIndex(from: healthcare?.quantityUnit)
            bagTextField.text = healthcare?.bag.stringFormat
            bagControl.getSegmentedControlSelectedIndex(from: healthcare?.bagUnit)
        }
    }
    
    @objc func handleDatePicker(_ sender: UIDatePicker) {
        activeTextField.text = sender.date.stringFormat
    }
    
    func addNewHealthcare() -> Healthcare {
        let newHealthcare = Healthcare(context: dataController.viewContext)
        newHealthcare.pet = pet
        return newHealthcare
    }
    
    func addNewExpense(to healthcare: Healthcare, date: Date) {
        let expense = Expense(context: dataController.viewContext)
        expense.pet = pet
        expense.healthcare = healthcare
        expense.category = selectedObjectSectionName
        expense.subcategory = selectedObjectName
        if let costText = Double(costTextField.text ?? "") {
            expense.amount = NSDecimalNumber(value: costText)
        }
        expense.date = date
    }
    
    func deleteExpenses() {
        guard let healthcare = healthcare else { return }
        Expense.deleteAllExpenses(for: healthcare, context: dataController.viewContext)
    }
    
    func removeExpenses() {
        let removeExpenses = AlertInformation(
            title: "Are you sure you want to remove all the calculated expenses?",
            message: "This action cannot be undone",
            actions: [
                Action(buttonTitle: "Cancel", buttonStyle: .cancel, handler: {
                    self.expensesSwitch.isOn = true
                }),
                Action(buttonTitle: "Delete", buttonStyle: .destructive, handler: {
                    self.endDateStackView.isHidden = true
                    self.deleteExpenses()
                })
            ]
        )
        presentAlertDialog(with: removeExpenses)
    }
    
    func daysBagWillLast() -> Int {
        let dailyQuantity = Double(quantityTextField.text ?? "") ?? 0
        let bag = Double(bagTextField.text ?? "") ?? 0
        var multiplier = Double()
        
        switch bagControl.selectedSegmentTitle {
        case "lb":
            multiplier = 16
        case "kg":
            multiplier = 1000
        default:
            fatalError("Unidentified unit")
        }
        
        let daysBagWillLast = Int(bag * multiplier / dailyQuantity)
        print(daysBagWillLast)
        return daysBagWillLast
    }
    
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        presentActivityIndicator(true, forButton: sender)
        
        let healthcare: Healthcare
        if let healthcareToEdit = self.healthcare {
            healthcare = healthcareToEdit
        } else {
            healthcare = addNewHealthcare()
        }
        
        healthcare.category = selectedObjectSectionName
        healthcare.subcategory = selectedObjectName
        healthcare.information = sectionTextField.text
        healthcare.frequencyUnit = frequencyControl.selectedSegmentTitle
        if let costText = Double(costTextField.text ?? "") {
            healthcare.cost = NSDecimalNumber(value: costText)
        }
        let startDate = startDateTextField.text!.dateFormat
        healthcare.startDate = startDate
        let endDate = endDateTextField.text!.dateFormat
        healthcare.endDate = endDate
        healthcare.eventIdentifier = eventIdentifier
        healthcare.quantity = Double(quantityTextField.text ?? "") ?? 0
        healthcare.quantityUnit = quantityControl.selectedSegmentTitle
        healthcare.bag = Double(bagTextField.text ?? "") ?? 0
        healthcare.bagUnit = bagControl.selectedSegmentTitle

        if !savedExpenses {
            var frequencyUnit = String()
            var step = Int()
            if selectedObjectSectionName == "Food" {
                frequencyUnit = "Day"
                step = daysBagWillLast()
            } else {
                frequencyUnit = frequencyControl.selectedSegmentTitle!
                step = 1
            }
            let numberOfComponents = Calendar.current.countNumberOfComponents(between: startDate, and: endDate, in: frequencyUnit)
            var i = 0
            while i < numberOfComponents {
                let expenseDate = startDate.calculateNextDate(after: i, unit: frequencyUnit)
                addNewExpense(to: healthcare, date: expenseDate)
                i += step
            }
        }
        
        try? dataController.viewContext.save()
        performSegue(withIdentifier: UIStoryboardSegue.Identifiers.unwindToHealthSection, sender: nil)
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        if let eventIdentifier = eventIdentifier {
            deleteEventFromStore(withIdentifier: eventIdentifier)
        }
        performSegue(withIdentifier: UIStoryboardSegue.Identifiers.unwindToHealthSection, sender: nil)
    }
    
    @IBAction func calculateFutureExpenses(_ sender: UISwitch) {
        if expensesSwitch.isOn {
            endDateStackView.isHidden = false
        } else {
            removeExpenses()
        }
    }
    
    @IBAction func addCalendarTapped(_ sender: UISwitch) {
        if calendarSwitch.isOn {
            checkAuthorizationStatus(for: .event)
        } else {
            removeEvent()
        }
    }
    
    func removeEvent() {
        guard let eventIdentifier = healthcare?.eventIdentifier else { return }
        let removeAlert = AlertInformation(
            title: "Are you sure you want to remove this event?",
            message: "This action cannot be undone",
            actions: [
                Action(buttonTitle: "Cancel", buttonStyle: .cancel, handler: {
                    self.calendarSwitch.isOn = true
                }),
                Action(buttonTitle: "Delete", buttonStyle: .destructive, handler: {
                    self.setEventIdentifier(nil)
                    self.deleteEventFromStore(withIdentifier: eventIdentifier)
                })
            ]
        )
        presentAlertDialog(with: removeAlert)
    }
    
    func deleteEventFromStore(withIdentifier identifier: String) {
        if let event = self.eventStore.event(withIdentifier: identifier) {
            do {
                try self.eventStore.remove(event, span: .futureEvents)
            } catch {
                fatalError("Delete event error")
            }
        }
    }
    
    func createEvent() {
        let eventViewController = EKEventEditViewController()
        eventViewController.editViewDelegate = self
        eventViewController.eventStore = eventStore
        event = EKEvent(eventStore: eventStore)
        event?.calendar = EKCalendar.loadCalendar(type: .event, from: eventStore, with: calendarKey)
        event?.title = sectionSubcategoryLabel.text
        event?.notes = "\(pet?.name ?? "#")'s \(selectedObjectSectionName): \(sectionSubcategoryLabel.text ?? "#")"
        eventViewController.event = event
        present(eventViewController, animated: true, completion: nil)
    }
    
    func setEventIdentifier(_ identifier: String?) {
        healthcare?.eventIdentifier = identifier
        try? dataController.viewContext.save()
    }
}

// -----------------------------------------------------------------------------
// MARK: - EventStoreAuthorization

extension HealthcareViewController: CalendarAuthorization {
    func accessGranted() {
        createEvent()
    }
}

// -----------------------------------------------------------------------------
// MARK: - EKEventEditViewDelegate

extension HealthcareViewController: EKEventEditViewDelegate {
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        switch action {
        case .canceled:
            controller.dismiss(animated: true, completion: {
                self.calendarSwitch.isOn = false
            })
        case .saved:
            controller.dismiss(animated: true, completion: {
                self.eventIdentifier = controller.event?.eventIdentifier
            })
        default:
            fatalError("Invalid action")
        }
    }
}

// -----------------------------------------------------------------------------
// MARK: - KeyboardNotifications

extension HealthcareViewController: KeyboardNotifications { }

// -----------------------------------------------------------------------------
// MARK: - SaveActivityIndicator

extension HealthcareViewController: SaveActivityIndicator { }

// -----------------------------------------------------------------------------
// MARK: - UITextFieldDelegate

extension HealthcareViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case startDateTextField:
            activeTextField = startDateTextField
            startDateTextField.inputView = .customizedDatePickerView(setMinimumDate: nil, setDate: healthcare?.startDate ?? Date(), withTarget: self, action: #selector(handleDatePicker(_:)))
        case endDateTextField:
            activeTextField = endDateTextField
            endDateTextField.inputView = .customizedDatePickerView(setMinimumDate: healthcare?.startDate, setDate: healthcare?.endDate ?? Date(), withTarget: self, action: #selector(handleDatePicker(_:)))
        case quantityTextField, bagTextField, costTextField:
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
        case bagTextField, costTextField:
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

