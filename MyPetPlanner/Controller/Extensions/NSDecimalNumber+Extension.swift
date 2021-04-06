//
//  NSDecimalNumber+Extension.swift
//  MyPetPlanner
//
//  Created by Lidia on 05/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import Foundation

extension NSDecimalNumber {
    
    var stringFormat: String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.generatesDecimalNumbers = true
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: self)
    }
    
}
