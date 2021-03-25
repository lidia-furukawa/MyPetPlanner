//
//  TabBarController.swift
//  MyPetPlanner
//
//  Created by Lidia on 25/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the tab bar colors
        self.tabBar.tintColor = tintColor
    }
}
