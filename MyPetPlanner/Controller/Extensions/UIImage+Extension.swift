//
//  UIImage+Extension.swift
//  MyPetPlanner
//
//  Created by Lidia on 29/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit

extension UIImage {
    
    var templateImage: UIImage {
        return self.withRenderingMode(.alwaysTemplate)
    }
}
