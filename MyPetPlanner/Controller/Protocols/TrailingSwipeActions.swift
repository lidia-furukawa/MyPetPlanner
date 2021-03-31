//
//  TrailingSwipeActions.swift
//  MyPetPlanner
//
//  Created by Lidia on 30/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit

protocol TrailingSwipeActions {
    func setEditAction(at indexPath: IndexPath)
    func setDeleteAction(at indexPath: IndexPath)
}

extension TrailingSwipeActions where Self: UIViewController {
    
    func configureSwipeActionsForRow(at indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editRowAction = UIContextualAction(style: .normal, title: "Edit", handler: { (action, view, completion) in
            self.setEditAction(at: indexPath)
            completion(true)
        })
        
        let deleteRowAction = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, completion) in
            // Delete confirmation dialog
            let alert = UIAlertController(title: "Are you sure you want to delete?", message: "This action cannot be undone", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                self.setDeleteAction(at: indexPath)
                completion(true)
            })
            
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)
            self.present(alert, animated: true, completion: nil)
        })
        
        editRowAction.backgroundColor = .green
        deleteRowAction.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [editRowAction, deleteRowAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}
