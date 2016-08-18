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
import FBSDKCoreKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    // MARK: - IB elements
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var facebookButton: FBSDKLoginButton!
    
    // MARK: - Variables
    
    var fbLoginManager: FBSDKLoginManager!
    
    // MARK: - IBActions
    
    // Target of Logout Unwinding
    @IBAction func unwindToLoginReceiver(segue:UIStoryboardSegue){
    }
    
    
    // Responds to presses on login button
    @IBAction func attempToLogin(sender: AnyObject) {
        myActivityIndicator.startAnimating()
        if FBSDKAccessToken.currentAccessToken() == nil {
            udacityClient.loginToUdacity(usernameTextField.text!, password: passwordTextField.text!,completionHandlerForLogin: loginToMapClosure)
        } else {
            udacityClient.loginToUdacityWithFacebook(FBSDKAccessToken.currentAccessToken().tokenString, completionHandlerForLogin: loginToMapClosure)
        }
        
    }
    
    // MARK: - Closure Expressions
    
    func loginToMapClosure(success: Bool?,error: NSError?) -> Void {
        self.stopAnimating()
        if success == true {
            performUIUpdatesOnMain {
                self.performSegueWithIdentifier("LoginToMap", sender: self)
            }
        } else { // There is an error
            self.displayAlertWindow("Login Error", msg: "Error logging in\nPlease try again" , actions: [self.dismissAction()])
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
        facebookButton.delegate = self
        fbLoginManager = FBSDKLoginManager()
    }
    
    override func viewWillAppear(b: Bool){
        super.viewWillAppear(b)
        // When Facebook is logged in we should only present the option to continue with facebook login on the login button as per Single Sign On style.
        if FBSDKAccessToken.currentAccessToken() != nil {
            loginButton.setTitle("Continue with Facebook Login", forState: UIControlState.Normal)
        }
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
    internal func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!){
        if error == nil && !result.isCancelled {
            myActivityIndicator.startAnimating()
            udacityClient.loginToUdacityWithFacebook(FBSDKAccessToken.currentAccessToken().tokenString, completionHandlerForLogin: loginToMapClosure)
        } else {
            result.isCancelled ?
                self.displayAlertWindow("Login Error", msg: "Cancelled Facebook Login,\n Supply Udacity Credentials" , actions: [self.dismissAction()])
                : self.displayAlertWindow("Login Error", msg: "Error logging in with Facebook\nPlease try again" , actions: [self.dismissAction()])
        }
        
    }
    
    /*!
    @abstract Sent to the delegate when the button was used to logout.
    @param loginButton The button that was clicked.
    */
    internal func loginButtonDidLogOut(loginButton: FBSDKLoginButton!){
        // Change the Login button back to normal and logout of Facebook
        self.loginButton.setTitle("Login", forState: UIControlState.Normal)
        FBSDKLoginManager().logOut()
    }
    
    
}