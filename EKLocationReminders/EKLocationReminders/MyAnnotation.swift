//
//  MyAnnotation.swift
//  EKLocationReminders
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/15.
//
//
/*

 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 Custom MKAnnotation object representing a generic location.

 */
import UIKit
import MapKit

@objc(MyAnnotation)
class MyAnnotation: NSObject, MKAnnotation {
    var address: String?
    
    var title: String?
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    
    init(title name: String?, latitude: Double, longitude: Double, address: String?) {
        self.title = name
        self.coordinate.latitude = latitude
        self.coordinate.longitude = longitude
        self.address = address
        super.init()
    }
    
}