//
//  Alert.swift
//  MyPetPlanner
//
//  Created by Lidia on 31/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit

struct Action {
    let buttonTitle: String
    let buttonStyle: UIAlertAction.Style
    let handler: (() -> Void)?
}

struct AlertInformation {
    let title: String
    let message: String?
    let actions: [Action]
}
