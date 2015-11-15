//
//  AddLocationReminder.swift
//  EKLocationReminders
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/15.
//
//
/*

 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This view controller allows you to enter the title, proximity, and geofence's radius for a new location-based reminder.

 */
import UIKit
import EventKit
import MapKit

@objc(AddLocationReminder)
class AddLocationReminder: UITableViewController, UITextFieldDelegate {
    let reminder: LocationReminder? = nil //### Why this is needed?
    // Location's name
    var name: String?
    // Location's address
    var address: String?
    // Used to pass back the user input to the Map view controller
    var userInput: [String: AnyObject] = [:]
    
    @IBOutlet private weak var radiusLabel: UITextField!
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var proximitySegmentControl: UISegmentedControl!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var addressName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Display the name and address of the location associated with this new reminder
        self.nameLabel.text = "Location: \(self.name ?? "")"
        self.addressName.text = self.address
    }
    
    
    //MARK: - Handle User Text Input
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // When the user presses return, take focus away from the text field so
        // that the keyboard is dismissed.
        textField.resignFirstResponder()
        if !(self.titleTextField.text?.isEmpty ?? true) && !(self.radiusLabel.text?.isEmpty ?? true) {
            self.navigationItem.rightBarButtonItem!.enabled = true
        }
        
        return true
    }
    
    
    //MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "unwindToMapViewController" {
            // Fetch the proximity value, which is either Arriving (EKAlarmProximityEnter) or Leaving (EKAlarmProximityLeave)
            let proximity = self.proximitySegmentControl.titleForSegmentAtIndex(self.proximitySegmentControl.selectedSegmentIndex)
            // Return the entered title, proximity, and radius
            self.userInput = [EKRSTitle: self.titleTextField.text ?? "", EKRSLocationProximity: proximity ?? "", EKRSLocationRadius: Double(self.radiusLabel.text ?? "0") ?? 0.0]
        }
    }
    
    
    //MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}