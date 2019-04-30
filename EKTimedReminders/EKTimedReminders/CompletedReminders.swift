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
        NotificationCenter.default.addObserver(self,
            selector: #selector(handleTTBCompletedRemindersNotification(_:)),
            name: NSNotification.Name(TTBCompletedRemindersNotification),
            object: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.toolbarItems = [UIBarButtonItem(title: NSLocalizedString("Delete All", comment: ""), style: .plain, target: self, action: #selector(deleteAll(_:)))]
    }
    
    
    func showOrHideEditButton() {
        // Show the Edit button if there are complete timed-based reminders and hide it, otherwise.
        self.navigationItem.leftBarButtonItem = !self.completed.isEmpty ? self.editButtonItem : nil
    }
    
    
    @objc func deleteAll(_: AnyObject) {
        let alert = UIAlertController(title: nil,
            message: NSLocalizedString("Are you sure you want to remove all these reminders?", comment: ""),
            preferredStyle: .actionSheet)
        
        
        let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
            style: .default
            ) {action in
                for reminder in self.completed {
                    TimedReminderStore.shared.remove(reminder)
                }
                
                self.tableView.reloadData()
                self.setEditing(false, animated: true)
        }
        alert.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Handle TimedTabBarController Notification
    
    // Refresh the UI with complete timed-based reminders and enable the Edit button
    @objc func handleTTBCompletedRemindersNotification(_ notification: Notification) {
        let result = TimedReminderStore.shared.completedReminders
        if self.completed != result {
            self.completed = result
            self.tableView.reloadData()
            self.showOrHideEditButton()
        }
    }
    
    
    //MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.completed.count
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let reminder = self.completed[indexPath.row]
        
        // Display the reminder's title
        cell.textLabel!.text = reminder.title
        // Display the reminder's completion date
        cell.detailTextLabel!.text = EKRSHelperClass.dateFormatter.string(from: reminder.completionDate!)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: EKTRCompletedRemindersCellID, for: indexPath)
    }
    
    
    // Used to delete a reminder
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let reminder = self.completed[indexPath.row]
            
            // Remove the selected reminder from the UI
            self.completed = self.completed.filter{$0 !== reminder}
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Called to remove the selected reminder from event store
            TimedReminderStore.shared.remove(reminder)
        }
    }
    
    
    //MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    
    //MARK: - UITableView
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        // Remove the Edit button if there are no reminders
        if self.completed.isEmpty {
            self.navigationItem.leftBarButtonItem = nil
        }
        self.navigationController!.isToolbarHidden = !editing
    }
    
    
    //MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    deinit {
        // Unregister for TimedTabBarController notification
        NotificationCenter.default.removeObserver(self,
            name: NSNotification.Name(TTBCompletedRemindersNotification),
            object: nil)
    }
    
}
