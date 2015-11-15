//
//  RepeatViewController.swift
//  EKTimedReminders
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/15.
//
//
/*

 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This view controller allows you to select a recurrence frequency for a reminder, which is Never, Daily, Weekly, Biweekly, Monthly, or Yearly.
         It passes the selected frequency to the AddTimedReminder view controller via the prepareForSegue:sender: method.

 */
import UIKit

@objc(RepeatViewController)
class RepeatViewController: UITableViewController {
    // Keep track of the displayed frequency
    var displayedFrequency: String?
    
    private let EKTRFrequenciesListExtension = "plist"
    private let EKTRFrequenciesList = "FrequenciesList"
    
    // Cell identifier
    private let EKTRRepeatViewControllerCellID = "frequencyCellID"
    
    
    private var frequencies: [[String: String]] = []
    private var currentFrequencyOption: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch all frequency and description values
        let plistURL = NSBundle.mainBundle().URLForResource(EKTRFrequenciesList, withExtension: EKTRFrequenciesListExtension)!
        self.frequencies = NSArray(contentsOfURL: plistURL) as! [[String: String]]
    }
    
    
    //MARK: - Utilities
    
    // Return the description matching a given frequency's title
    //-(NSString *)descriptionMatchingTitle:(NSString *)title
    //{
    //    NSString *description = nil;
    //    for (NSDictionary *dictionary in self.frequencies)
    //    {
    //        if ([dictionary[EKRSTitle] isEqualToString:title])
    //        {
    //            description = dictionary[EKRSDescription];
    //        }
    //    }
    //    return description;
    //}
    
    
    // Return the frequency's title matching a given description
    //-(NSString *)titleMatchingDescription:(NSString *)description
    //{
    //    NSString *title = nil;
    //    for (NSDictionary *dictionary in self.frequencies)
    //    {
    //        if ([dictionary[EKRSDescription] isEqualToString:description])
    //        {
    //            title = dictionary[EKRSTitle];
    //        }
    //    }
    //    return title;
    //}
    
    
    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.frequencies.count
    }
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let dictionary = self.frequencies[indexPath.row]
        
        // Add a checkmark for the selected row
        if dictionary[EKRSTitle] == self.displayedFrequency {
            self.currentFrequencyOption = dictionary
            cell.accessoryType = .Checkmark
        }
        
        cell.textLabel!.text = dictionary[EKRSDescription]
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier(EKTRRepeatViewControllerCellID, forIndexPath: indexPath)
    }
    
    
    
    //MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let indexOfDisplayedFrequency = self.frequencies.indexOf{$0 == self.currentFrequencyOption}!
        
        // Check whether the same row was selected and return, if it was.
        if indexOfDisplayedFrequency == indexPath.row {
            return
        }
        
        let oldIndexPath = NSIndexPath(forRow: indexOfDisplayedFrequency, inSection: 0)
        
        let newCell = tableView.cellForRowAtIndexPath(indexPath)!
        if newCell.accessoryType == .None {
            newCell.accessoryType = .Checkmark
            self.currentFrequencyOption = self.frequencies[indexPath.row]
        }
        
        let oldCell = tableView.cellForRowAtIndexPath(oldIndexPath)!
        if oldCell.accessoryType == .Checkmark {
            oldCell.accessoryType = .None
        }
    }
    
    
    
    //MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Fetch the index for the current selected row
        let indexPath = self.tableView.indexPathForSelectedRow!
        // Update the displayed frequency with the one selected by the user
        self.displayedFrequency = self.frequencies[indexPath.row][EKRSTitle]
    }
    
    
    //MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}