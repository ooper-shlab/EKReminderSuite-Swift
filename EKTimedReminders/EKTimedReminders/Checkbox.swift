//
//  Checkbox.swift
//  EKTimedReminders
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/15.
//
//
/*

 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 A UIControl subclass that implements a checkbox.

 */
import UIKit

@objc(Checkbox)
class Checkbox: UIControl {
    
    // State of the checkbox
    var checked: Bool = false {
        didSet {
            didSetChecked(oldValue)
        }
    }
    
    
    //  This method is overridden to draw the control using Quartz2D.
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        let size = min(self.bounds.size.width, self.bounds.size.height)
        var transform = CGAffineTransformIdentity
        
        // Account for non-square frames.
        if self.bounds.size.width < self.bounds.size.height {
            // Vertical Center
            transform = CGAffineTransformMakeTranslation(0, (self.bounds.size.height - size)/2)
        } else if self.bounds.size.width > self.bounds.size.height {
            // Horizontal Center
            transform = CGAffineTransformMakeTranslation((self.bounds.size.width - size)/2, 0)
        }
        
        // Draw the checkbox
        do {
            let strokeWidth = 0.068359375 * size
            let checkBoxInset = 0.171875 * size
            
            let checkboxRect = CGRectMake(checkBoxInset, checkBoxInset, size - checkBoxInset*2, size - checkBoxInset*2)
            let checkboxPath = UIBezierPath(rect: checkboxRect)
            
            checkboxPath.applyTransform(transform)
            
            self.tintColor = UIColor.blackColor()
            self.tintColor.setStroke()
            
            checkboxPath.lineWidth = strokeWidth
            
            checkboxPath.stroke()
        }
        
        // Draw the checkmark if self.checked==YES
        if self.checked {
            // The checkmark is drawn as a bezier path using Quartz2D.
            // The control points for this path are stored (hardcoded) as normalized
            // values so that the path can be accurately reconstructed at any size.
            
            // A small macro to scale the normalized control points for the
            // checkmark bezier path to the size of the control.
            func P(POINT: CGFloat) -> CGFloat {return POINT * size}
            
            CGContextSetGrayFillColor(context, 0.0, 1.0)
            CGContextConcatCTM(context, transform)
            
            CGContextBeginPath(context)
            CGContextMoveToPoint(context,
                P(0.304), P(0.425))
            CGContextAddLineToPoint(context, P(0.396), P(0.361))
            CGContextAddCurveToPoint(context,
                P(0.396), P(0.361),
                P(0.453), P(0.392),
                P(0.5), P(0.511))
            CGContextAddCurveToPoint(context,
                P(0.703), P(0.181),
                P(0.988), P(0.015),
                P(0.988), P(0.015))
            CGContextAddLineToPoint(context, P(0.998), P(0.044))
            CGContextAddCurveToPoint(context,
                P(0.998), P(0.044),
                P(0.769), P(0.212),
                P(0.558), P(0.605))
            CGContextAddLineToPoint(context, P(0.458), P(0.681))
            CGContextAddCurveToPoint(context,
                P(0.365), P(0.451),
                P(0.304), P(0.425),
                P(0.302), P(0.425))
            CGContextClosePath(context)
            
            CGContextFillPath(context)
            
        }
    }
    
    
    //MARK: - Control Methods
    
    // Custom implementation of the setter for the 'checked' property.
    private func didSetChecked(_checked: Bool) {
        if checked != _checked {
            
            // Flag ourself as needing to be redrawn.
            self.setNeedsDisplay()
            
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
        }
    }
    
    
    //  Sends action messages for the given control events along with the UIEvent which triggered them.
    //  UIControl provides the -sendActionsForControlEvents: method to send action
    //  messages associated with controlEvents.  A limitation of
    //  -sendActionsForControlEvents is that it does not include the UIEvent that
    //  triggered the controlEvents with the action messages.
    //
    //  AccessoryViewController and CustomAccessoryViewController rely on receiving
    //  the underlying UIEvent when their associated IBActions are invoked.
    //  This method functions identically to -sendActionsForControlEvents:
    //  but accepts a UIEvent that is sent with the action messages.
    func sendActionsForControlEvents(controlEvents: UIControlEvents, withEvent event: UIEvent?) {
        let allTargets = self.allTargets()
        
        for target in allTargets {
            let actionsForTarget = self.actionsForTarget(target, forControlEvent: controlEvents)
            
            // Actions are returned as NSString objects, where each string is the
            // selector for the action.
            for action in actionsForTarget ?? [] {
                let selector = Selector(action)
                self.sendAction(selector, to: target, forEvent: event)
            }
        }
    }
    
    
    //  If you override one of the touch event callbacks, you should override all of them.
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
    
    
    //  If you override one of the touch event callbacks, you should override all of them.
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
    
    
    //  This is the touch callback we are interested in.  If there is a touch inside
    //  our bounds, toggle our checked state and notify our target of the change.
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.first!.tapCount == 1 {
            // Toggle our state.
            self.checked = !self.checked
            
            // Notify our target (if we have one) of the change.
            self.sendActionsForControlEvents(.ValueChanged, withEvent: event)
        }
    }
    
    
    //  If you override one of the touch event callbacks, you should override all of them.
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
    }
    
    
    //MARK: -
    // If you implement a custom control, you should put in the extra work to
    // make it accessible.  Your users will appreciate it.
    //MARK: Accessibility
    
    
    //  Declare that this control is accessible element to assistive applications.
    override var isAccessibilityElement: Bool {
        get {
            return true
        }
        set {
            super.isAccessibilityElement = newValue
        }
    }
    
    
    // Note: accessibilityHint and accessibilityLabel should be configured
    // elsewhere because this control does not know its purpose as it relates to the program as a whole.
    override var accessibilityTraits: UIAccessibilityTraits {
        // Always combine our accessibilityTraits with the super's
        // accessibilityTraits
        get {
            return super.accessibilityTraits | UIAccessibilityTraitButton
        }
        set {
            super.accessibilityTraits = newValue
        }
    }
    
    
    override var accessibilityValue: String? {
        get {
            return self.checked ? "Enabled" : "Disabled"
        }
        set {
            super.accessibilityValue = newValue
        }
    }
    
}