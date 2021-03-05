//
//  NewPetViewController.swift
//  MyPetPlanner
//
//  Created by Lidia on 04/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit
import CoreData

class NewPetViewController: UIViewController {

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var basicInformationLabel: UILabel!
    @IBOutlet weak var bodyMeasurementsLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeControl: UISegmentedControl!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var genderControl: UISegmentedControl!
    @IBOutlet weak var breedTextField: UITextField!
    @IBOutlet weak var colorTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet var textFields: [UITextField]!
    
    var dataController: DataController!

    var fetchedResultsController: NSFetchedResultsController<Pet>!

    /// The pet whose infos will be added
    var newPet: Pet!
    
    let pickerView = UIPickerView()
    
    var dogBreeds: [String] = []
    
    var catBreeds: [String] = []
    
    let dateFormatter = DateFormatter()
    
    fileprivate func roundLabelEdges(label: UILabel, cornerRadius: CGFloat) {
        label.layer.masksToBounds = true
        label.layer.cornerRadius = cornerRadius
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupFetchedResultsController()
        roundLabelEdges(label: basicInformationLabel, cornerRadius: 5)
        roundLabelEdges(label: bodyMeasurementsLabel, cornerRadius: 5)
        
        dateFormatter.dateFormat = "MM-dd-yyyy"
        birthdayTextField.text = dateFormatter.string(from: Date())
        saveButton.isEnabled = false
        
        for textField in textFields {
            textField.delegate = self
        }

        pickerView.dataSource = self
        pickerView.delegate = self
        DogAPIClient.getBreedsList(completion: handleBreedsListResponse(breeds:error:))

        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: nameTextField, queue: .main) { notif in
            if let text = self.nameTextField.text, !text.isEmpty {
                self.saveButton.isEnabled = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        fetchedResultsController = nil
    }
    
    func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pet> = Pet.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    @objc func handleDatePicker(_ sender: UIDatePicker!) {
        dateFormatter.dateFormat = "MM-dd-yyyy"
        birthdayTextField.text = dateFormatter.string(from: sender.date)
    }
    
    func handleBreedsListResponse(breeds: [String], error: Error?) {
        self.dogBreeds = breeds
        DispatchQueue.main.async {
            self.pickerView.reloadAllComponents()
        }
    }
    
    func updatePicker(){
        self.pickerView.reloadAllComponents()
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let pet = Pet(context: dataController.viewContext)
        pet.name = nameTextField.text
        let selectedType = typeControl.selectedSegmentIndex
        pet.type = typeControl.titleForSegment(at: selectedType)
        
        if let birthdayText = birthdayTextField.text {
            pet.birthday = dateFormatter.date(from: birthdayText)
        }
        
        pet.breed = breedTextField.text
        pet.color = colorTextField.text
        
        let selectedGender = genderControl.selectedSegmentIndex
        pet.gender = genderControl.titleForSegment(at: selectedGender)
        
        if let weightText = weightTextField.text {
            pet.weight = Double(weightText) ?? 0
        }
        
        if let heightText = heightTextField.text {
            pet.height = Double(heightText) ?? 0
        }

        try? dataController.viewContext.save()
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

// -----------------------------------------------------------------------------
// MARK: - UITextFieldDelegate

extension NewPetViewController: UITextFieldDelegate {
    
    /// Make the next textField the first responder when the user taps the return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            birthdayTextField.becomeFirstResponder()
        case birthdayTextField:
            breedTextField.becomeFirstResponder()
        case breedTextField:
            colorTextField.becomeFirstResponder()
        case colorTextField:
            weightTextField.becomeFirstResponder()
        case weightTextField:
            heightTextField.becomeFirstResponder()
        default:
            heightTextField.resignFirstResponder()
        }
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case birthdayTextField:
            let datePickerView = UIDatePicker()
            datePickerView.datePickerMode = .date
            datePickerView.backgroundColor = .white
            birthdayTextField.inputView = datePickerView
            datePickerView.addTarget(self, action: #selector(handleDatePicker(_:)), for: .valueChanged)
        case breedTextField:
            pickerView.reloadAllComponents()
            pickerView.backgroundColor = .white
            breedTextField.inputView = pickerView
        default:
            break
        }
    }
}

// -----------------------------------------------------------------------------
// MARK: - UIPickerViewDataSource, UIPickerViewDelegate

extension NewPetViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if typeControl.isEnabledForSegment(at: 0) {
            return dogBreeds.count
        } else {
            return catBreeds.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if typeControl.isEnabledForSegment(at: 0) {
            return dogBreeds[row]
        } else {
            return catBreeds[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if typeControl.isEnabledForSegment(at: 0) {
            breedTextField.text = dogBreeds[row]
        } else {
            breedTextField.text = catBreeds[row]
        }
    }
}
