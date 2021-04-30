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
    @IBOutlet weak var cancelButton: UIBarButtonItem!
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
    
    var dataController: DataController!

    /// The pet whose info is being displayed/edited
    var pet: Pet?
    let pickerView = UIPickerView()
    let imagePicker = UIImagePickerController()
    var activeTextField = UITextField()
    var dogBreeds: [String]!
    var catBreeds: [String]!
    var alertHasBeenDisplayed = false

    var viewTitle: String {
        return pet == nil ? "Create New Pet" : "Edit Pet"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        reloadPetAttributes()
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
        basicInformationLabel.configureTitle()
        bodyMeasurementsLabel.configureTitle()
        photoImageView.roundImage()
        saveButton.isEnabled = false
        for textField in textFields {
            textField.delegate = self
        }
        pickerView.dataSource = self
        pickerView.delegate = self
        imagePicker.delegate = self
    }
    
    /// Enable save button if any text field is changed
    func subscribeToTextFieldsNotifications() {
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: nil, queue: .main) { notification in
            self.saveButton.isEnabled = true
        }
    }
    
    func addNewPet() -> Pet {
        let newPet = Pet(context: dataController.viewContext)
        return newPet
    }
    
    func reloadPetAttributes() {
        if let photoData = pet?.photo {
            photoImageView.image = UIImage(data: photoData)
        } else {
            photoImageView.image = UIImage(named: "placeholder")
        }
        nameTextField.text = pet?.name
        typeControl.getSegmentedControlSelectedIndex(from: pet?.type)
        birthdayTextField.text = pet?.birthday?.stringFormat ?? Date().stringFormat
        breedTextField.text = pet?.breed
        colorTextField.text = pet?.color
        genderControl.getSegmentedControlSelectedIndex(from: pet?.gender)
        weightTextField.text = pet?.weight.stringFormat
        heightTextField.text = pet?.height.stringFormat
    }
    
    @objc func handleDatePicker(_ sender: UIDatePicker!) {
        activeTextField.text = sender.date.stringFormat
    }
    
    func showNetworkAlert() {
        let networkFailureAlert = AlertInformation(
            title: "Unable to Display Breeds List",
            message: "Check your internet connection or manually enter the breed",
            actions: [Action(buttonTitle: "OK", buttonStyle: .default, handler: {
                self.activeTextField.becomeFirstResponder()
            })]
        )
        presentAlertDialog(with: networkFailureAlert)
    }
    
    @IBAction func selectPhotoButton(_ sender: Any) {
        let imagePickerActions = [
            Action(buttonTitle: "Take Photo", buttonStyle: .default, handler: {
                self.openImagePickerWith(sourceType: .camera)
            }),
            Action(buttonTitle: "Choose Photo", buttonStyle: .default, handler: {
                self.openImagePickerWith(sourceType: .photoLibrary)
            })
        ]
        presentActionSheetDialog(with: imagePickerActions)
    }
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        presentActivityIndicator(true, forButton: sender)
        
        let pet: Pet
        if let petToEdit = self.pet {
            pet = petToEdit
        } else {
            pet = addNewPet()
        }
        
        pet.photo = photoImageView.image?.pngData()
        pet.birthday = birthdayTextField.text?.dateFormat
        pet.type = typeControl.selectedSegmentTitle
        pet.gender = genderControl.selectedSegmentTitle
        if nameTextField.text!.isEmpty {
            pet.name = "#"
            pet.initialName = "#"
        } else {
            pet.name = nameTextField.text
            pet.initialName = String(nameTextField.text!.prefix(1))
        }
        pet.breed = breedTextField.text
        pet.color = colorTextField.text
        pet.weight = weightTextField.text?.doubleFormat ?? 0
        pet.height = heightTextField.text?.doubleFormat ?? 0

        try? dataController.viewContext.save()
        performSegue(withIdentifier: UIStoryboardSegue.Identifiers.unwindToMyPets, sender: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        performSegue(withIdentifier: UIStoryboardSegue.Identifiers.unwindToMyPets, sender: nil)
    }
    
    /// Enable save button if any segmented control is changed
    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl) {
        self.view.endEditing(true)
        sender.becomeFirstResponder()
        saveButton.isEnabled = true
    }
}

// -----------------------------------------------------------------------------
// MARK: - KeyboardNotifications

extension PetViewController: KeyboardNotifications { }

// -----------------------------------------------------------------------------
// MARK: - SaveActivityIndicator

extension PetViewController: SaveActivityIndicator { }

// -----------------------------------------------------------------------------
// MARK: - SingleButtonAlertDialog

extension PetViewController: AlertDialog { }

// -----------------------------------------------------------------------------
// MARK: - ActionSheetDialog

extension PetViewController: ActionSheetDialog { }

// -----------------------------------------------------------------------------
// MARK: - UITextFieldDelegate

extension PetViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField

        switch textField {
        case birthdayTextField:
            activeTextField = birthdayTextField
            birthdayTextField.inputView = .customizedDatePickerView(setMinimumDate: nil, setDate: pet?.birthday ?? Date(), withTarget: self, action: #selector(handleDatePicker(_:)))
            textField.addDoneButtonToKeyboard(action: #selector(self.resignFirstResponder))
        case breedTextField:
            if dogBreeds.isEmpty || catBreeds.isEmpty {
                guard alertHasBeenDisplayed else {
                    alertHasBeenDisplayed = true
                    textField.resignFirstResponder()
                    showNetworkAlert()
                    return
                }
            } else {
                pickerView.reloadAllComponents()
                pickerView.backgroundColor = .white
                breedTextField.inputView = pickerView
                textField.addDoneButtonToKeyboard(action: #selector(self.resignFirstResponder))
            }
        case weightTextField,heightTextField:
            textField.addDoneButtonToKeyboard(action: #selector(self.resignFirstResponder))
            textField.text = ""
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

// -----------------------------------------------------------------------------
// MARK: - UIPickerViewDataSource, UIPickerViewDelegate

extension PetViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return typeControl.selectedSegmentIndex == 0 ? dogBreeds.count : catBreeds.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return typeControl.selectedSegmentIndex == 0 ? dogBreeds[row] : catBreeds[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if typeControl.selectedSegmentIndex == 0 {
            breedTextField.text = dogBreeds[row]
        } else {
            breedTextField.text = catBreeds[row]
        }
        saveButton.isEnabled = true
    }
}

// -----------------------------------------------------------------------------
// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension PetViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openImagePickerWith(sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            imagePicker.sourceType = sourceType
            present(imagePicker, animated: true, completion: nil)
        } else {
            let optionNotAvailableAlert = AlertInformation(
                title: "Warning",
                message: "\(sourceType.stringValue) Not Available",
                actions: [Action(buttonTitle: "OK", buttonStyle: .default, handler: nil)]
            )
            presentAlertDialog(with: optionNotAvailableAlert)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            photoImageView.image = image
            saveButton.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension UIImagePickerController.SourceType {
    var stringValue: String {
        switch self {
        case .photoLibrary:
            return "Photo Library"
        case .camera:
            return "Camera"
        default:
            return "Unidentified Source Type"
        }
    }
}
