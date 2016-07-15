//
//  UIViewControllerExtension.swift
//  OnTheMap
//
//  Created by James Jongsurasithiwat on 6/13/16.
//  Copyright © 2016 James Jongs. All rights reserved.
//

import UIKit

extension UIViewController {
    
    var parseClient: ParseClient {
        get {return ParseClient.sharedInstance()}
    }
    
    
    var udacityClient: UdacityLoginClient{
        get {return UdacityLoginClient.sharedInstance() }
    }
    
    
    // MARK: Helper functions to reduce duplicaiton
    
    func logoutAsynchronously(){
        udacityClient.logOutOfUdacity(self) {
            (requestSuccess, error) -> Void in
            if error != nil {
                self.displayAlertWindow("Failure to Logout", msg: "(error?.localizedDescription)!\n Please Try Again", actions: [self.dismissAction()])
                return
            }
            self.unwindToLoginInitiation()
        }
    }
    
    
    // Callback action to perform segue to Login screen if successful.
    func unwindToLoginInitiation(){
        self.performSegueWithIdentifier("unwindToLoginSegueID", sender: self)
    }
    
    
    // MARK: Specialized alert displays for UIViewControllers
    func displayAlertWindow(title: String, msg: String, actions: [UIAlertAction]){
        performUIUpdatesOnMain() { () -> Void in
            let alertWindow: UIAlertController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
            for action in actions {
                alertWindow.addAction(action)
            }
            self.presentViewController(alertWindow, animated: true, completion: nil)
        }
    }
    
    
    func dismissAction()-> UIAlertAction {
        return UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil)
    }
    
    
    func checkStudentPostingStatusAndShowPostingScreen(completionHandlerCheckStudentPosting: (success: Bool, present: Bool?, error: NSError?)-> Void) {
        ParseClient.sharedInstance().getThisStudentLocation(UdacityLoginClient.sharedInstance().uniqueKey, completionHandlerForGetThisStudentLocation: completionHandlerCheckStudentPosting)
    }
}