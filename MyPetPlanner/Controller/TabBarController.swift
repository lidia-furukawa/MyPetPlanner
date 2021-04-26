//
//  TabBarController.swift
//  MyPetPlanner
//
//  Created by Lidia on 08/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit
import CoreData

class TabBarController: UITabBarController {
    
    var dataController: DataController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupChildViewControllers()
    }
    
    func setupChildViewControllers() {
        guard let viewControllers = viewControllers else {
            return
        }
        
        for viewController in viewControllers {
            var childViewController: UIViewController?
            
            // If the child view controller is embedded in a navigation controller, use first view controller of the navigation stack
            if let navigationController = viewController as? UINavigationController {
                childViewController = navigationController.viewControllers.first
            } else {
                childViewController = viewController
            }
            
            // Inject the dataController into its children
            switch childViewController {
            case let viewController as MyPetsViewController:
                viewController.dataController = dataController
            case let viewController as HealthViewController:
                viewController.dataController = dataController
            case let viewController as ExpensesViewController:
                viewController.dataController = dataController
            default:
                break
            }
        }
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
        if let vc = viewController as? UINavigationController {
            vc.popToRootViewController(animated: false)
        }
    }
}
