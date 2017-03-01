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
    
    fileprivate var uniqueKey: String = ""
    fileprivate var logAgain: String = "\nPlease Login Again"
    fileprivate var model = Model.sharedInstance()
    fileprivate var thisStudentInformation: StudentInformation = Model.sharedInstance().getThisStudent()
    
    // MARK: Functions
    
    // Will create a login Session with udacity and pull any Udacity user public information
    func loginToUdacity(_ username: String, password: String, completionHandlerForLogin: @escaping (_ requestSuccess: Bool?, _ error: NSError? )-> Void) {
        let request = NSMutableURLRequest(url: URL(string: "\(Constants.UdacityURL)\(Methods.Session)")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let req = request as URLRequest
//        let t = session.dataTask(with: req) {
//            (data,resp,err) -> Void in
//        }
        let task = session.dataTask(with: req as URLRequest) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            self.guardChecks(data,response: response, error: error as NSError?) {
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
                            completionHandlerForLogin(false, error)
                            return
                        }
                    }
                } else {
                    completionHandlerForLogin(false, error)
                    return
                }
            }
        }
        task.resume()
    }
    
    // Method to login with Facebook access token
    func loginToUdacityWithFacebook(_ token: String, completionHandlerForLogin: @escaping (_ requestSuccess:Bool?,_ error: NSError?)-> Void){
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"facebook_mobile\": {\"access_token\": \"\(token)\"}}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            self.guardChecks(data,response: response, error: error as NSError?) {
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
                            completionHandlerForLogin(false, error)
                            return
                        }
                    }
                } else {
                    completionHandlerForLogin(false, error)
                    return
                }
            }
        }) 
        task.resume()
    }
    
    
    func logOutOfUdacity(_ presentingView:UIViewController, completionHandlerForLogout: @escaping (_ requestSuccess: Bool?, _ error: NSError?)-> Void){
        let request = NSMutableURLRequest(url: URL(string: "\(Constants.UdacityURL)\(Methods.Session)")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            self.guardChecks(data,response: response, error: error as NSError?) {
                (success, error) -> Void in
                if success == true {
                    // Parsing data
                    self.parseResult(data) {dict, error in
                        if error == nil{
                            completionHandlerForLogout(true, nil)
                        } else {
                            completionHandlerForLogout(false, error)
                            return
                        }
                    }
                } else {
                    completionHandlerForLogout(false, error)
                    return
                }
            }
        }) 
        task.resume()
        
    }
    
    
    // MARK: Get User Public Data From Udacity
    
    // Function to GET the user public data from udacity
    func getUserPublicData(_ completionHandlerForPublicData: @escaping (_ requestSuccess: Bool?, _ error: NSError? )-> Void){
        let request = NSMutableURLRequest(url: URL(string: "\(Constants.UdacityURL)\(Methods.Users)/\(uniqueKey)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            self.guardChecks(data,response: response, error: error as NSError?){
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
                            completionHandlerForPublicData(true, nil)
                            return
                        } else {
                            completionHandlerForPublicData(false, error)
                            return
                        }
                    }
                } else {
                    completionHandlerForPublicData(false, error)
                }
            }
        }) 
        task.resume()
    }
    
    fileprivate func parseResult(_ data: Data?, completionHandlerForParsingData: (_ parsedDictionary: NSDictionary?, _ error: NSError?)-> Void) {
        let range = NSMakeRange(5, data!.count - 5)
        let newData = data!.subdata(in: range.toRange()!)/* subset response data! */
        var parsedResult: NSDictionary
        do {
            parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! NSDictionary
            completionHandlerForParsingData(parsedResult, nil)
            return
        } catch {
            let userInfo : [AnyHashable: Any]? = [NSLocalizedDescriptionKey: "Error Parsing User Information\(logAgain)"]
            completionHandlerForParsingData(nil, NSError(domain: "parseResult", code: 1, userInfo: userInfo))
            return
        }
    }
    
    fileprivate func guardChecks(_ data: Data?, response: URLResponse?, error: NSError?, completionHandlerForGuardChecks: @escaping (_ requestSuccess: Bool?, _ error: NSError?)-> Void){
        
        func sendError(_ error: String) {
            let userInfo = [NSLocalizedDescriptionKey : error]
            completionHandlerForGuardChecks(false, NSError(domain: "loginToUdacity", code: 1, userInfo: userInfo))
        }
        
        // GUARD: For any error
        guard (error == nil) else { // Handle error...
            sendError("\(error!.localizedDescription)\(logAgain)")
            return
        }
        
        // GUARD: There was no error from server; however server did not take further action
        guard let statuscode: Int = (response as! HTTPURLResponse).statusCode , statuscode != 403 else {
            sendError("Invalid login credentials \(logAgain)")
            return
        }
        
        // GUARD: Did we get successful 2XX response?
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
            sendError("There was an error logging in\(logAgain)")
            return
        }
        
        // GUARD: Was there data returned?
        guard let _ = data else {
            sendError("No data was returned by the request!\(logAgain)")
            return
        }
        
        completionHandlerForGuardChecks(true, nil)
    }
    
    
    // MARK: - Singleton Implementation
    fileprivate init(){}
    
    class func sharedInstance()-> UdacityLoginClient{
        struct Singleton {
            static var sharedInstance = UdacityLoginClient()
        }
        return Singleton.sharedInstance
        
    }
    
}
