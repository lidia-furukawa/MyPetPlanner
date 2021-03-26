//
//  KeyboardNotifications.swift
//  MyPetPlanner
//
//  Created by Lidia on 26/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit

protocol KeyboardNotifications {
    /// Shift the scroll view's frame up
    func keyboardWillShow(_ notification: Notification)
    
    /// Move the scroll view back down
    func keyboardWillHide(_ notification: Notification)
}

extension KeyboardNotifications where Self: UIViewController {
    /// Sign up to be notified when a keyboard event is coming up
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { (notification) in
            self.keyboardWillShow(notification)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (notification) in
            self.keyboardWillHide(notification)
        }
    }

    /// Remove all the subscribed observers
    func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
}
