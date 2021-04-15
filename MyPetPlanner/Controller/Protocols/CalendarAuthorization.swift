//
//  CalendarAuthorization.swift
//  MyPetPlanner
//
//  Created by Lidia on 30/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import EventKit
import UIKit

protocol CalendarAuthorization: AlertDialog {
    var eventStore: EKEventStore { get }
    func accessGranted()
}

extension CalendarAuthorization where Self: UIViewController {
    
    func checkAuthorizationStatus(for type: EKEntityType) {
        let status = EKEventStore.authorizationStatus(for: type)
        
        switch status {
        case EKAuthorizationStatus.notDetermined:
            print("First run")
            requestAccess(to: type)
        case EKAuthorizationStatus.authorized:
            print("Access granted")
            accessGranted()
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            print("Access denied")
            showPermissionAlert(to: type)
        @unknown default:
            fatalError()
        }
    }
    
    func requestAccess(to type: EKEntityType) {
        eventStore.requestAccess(to: type, completion: { granted, error in
            if granted == true {
                DispatchQueue.main.async{
                    self.accessGranted()
                }
            } else {
                DispatchQueue.main.async(execute: {
                    self.showPermissionAlert(to: type)
                })
            }
        })
    }
    
    func showPermissionAlert(to type: EKEntityType) {
        let permissionAlert = AlertInformation(
            title: "\"MyPetPlanner\" is not allowed to access \(type.rawValue)",
            message: "Allow permission in Settings and try again",
            actions: [Action(buttonTitle: "OK", buttonStyle: .default, handler: nil)]
        )
        presentAlertDialog(with: permissionAlert)
    }
}
