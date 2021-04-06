//
//  UIView+Extension.swift
//  MyPetPlanner
//
//  Created by Lidia on 01/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit

extension UIView {
    
    func roundImage() {
        self.layer.masksToBounds = true
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = self.bounds.width/2
    }
    
    static func customizedDatePickerView(setDate date: Date, withTarget target: Any, action: Selector) -> UIDatePicker {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        datePickerView.backgroundColor = .white
        datePickerView.setDate(date, animated: false)
        datePickerView.addTarget(target, action: action, for: .valueChanged)

        return datePickerView
    }
}
