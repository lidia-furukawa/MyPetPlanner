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

    let eventStore = EKEventStore()
    var reminders: [EKReminder]?
    let calendarKey = "MyPetPlanner"

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        checkAuthorizationStatus(for: .reminder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkAuthorizationStatus(for: .reminder)
    }
    
    func checkAuthorizationStatus(for type: EKEntityType) {
        let status = EKEventStore.authorizationStatus(for: type)
        
        switch status {
        case EKAuthorizationStatus.notDetermined:
            requestAccess(type)
        case EKAuthorizationStatus.authorized:
            loadEntity(type)
            tableView.reloadData()
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            showPermissionAlert()
        @unknown default:
            fatalError()
        }
    }
    
    func requestAccess(_ type: EKEntityType) {
        eventStore.requestAccess(to: type, completion: {(accessGranted: Bool, error: Error?) in
            if accessGranted == true {
                DispatchQueue.main.async(execute: {
                    self.loadEntity(type)
                    self.tableView.reloadData()
                })
            } else {
                DispatchQueue.main.async(execute: {
                    self.showPermissionAlert()
                })
            }
        })
    }
    
    func showPermissionAlert() {
        let alert = UIAlertController(title: "\"MyPetPlanner\" is not allowed to access Reminders", message: "Allow permission in Settings and try again", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func loadEntity(_ type: EKEntityType) {
        // Use an Event Store instance to create and properly configure an NSPredicate
        if let calendar = loadCalendar(.reminder) {
            let remindersPredicate = eventStore.predicateForReminders(in: [calendar])
            
            switch type {
            case .reminder:
                // Use the NSPredicate to fetch reminders in the Event Store
                eventStore.fetchReminders(matching: remindersPredicate, completion: { (reminders: [EKReminder]?) -> Void in
                    self.reminders = reminders
                })
            default:
                fatalError()
            }
        } else {
            print("No reminders to show")
        }
    }
    
    func loadCalendar(_ type: EKEntityType) -> EKCalendar? {
        // Access all available reminder calendars from the Event Store
        let allCalendars = eventStore.calendars(for: type)
        
        // Filter the available calendars to return the one that matches the retrieved identifier from UserDefaults
        if let retrievedIdentifier = UserDefaults.standard.object(forKey: self.calendarKey) {
            return allCalendars.filter {
                (calendar: EKCalendar) -> Bool in
                calendar.calendarIdentifier == retrievedIdentifier as! String
                }.first!
        } else {
            return nil
        }
    }
}

extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let reminders = self.reminders {
            return reminders.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell")!
        
        if let reminders = self.reminders {
            let reminder = reminders[indexPath.row]
            cell.textLabel?.text = reminder.title
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dueDate = reminder.dueDateComponents?.date
            cell.detailTextLabel?.text = dateFormatter.string(from: dueDate!)
        } else {
            cell.textLabel?.text = "Unknown Reminder"
            cell.detailTextLabel?.text = "Unknown Due Date"
        }
        return cell
    }
    
}
