//
//  UIViewController+Extension.swift
//  MyPetPlanner
//
//  Created by Lidia on 24/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit

extension UIViewController {
    
    private struct ControlsColors {
        static var tintColor = #colorLiteral(red: 0.6509035826, green: 0.2576052547, blue: 0.8440084457, alpha: 1)
        static var backgroundColor = #colorLiteral(red: 0.8941176471, green: 0.7176470588, blue: 0.8980392157, alpha: 1)
    }
    
    var tintColor: UIColor! {
        get {
            guard let tintColor = objc_getAssociatedObject(self, &ControlsColors.tintColor) as? UIColor else {
                return UIColor()
            }
            return tintColor
        }
    }
    
    var backgroundColor: UIColor! {
        get {
            guard let backgroundColor = objc_getAssociatedObject(self, &ControlsColors.backgroundColor) as? UIColor else {
                return UIColor()
            }
            return backgroundColor
        }
    }

}
