//
//  EKRSReminderStore.swift
//  EKTimedReminders
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/15.
//
//
/*

 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 EKRSReminderStore allows you to add, fetch, and remove upcoming, past-due, incomplete, and completed reminders
         using the EventKit framework. It checks and requests access to the Reminders application and observes changes
         using EKEventStoreChangedNotification. It also shows how to mark reminders as completed. EKRSReminderStore uses
         the default calendar for reminders.

 */
import UIKit
import EventKit

@objc(EKRSReminderStore)
class EKRSReminderStore: NSObject {
    var eventStore: EKEventStore
    var calendar: EKCalendar?
    // Specifies the type of calendar being created
    var calendarName: String?
    
    // Error encountered while saving or removing a reminder
    var errorMessage: String?
    
    // Keep track of all past-due reminders
    var pastDueReminders: [EKReminder] = []
    // Keep track of all upcoming reminders
    var upcomingReminders: [EKReminder] = []
    // Keep track of all completed reminders
    var completedReminders: [EKReminder] = []
    // Keep track of location reminders
    var locationReminders: [EKReminder] = []
    
    
    
    override init() {
        eventStore = EKEventStore()
        
        super.init()
        NotificationCenter.default.addObserver(self,
            selector: #selector(storeChanged(_:)),
            name: NSNotification.Name.EKEventStoreChanged,
            object: eventStore)
    }
    
    
    //MARK: - Reminders Access Methods
    
    // Check whether application has access to the Reminders application
    // Check the authorization status of our application for Reminders
    func checkEventStoreAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        
        switch status {
        case .authorized:
            self.accessGrantedForReminders()
        case .notDetermined:
            self.requestEventStoreAccessForReminders()
        case .denied, .restricted:
            self.accessDeniedForReminders()
        @unknown default:
            break
        }
    }
    
    
    // Prompt the user for access to their Reminders app
    private func requestEventStoreAccessForReminders() {
        self.eventStore.requestAccess(to: .reminder) {granted, error in
            if granted {
                self.accessGrantedForReminders()
            } else {
                self.accessDeniedForReminders()
            }
        }
        
    }
    
    
    // Called when the user has granted access to Reminders
    private func accessGrantedForReminders() {
        // EKRSReminderStore uses the default calendar for reminders
        self.calendar = self.eventStore.defaultCalendarForNewReminders()
        
        // Notifies the listener that access was granted to Reminders
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(EKRSAccessGrantedNotification), object: self)
        }
    }
    
    
    // Called when the user has denied or restricted access to Reminders
    private func accessDeniedForReminders() {
        // Notifies the listener that access was denied to Reminders
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(EKRSAccessDeniedNotification), object: self)
        }
    }
    
    
    
    //MARK: - Handle EKEventStoreChangedNotification
    
    @objc func storeChanged(_ notification: Notification) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(EKRSRefreshDataNotification), object: self)
        }
    }
    
    
    //MARK: - Filter Reminders
    
    // Return incomplete location reminders
    private func predicateForLocationReminders(_ reminders: [EKReminder]) -> [EKReminder] {
        return reminders.filter{reminder->Bool in
            var hasLocationAlarm = false
            
            for alarm in reminder.alarms ?? [] {
                if !reminder.isCompleted && alarm.structuredLocation != nil && (alarm.proximity == .leave || alarm.proximity == .enter) {
                    hasLocationAlarm = true
                    break
                }
            }
            return hasLocationAlarm
        }
    }
    
    
    //MARK: - Fetch Past-Due Reminders
    
    // Fetch all incomplete reminders ending now
    // Fetch all past-due reminders
    func fetchPastDueRemindersWithDateStarting(_ startDate: Date) {
        // Predicate to fetch all incomplete reminders ending now in the calendar
        let predicate = self.eventStore.predicateForIncompleteReminders(withDueDateStarting: startDate,
            ending: Date(),
            calendars: [self.calendar!])
        // Fetch reminders matching the above predicate
        self.eventStore.fetchReminders(matching: predicate) {reminders in
            self.pastDueReminders = reminders ?? []
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(EKRSPastDueRemindersNotification), object: self)
            }
        }
    }
    
    
    
    //MARK: - Fetch Upcoming Reminders
    
    // Fetch all incomplete reminders starting now and ending later
    // Fetch all upcoming reminders
    func fetchUpcomingRemindersWithDueDate(_ endDate: Date) {
        // Predicate to fetch all incomplete reminders starting now and ending on endDate
        let predicate = self.eventStore.predicateForIncompleteReminders(withDueDateStarting: Date(),
            ending: endDate,
            calendars: [self.calendar!])
        // Fetch reminders matching the above predicate
        self.eventStore.fetchReminders(matching: predicate) {reminders in
            self.upcomingReminders = reminders ?? []
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(EKRSUpcomingRemindersNotification), object: self)
            }
        }
    }
    
    
    //MARK: - Fetch Completed Reminders
    
    // Fetch all completed reminders, which start and end within a given period
    // Fetch all completed reminders within a period
    func fetchCompletedRemindersWithDueDateStarting(_ startDate: Date, ending endDate: Date) {
        // Predicate to fetch all completed reminders falling within startDate and endDate in calendar
        let predicate = self.eventStore.predicateForCompletedReminders(withCompletionDateStarting: startDate,
            ending: endDate,
            calendars: [self.calendar!])
        // Fetch reminders matching the above predicate
        self.eventStore.fetchReminders(matching: predicate) {reminders in
            self.completedReminders = reminders ?? []
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(EKRSCompletedRemindersNotification), object: self)
            }
        }
    }
    
    
    //MARK: - Fetch Location Reminders
    
    // Fetch all location reminders
    // Fetch all reminders, then use predicateForLocationReminders: to filter the result for incomplete location-based reminders
    func fetchLocationReminders() {
        // Fetch all reminders available in calendar
        let predicate = self.eventStore.predicateForReminders(in: [self.calendar!])
        
        self.eventStore.fetchReminders(matching: predicate) {reminders in
            // Filter the reminders for location ones
            self.locationReminders = self.predicateForLocationReminders(reminders ?? [])
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(EKRSLocationRemindersNotification), object: self)
            }
        }
    }
    
    
    //MARK: - Mark Reminder as Completed
    
    // Mark reminder as completed
    // Use the completed property to mark a reminder as completed
    func complete(_ reminder: EKReminder) {
        reminder.isCompleted = true
        // Update the reminder
        self.save(reminder)
    }
    
    
    //MARK: - Save Reminder
    
    // Save reminder
    // Save the reminder to the event store
    func save(_ reminder: EKReminder) {
        do {
            try self.eventStore.save(reminder, commit: true)
            // Notifies the listener that the operation was successful
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(EKRSRefreshDataNotification), object: self)
            }
        } catch let error as NSError {
            // Keep track of the error message encountered
            self.errorMessage = error.localizedDescription
            // Notifies the listener that the operation failed
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(EKRSFailureNotification), object: self)
            }
        }
    }
    
    
    //MARK: - Remove Reminder
    
    // Delete reminder
    // Remove reminder from the event store
    func remove(_ reminder: EKReminder) {
        do {
            try self.eventStore.remove(reminder, commit: true)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(EKRSRefreshDataNotification), object: self)
            }
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(EKRSFailureNotification), object: self)
            }
        }
    }
    
    
    //MARK: - Memory Management
    
    deinit {
        NotificationCenter.default.removeObserver(self,
            name: NSNotification.Name.EKEventStoreChanged,
            object: nil)
    }
}
