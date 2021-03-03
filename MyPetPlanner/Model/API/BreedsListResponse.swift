//
//  BreedsListResponse.swift
//  MyPetPlanner
//
//  Created by Lidia on 03/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import Foundation

struct BreedsListResponse: Codable {
    let status: String
    let message: [String: [String]]
}
