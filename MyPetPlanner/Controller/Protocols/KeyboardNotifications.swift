//
//  KeyboardNotifications.swift
//  MyPetPlanner
//
//  Created by Lidia on 26/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit

protocol KeyboardNotifications {
    var scrollView: UIScrollView! { get }
    var activeTextField: UITextField { get }
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
    
    /// Shift the scroll view's frame up
    func keyboardWillShow(_ notification:Notification) {
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: getKeyboardHeight(notification), right: 0.0)
        setScrollViewInsets(scrollView, contentInsets)
        
        // If the active text field is hidden by keyboard, scroll it so it's visible
        var aRect = self.view.frame
        aRect.size.height = -getKeyboardHeight(notification)
        if !aRect.contains(activeTextField.frame.origin) {
            scrollView.scrollRectToVisible(activeTextField.frame, animated: true)
        }
    }
    
    /// Move the scroll view back down
    func keyboardWillHide(_ notification:Notification) {
        let contentInsets = UIEdgeInsets.zero
        setScrollViewInsets(scrollView, contentInsets)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func setScrollViewInsets(_ scrollView: UIScrollView, _ contentInsets: UIEdgeInsets) {
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
}
