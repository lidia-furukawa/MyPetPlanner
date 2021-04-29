//
//  CalendarViewController.swift
//  MyPetPlanner
//
//  Created by Lidia on 02/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class CalendarViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    /// The pet posted by `MyPetsViewController` when a pet cell's selected
    var pet: Pet?
    var dataController: DataController!
    var petEventIdentifiers: [String]?
    let eventViewController = EKEventEditViewController()
    var eventStore = EKEventStore()
    let calendarKey = "MyPetPlanner"
    var events: [EKEvent]?
    var startDate: Date?
    var endDate: Date?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        subscribeToPetNotification()
    }
    
    deinit {
        unsubscribeFromNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Pet: \(pet?.name ?? "None")"
        loadLastDates()
        Healthcare.fetchAllEventIdentifiers(for: pet, context: dataController.viewContext) { eventIdentifiers in
            guard !eventIdentifiers.isEmpty else {
                self.petEventIdentifiers = nil
                return
            }
            self.petEventIdentifiers = eventIdentifiers
            self.checkAuthorizationStatus(for: .event)
        }
        subscribeToEventStoreNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromNotifications()
    }

    func initView() {
        eventViewController.editViewDelegate = self
        eventViewController.eventStore = eventStore
        setupRightBarButton()
        tableView.tableFooterView = UIView()
    }
    
    func setupRightBarButton() {
        let filterDateButton = UIBarButtonItem(image: UIImage(named: "date"), style: .plain, target: self, action: #selector(filterDateButton(_:)))
        navigationItem.rightBarButtonItem = filterDateButton
    }
    
    @objc func filterDateButton(_ sender: UIBarButtonItem) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "DateFilterViewController") as! DateFilterViewController
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        vc.isSaved = { [weak self] in
            self?.loadLastDates()
            self?.loadEvents()
        }
        present(vc, animated: true, completion: nil)
    }
    
    func loadLastDates() {
        if let lastStartDate = UserDefaults.standard.string(forKey: UserDefaults.Keys.startDateKey), let lastEndDate = UserDefaults.standard.string(forKey: UserDefaults.Keys.endDateKey) {
            startDate = lastStartDate.dateFormat
            endDate = lastEndDate.dateFormat
        }
    }
    
    func loadEvents() {
        guard let petEventIdentifiers = petEventIdentifiers else {
            events = nil
            return
        }
        if let calendar = EKCalendar.loadCalendar(type: .event, from: eventStore, with: calendarKey) {
            // Create and properly configure an events predicate
            let eventsPredicate = eventStore.predicateForEvents(withStart: startDate ?? Date(), end: endDate ?? Date(), calendars: [calendar])
            // Use the predicate to fetch events in the Event Store
            let predicateEvents = eventStore.events(matching: eventsPredicate)
            // Filter the fetched events using the pet's event identifiers
            events = predicateEvents.filter({
                petEventIdentifiers.contains($0.eventIdentifier)
            })
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            print("No matching calendar")
        }
    }
    
    func deleteEvent(at indexPath: IndexPath) {
        if let event = events?[indexPath.row] {
            do {
                try eventStore.remove(event, span: .futureEvents)
                events?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                fatalError("Error deleting the event")
            }
        }
    }
}

// -----------------------------------------------------------------------------
// MARK: - PetNotification

extension CalendarViewController: PetNotification { }

// -----------------------------------------------------------------------------
// MARK: - EventStoreAuthorization

extension CalendarViewController: CalendarAuthorization {
    func accessGranted() {
        loadEvents()
    }
}

// -----------------------------------------------------------------------------
// MARK: - EKEventEditViewDelegate

extension CalendarViewController: EKEventEditViewDelegate {
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: {
            self.tableView.reloadData()
        })
    }
}

// -----------------------------------------------------------------------------
// MARK: - EventStore Notifications

extension CalendarViewController {
    /// Sign up to be notified when a change is made to the Event Store
    func subscribeToEventStoreNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged(_:)), name: .EKEventStoreChanged, object: eventStore)
    }
    
    /// Reload all events as they are considered stale
    @objc func storeChanged(_ notification:Notification) {
        loadEvents()
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
        if let event = events?[indexPath.row] {
            eventViewController.event = event
            present(eventViewController, animated: true, completion: nil)
        }
    }
    
    func setDeleteAction(at indexPath: IndexPath) {
        deleteEvent(at: indexPath)
    }
}

// -----------------------------------------------------------------------------
// MARK: - UITableViewDataSource, UITableViewDelegate

extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryType = .disclosureIndicator
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell")!
        
        if let event = events?[indexPath.row] {
            cell.textLabel?.text = event.notes ?? "No Notes"
            let startDate = event.startDate.stringFormat
            let endDate = event.endDate.stringFormat
            cell.detailTextLabel?.text = "From: \(startDate) to: \(endDate)"
            let eventImage = UIImage(named: event.title)
            let templateImage = eventImage?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.image = templateImage
        } else {
            cell.textLabel?.text = "Unknown Event"
            cell.detailTextLabel?.text = "Unknown Dates"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setEditAction(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return configureSwipeActionsForRow(at: indexPath)
    }
}

// -----------------------------------------------------------------------------
// MARK: - UIViewControllerTransitioningDelegate

extension CalendarViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
}
