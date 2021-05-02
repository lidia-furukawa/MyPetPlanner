//
//  ActivityIndicator.swift
//  MyPetPlanner
//
//  Created by Lidia on 24/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//
import UIKit

protocol ActivityIndicator {
    func presentActivityIndicator(_ isPerformingTask: Bool)
}

extension ActivityIndicator where Self: UIViewController {    
    func presentActivityIndicator(_ isPerformingTask: Bool) {
        if isPerformingTask {
            let activityView = UIView()
            activityView.frame = view.bounds
            activityView.backgroundColor = .white
            activityView.alpha = 0.5
            activityView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            activityView.tag = 1000
            
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.style = .gray
            activityIndicator.center = CGPoint(x: activityView.frame.size.width/2, y: activityView.frame.size.height/2)
            activityIndicator.tag = 1001
            
            activityView.addSubview(activityIndicator)
            view.addSubview(activityView)
            activityIndicator.startAnimating()
        } else {
            guard let activityView = view.viewWithTag(1000), let activityIndicator = view.viewWithTag(1001) as? UIActivityIndicatorView else { return }
            activityIndicator.stopAnimating()
            activityView.alpha = 0.0
            activityView.removeFromSuperview()
        }
    }
}
