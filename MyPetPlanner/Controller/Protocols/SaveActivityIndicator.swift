//
//  SaveActivityIndicator.swift
//  MyPetPlanner
//
//  Created by Lidia on 24/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//
import UIKit

protocol SaveActivityIndicator {
    func presentActivityIndicator(_ isSaving: Bool, forButton button: UIBarButtonItem)
}

extension SaveActivityIndicator where Self: UIViewController {
    func presentActivityIndicator(_ isSaving: Bool, forButton button: UIBarButtonItem) {
        let savingView = UIView()
        savingView.frame = view.bounds
        savingView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        savingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = CGPoint(x: savingView.frame.size.width/2, y: savingView.frame.size.height/2)
        activityIndicator.style = .gray
        
        savingView.addSubview(activityIndicator)
        view.addSubview(savingView)
        
        isSaving ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        button.isEnabled = !isSaving
    }
}
