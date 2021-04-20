//
//  GroomingViewController.swift
//  MyPetPlanner
//
//  Created by Lidia on 19/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit
import CoreData
import EventKit
import EventKitUI

class GroomingViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var groomingImageView: UIImageView!
    @IBOutlet var groomingSubcategoryLabel: UILabel!
    @IBOutlet var groomingTextField: UITextField!
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
    
    /// The pet whose grooming is being displayed/edited
    var pet: Pet?
    
    /// The grooming either passed by `HealthSectionViewController` or constructed when adding a new grooming
    var grooming: Grooming?
    
    var activeTextField = UITextField()
    var selectedObjectName = String()
    var eventStore = EKEventStore()
    let calendarKey = "MyPetPlanner"
    var event: EKEvent?
    var eventIdentifier = String()
    
    var viewTitle: String {
        return grooming == nil ? "Add New Grooming" : "Edit Grooming"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        reloadGroomingAttributes()
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
    
    func reloadGroomingAttributes() {
        groomingImageView.image = UIImage(named: selectedObjectName)
        groomingSubcategoryLabel.text = selectedObjectName
        groomingTextField.text = grooming?.groomerInfo
        frequencyTextField.text = String(grooming?.frequency ?? 0)
        frequencyControl.getSegmentedControlSelectedIndex(from: grooming?.frequencyUnit)
        priceTextField.text = grooming?.amount?.stringFormat ?? ""
        expensesDateTextField.text = grooming?.date?.stringFormat ?? Date().stringFormat
        startDateTextField.text = grooming?.startDate?.stringFormat ?? Date().stringFormat
        endDateTextField.text = grooming?.endDate?.stringFormat ?? Date().stringFormat
        if grooming?.eventIdentifier != nil {
            calendarSwitch.isOn = true
        }
    }
    
    func addNewGrooming() -> Grooming {
        let newGrooming = Grooming(context: dataController.viewContext)
        newGrooming.pet = pet
        return newGrooming
    }
    
    @objc func handleDatePicker(_ sender: UIDatePicker) {
        activeTextField.text = sender.date.stringFormat
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        presentActivityIndicator(true, forButton: sender)
        
        let grooming: Grooming
        if let groomingToEdit = self.grooming {
            grooming = groomingToEdit
        } else {
            grooming = addNewGrooming()
        }
        
        grooming.category = "Grooming"
        grooming.subcategory = selectedObjectName
        grooming.groomerInfo = groomingTextField.text
        if let frequencyText = frequencyTextField.text {
            grooming.frequency = Int16(frequencyText)!
        }
        grooming.frequencyUnit = frequencyControl.selectedSegmentTitle
        if let priceText = Double(priceTextField.text ?? "") {
            grooming.amount = NSDecimalNumber(value: priceText)
        }
        grooming.date = expensesDateTextField.text?.dateFormat
        grooming.startDate = startDateTextField.text?.dateFormat
        grooming.endDate = endDateTextField.text?.dateFormat
        
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
        guard let eventIdentifier = grooming?.eventIdentifier else { return }
        let removeAlert = AlertInformation(
            title: "Are you sure you want to remove this event?",
            message: "This action cannot be undone",
            actions: [
                Action(buttonTitle: "Cancel", buttonStyle: .cancel, handler: {
                    self.calendarSwitch.isOn = true
                }),
                Action(buttonTitle: "Delete", buttonStyle: .destructive, handler: {
                    if let event = self.eventStore.event(withIdentifier: eventIdentifier) {
                        self.grooming?.eventIdentifier = nil
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
        event?.title = groomingSubcategoryLabel.text
        event?.startDate = grooming?.startDate
        event?.endDate = grooming?.endDate
        event?.notes = "\(pet?.name ?? "#")'s Grooming: \(groomingSubcategoryLabel.text ?? "#")"
        eventViewController.event = event
        present(eventViewController, animated: true, completion: nil)
    }
    
    func setEventIdentifier(_ identifier: String) {
        grooming?.eventIdentifier = identifier
        try? dataController.viewContext.save()
    }
}

// -----------------------------------------------------------------------------
// MARK: - EventStoreAuthorization

extension GroomingViewController: CalendarAuthorization {
    func accessGranted() {
        createEvent()
    }
}

// -----------------------------------------------------------------------------
// MARK: - EKEventEditViewDelegate

extension GroomingViewController: EKEventEditViewDelegate {
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

extension GroomingViewController: KeyboardNotifications { }

// -----------------------------------------------------------------------------
// MARK: - SaveActivityIndicator

extension GroomingViewController: SaveActivityIndicator { }

// -----------------------------------------------------------------------------
// MARK: - UITextFieldDelegate

extension GroomingViewController: UITextFieldDelegate {
    
    /// Make the next textField the first responder when the user taps the return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case groomingTextField:
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
            expensesDateTextField.inputView = .customizedDatePickerView(setMinimumDate: nil, setDate: grooming?.startDate ?? Date(), withTarget: self, action: #selector(handleDatePicker(_:)))
        case startDateTextField:
            activeTextField = startDateTextField
            startDateTextField.inputView = .customizedDatePickerView(setMinimumDate: nil, setDate: grooming?.startDate ?? Date(), withTarget: self, action: #selector(handleDatePicker(_:)))
        case endDateTextField:
            activeTextField = endDateTextField
            endDateTextField.inputView = .customizedDatePickerView(setMinimumDate: grooming?.startDate, setDate: grooming?.endDate ?? Date(), withTarget: self, action: #selector(handleDatePicker(_:)))
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
