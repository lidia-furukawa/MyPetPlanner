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
        TableRow(sectionHeader: "Food", text: "Kibble or Dry Food", image: "Kibble or Dry Food", requiredInformation: "Brand:", informationPlaceholder: "Brand's Name"),
        TableRow(sectionHeader: "Food", text: "Fresh or Raw Food", image: "Fresh or Raw Food", requiredInformation: "Brand:", informationPlaceholder: "Brand's Name"),
        TableRow(sectionHeader: "Grooming", text: "Bathing", image: "Bathing", requiredInformation: "Groomer:", informationPlaceholder: "Groomer's Name/Place"),
        TableRow(sectionHeader: "Grooming", text: "Fur", image: "Fur", requiredInformation: "Groomer:", informationPlaceholder: "Groomer's Name/Place"),
        TableRow(sectionHeader: "Grooming", text: "Teeth", image: "Teeth", requiredInformation: "Groomer:", informationPlaceholder: "Groomer's Name/Place"),
        TableRow(sectionHeader: "Grooming", text: "Nails", image: "Nails", requiredInformation: "Groomer:", informationPlaceholder: "Groomer's Name/Place"),
        TableRow(sectionHeader: "Grooming", text: "Ears", image: "Ears", requiredInformation: "Groomer:", informationPlaceholder: "Groomer's Name/Place"),
        TableRow(sectionHeader: "Parasite Control", text: "Internal", image: "Internal", requiredInformation: "Treatment:", informationPlaceholder: "e.g. Heartworm Prevention"),
        TableRow(sectionHeader: "Parasite Control", text: "External", image: "External", requiredInformation: "Treatment:", informationPlaceholder: "e.g. Flea-Tick Spray"),
        TableRow(sectionHeader: "Veterinary Care", text: "Appointment", image: "Appointment", requiredInformation: "Reason:", informationPlaceholder: "e.g. Routine Checkup"),
        TableRow(sectionHeader: "Veterinary Care", text: "Vaccine", image: "Vaccine", requiredInformation: "Name/Type:", informationPlaceholder: "e.g. Rabies"),
        TableRow(sectionHeader: "Veterinary Care", text: "Medication", image: "Medication", requiredInformation: "Name/Type:", informationPlaceholder: "e.g. Anti-Inflammatory")
    ]
}
