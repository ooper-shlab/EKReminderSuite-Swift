//
//  LocationTabBarController.swift
//  EKLocationReminders
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/15.
//
//
/*

 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This view controller manages the child view controllers: MapViewController and RemindersViewController.
  It calls LocationReminderStore to check access to the Reminders application.

 */
import UIKit
import EventKit


@objc(LocationTabBarController)
class LocationTabBarController: UITabBarController {
    
    
    private var rsObservers: [AnyObject] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainQueue = OperationQueue.main
        let center = NotificationCenter.default
        
        // Register for access granted and denied, refresh data, location, and failure notifications
        let accessGranted = center.addObserver(forName: NSNotification.Name(EKRSAccessGrantedNotification),
            object: LocationReminderStore.shared,
            queue: mainQueue
            ) {[weak self] note in
                self?.handleEKRSAccessGrantedNotification(note)
        }
        
        
        let accessDenied = center.addObserver(forName: NSNotification.Name(EKRSAccessDeniedNotification),
            object: LocationReminderStore.shared,
            queue: mainQueue
            ) {[weak self] note in
                self?.handleEKRSAccessDeniedNotification(note)
                
        }
        
        
        let refreshData = center.addObserver(forName: NSNotification.Name(EKRSRefreshDataNotification),
            object: LocationReminderStore.shared,
            queue: mainQueue
            ) {[weak self] note in
                self?.handleEKRSRefreshDataNotification(note)
        }
        
        let reminders = center.addObserver(forName: NSNotification.Name(EKRSLocationRemindersNotification),
            object: LocationReminderStore.shared,
            queue: mainQueue
            ) {[weak self] note in
                self?.handleEKRSLocationRemindersNotification(note)
        }
        
        let failure = center.addObserver(forName: NSNotification.Name(EKRSFailureNotification),
            object: LocationReminderStore.shared,
            queue: mainQueue
            ) {[weak self] note in
                self?.handleEKRSFailureNotification(note)
        }
        
        // Keep track of our observers
        self.rsObservers = [accessGranted, accessDenied, refreshData, reminders, failure]
        // Check whether EKLocationReminders has access to Reminders
        LocationReminderStore.shared.checkEventStoreAuthorizationStatus()
    }
    
    
    //MARK: - Handle Access Granted Notification
    
    // Handle the EKRSAccessGrantedNotification notification
    private func handleEKRSAccessGrantedNotification(_ notification: Notification) {
        NotificationCenter.default.post(name: Notification.Name(LTBAccessGrantedNotification), object: self)
        LocationReminderStore.shared.fetchLocationReminders()
    }
    
    
    //MARK: - Handle Access Denied Notification
    
    // Handle the EKRSAccessDeniedNotification notification
    private func handleEKRSAccessDeniedNotification(_ notification: Notification) {
        let alert = EKRSHelperClass.alert(title: NSLocalizedString("Privacy Warning", comment: ""),
            message: NSLocalizedString("Access was not granted for Reminders.", comment: ""))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Handle Refresh Data Notification
    
    // Handle the EKRSRefreshDataNotification notification
    private func handleEKRSRefreshDataNotification(_ notificaion: Notification) {
        LocationReminderStore.shared.fetchLocationReminders()
    }
    
    
    //MARK: - Handle Failure Notification
    
    // Handle the EKRSFailureNotification notification. Display the error message encountered
    private func handleEKRSFailureNotification(_ notification: Notification) {
        let myNotification = notification.object as! LocationReminderStore
        EKRSHelperClass.alert(title: NSLocalizedString("Status", comment: ""),
            message: myNotification.errorMessage!) //### Just creating an alert without showing it...
    }
    
    
    //MARK: - Handle Incomplete Reminders Notification
    
    // Handle the EKRSLocationRemindersNotification notification
    private func handleEKRSLocationRemindersNotification(_ notification : Notification) {
        let myNotification = notification.object as! LocationReminderStore
        
        // Update the number of the reminders in the tab bar
        self.tabBar.items?[1].badgeValue = String(myNotification.locationReminders.count)
        // Notify the listener that there are location reminders
        NotificationCenter.default.post(name: Notification.Name(LTBRemindersFetchedNotification), object: self)
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
