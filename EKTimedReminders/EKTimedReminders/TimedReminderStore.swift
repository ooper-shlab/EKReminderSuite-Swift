//
//  TimedReminderStore.swift
//  EKTimedReminders
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/15.
//
//
/*

 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 An EKRSReminderStore subclass that shows how to create recurring timed-based reminders using EKReminder,
         EKAlarm, and EKRecurrenceRule.

 */
import UIKit
import EventKit

@objc(TimedReminderStore)
class TimedReminderStore: EKRSReminderStore {
    
    
    static let sharedInstance = TimedReminderStore()
    
    
    //MARK: - Create Timed-Based Reminder
    
    // Create a timed-based reminder
    func createTimedReminder(reminder: TimedReminder) {
        let myReminder = EKReminder(eventStore: self.eventStore)
        myReminder.title = reminder.title ?? ""
        myReminder.calendar = self.calendar!
        myReminder.priority = myReminder.priorityMatchingName(reminder.priority)
        
        // Create the date components of the reminder's start date components
        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let unitFlags: NSCalendarUnit = [.Second, .Minute, .Hour, .Day, .Month, .Year]
        let dateComponents = gregorian.components(unitFlags, fromDate: reminder.startDate!)
        dateComponents.timeZone = myReminder.timeZone
        
        
        // For iOS apps, EventKit requires a start date if a due date was set
        myReminder.startDateComponents = dateComponents
        myReminder.dueDateComponents = dateComponents
        
        // Create a recurrence rule if the reminder repeats itself over a given period of time
        if reminder.frequency != EKRSFrequencyNever {
            let rule = EKRecurrenceRule()
            // Fetch the recurrence rule matching the reminder's frequency, then apply it to myReminder
            myReminder.addRecurrenceRule(rule.recurrenceRuleMatchingFrequency(reminder.frequency!))
        }
        
        // Create an alarm that will fire at a specific date and time
        let alarm = EKAlarm(absoluteDate: reminder.startDate!)
        // Attach an alarm to the reminder
        myReminder.addAlarm(alarm)
        
        // Attempt to save the reminder
        self.save(myReminder)
    }
    
}