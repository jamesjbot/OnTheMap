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
    let udacitySignUpURL = "https://www.udacity.com/account/auth#!/signup"
    
    // MARK: - IBActions
    
    // Target of Logout Unwinding
    @IBAction func unwindToLoginReceiver(_ segue:UIStoryboardSegue){
    }
    
    
    // Responds to presses on login button
    @IBAction func attempToLogin(_ sender: AnyObject) {
        myActivityIndicator.startAnimating()
        if FBSDKAccessToken.current() == nil {
            udacityClient.loginToUdacity(usernameTextField.text!, password: passwordTextField.text!,completionHandlerForLogin: loginToMapViewClosure)
        } else {
            udacityClient.loginToUdacityWithFacebook(FBSDKAccessToken.current().tokenString, completionHandlerForLogin: loginToMapViewClosure)
        }
        
    }
    
    @IBAction func signUp2Udacity(_ sender: AnyObject) {
        let url = udacitySignUpURL
        openURL(url)
    }
    
    // MARK: - Closure Expressions
    
    func loginToMapViewClosure(_ success: Bool?,error: NSError?) -> Void {
        self.stopAnimating()
        if success == true {
            performUIUpdatesOnMain {
                self.performSegue(withIdentifier: "LoginToMap", sender: self)
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
        myActivityIndicator.transform = CGAffineTransform(scaleX: 5, y: 5)
        subscribeToKeyboardShowNotifications()
        
        // Add facebook loginbutton relationships
        facebookButton.delegate = self
        facebookButton.readPermissions = ["public_profile"]

    }
    
    override func viewWillAppear(_ b: Bool){
        super.viewWillAppear(b)
    }
    
    // MARK: - UITextField Delegate methods
    
    // Return button enabled on soft keyboard to dismiss the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
    internal func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!){
        if error == nil && !result.isCancelled {
            myActivityIndicator.startAnimating()
            udacityClient.loginToUdacityWithFacebook(FBSDKAccessToken.current().tokenString, completionHandlerForLogin: loginToMapViewClosure)
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
    internal func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!){
        FBSDKLoginManager().logOut()
    }
    
    
}
