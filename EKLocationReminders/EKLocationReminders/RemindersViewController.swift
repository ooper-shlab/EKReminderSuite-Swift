//
//  RemindersViewController.swift
//  EKLocationReminders
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/15.
//
//
/*

 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This view controller displays incomplete location reminders if your app has access to Reminders.
         It uses the alarms and title properties of EKReminder and EKAlarm's proximity and structuredLocation
         ones to provide information about a reminder. Tap any reminder to remove it.

 */
import UIKit
import EventKit

// Cell identifier
private let EKLRRemindersCellID = "remindersCellID"

@objc(RemindersViewController)
class RemindersViewController: UITableViewController {
    private var reminders: [EKReminder] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "handleLTBControllerNotification:",
            name: LTBRemindersFetchedNotification,
            object: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.toolbarItems = [UIBarButtonItem(title: NSLocalizedString("Delete All", comment: ""), style: .Plain, target: self, action: "deleteAll:")]
    }
    
    
    @objc func deleteAll(_: AnyObject) {
        let alert = UIAlertController(title: nil,
            message: NSLocalizedString("Are you sure you want to remove all these reminders?", comment: ""),
            preferredStyle: .ActionSheet)
        
        
        let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
            style: .Default
            ) {action in
                for reminder in self.reminders {
                    LocationReminderStore.sharedInstance.remove(reminder)
                }
                
                self.tableView.reloadData()
                self.setEditing(false, animated: true)
        }
        alert.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Default, handler: nil)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    private func showOrHideEditButton() {
        // Show the Edit button if there are incomplete location-based reminders and hide it, otherwise.
        self.navigationItem.leftBarButtonItem = !self.reminders.isEmpty ? self.editButtonItem() : nil
    }
    
    
    //MARK: - Handle LocationTabBarController Notification
    
    @objc func handleLTBControllerNotification(notification: NSNotification) {
        let result = LocationReminderStore.sharedInstance.locationReminders
        
        // Refresh the UI
        if self.reminders != result {
            self.reminders = result
            self.tableView.reloadData()
            self.showOrHideEditButton()
        }
    }
    
    
    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.reminders.count
    }
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let reminder = self.reminders[indexPath.row]
        let alarm = reminder.alarms?.first
        
        let proximity = alarm?.nameMatchingProximity(alarm!.proximity) ?? ""
        let radius = (alarm?.structuredLocation?.radius ?? 0.0)/kMeter
        
        cell.textLabel!.text = reminder.title
        cell.detailTextLabel!.text = (radius > 0) ?
            String(format: "%@: within %.2f miles of %@", proximity, radius, alarm?.structuredLocation?.title ?? "") :
            String(format: "%@: %@", proximity, alarm?.structuredLocation?.title ?? "")
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier(EKLRRemindersCellID, forIndexPath: indexPath)
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let reminder = self.reminders[indexPath.row]
            
            self.reminders = self.reminders.filter{$0 !== reminder}
            // Update the table view
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            LocationReminderStore.sharedInstance.remove(reminder)
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
        if self.reminders.isEmpty {
            self.navigationItem.leftBarButtonItem = nil
        }
        self.navigationController!.toolbarHidden = !editing
    }
    
    
    //MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: LTBRemindersFetchedNotification,
            object: nil)
    }
    
}