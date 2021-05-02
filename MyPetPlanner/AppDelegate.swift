//
//  AppDelegate.swift
//  MyPetPlanner
//
//  Created by Lidia on 12/02/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dataController = DataController(modelName: "MyPetPlanner")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        dataController.load()
        
        /// Inject data controller dependency into the TabBarController
        let tabBarController = window?.rootViewController as! TabBarController
        tabBarController.dataController = dataController
        
        self.window?.tintColor = UIColor.tintColor

        return true
    }
}

