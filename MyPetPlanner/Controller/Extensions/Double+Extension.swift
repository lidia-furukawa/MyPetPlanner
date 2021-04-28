//
//  Double+Extension.swift
//  MyPetPlanner
//
//  Created by Lidia on 26/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import Foundation

extension Double {
    
    var stringFormat: String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.generatesDecimalNumbers = true
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self))
    }
    
    var stringCurrencyFormat: String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = .current
        numberFormatter.numberStyle = .currency
        return numberFormatter.string(from: self as NSNumber)
    }
}
