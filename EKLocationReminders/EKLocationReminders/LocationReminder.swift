//
//  LocationReminder.swift
//  EKLocationReminders
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/15.
//
//
/*

 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 Model class representing a location reminder.

 */
import UIKit
import EventKit


@objc(LocationReminder)
class LocationReminder: NSObject {
    //var radius: Double = 0.0
    // Reminder's title
    var title: String?
    // Reminder's proximity value
    var proximity: String?
    // Reminder's recurrence frequency
    //var frequency: String?
    // Reminder's location used to trigger alarm
    var structuredLocation: EKStructuredLocation?
    
    
    init(title name: String?, proximity: String, structureLocation location: EKStructuredLocation) {
        self.title = name
        self.proximity = proximity
        self.structuredLocation = location
        super.init()
    }
    
}