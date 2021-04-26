<<<<<<< HEAD
//
//  Double+Extension.swift
//  MyPetPlanner
//
//  Created by Lidia on 26/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import Foundation

extension Double {
    
    var stringFormat: String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = .current
        numberFormatter.numberStyle = .currency
        return numberFormatter.string(from: self as NSNumber)
    }
}
||||||| merged common ancestors
=======
//
//  File.swift
//  MyPetPlanner
//
//  Created by Lidia on 26/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import Foundation
>>>>>>> c82e62ba2e36889a608ea1a4cd2ce6875767daa3
