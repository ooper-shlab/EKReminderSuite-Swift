//
//  EKRSReminderStoreUtilities.swift
//  EKTimedReminders
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/14.
//
//
/*

 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This class creates categories for the EKAlarm, EKRecurrenceRule, and EKReminder classes.

 */
import UIKit
import EventKit


//MARK: - EKAlarm Additions

extension EKAlarm {
    
    // Return the EKAlarmProximity value matching a given name
    func proximityMatchingName(_ name: String) -> EKAlarmProximity {
        // Default value
        var alarmProximity = EKAlarmProximity.none
        
        if name == EKRSAlarmLeaving {
            alarmProximity = .leave
        } else if name == EKRSAlarmArriving {
            alarmProximity = .enter
        }
        
        return alarmProximity
    }
    
    
    // Return the name matching a given EKAlarmProximity value
    func nameMatchingProximity(_ proximity: EKAlarmProximity) -> String? {
        var name: String? = nil
        
        if proximity == .leave {
            name = EKRSAlarmLeaving
        } else if proximity == .enter {
            name = EKRSAlarmArriving
        }
        
        return name
    }
    
}


//MARK: - EKRecurrenceRule Additions

extension EKRecurrenceRule {
    
    // Return the EKRecurrenceFrequency value matching a given name
    func frequencyMatchingName(_ name: String) -> EKRecurrenceFrequency {
        // Default value
        var recurrence = EKRecurrenceFrequency.daily
        
        if name == EKRSFrequencyWeekly {
            recurrence = .weekly
        } else if name == EKRSFrequencyMonthly {
            recurrence = .monthly
        } else if name == EKRSFrequencyYearly {
            recurrence = .yearly
        }
        
        return recurrence
    }
    
    
    // Return the name matching a given EKRecurrenceFrequency value
    func nameMatchingFrequency(_ frequency: EKRecurrenceFrequency) -> String {
        // Default value
        var name = EKRSFrequencyDaily
        
        switch frequency {
        case .daily:
            name = EKRSFrequencyDaily
        case .weekly:
            name = EKRSFrequencyWeekly
        case .monthly:
            name = EKRSFrequencyMonthly
        case .yearly:
            name = EKRSFrequencyYearly
        @unknown default:
            break
        }
        
        return name
    }
    
    
    // Create a recurrence interval
    func intervalMatchingFrequency(_ frequency: String) -> Int {
        // Return 2 if the reminder repeats every two weeks and 1, otherwise
        let interval = frequency == EKRSFrequencyBiweekly ? 2 : 1
        return  interval
    }
    
    
    // Create a recurrence rule
    func recurrenceRuleMatchingFrequency(_ frequency: String) -> EKRecurrenceRule {
        // Create a recurrence interval matching the specified frequency
        let interval = self.intervalMatchingFrequency(frequency)
        // Create a weekly recurrence frequency if the reminder repeats every two  weeks. Fetch the EKRecurrenceFrequency value matching frequency, otherwise.
        let recurrenceFrequency = frequency == EKRSFrequencyBiweekly ? EKRecurrenceFrequency.weekly : self.frequencyMatchingName(frequency)
        
        // Create a recurrence rule using the above recurrenceFrequency and interval
        let rule = EKRecurrenceRule(recurrenceWith: recurrenceFrequency,
            interval: interval,
            end: nil)
        return rule
    }
    
    
    // Return the name matching a recurrence rule
    func nameMatchingRecurrenceRuleWithFrequency(_ frequence: EKRecurrenceFrequency, interval: Int) -> String {
        // Get the name matching frequency
        var name = self.nameMatchingFrequency(frequency)
        
        // A Biweekly reminder is one with a weekly recurrence frequency and an interval of 2.
        // Set name to Biweekly if that is the case.
        if interval == 2 && name == EKRSFrequencyWeekly {
            name = EKRSFrequencyBiweekly
        }
        
        return name
    }
    
}


//MARK: - EKReminder Additions

extension EKReminder {
    
    // Return the priority value matching a given name
    func priorityMatchingName(_ name: String?) -> Int {
        var priority = 0
        switch name {
        case EKRSPriorityNone?:
            priority = 0
        case EKRSPriorityHigh?:
            priority = 4
        case EKRSPriorityMedium?:
            priority = 5
        case EKRSPriorityLow?:
            priority = 6
        default:
            break
        }
        
        return priority
    }
    
    
    // Return the symbol(s) matching a given priority value. The priority is an integer
    // going from 1 (highest) to 9 (lowest). A priority of 0 means no priority.
    // Priorities of 1-4, which are considered High, are represented by "!!!".
    // A priority of 5, which is considered Medium, is represented by "!!".
    // A priority of 6-9, which are considered Low, are represented by "!".
    func symbolMatchingPriority(_ priority: Int) -> String? {
        var name: String? = nil
        switch priority {
        case 0:
            name = nil
        case 1..<5:
            name = EKRSSymbolPriorityHigh
        case 5:
            name = EKRSSymbolPriorityMedium
        case let x where x > 5:
            name = EKRSSymbolPriorityLow
        default:
            break
        }
        
        return name
    }
    
}
