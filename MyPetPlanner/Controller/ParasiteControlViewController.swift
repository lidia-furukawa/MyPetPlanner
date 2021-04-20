//
//  ParasiteControlViewController.swift
//  MyPetPlanner
//
//  Created by Lidia on 20/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit
import CoreData
import EventKit
import EventKitUI

class ParasiteControlViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var parasiteControlImageView: UIImageView!
    @IBOutlet var parasiteControlSubcategoryLabel: UILabel!
    @IBOutlet var treatmentTextField: UITextField!
    @IBOutlet var frequencyTextField: UITextField!
    @IBOutlet var frequencyStepper: UIStepper!
    @IBOutlet var frequencyControl: UISegmentedControl!
    @IBOutlet var expensesLabel: UILabel!
    @IBOutlet var priceTextField: UITextField!
    @IBOutlet var expensesDateTextField: UITextField!
    @IBOutlet var expensesSwitch: UISwitch!
    @IBOutlet var calendarLabel: UILabel!
    @IBOutlet var startDateTextField: UITextField!
    @IBOutlet var endDateTextField: UITextField!
    @IBOutlet var calendarSwitch: UISwitch!
    @IBOutlet var textFields: [UITextField]!
    
    var dataController: DataController!
    
    /// The pet whose parasiteControl is being displayed/edited
    var pet: Pet?
    
    /// The parasiteControl either passed by `HealthSectionViewController` or constructed when adding a new parasiteControl
    var parasiteControl: ParasiteControl?
    
    var activeTextField = UITextField()
    var selectedObjectName = String()
    var eventStore = EKEventStore()
    let calendarKey = "MyPetPlanner"
    var event: EKEvent?
    var eventIdentifier = String()
    
    var viewTitle: String {
        return parasiteControl == nil ? "Add New Parasite Control" : "Edit Parasite Control"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        reloadParasiteControlAttributes()
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
    
    func reloadParasiteControlAttributes() {
        parasiteControlImageView.image = UIImage(named: selectedObjectName)
        parasiteControlSubcategoryLabel.text = selectedObjectName
        treatmentTextField.text = parasiteControl?.treatment
        frequencyTextField.text = String(parasiteControl?.frequency ?? 0)
        frequencyControl.getSegmentedControlSelectedIndex(from: parasiteControl?.frequencyUnit)
        priceTextField.text = parasiteControl?.expenseAmount?.stringFormat ?? ""
        expensesDateTextField.text = parasiteControl?.expenseDate?.stringFormat ?? Date().stringFormat
        startDateTextField.text = parasiteControl?.startDate?.stringFormat ?? Date().stringFormat
        endDateTextField.text = parasiteControl?.endDate?.stringFormat ?? Date().stringFormat
        if parasiteControl?.eventIdentifier != nil {
            calendarSwitch.isOn = true
        }
    }
    
    func addNewParasiteControl() -> ParasiteControl {
        let newParasiteControl = ParasiteControl(context: dataController.viewContext)
        newParasiteControl.pet = pet
        return newParasiteControl
    }
    
    @objc func handleDatePicker(_ sender: UIDatePicker) {
        activeTextField.text = sender.date.stringFormat
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        presentActivityIndicator(true, forButton: sender)
        
        let parasiteControl: ParasiteControl
        if let parasiteControlToEdit = self.parasiteControl {
            parasiteControl = parasiteControlToEdit
        } else {
            parasiteControl = addNewParasiteControl()
        }
        
        parasiteControl.category = "ParasiteControl"
        parasiteControl.subcategory = selectedObjectName
        parasiteControl.treatment = treatmentTextField.text
        if let frequencyText = frequencyTextField.text {
            parasiteControl.frequency = Int16(frequencyText)!
        }
        parasiteControl.frequencyUnit = frequencyControl.selectedSegmentTitle
        if let priceText = Double(priceTextField.text ?? "") {
            parasiteControl.expenseAmount = NSDecimalNumber(value: priceText)
        }
        parasiteControl.expenseDate = expensesDateTextField.text?.dateFormat
        parasiteControl.startDate = startDateTextField.text?.dateFormat
        parasiteControl.endDate = endDateTextField.text?.dateFormat
        
        try? dataController.viewContext.save()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func frequencyStepper(_ sender: UIStepper) {
        frequencyTextField.text = Int(sender.value).description
    }
    
    @IBAction func calculateFutureExpenses(_ sender: UISwitch) {
        if expensesSwitch.isOn {
            
        } else {
            
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
        guard let eventIdentifier = parasiteControl?.eventIdentifier else { return }
        let removeAlert = AlertInformation(
            title: "Are you sure you want to remove this event?",
            message: "This action cannot be undone",
            actions: [
                Action(buttonTitle: "Cancel", buttonStyle: .cancel, handler: {
                    self.calendarSwitch.isOn = true
                }),
                Action(buttonTitle: "Delete", buttonStyle: .destructive, handler: {
                    if let event = self.eventStore.event(withIdentifier: eventIdentifier) {
                        self.parasiteControl?.eventIdentifier = nil
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
        event?.title = parasiteControlSubcategoryLabel.text
        event?.startDate = parasiteControl?.startDate
        event?.endDate = parasiteControl?.endDate
        event?.notes = "Give \(pet?.name ?? "#")'s \(parasiteControlSubcategoryLabel.text ?? "#") Parasite Control"
        eventViewController.event = event
        present(eventViewController, animated: true, completion: nil)
    }
    
    func setEventIdentifier(_ identifier: String) {
        parasiteControl?.eventIdentifier = identifier
        try? dataController.viewContext.save()
    }
}

// -----------------------------------------------------------------------------
// MARK: - EventStoreAuthorization

extension ParasiteControlViewController: CalendarAuthorization {
    func accessGranted() {
        createEvent()
    }
}

// -----------------------------------------------------------------------------
// MARK: - EKEventEditViewDelegate

extension ParasiteControlViewController: EKEventEditViewDelegate {
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

extension ParasiteControlViewController: KeyboardNotifications { }

// -----------------------------------------------------------------------------
// MARK: - SaveActivityIndicator

extension ParasiteControlViewController: SaveActivityIndicator { }

// -----------------------------------------------------------------------------
// MARK: - UITextFieldDelegate

extension ParasiteControlViewController: UITextFieldDelegate {
    
    /// Make the next textField the first responder when the user taps the return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case treatmentTextField:
            frequencyTextField.becomeFirstResponder()
        case frequencyTextField:
            priceTextField.becomeFirstResponder()
        case priceTextField:
            expensesDateTextField.becomeFirstResponder()
        case expensesDateTextField:
            startDateTextField.becomeFirstResponder()
        case startDateTextField:
            endDateTextField.becomeFirstResponder()
        default:
            endDateTextField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case expensesDateTextField:
            activeTextField = expensesDateTextField
            expensesDateTextField.inputView = .customizedDatePickerView(setMinimumDate: nil, setDate: parasiteControl?.startDate ?? Date(), withTarget: self, action: #selector(handleDatePicker(_:)))
        case startDateTextField:
            activeTextField = startDateTextField
            startDateTextField.inputView = .customizedDatePickerView(setMinimumDate: nil, setDate: parasiteControl?.startDate ?? Date(), withTarget: self, action: #selector(handleDatePicker(_:)))
        case endDateTextField:
            activeTextField = endDateTextField
            endDateTextField.inputView = .customizedDatePickerView(setMinimumDate: parasiteControl?.startDate, setDate: parasiteControl?.endDate ?? Date(), withTarget: self, action: #selector(handleDatePicker(_:)))
        case frequencyTextField, priceTextField:
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
        case priceTextField:
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
