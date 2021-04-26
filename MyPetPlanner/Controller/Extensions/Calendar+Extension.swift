//
//  Calendar+Extension.swift
//  MyPetPlanner
//
//  Created by Lidia on 26/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import Foundation

extension Calendar {
    
    /// Count the number of calendar component units (days, weeks, months or years) between two dates
    func countNumberOfComponents(between startDate: Date, and endDate: Date, in stringUnit: String) -> Int {
        let fromDate = startOfDay(for: startDate)
        let toDate = startOfDay(for: endDate)
        
        let numberOfComponents = dateComponents([stringUnit.calendarComponentFormat], from: fromDate, to: toDate)
        
        // Include the start date by adding another unit (+ 1) to the result
        return numberOfComponents.inDateComponentUnit(from: stringUnit)! + 1
    }
}
