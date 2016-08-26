//
//  keyboardExtension.swift
//  OnTheMap
//
//  Created by James Jongsurasithiwat on 7/14/16.
//  Copyright © 2016 James Jongs. All rights reserved.
//

import UIKit
extension UIViewController {
    /**
     
     
     Keyboard elevating functions
        
     **/
     // MARK: - Keyboard elevating functions
     
     // Generates a keyboard height for the bottom textfield, generates 0 for top textfield
    func getKeyboardHeight(notification:NSNotification) -> CGFloat {
        let keyboardSize = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue// of CGRect
        /** For the login view controller we do not want to move by the full height just enough to clear editable fields so save the stackview's offset and calculate the edge of the lowest editable UITextfield
        then accomodate the keyboard
        **/
        if self is LoginViewController {
            let topedgeofkeyboard = ( self.view.frame.height ) - (keyboardSize.CGRectValue().height)
            for uiStackViewSubview in self.view.subviews {
                guard uiStackViewSubview is UIStackView else { continue }
                var countUITextfields = 0
                for stackcell in uiStackViewSubview.subviews {
                    guard stackcell is UITextField else { continue }
                    countUITextfields += 1
                    guard countUITextfields == 2 else { continue }
                    let bottom = stackcell.frame.maxY + uiStackViewSubview.frame.minY // bottom + stackviewoffset
                    if ( countUITextfields == 2 ) && ( CGFloat(topedgeofkeyboard) < bottom ) {
                        // Someparts of the textfields blocked move up by diffence from bottom
                        let movementAmt = bottom - CGFloat(topedgeofkeyboard)
                        return CGFloat(movementAmt)
                    } else { // No movement necessary
                        return CGFloat(0)
                    }
                }
            }
        }
        // All other viewcontrollers
        return keyboardSize.CGRectValue().height
    }
    
    // Moves the view up prior to presenting keyboard
    func keyboardWillShow(notification: NSNotification){
        
        view.autoresizesSubviews = false
        // Get height of keyboard and save it globally
        let myKeyboardHeight = getKeyboardHeight(notification)
        // Move the whole UIView up by the keyboard amount
        
        if myKeyboardHeight != 0 {
            view.autoresizingMask  = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
            view.transform = CGAffineTransformMakeTranslation(0,-myKeyboardHeight)
        }
        // Stop responding to keyboard will SHOW notificaions
        unsubscribeFromKeyboardShowNotifications()
        // Begin to respond to keyboard will HIDE notifications
        subscribeToKeyboardHideNotifications()
    }
    
    // Moves the view down when the keyboard is dismissed
    func keyboardWillHide(notification: NSNotification){
        // Move the bottomTextFiled UIView down by the keyboard amount
        if getKeyboardHeight(notification) != 0 {
            // This allows autolayout in portrait mode, to adjust the Location Textview dynamically. Otherwise the view will autosize and be the incorrect size on screen.
            view.autoresizingMask = UIViewAutoresizing.FlexibleWidth
            view.transform = CGAffineTransformMakeTranslation(0, 0)

        }
        // This restores the autosizing properties
        view.autoresizingMask  = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        unsubscribeFromKeyboardHideNotifications()
        subscribeToKeyboardShowNotifications()
    }
    
    // Subscribes to the notification center for keyboard appearances
    func subscribeToKeyboardShowNotifications(){
        // Notify this view controller when keyboard will show
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    // Subscribes to the notification center for keyboard disappearances
    func subscribeToKeyboardHideNotifications(){
        // Notify this viewcontroller when keyboard will hide
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /// Unsubscribes to the notification center for keyboard appearnaces
    func unsubscribeFromKeyboardShowNotifications(){
        // Stop notifying this view controller when the keyboard will show
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillShowNotification, object: nil)
    }
    
    /// Unscubscribes to the notification center for keyboard disappearances
    func unsubscribeFromKeyboardHideNotifications(){
        // Stop notifying this view controller when the keyboard will hide
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
}