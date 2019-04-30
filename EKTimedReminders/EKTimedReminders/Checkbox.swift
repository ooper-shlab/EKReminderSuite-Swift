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
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        let size = min(self.bounds.size.width, self.bounds.size.height)
        var transform = CGAffineTransform.identity
        
        // Account for non-square frames.
        if self.bounds.size.width < self.bounds.size.height {
            // Vertical Center
            transform = CGAffineTransform(translationX: 0, y: (self.bounds.size.height - size)/2)
        } else if self.bounds.size.width > self.bounds.size.height {
            // Horizontal Center
            transform = CGAffineTransform(translationX: (self.bounds.size.width - size)/2, y: 0)
        }
        
        // Draw the checkbox
        do {
            let strokeWidth = 0.068359375 * size
            let checkBoxInset = 0.171875 * size
            
            let checkboxRect = CGRect(x: checkBoxInset, y: checkBoxInset, width: size - checkBoxInset*2, height: size - checkBoxInset*2)
            let checkboxPath = UIBezierPath(rect: checkboxRect)
            
            checkboxPath.apply(transform)
            
            self.tintColor = .black
            self.tintColor.setStroke()
            
            checkboxPath.lineWidth = strokeWidth
            
            checkboxPath.stroke()
        }
        
        // Draw the checkmark if self.checked==YES
        if self.checked, let context = context {
            // The checkmark is drawn as a bezier path using Quartz2D.
            // The control points for this path are stored (hardcoded) as normalized
            // values so that the path can be accurately reconstructed at any size.
            
            // A small macro to scale the normalized control points for the
            // checkmark bezier path to the size of the control.
            func P(_ POINT: CGFloat) -> CGFloat {return POINT * size}
            
            context.setFillColor(gray: 0.0, alpha: 1.0)
            context.concatenate(transform)
            
            context.beginPath()
            context.move(to: CGPoint(x: P(0.304), y: P(0.425)))
            context.addLine(to: CGPoint(x: P(0.396), y: P(0.361)))
            context.addCurve(to: CGPoint(x: P(0.396), y: P(0.361)),
                              control1: CGPoint(x: P(0.453), y: P(0.392)),
                              control2: CGPoint(x: P(0.5), y: P(0.511)))
            context.addCurve(to: CGPoint(x: P(0.703), y: P(0.181)),
                             control1: CGPoint(x: P(0.988), y: P(0.015)),
                             control2: CGPoint(x: P(0.988), y: P(0.015)))
            context.addLine(to: CGPoint(x: P(0.998), y: P(0.044)))
            context.addCurve(to: CGPoint(x: P(0.998), y: P(0.044)),
                             control1: CGPoint(x: P(0.769), y: P(0.212)),
                             control2: CGPoint(x: P(0.558), y: P(0.605)))
            context.addLine(to: CGPoint(x: P(0.458), y: P(0.681)))
            context.addCurve(to: CGPoint(x: P(0.365), y: P(0.451)),
                             control1: CGPoint(x: P(0.304), y: P(0.425)),
                             control2: CGPoint(x: P(0.302), y: P(0.425)))
            context.closePath()
            
            context.fillPath()
            
        }
    }
    
    
    //MARK: - Control Methods
    
    // Custom implementation of the setter for the 'checked' property.
    private func didSetChecked(_ _checked: Bool) {
        if checked != _checked {
            
            // Flag ourself as needing to be redrawn.
            self.setNeedsDisplay()
            
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: nil)
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
    func sendActionsForControlEvents(_ controlEvents: UIControl.Event, withEvent event: UIEvent?) {
        let allTargets = self.allTargets
        
        for target in allTargets {
            let actionsForTarget = self.actions(forTarget: target, forControlEvent: controlEvents)
            
            // Actions are returned as NSString objects, where each string is the
            // selector for the action.
            for action in actionsForTarget ?? [] {
                let selector = Selector(action)
                self.sendAction(selector, to: target, for: event)
            }
        }
    }
    
    
    //  If you override one of the touch event callbacks, you should override all of them.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    //  If you override one of the touch event callbacks, you should override all of them.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    //  This is the touch callback we are interested in.  If there is a touch inside
    //  our bounds, toggle our checked state and notify our target of the change.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first!.tapCount == 1 {
            // Toggle our state.
            self.checked = !self.checked
            
            // Notify our target (if we have one) of the change.
            self.sendActionsForControlEvents(.valueChanged, withEvent: event)
        }
    }
    
    
    //  If you override one of the touch event callbacks, you should override all of them.
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
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
            return [super.accessibilityTraits, .button]
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
