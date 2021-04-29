//
//  String+Extension.swift
//  MyPetPlanner
//
//  Created by Lidia on 05/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import Foundation

extension String {
    
    var dateFormat: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.date(from: self)!
    }
    
    var doubleFormat: Double? {
        let numberFormatter = NumberFormatter()
        return numberFormatter.number(from: self)?.doubleValue
    }
    
    var calendarComponentFormat: Calendar.Component {
        switch self {
        case "Day":
            return .day
        case "Week":
            return .weekOfMonth
        case "Month":
            return .month
        case "Year":
            return .year
        default:
            fatalError("Unidentified Date Component")
        }
    }
}
