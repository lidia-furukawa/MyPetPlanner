//
//  AlertDialog.swift
//  MyPetPlanner
//
//  Created by Lidia on 31/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit

protocol AlertDialog {
    func presentAlertDialog(with alert: AlertInformation)

}

extension AlertDialog where Self: UIViewController {
    func presentAlertDialog(with alert: AlertInformation) {
        let alertDialog = UIAlertController(title: alert.title,
                                                message: alert.message,
                                                preferredStyle: .alert)
        for action in alert.actions {
            alertDialog.addAction(UIAlertAction(title: action.buttonTitle,
                                                style: action.buttonStyle,
                                                handler: { _ in action.handler?() }))
        }
        self.present(alertDialog, animated: true, completion: nil)
    }
}
