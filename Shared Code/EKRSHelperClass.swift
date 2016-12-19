//
//  EKRSHelperClass.swift
//  EKTimedReminders
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/15.
//
//
/*

 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 A helper class that includes methods to create a date formatter, generate a custom date, and display an alert.

 */
import UIKit

let kMeter = 1609.344

@objc(EKRSHelperClass)
class EKRSHelperClass: NSObject {
    
    //MARK: - Date Formatter
    
    // Create a date formatter with a short date and time
    class var dateFormatter: DateFormatter {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = .short
        myDateFormatter.timeStyle = .short
        
        return myDateFormatter
    }
    
    
    //MARK: - Create a Date
    
    // Create a new date by adding a given number of days to the current date
    static func dateByAddingDays(_ day: Int) -> Date {
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        var dateComponents = DateComponents()
        dateComponents.day = day
        
        return gregorian.date(byAdding: dateComponents, to: Date())!
    }
    
    
    //MARK: - Create Alert Dialog
    
    // Return an alert with a given title and message
    //@discardableResult
    static func alert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title,
            message: message,
            preferredStyle: .actionSheet)
        
        
        let defaultAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
            style: .default,
            handler: {action in})
        
        alert.addAction(defaultAction)
        
        return alert
    }
    
}
