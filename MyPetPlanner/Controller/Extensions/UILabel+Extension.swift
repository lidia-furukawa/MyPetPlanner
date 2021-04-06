//
//  UILabel+Extension.swift
//  MyPetPlanner
//
//  Created by Lidia on 24/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit

extension UILabel {
    
    func configureTitle() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 3
        self.backgroundColor = UIColor.backgroundColor
        self.textColor = UIColor.white
    }
}
