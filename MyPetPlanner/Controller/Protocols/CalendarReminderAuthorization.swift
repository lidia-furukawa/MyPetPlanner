//
//  CalendarReminderAuthorization.swift
//  MyPetPlanner
//
//  Created by Lidia on 30/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import EventKit
import UIKit

protocol CalendarReminderAuthorization {
    var eventStore: EKEventStore { get }
    func accessGranted()
}

extension CalendarReminderAuthorization where Self: UIViewController {
    
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
            showPermissionAlert()
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
                    self.showPermissionAlert()
                })
            }
        })
    }
    
    func showPermissionAlert() {
        let alert = UIAlertController(title: "\"MyPetPlanner\" is not allowed to access Reminders", message: "Allow permission in Settings and try again", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}