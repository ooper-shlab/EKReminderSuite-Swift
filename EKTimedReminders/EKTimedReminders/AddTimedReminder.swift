//
//  AddTimedReminder.swift
//  EKTimedReminders
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/15.
//
//
/*

 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This view controller allows you to enter the title, priority, and alarm (time and frequency) information for a new reminder.

 */
import UIKit
import EventKit

@objc(AddTimedReminder)
class AddTimedReminder: UITableViewController, UITextFieldDelegate {
    // Used to pass back the user input to the AddTimedReminder view controller
    var reminder: TimedReminder?
    
    
    private let EKTRAddTimedReminderTitleTag = 10      // View tag identifying the title cell
    private let EKTRAddTimedReminderDatePickerTag = 11 // View tag identifying the date picker view
    private let EKTRAddTimedReminderPriorityTag = 12   // View tag identifying the priority segmented control
    
    private let EKTRAddTimedReminderMeOnDateRow = 0  // Index of row containing the "Remind me on" cell
    private let EKTRAddTimedReminderNumberOfRowsWithDatePicker = 3  // Number of rows when the date picker is shown
    private let EKTRAddTimedReminderNumberOfRowsWithoutDatePicker = 2  // Number of rows when the date picker is hidden
    
    private let EKTRAddTimedReminderTitleCellID = "titleCellID" // Cell containing the title
    private let EKTRAddTimedReminderDateCellID = "dateCellID"     // Cell containing the start date
    private let EKTRAddTimedReminderDatePickerID = "datePickerCellID" // Cell containing the date picker view
    private let EKTRAddTimedReminderFrequencyCellID = "frequencyCellID" // Cell with the frequency
    private let EKTRAddTimedReminderPriorityCellID = "priorityCellID" // Cell containing the priority segmented control
    
    private let EKTRAddTimedReminderAlarmSection = "ALARM"
    private let EKTRAddTimedReminderPrioritySection = "PRIORITY"
    
