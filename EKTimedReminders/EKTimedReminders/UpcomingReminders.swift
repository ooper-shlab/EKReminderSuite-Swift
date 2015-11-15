//
//  UpcomingReminders.swift
//  EKTimedReminders
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/15.
//
//
/*

 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This view controller displays all reminders whose due date is within the next 7 days.
         It shows the title, due date, priority, and frequency of each reminder using EKReminder's title,
         dueDateComponents, and priority properties and EKRecurrenceRule, respectively.
         It allows you to create a reminder and mark a reminder as completed.

 */
import UIKit
import EventKit


// Cell identifier
private let EKTRUpcomingRemindersCellID = "upcomingCellID"


@objc(UpcomingReminders)
class UpcomingReminders: UITableViewController {
    @IBOutlet private weak var addButton: UIBarButtonItem!
    // Keep track of all upcoming reminders
    private var upcoming: [EKReminder] = []
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Register for TimedTabBarController notifications
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "handleTTBAccessGrantedNotification:",
            name: TTBAccessGrantedNotification,
            object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "handleTTBUpcomingRemindersNotification:",
            name: TTBUpcomingRemindersNotification,
            object: nil)
        
    }
    
    
    //MARK: - Handle TimedTabBarController Notifications
    
    // Enable the addButton button when access was granted to Reminders
    @objc func handleTTBAccessGrantedNotification(_: NSNotification) {
        self.addButton.enabled = true
    }
    
    
    // Refresh the UI with all upcoming reminders
    @objc func handleTTBUpcomingRemindersNotification(_: NSNotification) {
        // Refresh the UI with all upcoming reminders
        self.upcoming = TimedReminderStore.sharedInstance.upcomingReminders
        self.tableView.reloadData()
    }
    
    
    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.upcoming.count
    }
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let reminder = self.upcoming[indexPath.row]
        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        // Fetch the date by which the reminder should be completed
        let date = gregorian.dateFromComponents(reminder.dueDateComponents!)
        let formattedDateString = EKRSHelperClass.dateFormatter.stringFromDate(date!)
        var frequency: String = ""
        
        // If the reminder is a recurring one, only show its first recurrence rule
        if reminder.hasRecurrenceRules {
            // Fetch all recurrence rules associated with this reminder
            let recurrencesRules = reminder.recurrenceRules!
            let rule = recurrencesRules.first!
            frequency = rule.nameMatchingRecurrenceRuleWithFrequency(rule.frequency, interval: rule.interval)
        }
        
        // Use the hasRecurrenceRules property to determine whether to show the recurrence pattern for this reminder
        let dateAndFrequency = reminder.hasRecurrenceRules ? "\(formattedDateString), \(frequency)" : formattedDateString
        
        let myCell = cell as! CustomCell
        
        myCell.checkBox.checked = false
        myCell.title.text = reminder.title
        
        // Display the due date and frequency of the reminder
        myCell.dateAndFrequency.text = dateAndFrequency
        
        // Show the reminder's priority
        myCell.priority.text = reminder.symbolMatchingPriority(reminder.priority)
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier(EKTRUpcomingRemindersCellID, forIndexPath: indexPath)
    }
    
    
    //MARK: - UITableViewDelegate
    
    // Called when tapping a reminder. Briefly select its checkbox, then remove this reminder.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Find the cell being touched
        let targetCustomCell = tableView.cellForRowAtIndexPath(indexPath) as! CustomCell
        // Add a checkmarck for this reminder
        targetCustomCell.checkBox.checked = !targetCustomCell.checkBox.checked
        // Let's mark the selected reminder as completed
        self.completeReminderAtIndexPath(indexPath)
    }
    
    
    
    //MARK: - Unwind Segues
    
    // Called when tapping the Cancel button in the AddTimedReminder view controller
    @IBAction func cancel(_: UIStoryboardSegue) {
    }
    
    
    // Called when tapping the Done button in the AddTimedReminder view controller
    @IBAction func done(sender: UIStoryboardSegue) {
        let addTimedReminder = sender.sourceViewController as! AddTimedReminder
        // Called to create a timed-based reminder
        TimedReminderStore.sharedInstance.createTimedReminder(addTimedReminder.reminder!)
    }
    
    
    //MARK: - Managing Selections
    
    // Called when tapping a checkbox. Briefly select it, then remove its associated reminder.
    @IBAction func checkBoxTapped(_: AnyObject, forEvent event: UIEvent) {
        let touches = event.allTouches()!
        let touch = touches.first!
        let currentTouchPosition = touch.locationInView(self.tableView)
        
        // Lookup the index path of the cell whose checkbox was modified.
        if let indexPath = self.tableView.indexPathForRowAtPoint(currentTouchPosition) {
            
            // Let's mark the selected reminder as completed
            self.completeReminderAtIndexPath(indexPath)
        }
    }
    
    
    // Call TimedReminderStore to mark the selected reminder as completed
    private func completeReminderAtIndexPath(indexPath: NSIndexPath) {
        let reminder = self.upcoming[indexPath.row]
        // Remove the selected reminder from the UI
        self.upcoming = self.upcoming.filter{$0 !== reminder}
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        // Tell TimedReminderStore to mark the selected reminder as completed
        TimedReminderStore.sharedInstance.complete(reminder)
    }
    
    
    //MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    deinit {
        // Unregister for TimedTabBarController notifications
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: TTBAccessGrantedNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: TTBUpcomingRemindersNotification,
            object: nil)
    }
    
}