//
//  DateComponents+Extension.swift
//  MyPetPlanner
//
//  Created by Lidia on 23/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import Foundation

extension DateComponents {
    
    func inDateComponentUnit(from unit: String) -> Int? {
        switch unit {
        case "Day":
            return day
        case "Week":
            return weekOfMonth
        case "Month":
            return month
        case "Year":
            return year
        default:
            fatalError("Unidentified Date Component")
        }
    }
}
