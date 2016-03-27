//
//  CompletedReminders.swift
//  EKTimedReminders
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/15.
//
//
/*

 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This view controller displays all completed reminders. It shows the title and completion date of each reminder
         using EKReminder's title and completionDate properties and calls TimedReminderStore to remove reminders.

 */
import UIKit
import EventKit


// Cell identifier
private let EKTRCompletedRemindersCellID = "completedCellID"

@objc(CompletedReminders)
class CompletedReminders: UITableViewController {
    // Keep track of all completed reminders
    private var completed: [EKReminder] = []
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Register for TimedTabBarController notification
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: #selector(CompletedReminders.handleTTBCompletedRemindersNotification(_:)),
            name: TTBCompletedRemindersNotification,
            object: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.toolbarItems = [UIBarButtonItem(title: NSLocalizedString("Delete All", comment: ""), style: .Plain, target: self, action: #selector(CompletedReminders.deleteAll(_:)))]
    }
    
    
    func showOrHideEditButton() {
        // Show the Edit button if there are complete timed-based reminders and hide it, otherwise.
        self.navigationItem.leftBarButtonItem = !self.completed.isEmpty ? self.editButtonItem() : nil
    }
    
    
    @objc func deleteAll(_: AnyObject) {
        let alert = UIAlertController(title: nil,
            message: NSLocalizedString("Are you sure you want to remove all these reminders?", comment: ""),
            preferredStyle: .ActionSheet)
        
        
        let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
            style: .Default
            ) {action in
                for reminder in self.completed {
                    TimedReminderStore.sharedInstance.remove(reminder)
                }
                
                self.tableView.reloadData()
                self.setEditing(false, animated: true)
        }
        alert.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Default, handler: nil)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Handle TimedTabBarController Notification
    
    // Refresh the UI with complete timed-based reminders and enable the Edit button
    @objc func handleTTBCompletedRemindersNotification(notification: NSNotification) {
        let result = TimedReminderStore.sharedInstance.completedReminders
        if self.completed != result {
            self.completed = result
            self.tableView.reloadData()
            self.showOrHideEditButton()
        }
    }
    
    
    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.completed.count
    }
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let reminder = self.completed[indexPath.row]
        
        // Display the reminder's title
        cell.textLabel!.text = reminder.title
        // Display the reminder's completion date
        cell.detailTextLabel!.text = EKRSHelperClass.dateFormatter.stringFromDate(reminder.completionDate!)
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier(EKTRCompletedRemindersCellID, forIndexPath: indexPath)
    }
    
    
    // Used to delete a reminder
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let reminder = self.completed[indexPath.row]
            
            // Remove the selected reminder from the UI
            self.completed = self.completed.filter{$0 !== reminder}
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            // Called to remove the selected reminder from event store
            TimedReminderStore.sharedInstance.remove(reminder)
        }
    }
    
    
    //MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    
    //MARK: - UITableView
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        // Remove the Edit button if there are no reminders
        if self.completed.isEmpty {
            self.navigationItem.leftBarButtonItem = nil
        }
        self.navigationController!.toolbarHidden = !editing
    }
    
    
    //MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    deinit {
        // Unregister for TimedTabBarController notification
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: TTBCompletedRemindersNotification,
            object: nil)
    }
    
}