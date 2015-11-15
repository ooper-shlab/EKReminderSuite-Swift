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
        
        let mainQueue = NSOperationQueue.mainQueue()
        let center = NSNotificationCenter.defaultCenter()
        
        // Register for access granted and denied, refresh data, location, and failure notifications
        let accessGranted = center.addObserverForName(EKRSAccessGrantedNotification,
            object: LocationReminderStore.sharedInstance,
            queue: mainQueue
            ) {[weak self] note in
                self?.handleEKRSAccessGrantedNotification(note)
        }
        
        
        let accessDenied = center.addObserverForName(EKRSAccessDeniedNotification,
            object: LocationReminderStore.sharedInstance,
            queue: mainQueue
            ) {[weak self] note in
                self?.handleEKRSAccessDeniedNotification(note)
                
        }
        
        
        let refreshData = center.addObserverForName(EKRSRefreshDataNotification,
            object: LocationReminderStore.sharedInstance,
            queue: mainQueue
            ) {[weak self] note in
                self?.handleEKRSRefreshDataNotification(note)
        }
        
        let reminders = center.addObserverForName(EKRSLocationRemindersNotification,
            object: LocationReminderStore.sharedInstance,
            queue: mainQueue
            ) {[weak self] note in
                self?.handleEKRSLocationRemindersNotification(note)
        }
        
        let failure = center.addObserverForName(EKRSFailureNotification,
            object: LocationReminderStore.sharedInstance,
            queue: mainQueue
            ) {[weak self] note in
                self?.handleEKRSFailureNotification(note)
        }
        
        // Keep track of our observers
        self.rsObservers = [accessGranted, accessDenied, refreshData, reminders, failure]
        // Check whether EKLocationReminders has access to Reminders
        LocationReminderStore.sharedInstance.checkEventStoreAuthorizationStatus()
    }
    
    
    //MARK: - Handle Access Granted Notification
    
    // Handle the EKRSAccessGrantedNotification notification
    private func handleEKRSAccessGrantedNotification(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().postNotificationName(LTBAccessGrantedNotification, object: self)
        LocationReminderStore.sharedInstance.fetchLocationReminders()
    }
    
    
    //MARK: - Handle Access Denied Notification
    
    // Handle the EKRSAccessDeniedNotification notification
    private func handleEKRSAccessDeniedNotification(notification: NSNotification) {
        let alert = EKRSHelperClass.alertWithTitle(NSLocalizedString("Privacy Warning", comment: ""),
            message: NSLocalizedString("Access was not granted for Reminders.", comment: ""))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Handle Refresh Data Notification
    
    // Handle the EKRSRefreshDataNotification notification
    private func handleEKRSRefreshDataNotification(notificaion: NSNotification) {
        LocationReminderStore.sharedInstance.fetchLocationReminders()
    }
    
    
    //MARK: - Handle Failure Notification
    
    // Handle the EKRSFailureNotification notification. Display the error message encountered
    private func handleEKRSFailureNotification(notification: NSNotification) {
        let myNotification = notification.object as! LocationReminderStore
        EKRSHelperClass.alertWithTitle(NSLocalizedString("Status", comment: ""),
            message: myNotification.errorMessage!)
    }
    
    
    //MARK: - Handle Incomplete Reminders Notification
    
    // Handle the EKRSLocationRemindersNotification notification
    private func handleEKRSLocationRemindersNotification(notification : NSNotification) {
        let myNotification = notification.object as! LocationReminderStore
        
        // Update the number of the reminders in the tab bar
        self.tabBar.items?[1].badgeValue = String(myNotification.locationReminders.count)
        // Notify the listener that there are location reminders
        NSNotificationCenter.defaultCenter().postNotificationName(LTBRemindersFetchedNotification, object: self)
    }
    
    
    //MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    deinit {
        // Unregister for all observers saved in rsObservers
        for anObserver in self.rsObservers {
            NSNotificationCenter.defaultCenter().removeObserver(anObserver)
        }
    }
    
}