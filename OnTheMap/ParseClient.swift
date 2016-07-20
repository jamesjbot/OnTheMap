//
//  ParseClient.swift
//  OnTheMap
//
//  Created by James Jongsurasithiwat on 5/5/16.
//  Copyright © 2016 James Jongs. All rights reserved.
//
import UIKit
import Foundation

class ParseClient {
    
    // MARK: Variables
    
    private var parseLocations: [[String : AnyObject]] = [[String : AnyObject]]()
    var model = Model.sharedInstance()
    
    // MARK: Functions
    
    // Function to sort Student Information structures, instead of using the api's sorting method
    func sortFunc(dict1: [String:AnyObject], dict2: [String:AnyObject]) -> Bool {
        if dict1[Keys.UpdatedAt] as! String > dict2[Keys.UpdatedAt] as! String {
            return true // When dictionary 1 goes before dictionary 2
        } else {
            return false
        }
    }
    
    // MARK: Convenience functions to help create url requests
    
    func formatRequest(request: NSMutableURLRequest, student: StudentInformation){
        formatRequestHeaders(request)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let bodyString: String = "{\"uniqueKey\": \"\(student.uniqueKey)\", \"firstName\": \"\(student.firstName)\", \"lastName\": \"\(student.lastName)\",\"mapString\": \"\(student.mapString)\", \"mediaURL\": \"\(student.mediaURL)\",\"latitude\": \(student.latitude), \"longitude\": \(student.longitude)}"
        request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    func formatRequestHeaders(request: NSMutableURLRequest){
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
    }
    
    // This function tells the view controller whether or not this student already has a location entry, this should just tell the viewcontroller whether or not present a warning
    func getThisStudentLocation(input: String, completionHandlerForGetThisStudentLocation: (success: Bool, present: Bool? ,error: NSError?) -> Void ){
        let urlString = "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(input)%22%7D"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        formatRequestHeaders(request)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            self.guardChecks(data, response: response, error: error) {
                (success, error) -> Void in
                if success {
                    self.parseResult(data) {
                        (dict, error) -> Void in
                        if error == nil {
                            let arrayDictionaries = dict!["results"] as! NSArray
                            if arrayDictionaries.count != 0 {
                                completionHandlerForGetThisStudentLocation(success: true, present: true, error: nil)
                                return
                            } else {
                                completionHandlerForGetThisStudentLocation(success: true, present: false, error: nil)
                                return
                            }
                        } else { // There was a parsing error
                            completionHandlerForGetThisStudentLocation(success: false, present: nil, error: error)
                        }
                    }
                } else { // there was a guard error
                    completionHandlerForGetThisStudentLocation(success: false, present: nil, error: error)
                }
            }
        }
        task.resume()
    }
    
