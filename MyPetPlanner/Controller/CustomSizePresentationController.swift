//
//  CustomSizePresentationController.swift
//  MyPetPlanner
//
//  Created by Lidia on 16/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit

class CustomSizePresentationController: UIPresentationController {
    
    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            guard let containerView = containerView else {
                return CGRect.zero
            }
            return CGRect(x: 0, y: 0, width: containerView.bounds.width, height: containerView.bounds.height/4)
        }
    }
    
    override func presentationTransitionWillBegin() {
        // Add opacity to the background view
        let backgroundView = UIView(frame: containerView!.bounds)
        backgroundView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        containerView?.addSubview(backgroundView)
        backgroundView.addSubview(presentedView!)
        
        // Add a tap press gesture recognizer in the background view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeView(_:)))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    /// Detect a tap touch and close the presented view
    @objc func closeView(_ sender: UITapGestureRecognizer) {
        let vc = presentedViewController
        vc.dismiss(animated: true, completion: nil)
    }
}