    private let EKTRAddTimedReminderShowSegue = "showRepeatViewController"
    private let EKTRAddTimedReminderUnwindSegue = "unwindToReminders"
    
    
    @NSCopying private var displayedDate: NSDate!
    // Height of the date picker view
    private var pickerCellRowHeight: CGFloat = 0
    // keep track of which indexPath points to the cell with UIDatePicker
    private var datePickerIndexPath: NSIndexPath?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.displayedDate = NSDate()
        let pickerViewCellToCheck = self.tableView.dequeueReusableCellWithIdentifier(EKTRAddTimedReminderDatePickerID)!
        self.pickerCellRowHeight = pickerViewCellToCheck.frame.size.height
    }
    
    
    //MARK: - Handle User Text Input
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let titleCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
        let myTextField = titleCell.viewWithTag(EKTRAddTimedReminderTitleTag) as! UITextField
        
        // When the user presses return, take focus away from the text field so that the keyboard is dismissed.
        if textField === myTextField {
            textField.resignFirstResponder()
        }
        // Enable the Done button if and only if the user has entered a title for the reminder
        if !(myTextField.text?.isEmpty ?? true) {
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
        return true
    }
    
    
    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (self.indexPathHasPicker(indexPath) && indexPath.section == 1) ? self.pickerCellRowHeight : self.tableView.rowHeight
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 3
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionHeaderTitle: String? = nil
        switch section {
        case 1:
            sectionHeaderTitle = EKTRAddTimedReminderAlarmSection
        case 2:
            sectionHeaderTitle = EKTRAddTimedReminderPrioritySection
            
        default:
            break
        }
        return sectionHeaderTitle
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 1
        if section == 1 {
            // Show 3 rows if the date picker is shown and 2, otherwise
            numberOfRows = self.hasInlineDatePicker ? EKTRAddTimedReminderNumberOfRowsWithDatePicker : EKTRAddTimedReminderNumberOfRowsWithoutDatePicker
        }
        // Return the number of rows in the section
        return numberOfRows
    }
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && self.indexPathHasDate(indexPath) {
            cell.detailTextLabel?.text = EKRSHelperClass.dateFormatter.stringFromDate(self.displayedDate)
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellID: String? = nil
        switch indexPath.section {
        case 0:
            cellID = EKTRAddTimedReminderTitleCellID
        case 1:
            if self.indexPathHasPicker(indexPath) {
                cellID = EKTRAddTimedReminderDatePickerID
            } else if self.indexPathHasDate(indexPath) {
                cellID = EKTRAddTimedReminderDateCellID
            } else {
                cellID = EKTRAddTimedReminderFrequencyCellID
            }
        case 2:
            cellID = EKTRAddTimedReminderPriorityCellID
            
        default:
            break
        }
        
        return tableView.dequeueReusableCellWithIdentifier(cellID!, forIndexPath: indexPath)
    }
    
    
    //MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.reuseIdentifier == EKTRAddTimedReminderDateCellID {
            self.displayDatePickerInlineForRowAtIndexPath(indexPath)
        }
    }
    
    
    //MARK: - Handle Date Picker
    
    // Determines if the UITableViewController has a UIDatePicker in any of its cells.
    var hasInlineDatePicker: Bool {
        return self.datePickerIndexPath != nil
    }
    
    
    // Determines if the given indexPath points to a cell that contains the UIDatePicker.
    private func indexPathHasPicker(indexPath: NSIndexPath) -> Bool {
        return self.hasInlineDatePicker && self.datePickerIndexPath?.row == indexPath.row
    }
    
    
    // Determines if the given indexPath points to a cell that contains the start/end dates.
    private func indexPathHasDate(indexPath: NSIndexPath) -> Bool {
        var hasDate = false
        
        if indexPath.row == EKTRAddTimedReminderMeOnDateRow {
            hasDate = true
        }
        return hasDate
    }
    
    
    // Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath"
    private func displayDatePickerInlineForRowAtIndexPath(indexPath: NSIndexPath) {
        self.tableView.beginUpdates()
        
        // Show the picker if date cell was selected and picker is not shown
        if self.hasInlineDatePicker {
            self.hideDatePickerAtIndexPath(indexPath)
            self.datePickerIndexPath = nil
            // Hide the picker if date cell was selected and picker is shown
        } else {
            self.addDatePickerAtIndexPath(indexPath)
            self.datePickerIndexPath = NSIndexPath(forRow: indexPath.row+1, inSection: 1)
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.tableView.endUpdates()
        self.updateDatePicker()
    }
    
    
    // Add the date picker view to the UI
    private func addDatePickerAtIndexPath(indexPath: NSIndexPath) {
        
        let indexPaths = [NSIndexPath(forRow: indexPath.row+1, inSection: 1)]
        self.tableView.insertRowsAtIndexPaths(indexPaths,
            withRowAnimation: .Fade)
    }
    
    
    // Remove the date picker view to the UI
    private func hideDatePickerAtIndexPath(indexPath: NSIndexPath) {
        let indexPaths = [NSIndexPath(forRow: indexPath.row+1, inSection: 1)]
        self.tableView.deleteRowsAtIndexPaths(indexPaths,
            withRowAnimation: .Fade)
    }
    
    
    // Update the UIDatePicker's value to match with the date of the cell above it
    private func updateDatePicker() {
        if let indexPath = self.datePickerIndexPath {
            let datePickerCell = self.tableView.cellForRowAtIndexPath(indexPath)!
            
            if let datePicker = datePickerCell.viewWithTag(EKTRAddTimedReminderDatePickerTag) as? UIDatePicker {
                datePicker.date = self.displayedDate
            }
        }
    }
    
    
    // Called when the user selects a date from the date picker view. Update the displayed date.
    @IBAction func datePickerValueChanged(datePicker: UIDatePicker) {
        if self.hasInlineDatePicker {
            let dateCellIndexPath = NSIndexPath(forRow: self.datePickerIndexPath!.row-1, inSection: 1)
            
            let cell = self.tableView.cellForRowAtIndexPath(dateCellIndexPath)
            // Update the displayed date
            cell?.detailTextLabel?.text = EKRSHelperClass.dateFormatter.stringFromDate(datePicker.date)
            self.displayedDate = datePicker.date
        }
    }
    
    
    //MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == EKTRAddTimedReminderShowSegue {
            let repeatViewController = segue.destinationViewController as! RepeatViewController
            var frequencyCell: UITableViewCell? = nil
            
            if self.hasInlineDatePicker {
                frequencyCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 1))
            } else {
                frequencyCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1))
            }
            
            repeatViewController.displayedFrequency = frequencyCell?.detailTextLabel!.text
        } else if segue.identifier == EKTRAddTimedReminderUnwindSegue {
            let titleCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
            let textField = titleCell.viewWithTag(EKTRAddTimedReminderTitleTag) as! UITextField
            
            
            let dateCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1))!
            let date = EKRSHelperClass.dateFormatter.dateFromString(dateCell.detailTextLabel!.text!)
            
            
            var frequencyCell: UITableViewCell? = nil
            if self.hasInlineDatePicker {
                frequencyCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 1))
            } else {
                frequencyCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1))
            }
            
            let priorityCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2))
            let prioritySegmentControl = priorityCell?.viewWithTag(EKTRAddTimedReminderPriorityTag) as! UISegmentedControl
            let priority = prioritySegmentControl.titleForSegmentAtIndex(prioritySegmentControl.selectedSegmentIndex)
            
            
            
            self.reminder = TimedReminder(title: textField.text!,
                startDate: date!,
                frequency: frequencyCell!.detailTextLabel!.text!,
                priority: priority!)
        }
    }
    
    
    // Unwind action from the Repeat view controller
    @IBAction func unwindToAddTimedReminders(sender: UIStoryboardSegue) {
        let repeatViewController = sender.sourceViewController as! RepeatViewController
        var frequencyCell: UITableViewCell? = nil
        
        // The frequency cell is at row 2 when the date picker is shown and at row 1, otherwise
        if self.hasInlineDatePicker {
            frequencyCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 1))
        } else {
            frequencyCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1))
        }
        // Display the frequency value
        frequencyCell?.detailTextLabel?.text = repeatViewController.displayedFrequency
    }
    
    
    //MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}