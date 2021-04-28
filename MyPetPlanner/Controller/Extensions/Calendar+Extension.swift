//
//  Calendar+Extension.swift
//  MyPetPlanner
//
//  Created by Lidia on 26/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import Foundation

extension Calendar {
    
    /// Calculate age in years or months
    public func calculateAgeIn(_ component: Calendar.Component, from birthday: Date) -> Int {
        let age = dateComponents([component], from: birthday, to: Date())
        switch component {
        case .year:
            return age.year ?? 0
        case .month:
            return age.month ?? 0
        default:
            fatalError("Age component should be in .year or .month")
        }
    }
    
    public func calculateAgeResidualMonths(from birthday: Date) -> Int {
        let residualMonths = calculateAgeIn(.month, from: birthday) % 12
        return residualMonths
    }
    
    /// Count the number of calendar component units (days, weeks, months or years) between two dates
    func countNumberOfComponents(between startDate: Date, and endDate: Date, in stringUnit: String) -> Int {
        let fromDate = startOfDay(for: startDate)
        let toDate = startOfDay(for: endDate)
        
        let numberOfComponents = dateComponents([stringUnit.calendarComponentFormat], from: fromDate, to: toDate)
        
        // Include the start date by adding another unit (+ 1) to the result
        return numberOfComponents.inDateComponentUnit(from: stringUnit)! + 1
    }
}
