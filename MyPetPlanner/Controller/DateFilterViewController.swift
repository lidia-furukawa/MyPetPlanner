//
//  DateFilterViewController.swift
//  MyPetPlanner
//
//  Created by Lidia on 15/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit

class DateFilterViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    
    var activeTextField = UITextField()

    /// A closure that is run when the user saves the filter dates
    var isSaved: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.topItem?.title = "Filter Date"
        startDateTextField.delegate = self
        endDateTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadLastDates()
    }
    
    func loadLastDates() {
        let lastStartDate = UserDefaults.standard.string(forKey: UserDefaults.Keys.startDateKey)
        let lastEndDate = UserDefaults.standard.string(forKey: UserDefaults.Keys.endDateKey)
        startDateTextField.text = lastStartDate ?? Date().stringFormat
        endDateTextField.text = lastEndDate ?? Date().stringFormat
    }
    
    func saveDates(_ startDate: String, _ endDate: String) {
        UserDefaults.standard.set(startDate, forKey: UserDefaults.Keys.startDateKey)
        UserDefaults.standard.set(endDate, forKey: UserDefaults.Keys.endDateKey)
    }
    
    @objc func handleDatePicker(_ sender: UIDatePicker) {
        activeTextField.text = sender.date.stringFormat
    }
    
    @IBAction func saveButton(_ sender: Any) {
        saveDates(startDateTextField.text!, endDateTextField.text!)
        isSaved?()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// -----------------------------------------------------------------------------
// MARK: - UITextFieldDelegate

extension DateFilterViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case startDateTextField:
            activeTextField = startDateTextField
            startDateTextField.inputView = .customizedDatePickerView(setMinimumDate: nil, setDate: startDateTextField.text?.dateFormat ?? Date(), withTarget: self, action: #selector(handleDatePicker(_:)))
        case endDateTextField:
            activeTextField = endDateTextField
            endDateTextField.inputView = .customizedDatePickerView(setMinimumDate: startDateTextField.text?.dateFormat ?? Date(), setDate: endDateTextField.text?.dateFormat ?? Date(), withTarget: self, action: #selector(handleDatePicker(_:)))
        default:
            fatalError("Unidentified textfield")
        }
    }
}
