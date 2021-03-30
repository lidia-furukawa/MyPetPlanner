//
//  EKCalendar+Extension.swift
//  MyPetPlanner
//
//  Created by Lidia on 29/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import EventKit

extension EKCalendar {
    
    public static func loadCalendar(type: EKEntityType, from eventStore: EKEventStore, with calendarKey: String) -> EKCalendar? {
        // Access all available reminder calendars from the Event Store
        let allCalendars = eventStore.calendars(for: type)
        
        // Filter the available calendars to return the one that matches the retrieved identifier from UserDefaults
        if let retrievedIdentifier = UserDefaults.standard.object(forKey: calendarKey) {
            print("Calendar retrieved from UserDefaults")
            return allCalendars.filter {
                (calendar: EKCalendar) -> Bool in
                calendar.calendarIdentifier == retrievedIdentifier as! String
                }.first!
        } else {
            print("Create new calendar")
            return createNewCalendar(type: type, from: eventStore, with: calendarKey)
        }
    }
    
    public static func createNewCalendar(type: EKEntityType, from eventStore: EKEventStore, with calendarKey: String) -> EKCalendar? {
        // Use the Event Store to create a new calendar instance
        let newCalendar = EKCalendar(for: type, eventStore: eventStore)
        newCalendar.title = calendarKey
        
        // Access all available sources from the Event Store
        let sourcesInEventStore = eventStore.sources
        
        // Filter the available sources and return the one that matches .local
        newCalendar.source = sourcesInEventStore.filter {
            (source: EKSource) -> Bool in
            source.sourceType.rawValue == EKSourceType.local.rawValue
            }.first!
        
        // Save the new calendar
        do {
            try eventStore.saveCalendar(newCalendar, commit: true)
            UserDefaults.standard.set(newCalendar.calendarIdentifier, forKey: calendarKey)
            return newCalendar
        } catch {
            fatalError("Error saving the calendar")
        }
    }
}
