//
//  HealthcareCategory.swift
//  MyPetPlanner
//
//  Created by Lidia on 26/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit

struct HealthcareCategory {
    
    var title: String
    var subcategories: [HealthcareSubcategory]
    
    static func group(subcategories: [HealthcareSubcategory]) -> [HealthcareCategory] {
        let groups = Dictionary(grouping: subcategories) { subcategory in
            subcategory.category
        }
        return groups.map(HealthcareCategory.init(title:subcategories:))
    }
}

extension HealthcareCategory {

    static var healthSections: [HealthcareCategory] {

        var healthSectionArray = [HealthcareCategory]()

        healthSectionArray = HealthcareCategory.group(subcategories: localHealthcareSubcategoryData)
        // Sort the section titles in alphabetical order
        healthSectionArray.sort { lhs, rhs in lhs.title < rhs.title }
        
        return healthSectionArray
    }

    static var localHealthcareSubcategoryData: [HealthcareSubcategory] = [
        HealthcareSubcategory(category: "Food", subcategory: "Kibble or Dry Food", image: "Kibble or Dry Food", requiredInformation: "Brand:", informationPlaceholder: "Brand's Name"),
        HealthcareSubcategory(category: "Food", subcategory: "Fresh or Raw Food", image: "Fresh or Raw Food", requiredInformation: "Brand:", informationPlaceholder: "Brand's Name"),
        HealthcareSubcategory(category: "Grooming", subcategory: "Bathing", image: "Bathing", requiredInformation: "Groomer:", informationPlaceholder: "Name/Place"),
        HealthcareSubcategory(category: "Grooming", subcategory: "Fur", image: "Fur", requiredInformation: "Groomer:", informationPlaceholder: "Name/Place"),
        HealthcareSubcategory(category: "Grooming", subcategory: "Teeth", image: "Teeth", requiredInformation: "Groomer:", informationPlaceholder: "Name/Place"),
        HealthcareSubcategory(category: "Grooming", subcategory: "Nails", image: "Nails", requiredInformation: "Groomer:", informationPlaceholder: "Name/Place"),
        HealthcareSubcategory(category: "Grooming", subcategory: "Ears", image: "Ears", requiredInformation: "Groomer:", informationPlaceholder: "Name/Place"),
        HealthcareSubcategory(category: "Parasite Control", subcategory: "Internal", image: "Internal", requiredInformation: "Treatment:", informationPlaceholder: "e.g. Heartworm Prevention"),
        HealthcareSubcategory(category: "Parasite Control", subcategory: "External", image: "External", requiredInformation: "Treatment:", informationPlaceholder: "e.g. Flea-Tick Spray"),
        HealthcareSubcategory(category: "Veterinary Care", subcategory: "Appointment", image: "Appointment", requiredInformation: "Reason:", informationPlaceholder: "e.g. Routine Checkup"),
        HealthcareSubcategory(category: "Veterinary Care", subcategory: "Vaccine", image: "Vaccine", requiredInformation: "Name/Type:", informationPlaceholder: "e.g. Rabies"),
        HealthcareSubcategory(category: "Veterinary Care", subcategory: "Medication", image: "Medication", requiredInformation: "Name/Type:", informationPlaceholder: "e.g. Anti-Inflammatory")
    ]
}
