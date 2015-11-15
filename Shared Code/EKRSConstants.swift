//
//  EKRSConstants.swift
//  EKTimedReminders
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/14.
//
//
/*

 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 Constants used by various classes in the EKReminderSuite project.

 */



//MARK: - EKRSReminderStore

let EKRSAccessDeniedNotification = "EKRSAccessDeniedNotification" // Indicates that access was denied to Reminders
let EKRSAccessGrantedNotification = "EKRSAccessGrantedNotification" // Indicates that access was granted to Reminders
let EKRSLocationRemindersNotification = "EKRSIncompleteRemindersNotification" // Indicates that location reminders were fetched
let EKRSCompletedRemindersNotification = "EKRSCompletedRemindersNotification" // Indicates that completed reminders were fetched
let EKRSPastDueRemindersNotification = "EKRSPastDueRemindersNotification" // Indicates that past-due reminders were fetched
let EKRSUpcomingRemindersNotification = "EKRSUpcomingRemindersNotification" // Indicates that upcoming reminders were fetched
let EKRSRefreshDataNotification = "EKRSRefreshDataNotification" // Sent when saving, removing, or marking a reminder as completed was successful
let EKRSFailureNotification = "EKRSFailureNotification" // Sent when saving, removing, or marking a reminder as completed failed


//MARK: - EKRSReminderStoreUtilities

let EKRSFrequencyNever = "Never";
let EKRSFrequencyDaily = "Daily";
let EKRSFrequencyWeekly = "Weekly";
let EKRSFrequencyYearly = "Yearly";
let EKRSFrequencyMonthly = "Monthly";
let EKRSFrequencyBiweekly = "Biweekly";

let EKRSAlarmLeaving = "Leaving";
let EKRSAlarmArriving = "Arriving";

let EKRSPriorityLow = "Low";
let EKRSPriorityHigh = "High";
let EKRSPriorityNone = "None";
let EKRSPriorityMedium = "Medium";

let EKRSSymbolPriorityLow = "!";
let EKRSSymbolPriorityHigh = "!!!";
let EKRSSymbolPriorityMedium = "!!";

//MARK: - TimedTabBarController

let TTBAccessGrantedNotification = "TTBAccessGrantedNotification";
let TTBUpcomingRemindersNotification = "TTBUpcomingRemindersNotification";
let TTBPastDueRemindersNotification = "TTBPastDueRemindersNotification";
let TTBCompletedRemindersNotification = "TTBCompletedRemindersNotification";


//MARK: - LocationTabBarController

let LTBAccessGrantedNotification = "LTBAccessGrantedNotification" // Indicates that access was granted to Reminders
let LTBRemindersFetchedNotification = "LTBRemindersFetchedNotification" // Indicates that location reminders were received

//MARK: -

let EKRSTitle = "title";
let EKRSLocationRadius = "radius";
let EKRSLocationProximity = "proximity";
let EKRSDescription = "description";

