//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by James Jongsurasithiwat on 5/4/16.
//  Copyright © 2016 James Jongs. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    // MARK: - IB elements
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - IBActions
    
    @IBAction func unwindToLoginReceiver(segue:UIStoryboardSegue){
    }
    
    @IBAction func attempToLogin(sender: AnyObject) {
        myActivityIndicator.startAnimating()
        udacityClient.loginToUdacity(usernameTextField.text!, password: passwordTextField.text!) {
            (success, error) -> Void in
            self.stopAnimating()
            if success == true {
                performUIUpdatesOnMain {
                    self.performSegueWithIdentifier("LoginToMap", sender: self)
                }
            } else { // There is an error
                self.displayAlertWindow("Login Error", msg: (error!.localizedDescription) , actions: [self.dismissAction()])
            }
        }
    }
    
    
    // MARK: - Functions
    
    // Function to stop the spinner on the main ui thread
    func stopAnimating(){
        performUIUpdatesOnMain(){()-> Void in
            self.myActivityIndicator.stopAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        // Increase the size of Spinner
        myActivityIndicator.transform = CGAffineTransformMakeScale(5, 5)
        subscribeToKeyboardShowNotifications()
        
        // Add facebook login
        let loginButton = FBSDKLoginButton()
        loginButton.delegate = self
        loginButton.center = self.view.center
        self.view.addSubview(loginButton)
    }
    
    
    // MARK: - UITextField Delegate methods
    
    // Return button on soft keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    // MARK: - Facebook Login Delegate methods
    /*!
    @abstract Sent to the delegate when the button was used to login.
    @param loginButton the sender
    @param result The results of the login
    @param error The error (if any) from the login
    */
    public func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!){
        print("Logged into facebook successfully")
        print("The result is\(FBSDKAccessToken.currentAccessToken())")
    }
    
    /*!
    @abstract Sent to the delegate when the button was used to logout.
    @param loginButton The button that was clicked.
    */
    public func loginButtonDidLogOut(loginButton: FBSDKLoginButton!){
        print("Logged out of facebook succcessfully")
    }
    
    /*!
    @abstract Sent to the delegate when the button is about to login.
    @param loginButton the sender
    @return YES if the login should be allowed to proceed, NO otherwise
    */
    //optional public func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool
    
}