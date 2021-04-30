//
//  UITextField+Extension.swift
//  MyPetPlanner
//
//  Created by Lidia on 29/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit

extension UITextField {
    
    func addDoneButtonToKeyboard(action: Selector?) {
        let keyboardToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        keyboardToolbar.barStyle = .default
        keyboardToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: action)
        ]
        keyboardToolbar.sizeToFit()
        self.inputAccessoryView = keyboardToolbar
    }
}
