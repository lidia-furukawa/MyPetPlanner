//
//  PetNotification.swift
//  MyPetPlanner
//
//  Created by Lidia on 08/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit

protocol PetNotification: class {
    var pet: Pet? { get set }
}

extension PetNotification where Self: UIViewController {
    
    func subscribeToPetNotification() {
        NotificationCenter.default.addObserver(forName: .petWasSelected, object: nil, queue: nil) { notification in
            self.petWasSelected(notification)
        }
    }
    
    func petWasSelected(_ notification: Notification) {
        if let selectedPet = notification.userInfo?["pet"] as? Pet {
            pet = selectedPet
        }
    }
    
    func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}
