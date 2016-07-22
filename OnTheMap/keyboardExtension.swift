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
            let userInfo = notification.userInfo
            let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue// of CGRect
            return keyboardSize.CGRectValue().height
    }
    
    // Moves the view up prior to presenting keyboard
    func keyboardWillShow(notification: NSNotification){
        print("Keyboard will show called,\(notification)")
        print("current view position \(view.frame.origin)")
        print("current view size  \(view.frame.size)")
        view.autoresizesSubviews = false
        // Get height of keyboard and save it globally
        let myKeyboardHeight = getKeyboardHeight(notification)
        // Move the whole UIView up by the keyboard amount
        
        print("current view position \(view.frame.origin)")
        
        if myKeyboardHeight != 0 {
            view.transform = CGAffineTransformMakeTranslation(0,-myKeyboardHeight)
            print("new view position \(view.frame.origin)")
            
        }
        // Stop responding to keyboard will SHOW notificaions
        unsubscribeFromKeyboardShowNotifications()
        // Begin to respond to keyboard will HIDE notifications
        subscribeToKeyboardHideNotifications()
    }
    
    // Moves the view down when the keyboard is dismissed
    func keyboardWillHide(notification: NSNotification){
        print("keyboard will hide called,\(notification)")
        
                print("current view position \(view.frame.origin)")
        // Move the bottomTextFiled UIView down by the keyboard amount
        if getKeyboardHeight(notification) != 0 {
            view.autoresizesSubviews = false
            view.transform = CGAffineTransformMakeTranslation(0, 0)
            view.transform = CGAffineTransformMakeTranslation(0, -getKeyboardHeight(notification))
            print("current view position \(view.frame.origin)")
            print("current view size  \(view.frame.size)")
        }
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