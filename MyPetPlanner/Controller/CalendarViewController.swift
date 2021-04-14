//
//  CalendarViewController.swift
//  MyPetPlanner
//
//  Created by Lidia on 02/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit
import EventKit

class CalendarViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var eventStore = EKEventStore()
    var reminders: [EKReminder]?
    let calendarKey = "MyPetPlanner"
    var selectedReminder: EKReminder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        checkAuthorizationStatus(for: .reminder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkAuthorizationStatus(for: .reminder)
        subscribeToEventStoreNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromNotifications()
    }

    func initView() {
        navigationItem.title = "My Pets Reminders"
        tableView.tableFooterView = UIView()
    }
    
    func loadEntity(_ type: EKEntityType) {
        // Use an Event Store instance to create and properly configure an NSPredicate
        if let calendar = EKCalendar.loadCalendar(type: .reminder, from: eventStore, with: calendarKey) {
            let remindersPredicate = eventStore.predicateForReminders(in: [calendar])
            
            switch type {
            case .reminder:
                // Use the NSPredicate to fetch reminders in the Event Store
                eventStore.fetchReminders(matching: remindersPredicate, completion: { (reminders: [EKReminder]?) -> Void in
                    self.reminders = reminders
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
            default:
                fatalError()
            }
        } else {
            print("No reminders to show")
        }
    }
    
    func deleteReminder(at indexPath: IndexPath) {
        if let reminder = reminders?[indexPath.row] {
            do {
                try self.eventStore.remove(reminder, commit: true)
                self.reminders?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                fatalError("Error deleting the reminder")
            }
        }
    }
}

// -----------------------------------------------------------------------------
// MARK: - EventStoreAuthorization

extension CalendarViewController: CalendarReminderAuthorization {
    func accessGranted() {
        loadEntity(.reminder)
    }
}

// -----------------------------------------------------------------------------
// MARK: - EventStore Notifications

extension CalendarViewController {
    /// Sign up to be notified when a change is made to the Event Store
    func subscribeToEventStoreNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged(_:)), name: .EKEventStoreChanged, object: eventStore)
    }
    
    /// Reload all reminders as they are considered stale
    @objc func storeChanged(_ notification:Notification) {
        loadEntity(.reminder)
    }
    
    /// Remove all the subscribed observers
    func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}

// -----------------------------------------------------------------------------
// MARK: - TrailingSwipeActions

extension CalendarViewController: TrailingSwipeActions {
    func setEditAction(at indexPath: IndexPath) {
        //TO DO
    }
    
    func setDeleteAction(at indexPath: IndexPath) {
        let deleteAlert = AlertInformation(
            title: "Are you sure you want to delete this reminder?",
            message: "This action cannot be undone",
            actions: [
                Action(buttonTitle: "Cancel", buttonStyle: .cancel, handler: nil),
                Action(buttonTitle: "Delete", buttonStyle: .destructive, handler: {
                    self.deleteReminder(at: indexPath)
                })
            ]
        )
        presentAlertDialog(with: deleteAlert)
    }
}

// -----------------------------------------------------------------------------
// MARK: - UITableViewDataSource, UITableViewDelegate

extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell")!
        
        if let reminder = reminders?[indexPath.row] {
            cell.textLabel?.text = reminder.notes
            let dueDate = reminder.dueDateComponents?.date
            cell.detailTextLabel?.text = "Due date: \(dueDate?.stringFormat ?? "")"
            let reminderImage = UIImage(named: reminder.title)
            let templateImage = reminderImage?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.image = templateImage
        } else {
            cell.textLabel?.text = "Unknown Reminder"
            cell.detailTextLabel?.text = "Unknown Due Date"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return configureSwipeActionsForRow(at: indexPath)
    }
}
