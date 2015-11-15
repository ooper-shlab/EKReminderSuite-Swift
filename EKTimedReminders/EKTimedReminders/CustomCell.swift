//
//  CustomCell.swift
//  EKTimedReminders
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/15.
//
//
/*

 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 A custom UITableViewCell that contains a Checkbox control in addition to its accessory control.

 */
import UIKit

@objc(CustomCell)
class CustomCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var priority: UILabel!
    @IBOutlet weak var dateAndFrequency: UILabel!
    @IBOutlet weak var checkBox: Checkbox!
    
}