    func getAllStudentLocationsAndRefreshView(completionHandlerFromGetAllStudents:(requestSuccess: Bool,error: NSError?) -> Void ) {
        let request = NSMutableURLRequest(URL: NSURL(string: "\(Constants.URL)/StudentLocation?\(MethodParameters.Limit100)")!)
        formatRequestHeaders(request)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            self.guardChecks(data, response: response, error: error){
                (requestSuccess, error) -> Void in
                if requestSuccess {
                        self.parseResult(data) {
                        (dict, error) -> Void in
                        if error == nil {
                            let arrayDictionaries = dict!["results"] as! NSArray
                            // Sorting Student Information objects
                            let unSortedArray:[[String : AnyObject]] = arrayDictionaries as! [[String : AnyObject]]
                            let sortedArray:[[String : AnyObject]] = unSortedArray.sort(self.sortFunc)
                            // These line saves the data into the model
                            self.parseLocations = sortedArray
                            // FIXME I should save these as studentinformation in the model
                            
                            
                            for dictionary in self.parseLocations{ // Save the user information specially
                                if dictionary["uniqueKey"] as! String == self.model.thisStudentInformation.uniqueKey {
                                    // First and last name were populated when I logged into udacity
                                    self.model.thisStudentInformation.latitude = dictionary["latitude"]?.description
                                    self.model.thisStudentInformation.longitude = dictionary["longitude"]?.description
                                    self.model.thisStudentInformation.mapString = dictionary["mapString"] as! String
                                    self.model.thisStudentInformation.mediaURL = dictionary["mediaURL"] as! String
                                    self.model.thisStudentInformation.objectId = dictionary["objectId"] as! String
                                    self.model.thisStudentInformation.createdAt = dictionary["createdAt"] as! String
                                }
                            }
                            completionHandlerFromGetAllStudents(requestSuccess: true, error: nil)
                        } else {
                            completionHandlerFromGetAllStudents(requestSuccess: false, error: error)
                        }
                    } // end of self.parseResult(data)
                } else { // Guard checks failed
                    completionHandlerFromGetAllStudents(requestSuccess: false, error: error)
                }
            } // End of guard checks
        } // end oftask
        task.resume()
    }
    
    // Posting student information to server
    func postThisStudentLocation(student: StudentInformation, completionHandlerForPost: (success: Bool, error: NSError?) ->Void ) {
        let request = NSMutableURLRequest(URL: NSURL(string: "\(Constants.URL)/StudentLocation")!)
        request.HTTPMethod = "POST"
        formatRequest(request, student: student)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            self.guardChecks(data, response: response, error: error){
                (requestSuccess, error) -> Void in
                if requestSuccess {
                    self.parseResult(data) {
                        (dict, error) -> Void in
                        if error == nil {
                            let newCreationTime = dict!["createdAt"] as! String
                            let newObjectID = dict!["objectId"] as! String
                            self.updatedOurStudentInforamtionUpdatedAtTime(newCreationTime)
                            self.model.thisStudentInformation.objectId = newObjectID
                            completionHandlerForPost(success: true, error: nil)
                        } else {
                            completionHandlerForPost(success: false, error: error)
                        }
                    }
                } else { // Guard checks failed
                    completionHandlerForPost(success: false, error: error)
                }
            }
        }
        task.resume()
        
    }
    
    // Update this student's location information
    func updateThisStudentLocation(student: StudentInformation, completionHandlerForUpdate: (success: Bool, error: NSError?) -> Void) {
        let urlString = "https://api.parse.com/1/classes/StudentLocation/\(self.model.thisStudentInformation.objectId)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        formatRequest(request,student: student)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            self.guardChecks(data, response: response, error: error){
                (requestSuccess, error) -> Void in
                if requestSuccess {
                    self.parseResult(data) {
                        (dict, error) -> Void in
                        if error == nil {
                            let returnUpdatedTime: String = dict!["updatedAt"] as! String
                            self.updatedOurStudentInforamtionUpdatedAtTime(returnUpdatedTime)
                            completionHandlerForUpdate(success: true, error: nil)
                        } else {
                            completionHandlerForUpdate(success: false, error: error)
                        }
                    }
                } else { // Guard checks failed
                    completionHandlerForUpdate(success: false, error: error)
                }
            }
        }
        task.resume()
    }
    
    // Update the student's informatin timestamp
    func updatedOurStudentInforamtionUpdatedAtTime(updateTime: String){
        self.model.thisStudentInformation.updatedAt = updateTime
    }
    
    // Generic parsing function
    private func parseResult(data: NSData?, completionHandlerForParsingData: (parsedDictionary: NSDictionary?, error: NSError?)-> Void) {
        var parsedResult: NSDictionary
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
            completionHandlerForParsingData(parsedDictionary: parsedResult, error: nil)
            return
        } catch {
            let userInfo : [NSObject:AnyObject]? = [NSLocalizedDescriptionKey: "Error Parsing Information\nPlease Try again"]
            completionHandlerForParsingData(parsedDictionary: nil, error: NSError(domain: "ParseClient", code: 1, userInfo: userInfo))
            return
        }
    }
    
    private func guardChecks(data: NSData?, response: NSURLResponse?, error: NSError?, completionHandlerForGuardChecks: (requestSuccess: Bool, error: NSError?)-> Void){
        
        func sendError(error: String) {
            let userInfo = [NSLocalizedDescriptionKey : error]
            completionHandlerForGuardChecks(requestSuccess: false, error: NSError(domain: "ParseClient", code: 1, userInfo: userInfo))
        }
        
        // GUARD: For any error
        guard (error == nil) else { // Handle error...
            sendError((error?.localizedDescription)!)
            return
        }
        
        // GUARD: There was no error from server; however server did not take further action
        guard (response as! NSHTTPURLResponse).statusCode != 403 else {
            sendError("Server not responding to request")
            return
        }
        
        // GUARD: Did we get successful 2XX response?
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            sendError("Your request returned a status code other than 2xx \((response as? NSHTTPURLResponse)?.statusCode)")
            return
        }
        
        // GUARD: Was there data returned?
        guard let _ = data else {
            sendError("No data was returned by the request!")
            return
        }
        

        
        completionHandlerForGuardChecks(requestSuccess: true, error: nil)
    }
    
    // MARK: - Singleton Implementation
    private init(){}
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}