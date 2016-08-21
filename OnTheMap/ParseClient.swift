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
    private var model = Model.sharedInstance()
    
    // MARK: Functions
    
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
        let urlString = "\(Constants.URL)/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(input)%22%7D"
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
        let request = NSMutableURLRequest(URL: NSURL(string: "\(Constants.URL)/StudentLocation?\(MethodParameters.Limit100)&\(MethodParameters.ReverseCreationDateOrder)")!)
        formatRequestHeaders(request)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            self.guardChecks(data, response: response, error: error){
                (requestSuccess, error) -> Void in
                if requestSuccess {
                        self.parseResult(data) {
                        (dict, error) -> Void in
                        if error == nil {
                            self.parseLocations = dict!["results"] as! [[String : AnyObject]]

                            // Remove all current students in the model
                            Model.sharedInstance().deleteAllStudents()
                            for dictionary in self.parseLocations{ // Save the user information seperately
                                Model.sharedInstance().appendStudent(StudentInformation(id: dictionary))
                                if (dictionary["uniqueKey"] ?? "")as! String == Model.sharedInstance().getThisStudent().uniqueKey {
                                    // First and last name were populated when I logged into udacity
                                    var localStudentInfo = Model.sharedInstance().getThisStudent()
                                    localStudentInfo.latitude = dictionary["latitude"]?.description
                                    localStudentInfo.longitude = dictionary["longitude"]?.description
                                    localStudentInfo.mapString = dictionary["mapString"] as! String
                                    localStudentInfo.mediaURL = dictionary["mediaURL"] as! String
                                    localStudentInfo.objectId = dictionary["objectId"] as! String
                                    localStudentInfo.createdAt = dictionary["createdAt"] as! String
                                    Model.sharedInstance().setThisStudent(localStudentInfo)
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
                            self.updatedOurStudentInforamtionUpdatedAtTime(student, updateTime: newCreationTime)
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
        let urlString = "\(Constants.URL)/StudentLocation/\(Model.sharedInstance().getThisStudent().objectId)"
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
                            self.updatedOurStudentInforamtionUpdatedAtTime(student, updateTime: returnUpdatedTime)
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
    func updatedOurStudentInforamtionUpdatedAtTime(inputStudent: StudentInformation, updateTime: String){
        // Update the isolated version
        var updatedStudent = inputStudent
        updatedStudent.updatedAt = updateTime
        Model.sharedInstance().setThisStudent(updatedStudent)
        // Update the annotated version
        var allStudents = Model.sharedInstance().getStudents()
        for (index,info) in allStudents.enumerate(){
            if info.objectId == updatedStudent.objectId {
                allStudents[index] = updatedStudent
            }
        }
        Model.sharedInstance().setStudents(allStudents)
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
            sendError((error!.localizedDescription))
            return
        }
        
        // GUARD: There was no error from server; however server did not take further action
        guard (response as! NSHTTPURLResponse).statusCode != 403 else {
            sendError("Server not responding to request")
            return
        }
        
        // GUARD: Did we get successful 2XX response?
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            sendError("Your request returned a status code other than 2xx \((response as? NSHTTPURLResponse)!.statusCode)")
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