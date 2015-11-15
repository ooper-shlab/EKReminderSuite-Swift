//
//  TimedReminder.swift
//  EKTimedReminders
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/15.
//
//
/*

 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 Model class representing a timed-based reminder.

 */
import UIKit
import EventKit

@objc(TimedReminder)
class TimedReminder: NSObject {
    // Reminder's title
    var title: String?
    // Reminder's priority
    var priority: String?
    // Reminder's recurrence frequency
    var frequency: String?
    // Reminder's start date
    var startDate: NSDate?
    
    
    init(title: String, startDate: NSDate, frequency: String, priority: String) {
        self.title = title
        self.startDate = startDate
        self.frequency = frequency
        self.priority = priority
        super.init()
    }
    
}