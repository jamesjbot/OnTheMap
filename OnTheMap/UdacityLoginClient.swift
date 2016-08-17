//
//  UdacityLogin.swift
//  OnTheMap
//
//  Created by James Jongsurasithiwat on 5/2/16.
//  Copyright © 2016 James Jongs. All rights reserved.
//

import Foundation
import UIKit

class UdacityLoginClient {
    
    // MARK:  Variables
    
    private var uniqueKey: String = ""
    private var logAgain: String = "\nPlease Login Again"
    private var model = Model.sharedInstance()
    private var thisStudentInformation: StudentInformation = Model.sharedInstance().getThisStudent()
    
    // MARK: Functions
    
    // Will create a login Session with udacity and pull any Udacity user public information
    func loginToUdacity(username: String, password: String, completionHandlerForLogin: (requestSuccess: Bool?, error: NSError? )-> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "\(Constants.UdacityURL)\(Methods.Session)")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            self.guardChecks(data,response: response, error: error) {
                (success, error) -> Void in
                if success == true {
                    // Parsing data
                    self.parseResult(data) {dict, error in
                        if error == nil {
                            let dicOfLoginData = dict!["account"] as! NSDictionary
                            self.uniqueKey = dicOfLoginData["key"] as! String
                            // Store the key in the model for later use
                            self.thisStudentInformation.uniqueKey = self.uniqueKey
                            // Get and store public user data
                            Model.sharedInstance().setThisStudent(self.thisStudentInformation)
                            self.getUserPublicData(completionHandlerForLogin)
                        } else {
                            completionHandlerForLogin(requestSuccess: false, error: error)
                            return
                        }
                    }
                } else {
                    completionHandlerForLogin(requestSuccess: false, error: error)
                    return
                }
            }
        }
        task.resume()
    }
    
    // Method to login with Facebook access token
    func loginToUdacityWithFacebook(token: String, completionHandlerForLogin: (requestSuccess:Bool?,error: NSError?)-> Void){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"facebook_mobile\": {\"access_token\": \"\(token)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            self.guardChecks(data,response: response, error: error) {
                (success, error) -> Void in
                if success == true {
                    // Parsing data
                    self.parseResult(data) {dict, error in
                        if error == nil {
                            let dicOfLoginData = dict!["account"] as! NSDictionary
                            self.uniqueKey = dicOfLoginData["key"] as! String
                            // Store the key in the model for later use
                            self.thisStudentInformation.uniqueKey = self.uniqueKey
                            // Get and store public user data
                            Model.sharedInstance().setThisStudent(self.thisStudentInformation)
                            self.getUserPublicData(completionHandlerForLogin)
                        } else {
                            completionHandlerForLogin(requestSuccess: false, error: error)
                            return
                        }
                    }
                } else {
                    completionHandlerForLogin(requestSuccess: false, error: error)
                    return
                }
            }
        }
        task.resume()
    }
    
    
    func logOutOfUdacity(presentingView:UIViewController, completionHandlerForLogout: (requestSuccess: Bool?, error: NSError?)-> Void){
        let request = NSMutableURLRequest(URL: NSURL(string: "\(Constants.UdacityURL)\(Methods.Session)")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            self.guardChecks(data,response: response, error: error) {
                (success, error) -> Void in
                if success == true {
                    // Parsing data
                    self.parseResult(data) {dict, error in
                        if error == nil{
                            completionHandlerForLogout(requestSuccess: true, error: nil)
                        } else {
                            completionHandlerForLogout(requestSuccess: false, error: error)
                            return
                        }
                    }
                } else {
                    completionHandlerForLogout(requestSuccess: false, error: error)
                    return
                }
            }
        }
        task.resume()
        
    }
    
    
    // MARK: Get User Public Data From Udacity
    
    // Function to GET the user public data from udacity
    func getUserPublicData(completionHandlerForPublicData: (requestSuccess: Bool?, error: NSError? )-> Void){
        let request = NSMutableURLRequest(URL: NSURL(string: "\(Constants.UdacityURL)\(Methods.Users)/\(uniqueKey)")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            self.guardChecks(data,response: response, error: error){
                (success, error)-> Void in
                // Parsing data
                if success == true {
                    self.parseResult(data) { dict, error in
                        if error == nil {
                            let dicOfLoginData = dict!["user"] as! NSDictionary
                            let lastname: String = dicOfLoginData["last_name"] as! String
                            let firstname: String = dicOfLoginData["first_name"] as! String
                            self.thisStudentInformation.lastName = lastname
                            self.thisStudentInformation.firstName = firstname
                            Model.sharedInstance().setThisStudent(self.thisStudentInformation)
                            completionHandlerForPublicData(requestSuccess: true, error: nil)
                            return
                        } else {
                            completionHandlerForPublicData(requestSuccess: false, error: error)
                            return
                        }
                    }
                } else {
                    completionHandlerForPublicData(requestSuccess: false, error: error)
                }
            }
        }
        task.resume()
    }
    
    private func parseResult(data: NSData?, completionHandlerForParsingData: (parsedDictionary: NSDictionary?, error: NSError?)-> Void) {
        let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
        var parsedResult: NSDictionary
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments) as! NSDictionary
            completionHandlerForParsingData(parsedDictionary: parsedResult, error: nil)
            return
        } catch {
            let userInfo : [NSObject:AnyObject]? = [NSLocalizedDescriptionKey: "Error Parsing User Information\(logAgain)"]
            completionHandlerForParsingData(parsedDictionary: nil, error: NSError(domain: "parseResult", code: 1, userInfo: userInfo))
            return
        }
    }
    
    private func guardChecks(data: NSData?, response: NSURLResponse?, error: NSError?, completionHandlerForGuardChecks: (requestSuccess: Bool?, error: NSError?)-> Void){
        
        func sendError(error: String) {
            let userInfo = [NSLocalizedDescriptionKey : error]
            completionHandlerForGuardChecks(requestSuccess: false, error: NSError(domain: "loginToUdacity", code: 1, userInfo: userInfo))
        }
        
        // GUARD: For any error
        guard (error == nil) else { // Handle error...
            sendError("\(error!.localizedDescription)\(logAgain)")
            return
        }
        
        // GUARD: There was no error from server; however server did not take further action
        guard let statuscode: Int = (response as! NSHTTPURLResponse).statusCode where statuscode != 403 else {
            sendError("Invalid login credentials \(logAgain)")
            return
        }
        
        // GUARD: Did we get successful 2XX response?
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            sendError("There was an error logging in\(logAgain)")
            return
        }
        
        // GUARD: Was there data returned?
        guard let _ = data else {
            sendError("No data was returned by the request!\(logAgain)")
            return
        }
        
        completionHandlerForGuardChecks(requestSuccess: true, error: nil)
    }
    
    
    // MARK: - Singleton Implementation
    private init(){}
    
    class func sharedInstance()-> UdacityLoginClient{
        struct Singleton {
            static var sharedInstance = UdacityLoginClient()
        }
        return Singleton.sharedInstance
        
    }
    
}
