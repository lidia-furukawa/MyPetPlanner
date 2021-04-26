//
//  Date+Extension.swift
//  MyPetPlanner
//
//  Created by Lidia on 05/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import Foundation

extension Date {
    
    var stringFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.string(from: self)
    }
    
    /// Calculate the next date after a specified value in days, weeks, months or years unit
    func calculateNextDate(after value: Int, unit: String,  using calendar: Calendar = .current) -> Date {
        var dateComponents = DateComponents()
        switch unit {
        case "Day":
            dateComponents = DateComponents(day: value)
        case "Week":
            dateComponents = DateComponents(weekOfMonth: value)
        case "Month":
            dateComponents = DateComponents(month: value)
        case "Year":
            dateComponents = DateComponents(year: value)
        default:
            fatalError("Unidentified Date Unit")
        }
        return calendar.date(byAdding: dateComponents, to: self)!
    }
}
