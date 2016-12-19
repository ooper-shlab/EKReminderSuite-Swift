//
//  TimedTabBarController.swift
//  EKTimedReminders
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/15.
//
//
/*

 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This view controller manages the child view controllers: CompletedReminders, PastDueReminders and UpcomingReminders.
         It calls TimedReminderStore to check access to the Reminders application. It listens and handles TimedReminderStore notifications.
         It calls TimedReminderStore to fetch upcoming, past-due, and completed reminders. It notifies the UpcomingReminders, PastDueReminders,
         and CompletedReminders view controllers upon receiving their associated data.

 */
import UIKit
import EventKit

@objc(TimedTabBarController)
class TimedTabBarController: UITabBarController {
    
    
    var rsObservers: [AnyObject] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mainQueue = OperationQueue.main
        let center = NotificationCenter.default
        
        // Register for TimedReminderStore notifications
        let accessGranted = center.addObserver(forName: NSNotification.Name(EKRSAccessGrantedNotification),
            object: TimedReminderStore.shared,
            queue: mainQueue
            ) {[weak self] note in
                self?.handleRSAccessGrantedNotification(note)
        }
        
        
        let accessDenied = center.addObserver(forName: NSNotification.Name(EKRSAccessDeniedNotification),
            object: TimedReminderStore.shared,
            queue: mainQueue
            ) {[weak self] note in
                self?.handleRSAccessDeniedNotification(note)
                
        }
        
        
        let refreshData = center.addObserver(forName: NSNotification.Name(EKRSRefreshDataNotification),
            object: TimedReminderStore.shared,
            queue: mainQueue
            ) {[weak self] note in
                self?.handleRSRefreshDataNotification(note)
        }
        
        
        
        let upcoming = center.addObserver(forName: NSNotification.Name(EKRSUpcomingRemindersNotification),
            object: TimedReminderStore.shared,
            queue: mainQueue
            ) {[weak self] note in
                self?.handleRSUpcomingRemindersNotification(note)
        }
        
        
        let pastDue = center.addObserver(forName: NSNotification.Name(EKRSPastDueRemindersNotification),
            object: TimedReminderStore.shared,
            queue: mainQueue
            ) {[weak self] note in
                
                self?.handleRSPastDueRemindersNotification(note)
        }
        
        let completed = center.addObserver(forName: NSNotification.Name(EKRSCompletedRemindersNotification),
            object: TimedReminderStore.shared,
            queue: mainQueue
            ) {[weak self] note in
                self?.handleRSCompletedRemindersNotification(note)
        }
        
        let failure = center.addObserver(forName: NSNotification.Name(EKRSFailureNotification),
            object: TimedReminderStore.shared,
            queue: mainQueue
            ) {[weak self] note in
                self?.handleRSFailureNotification(note)
        }
        
        // Keep track of all the created notifications
        self.rsObservers = [accessGranted, accessDenied, refreshData, upcoming, pastDue, completed, failure]
        // Check whether EKTimedReminders has access to Reminders
        TimedReminderStore.shared.checkEventStoreAuthorizationStatus()
    }
    
    
    //MARK: - Handle Access Granted Notification
    
    // Handle the RSAccessGrantedNotification notification
    private func handleRSAccessGrantedNotification(_ notification: Notification) {
        NotificationCenter.default.post(name: Notification.Name(TTBAccessGrantedNotification), object: self)
        self.accessGrantedForReminders()
    }
    
    
    // Access was granted to Reminders. Fetch past-due, pending, and completed reminders
    private func accessGrantedForReminders() {
        TimedReminderStore.shared.fetchUpcomingRemindersWithDueDate(EKRSHelperClass.dateByAddingDays(7))
        TimedReminderStore.shared.fetchPastDueRemindersWithDateStarting(EKRSHelperClass.dateByAddingDays(-7))
        
        TimedReminderStore.shared.fetchCompletedRemindersWithDueDateStarting(EKRSHelperClass.dateByAddingDays(-7),
            ending: EKRSHelperClass.dateByAddingDays(7))
    }
    
    
    //MARK: - Handle Access Denied Notification
    
    // Handle the RSAccessDeniedNotification notification
    private func handleRSAccessDeniedNotification(_ notification: Notification) {
        let alert = EKRSHelperClass.alert(title: NSLocalizedString("Access Status", comment: ""),
            message: NSLocalizedString("Access was not granted for Reminders.", comment: ""))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Handle Refresh Data Notification
    
    // Handle the RSRefreshDataNotification notification
    private func handleRSRefreshDataNotification(_ notification: Notification) {
        self.accessGrantedForReminders()
    }
    
    
    //MARK: - Handle Failure Notification
    
    // Handle the RSFailureNotification notification.
    // An error has occured. Display an alert with the error message.
    private func handleRSFailureNotification(_ notification: Notification) {
        let myNotification = notification.object as! TimedReminderStore?
        
        let alert = EKRSHelperClass.alert(title: NSLocalizedString("Status", comment: ""),
            message: myNotification?.errorMessage ?? "")
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Handle Upcoming Reminders Notification
    
    // Handle the RSUpcomingRemindersNotification notification
    private func handleRSUpcomingRemindersNotification(_ notification: Notification) {
        let myNotification = notification.object as! TimedReminderStore?
        
        // Update the number of upcoming reminders in the tab bar
        self.tabBar.items?[0].badgeValue = String(myNotification?.upcomingReminders.count ?? 0)
        // Notify the listener that there are past-due reminders
        NotificationCenter.default.post(name: Notification.Name(TTBUpcomingRemindersNotification), object: self)
    }
    
    
    //MARK: - Handle Past-Due Reminders Notification
    
    // Handle the RSPastDueRemindersNotification notification
    private func handleRSPastDueRemindersNotification(_ notification: Notification) {
        let myNotification = notification.object as! TimedReminderStore?
        
        // Update the number of past-due reminders in the tab bar
        self.tabBar.items?[1].badgeValue = String(myNotification?.pastDueReminders.count ?? 0)
        // Notify the listener that there are past-due reminders
        NotificationCenter.default.post(name: Notification.Name(TTBPastDueRemindersNotification), object: self)
    }
    
    
    //MARK: - Handle Completed Reminders Notification
    
    // Handle the RSCompletedRemindersNotification notification
    private func handleRSCompletedRemindersNotification(_ notification: Notification) {
        let myNotification = notification.object as! TimedReminderStore?
        
        // Update the number of completed reminders in the tab bar
        self.tabBar.items?[2].badgeValue = String(myNotification?.completedReminders.count ?? 0)
        // Notify the listener that there are completed reminders
        NotificationCenter.default.post(name: Notification.Name(TTBCompletedRemindersNotification), object: self)
    }
    
    
    
    //MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    deinit {
        // Unregister for all observers saved in rsObservers
        for anObserver in self.rsObservers {
            NotificationCenter.default.removeObserver(anObserver)
        }
    }
}
