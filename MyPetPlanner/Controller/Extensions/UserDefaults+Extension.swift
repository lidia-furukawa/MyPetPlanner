//
//  UserDefaults+Extension.swift
//  MyPetPlanner
//
//  Created by Lidia on 31/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import Foundation

extension UserDefaults {
    enum Keys {
        static let selectedIndexPath = "selectedIndexPath"
        static let sortKeyPath = "lastSortKey"
        static let sectionNameKeyPath = "lastSectionNameKey"
        static let expensesSortKeyPath = "expensesSortKey"
        static let startDateKey = "startDateKey"
        static let endDateKey = "endDateKey"
    }
}
