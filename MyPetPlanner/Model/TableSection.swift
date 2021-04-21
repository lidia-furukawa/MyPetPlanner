//
//  TableSection.swift
//  MyPetPlanner
//
//  Created by Lidia on 26/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import Foundation
import UIKit

struct TableSection {
    
    var title: String
    var rows: [TableRow]
    
    static func group(rows: [TableRow]) -> [TableSection] {
        let groups = Dictionary(grouping: rows) { row in
            row.sectionHeader
        }
        return groups.map(TableSection.init(title:rows:))
    }
}

extension TableSection {

    static var healthSections: [TableSection] {

        var healthSectionArray = [TableSection]()

        healthSectionArray = TableSection.group(rows: localHealthSectionData)
        // Sort the section titles in alphabetical order
        healthSectionArray.sort { lhs, rhs in lhs.title < rhs.title }
        
        return healthSectionArray
    }

    static var localHealthSectionData: [TableRow] = [
        TableRow(sectionHeader: "Food", text: "Kibble or Dry Food", image: "Kibble or Dry Food"),
        TableRow(sectionHeader: "Food", text: "Fresh or Raw Food", image: "Fresh or Raw Food"),
        TableRow(sectionHeader: "Grooming", text: "Bathing", image: "Bathing"),
        TableRow(sectionHeader: "Grooming", text: "Fur", image: "Fur"),
        TableRow(sectionHeader: "Grooming", text: "Teeth", image: "Teeth"),
        TableRow(sectionHeader: "Grooming", text: "Nails", image: "Nails"),
        TableRow(sectionHeader: "Grooming", text: "Ears", image: "Ears"),
        TableRow(sectionHeader: "Parasite Control", text: "Internal", image: "Internal"),
        TableRow(sectionHeader: "Parasite Control", text: "External", image: "External"),
        TableRow(sectionHeader: "Veterinary Care", text: "Appointment", image: "Appointment"),
        TableRow(sectionHeader: "Veterinary Care", text: "Vaccine", image: "Vaccine"),
        TableRow(sectionHeader: "Veterinary Care", text: "Medication", image: "Medication")
    ]
}
