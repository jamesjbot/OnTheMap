//
//  UIViewControllerExtension.swift
//  OnTheMap
//
//  Created by James Jongsurasithiwat on 6/13/16.
//  Copyright © 2016 James Jongs. All rights reserved.
//

import UIKit
import FBSDKLoginKit

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
            } else { // Success
                performUIUpdatesOnMain{
                    FBSDKLoginManager().logOut()
                    self.unwindToLoginInitiation()
                }
            }
        }

    }
    
    
    // Callback action to perform segue to Login screen if successful.
    func unwindToLoginInitiation(){
        self.performSegue(withIdentifier: "unwindToLoginSegueID", sender: self)
    }
    
    
    // MARK: Specialized alert displays for UIViewControllers
    func displayAlertWindow(_ title: String, msg: String, actions: [UIAlertAction]){
        performUIUpdatesOnMain() { () -> Void in
            let alertWindow: UIAlertController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
            for action in actions {
                alertWindow.addAction(action)
            }
            self.present(alertWindow, animated: true, completion: nil)
        }
    }
    
    
    func dismissAction()-> UIAlertAction {
        return UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil)
    }
    
    
    func checkStudentPostingStatusAndShowPostingScreen(_ completionHandlerCheckStudentPosting: @escaping (_ success: Bool, _ present: Bool?, _ error: NSError?)-> Void) {
        ParseClient.sharedInstance().getThisStudentLocation(Model.sharedInstance().getThisStudent().uniqueKey, completionHandlerForGetThisStudentLocation: completionHandlerCheckStudentPosting)
    }
    
    
    func openURL(_ personURL: String){
        let app = UIApplication.shared
        let url: String = (personURL)
        let targetURL: URL! = URL(string: url)
        if targetURL != nil && app.canOpenURL(targetURL) {
            app.openURL(targetURL)
        } else {
            displayAlertWindow("", msg: "Invalid Link", actions: [UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil)])
        }
    }
    
}
