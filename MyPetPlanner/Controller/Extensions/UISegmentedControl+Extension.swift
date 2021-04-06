//
//  UISegmentedControl+Extension.swift
//  MyPetPlanner
//
//  Created by Lidia on 05/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit

extension UISegmentedControl {
    
    var selectedSegmentTitle: String? {
        let selectedTitle = self.selectedSegmentIndex
        return self.titleForSegment(at: selectedTitle)
    }
    
    func getSegmentedControlSelectedIndex(from attribute: String?) {
        switch attribute {
        case self.titleForSegment(at: 0):
            self.selectedSegmentIndex = 0
        default:
            self.selectedSegmentIndex = 1
        }
    }
}
