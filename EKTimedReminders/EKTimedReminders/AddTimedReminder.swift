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
    
    
    private var displayedDate: Date!
    // Height of the date picker view
    private var pickerCellRowHeight: CGFloat = 0
    // keep track of which indexPath points to the cell with UIDatePicker
    private var datePickerIndexPath: IndexPath?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.displayedDate = Date()
        let pickerViewCellToCheck = self.tableView.dequeueReusableCell(withIdentifier: EKTRAddTimedReminderDatePickerID)!
        self.pickerCellRowHeight = pickerViewCellToCheck.frame.size.height
    }
    
    
    //MARK: - Handle User Text Input
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let titleCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))!
        let myTextField = titleCell.viewWithTag(EKTRAddTimedReminderTitleTag) as! UITextField
        
        // When the user presses return, take focus away from the text field so that the keyboard is dismissed.
        if textField === myTextField {
            textField.resignFirstResponder()
        }
        // Enable the Done button if and only if the user has entered a title for the reminder
        if !(myTextField.text?.isEmpty ?? true) {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        return true
    }
    
    
    //MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (self.indexPathHasPicker(indexPath) && indexPath.section == 1) ? self.pickerCellRowHeight : self.tableView.rowHeight
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 3
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 1
        if section == 1 {
            // Show 3 rows if the date picker is shown and 2, otherwise
            numberOfRows = self.hasInlineDatePicker ? EKTRAddTimedReminderNumberOfRowsWithDatePicker : EKTRAddTimedReminderNumberOfRowsWithoutDatePicker
        }
        // Return the number of rows in the section
        return numberOfRows
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && self.indexPathHasDate(indexPath) {
            cell.detailTextLabel?.text = EKRSHelperClass.dateFormatter.string(from: self.displayedDate)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        
        return tableView.dequeueReusableCell(withIdentifier: cellID!, for: indexPath)
    }
    
    
    //MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
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
    private func indexPathHasPicker(_ indexPath: IndexPath) -> Bool {
        return self.hasInlineDatePicker && self.datePickerIndexPath?.row == indexPath.row
    }
    
    
    // Determines if the given indexPath points to a cell that contains the start/end dates.
    private func indexPathHasDate(_ indexPath: IndexPath) -> Bool {
        var hasDate = false
        
        if indexPath.row == EKTRAddTimedReminderMeOnDateRow {
            hasDate = true
        }
        return hasDate
    }
    
    
    // Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath"
    private func displayDatePickerInlineForRowAtIndexPath(_ indexPath: IndexPath) {
        self.tableView.beginUpdates()
        
        // Show the picker if date cell was selected and picker is not shown
        if self.hasInlineDatePicker {
            self.hideDatePickerAtIndexPath(indexPath)
            self.datePickerIndexPath = nil
            // Hide the picker if date cell was selected and picker is shown
        } else {
            self.addDatePickerAtIndexPath(indexPath)
            self.datePickerIndexPath = IndexPath(row: indexPath.row+1, section: 1)
        }
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        self.tableView.endUpdates()
        self.updateDatePicker()
    }
    
    
    // Add the date picker view to the UI
    private func addDatePickerAtIndexPath(_ indexPath: IndexPath) {
        
        let indexPaths = [IndexPath(row: indexPath.row+1, section: 1)]
        self.tableView.insertRows(at: indexPaths,
            with: .fade)
    }
    
    
    // Remove the date picker view to the UI
    private func hideDatePickerAtIndexPath(_ indexPath: IndexPath) {
        let indexPaths = [IndexPath(row: indexPath.row+1, section: 1)]
        self.tableView.deleteRows(at: indexPaths,
            with: .fade)
    }
    
    
    // Update the UIDatePicker's value to match with the date of the cell above it
    private func updateDatePicker() {
        if let indexPath = self.datePickerIndexPath {
            let datePickerCell = self.tableView.cellForRow(at: indexPath)!
            
            if let datePicker = datePickerCell.viewWithTag(EKTRAddTimedReminderDatePickerTag) as? UIDatePicker {
                datePicker.date = self.displayedDate
            }
        }
    }
    
    
    // Called when the user selects a date from the date picker view. Update the displayed date.
    @IBAction func datePickerValueChanged(_ datePicker: UIDatePicker) {
        if self.hasInlineDatePicker {
            let dateCellIndexPath = IndexPath(row: self.datePickerIndexPath!.row-1, section: 1)
            
            let cell = self.tableView.cellForRow(at: dateCellIndexPath)
            // Update the displayed date
            cell?.detailTextLabel?.text = EKRSHelperClass.dateFormatter.string(from: datePicker.date)
            self.displayedDate = datePicker.date
        }
    }
    
    
    //MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == EKTRAddTimedReminderShowSegue {
            let repeatViewController = segue.destination as! RepeatViewController
            var frequencyCell: UITableViewCell? = nil
            
            if self.hasInlineDatePicker {
                frequencyCell = self.tableView.cellForRow(at: IndexPath(row: 2, section: 1))
            } else {
                frequencyCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 1))
            }
            
            repeatViewController.displayedFrequency = frequencyCell?.detailTextLabel!.text
        } else if segue.identifier == EKTRAddTimedReminderUnwindSegue {
            let titleCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))!
            let textField = titleCell.viewWithTag(EKTRAddTimedReminderTitleTag) as! UITextField
            
            
            let dateCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1))!
            let date = EKRSHelperClass.dateFormatter.date(from: dateCell.detailTextLabel!.text!)
            
            
            var frequencyCell: UITableViewCell? = nil
            if self.hasInlineDatePicker {
                frequencyCell = self.tableView.cellForRow(at: IndexPath(row: 2, section: 1))
            } else {
                frequencyCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 1))
            }
            
            let priorityCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2))
            let prioritySegmentControl = priorityCell?.viewWithTag(EKTRAddTimedReminderPriorityTag) as! UISegmentedControl
            let priority = prioritySegmentControl.titleForSegment(at: prioritySegmentControl.selectedSegmentIndex)
            
            
            
            self.reminder = TimedReminder(title: textField.text!,
                startDate: date!,
                frequency: frequencyCell!.detailTextLabel!.text!,
                priority: priority!)
        }
    }
    
    
    // Unwind action from the Repeat view controller
    @IBAction func unwindToAddTimedReminders(_ sender: UIStoryboardSegue) {
        let repeatViewController = sender.source as! RepeatViewController
        var frequencyCell: UITableViewCell? = nil
        
        // The frequency cell is at row 2 when the date picker is shown and at row 1, otherwise
        if self.hasInlineDatePicker {
            frequencyCell = self.tableView.cellForRow(at: IndexPath(row: 2, section: 1))
        } else {
            frequencyCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 1))
        }
        // Display the frequency value
        frequencyCell?.detailTextLabel?.text = repeatViewController.displayedFrequency
    }
    
    
    //MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
