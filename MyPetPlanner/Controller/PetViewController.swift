//
//  PetViewController.swift
//  MyPetPlanner
//
//  Created by Lidia on 04/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit
import CoreData

class PetViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var selectPhotoButton: UIButton!
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
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var activeTextField = UITextField()
    
    var dataController: DataController!

    /// The pet whose infos will be edited
    var pet: Pet!
    
    let pickerView = UIPickerView()
    
    var dogBreeds: [String] = []
    
    var catList: [CatResponse] = []
    
    var catBreeds: [String] = []
    
    let dateFormatter = DateFormatter()
    
    fileprivate func roundLabelEdges(label: UILabel, cornerRadius: CGFloat) {
        label.layer.masksToBounds = true
        label.layer.cornerRadius = cornerRadius
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        roundLabelEdges(label: basicInformationLabel, cornerRadius: 5)
        roundLabelEdges(label: bodyMeasurementsLabel, cornerRadius: 5)
        
        photoImageView.layer.masksToBounds = true
        photoImageView.layer.cornerRadius = photoImageView.bounds.width/2
        
        saveButton.isEnabled = false
        
        for textField in textFields {
            textField.delegate = self
        }

        pickerView.dataSource = self
        pickerView.delegate = self
        
        DogAPIClient.getBreedsList(completion: handleDogBreedsListResponse(breeds:error:))
        CatAPIClient.getCatsList(completion: handleCatResponse(cats:error:))
        
        // Enable save button if any text field is changed
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: nil, queue: .main) { notif in
            self.saveButton.isEnabled = true
        }
        
        if pet != nil {
            navigationBar.topItem?.title = "Edit Pet"
            reloadSavedPet()
        } else {
            // Set default fields values
            navigationBar.topItem?.title = "Add New Pet"
            photoImageView.image = UIImage(named: "placeholder")
            dateFormatter.dateFormat = "MM-dd-yyyy"
            birthdayTextField.text = dateFormatter.string(from: Date())
            addNewPet()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    func addNewPet() {
        let newPet = Pet(context: dataController.viewContext)
        try? dataController.viewContext.save()
        pet = newPet
    }
    
    func reloadSavedPet() {
        if let photoData = pet.photo {
            photoImageView.image = UIImage(data: photoData)
        }
        
        nameTextField.text = pet.name
        
        switch pet.type {
        case "Dog":
            typeControl.selectedSegmentIndex = 0
        case "Cat":
            typeControl.selectedSegmentIndex = 1
        default:
            break
        }
        
        if let birthdayDate = pet.birthday {
            dateFormatter.dateFormat = "MM-dd-yyyy"
            birthdayTextField.text = dateFormatter.string(from: birthdayDate)
        }
        
        breedTextField.text = pet.breed
        colorTextField.text = pet.color
        
        switch pet.gender {
        case "♂️":
            genderControl.selectedSegmentIndex = 0
        case "♀️":
            genderControl.selectedSegmentIndex = 1
        default:
            break
        }
        
        weightTextField.text = String(pet.weight)
        heightTextField.text = String(pet.height)
    }
    
    @objc func handleDatePicker(_ sender: UIDatePicker!) {
        dateFormatter.dateFormat = "MM-dd-yyyy"
        birthdayTextField.text = dateFormatter.string(from: sender.date)
    }
    
    func handleDogBreedsListResponse(breeds: [String], error: Error?) {
        dogBreeds = breeds
    }
    
    func handleCatResponse(cats: [CatResponse], error: Error?) {
        catList = cats
        for cat in catList {
            catBreeds.append(cat.name)
        }
    }
    
    /// Sign up to be notified when an event is coming up
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// Remove all the subscribed observers
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Shift the scroll view's frame up
    @objc func keyboardWillShow(_ notification:Notification) {
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: getKeyboardHeight(notification), right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets

        // If the active text field is hidden by keyboard, scroll it so it's visible
        var aRect = self.view.frame
        aRect.size.height = -getKeyboardHeight(notification)
        if !aRect.contains(activeTextField.frame.origin) {
            scrollView.scrollRectToVisible(activeTextField.frame, animated: true)
        }
    }
    
    /// Move the scroll view back down
    @objc func keyboardWillHide(_ notification:Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    @IBAction func selectPhotoButton(_ sender: Any) {
        let imagePickerPopup = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        imagePickerPopup.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.openImagePickerWith(sourceType: .camera)
        }))
        
        imagePickerPopup.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
            self.openImagePickerWith(sourceType: .photoLibrary)
        }))
        
        imagePickerPopup.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        present(imagePickerPopup, animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let photoImage = photoImageView.image
        if let photoImageData = photoImage!.pngData() {
            pet.setValue(photoImageData, forKey: "photo")
        }
        
        if let birthdayText = birthdayTextField.text {
            pet.setValue(dateFormatter.date(from: birthdayText), forKey: "birthday")
        }
        
        let selectedType = typeControl.selectedSegmentIndex
        pet.setValue(typeControl.titleForSegment(at: selectedType), forKey: "type")

        let selectedGender = genderControl.selectedSegmentIndex
        pet.setValue(genderControl.titleForSegment(at: selectedGender), forKey: "gender")
        
        pet.setValue(nameTextField.text, forKey: "name")
        pet.setValue(breedTextField.text, forKey: "breed")
        pet.setValue(colorTextField.text, forKey: "color")
        
        if let weightText = weightTextField.text {
            pet.setValue(Double(weightText) ?? 0, forKey: "weight")
        }
        
        if let heightText = heightTextField.text {
            pet.setValue(Double(heightText) ?? 0, forKey: "height")
        }

        try? dataController.viewContext.save()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

// -----------------------------------------------------------------------------
// MARK: - UITextFieldDelegate

extension PetViewController: UITextFieldDelegate {
    
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
        case nameTextField:
            activeTextField = nameTextField
        case birthdayTextField:
            activeTextField = birthdayTextField
            let datePickerView = UIDatePicker()
            datePickerView.datePickerMode = .date
            datePickerView.backgroundColor = .white
            birthdayTextField.inputView = datePickerView
            datePickerView.addTarget(self, action: #selector(handleDatePicker(_:)), for: .valueChanged)
        case breedTextField:
            activeTextField = breedTextField
            pickerView.reloadAllComponents()
            pickerView.backgroundColor = .white
            breedTextField.inputView = pickerView
        case colorTextField:
            activeTextField = colorTextField
        case weightTextField:
            activeTextField = weightTextField
        case heightTextField:
            activeTextField = heightTextField
        default:
            break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string)
        
        switch textField {
        case weightTextField, heightTextField:
            let textArray = newText.components(separatedBy: ".")
            
            //Limit textfield entry to only one decimal place
            if textArray.count > 2 {
                return false
            } else if textArray.count == 2 {
                let lastString = textArray.last
                if lastString!.count > 1 {
                    return false
                }
            }
        default:
            break
        }
        return true
    }
}

// -----------------------------------------------------------------------------
// MARK: - UIPickerViewDataSource, UIPickerViewDelegate

extension PetViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if typeControl.selectedSegmentIndex == 0 {
            return dogBreeds.count
        } else {
            return catBreeds.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if typeControl.selectedSegmentIndex == 0 {
            return dogBreeds[row]
        } else {
            return catBreeds[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if typeControl.selectedSegmentIndex == 0 {
            breedTextField.text = dogBreeds[row]
        } else {
            breedTextField.text = catBreeds[row]
        }
    }
}

// -----------------------------------------------------------------------------
// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension PetViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openImagePickerWith(sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "Option not available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            photoImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
