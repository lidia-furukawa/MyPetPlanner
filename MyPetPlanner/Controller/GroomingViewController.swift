//
//  GroomingViewController.swift
//  MyPetPlanner
//
//  Created by Lidia on 19/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit

class GroomingViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var groomingImageView: UIImageView!
    @IBOutlet var groomingTextField: UITextField!
    @IBOutlet var frequencyTextField: UITextField!
    @IBOutlet var frequencyStepper: UIStepper!
    @IBOutlet var frequencyControl: UISegmentedControl!
    @IBOutlet var priceTextField: UITextField!
    @IBOutlet var expensesDateTextField: UITextField!
    @IBOutlet var expensesSwitch: UISwitch!
    @IBOutlet var startDateTextField: UITextField!
    @IBOutlet var endDateTextField: UITextField!
    @IBOutlet var calendarSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
