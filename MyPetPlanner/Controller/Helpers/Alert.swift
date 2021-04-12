//
//  Alert.swift
//  MyPetPlanner
//
//  Created by Lidia on 31/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

struct Action {
    let buttonTitle: String
    let handler: (() -> Void)?
}

struct SingleButtonAlertInformation {
    let title: String
    let message: String?
    let action: Action
}
