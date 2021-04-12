//
//  ActionSheetDialog.swift
//  MyPetPlanner
//
//  Created by Lidia on 12/04/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit

protocol ActionSheetDialog {
    func presentActionSheetDialog(with actions: [Action])
    
}

extension ActionSheetDialog where Self: UIViewController {
    func presentActionSheetDialog(with actions: [Action]) {
        let actionSheetDialog = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        for action in actions {
            actionSheetDialog.addAction(UIAlertAction(title: action.buttonTitle,
                                                style: .default,
                                                handler: { _ in action.handler?() }))
        }
        
        actionSheetDialog.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheetDialog, animated: true, completion: nil)
    }
}
