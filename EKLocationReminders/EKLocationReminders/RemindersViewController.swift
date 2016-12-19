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
        NotificationCenter.default.addObserver(self,
            selector: #selector(RemindersViewController.handleLTBControllerNotification(_:)),
            name: NSNotification.Name(LTBRemindersFetchedNotification),
            object: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.toolbarItems = [UIBarButtonItem(title: NSLocalizedString("Delete All", comment: ""), style: .plain, target: self, action: #selector(RemindersViewController.deleteAll(_:)))]
    }
    
    
    @objc func deleteAll(_: AnyObject) {
        let alert = UIAlertController(title: nil,
            message: NSLocalizedString("Are you sure you want to remove all these reminders?", comment: ""),
            preferredStyle: .actionSheet)
        
        
        let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
            style: .default
            ) {action in
                for reminder in self.reminders {
                    LocationReminderStore.shared.remove(reminder)
                }
                
                self.tableView.reloadData()
                self.setEditing(false, animated: true)
        }
        alert.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    private func showOrHideEditButton() {
        // Show the Edit button if there are incomplete location-based reminders and hide it, otherwise.
        self.navigationItem.leftBarButtonItem = !self.reminders.isEmpty ? self.editButtonItem : nil
    }
    
    
    //MARK: - Handle LocationTabBarController Notification
    
    @objc func handleLTBControllerNotification(_ notification: Notification) {
        let result = LocationReminderStore.shared.locationReminders
        
        // Refresh the UI
        if self.reminders != result {
            self.reminders = result
            self.tableView.reloadData()
            self.showOrHideEditButton()
        }
    }
    
    
    //MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.reminders.count
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let reminder = self.reminders[indexPath.row]
        let alarm = reminder.alarms?.first
        
        let proximity = alarm?.nameMatchingProximity(alarm!.proximity) ?? ""
        let radius = (alarm?.structuredLocation?.radius ?? 0.0)/kMeter
        
        cell.textLabel!.text = reminder.title
        cell.detailTextLabel!.text = (radius > 0) ?
            String(format: "%@: within %.2f miles of %@", proximity, radius, alarm?.structuredLocation?.title ?? "") :
            String(format: "%@: %@", proximity, alarm?.structuredLocation?.title ?? "")
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: EKLRRemindersCellID, for: indexPath)
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let reminder = self.reminders[indexPath.row]
            
            self.reminders = self.reminders.filter{$0 !== reminder}
            // Update the table view
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            LocationReminderStore.shared.remove(reminder)
        }
    }
    
    
    //MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    
    //MARK: - UITableView
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        // Remove the Edit button if there are no reminders
        if self.reminders.isEmpty {
            self.navigationItem.leftBarButtonItem = nil
        }
        self.navigationController!.isToolbarHidden = !editing
    }
    
    
    //MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self,
            name: NSNotification.Name(LTBRemindersFetchedNotification),
            object: nil)
    }
    
}
