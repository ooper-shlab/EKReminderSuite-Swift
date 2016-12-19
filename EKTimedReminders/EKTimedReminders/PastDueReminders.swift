//
//  PastDueReminders.swift
//  EKTimedReminders
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/15.
//
//
/*

 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This view controller displays all reminders whose due date was within the last 7 days.
         It shows the title, due date, frequency, and priority of each reminder using EKReminder's title, dueDateComponents, and priority properties
         and EKRecurrenceRule, respectively. It also allows you to mark a reminder as completed.

 */
import UIKit
import EventKit


// Cell identifier
private let EKTRPastDueRemindersCellID = "pastDueCellID"

@objc(PastDueReminders)
class PastDueReminders: UITableViewController {
    // Keep track of all past-due reminders
    private var pastDue: [EKReminder] = []
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Register for TimedTabBarController notification
        NotificationCenter.default.addObserver(self,
            selector: #selector(PastDueReminders.handleTTBPastDueRemindersNotification(_:)),
            name: NSNotification.Name(TTBPastDueRemindersNotification),
            object: nil)
        
    }
    
    
    //MARK: - Handle TimedTabBarController Notification
    
    // Update the UI
    @objc func handleTTBPastDueRemindersNotification(_ notificaiton: Notification) {
        self.pastDue = TimedReminderStore.shared.pastDueReminders
        self.tableView.reloadData()
    }
    
    
    //MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.pastDue.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let reminder = self.pastDue[indexPath.row]
        
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        
        // Fetch the date by which this reminder should be completed
        let date = gregorian.date(from: reminder.dueDateComponents!)!
        let formattedDateString = EKRSHelperClass.dateFormatter.string(from: date)
        
        // Fetch the recurrence rule
        let recurrence = reminder.recurrenceRules
        let rule = recurrence?.first
        
        // Create a string comprising of the date and frequency
        let dateAndFrequency = (recurrence?.count ?? 0 > 0) ? "\(formattedDateString),\(rule?.nameMatchingFrequency(rule?.frequency ?? .daily) ?? "")" : formattedDateString
        
        let myCell = cell as! CustomCell
        myCell.checkBox.checked = false
        myCell.title.text = reminder.title
        myCell.dateAndFrequency.text = dateAndFrequency
        myCell.priority.text = reminder.symbolMatchingPriority(reminder.priority)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: EKTRPastDueRemindersCellID, for: indexPath)
    }
    
    
    
    //MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Find the cell being touched
        let targetCustomCell = tableView.cellForRow(at: indexPath) as! CustomCell
        // Add a checkmark for this reminder
        targetCustomCell.checkBox.checked = !targetCustomCell.checkBox.checked
        // Let's mark the selected reminder as completed
    }
    
    
    //MARK: - Managing Selections
    
    @IBAction func checkBoxTapped(_: AnyObject, forEvent event: UIEvent) {
        let touches = event.allTouches
        let touch = touches!.first!
        let currentTouchPosition = touch.location(in: self.tableView)
        
        // Lookup the index path of the cell whose checkbox was modified.
        if let indexPath = self.tableView.indexPathForRow(at: currentTouchPosition) {
            
            // Let's mark the selected reminder as completed
            self.completeReminderIndexPath(indexPath)
        }
    }
    
    
    // Call TimedReminderStore to mark the selected reminder as completed
    private func completeReminderIndexPath(_ indexPath: IndexPath) {
        let reminder = self.pastDue[indexPath.row]
        // Remove the selected reminder from the UI
        self.pastDue = self.pastDue.filter{$0 !== reminder}
        self.tableView.deleteRows(at: [indexPath], with: .fade)
        // Tell TimedReminderStore to mark the selected reminder as completed
        TimedReminderStore.shared.complete(reminder)
    }
    
    
    //MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    deinit {
        // Unregister for TimedTabBarController notification
        NotificationCenter.default.removeObserver(self,
            name: NSNotification.Name(TTBPastDueRemindersNotification),
            object: nil)
    }
    
}
