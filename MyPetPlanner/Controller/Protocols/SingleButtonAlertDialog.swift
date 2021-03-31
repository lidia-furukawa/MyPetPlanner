//
//  SingleButtonAlertDialog.swift
//  MyPetPlanner
//
//  Created by Lidia on 31/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit

protocol SingleButtonAlertDialog {
    func presentSingleButtonDialog(with alert: SingleButtonAlertInformation)

}

extension SingleButtonAlertDialog where Self: UIViewController {
    func presentSingleButtonDialog(with alert: SingleButtonAlertInformation) {
        let alertController = UIAlertController(title: alert.title,
                                                message: alert.message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: alert.action.buttonTitle,
                                                style: .default,
                                                handler: { _ in alert.action.handler?() }))
        self.present(alertController, animated: true, completion: nil)
    }
}
