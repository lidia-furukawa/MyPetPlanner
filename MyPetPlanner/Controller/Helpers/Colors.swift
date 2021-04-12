//
//  Colors.swift
//  MyPetPlanner
//
//  Created by Lidia on 05/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit

extension UIColor {
    static let tintColor = #colorLiteral(red: 0.6509035826, green: 0.2576052547, blue: 0.8440084457, alpha: 1)
    static let backgroundColor = #colorLiteral(red: 0.8941176471, green: 0.7176470588, blue: 0.8980392157, alpha: 1)
    static var randomColor: UIColor {
        let red = Double(arc4random_uniform(256))
        let green = Double(arc4random_uniform(256))
        let blue = Double(arc4random_uniform(256))
        return UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
    }
}
