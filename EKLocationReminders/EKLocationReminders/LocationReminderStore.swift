//
//  LocationReminderStore.swift
//  EKLocationReminders
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/15.
//
//
/*

 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 An EKRSReminderStore subclass that shows how to create location-based reminders using EKReminder and EKAlarm.

 */
import UIKit
import EventKit

@objc(LocationReminderStore)
class LocationReminderStore: EKRSReminderStore {
    
    static var sharedInstance: LocationReminderStore = LocationReminderStore()
    
    
    //MARK: -
    //MARK: Add Location Reminder
    
    // Create a location-based reminder
    func createLocationReminder(reminder: LocationReminder) {
        let myReminder = EKReminder(eventStore: self.eventStore)
        myReminder.title = reminder.title ?? ""
        myReminder.calendar = self.calendar!
        
        // Create an alarm
        let alarm = EKAlarm()
        // Configure a geofence by setting up the structured location and proximity properties
        alarm.proximity = alarm.proximityMatchingName(reminder.proximity!)
        alarm.structuredLocation = reminder.structuredLocation
        
        // Add the above alarm to myReminder
        myReminder.addAlarm(alarm)
        
        // Attempt to save the reminder
        self.save(myReminder)
    }
    
}