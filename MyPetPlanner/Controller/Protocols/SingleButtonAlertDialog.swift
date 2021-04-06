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
        let alertDialog = UIAlertController(title: alert.title,
                                                message: alert.message,
                                                preferredStyle: .alert)
        alertDialog.addAction(UIAlertAction(title: alert.action.buttonTitle,
                                                style: .default,
                                                handler: { _ in alert.action.handler?() }))
        self.present(alertDialog, animated: true, completion: nil)
    }
}
