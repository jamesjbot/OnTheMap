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
    
    fileprivate var parseLocations: [[String : AnyObject]] = [[String : AnyObject]]()
    fileprivate var model = Model.sharedInstance()
    
    // MARK: Functions
    
    // MARK: Convenience functions to help create url requests
    
    func formatRequest( _ request: NSMutableURLRequest, student: StudentInformation) -> NSMutableURLRequest {
        formatRequestHeaders(request)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let bodyString: String = "{\"uniqueKey\": \"\(student.uniqueKey!)\", \"firstName\": \"\(student.firstName!)\", \"lastName\": \"\(student.lastName!)\",\"mapString\": \"\(student.mapString!)\", \"mediaURL\": \"\(student.mediaURL!)\",\"latitude\": \(student.latitude!), \"longitude\": \(student.longitude!)}"
        request.httpBody = bodyString.data(using: String.Encoding.utf8)
        return request
    }
    
    func formatRequestHeaders(_ request: NSMutableURLRequest){
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
    }
    
    // This function tells the view controller whether or not this student already has a location entry, this should just tell the viewcontroller whether or not present a warning
    func getThisStudentLocation(_ input: String, completionHandlerForGetThisStudentLocation: @escaping (_ success: Bool, _ present: Bool? ,_ error: NSError?) -> Void ){
        let urlString = "\(Constants.URL)/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(input)%22%7D"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        formatRequestHeaders(request)
        let session = URLSession.shared

        let task = session.dataTask(with: request as URLRequest) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            self.guardChecks(data, response: response, error: error as NSError?) {
                (success, error) -> Void in
                if success {
                    self.parseResult(data) {
                        (dict, error) -> Void in
                        if error == nil {
                            let arrayDictionaries = dict!["results"] as! NSArray
                            if arrayDictionaries.count != 0 {
                                completionHandlerForGetThisStudentLocation(true, true, nil)
                                return
                            } else {
                                completionHandlerForGetThisStudentLocation(true, false, nil)
                                return
                            }
                        } else { // There was a parsing error
                            completionHandlerForGetThisStudentLocation(false, nil, error)
                        }
                    }
                } else { // there was a guard error
                    completionHandlerForGetThisStudentLocation(false, nil, error)
                }
            }
        }
        task.resume()
    }
    
    func getAllStudentLocationsAndRefreshView(_ completionHandlerFromGetAllStudents:@escaping (_ requestSuccess: Bool,_ error: NSError?) -> Void ) {
        let request = NSMutableURLRequest(url: URL(string: "\(Constants.URL)/StudentLocation?\(MethodParameters.Limit100)&\(MethodParameters.ReverseCreationDateOrder)")!)
        formatRequestHeaders(request)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            self.guardChecks(data, response: response, error: error as? NSError){
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
                                if (dictionary["uniqueKey"] as? String ?? "") == Model.sharedInstance().getThisStudent().uniqueKey {
                                    // First and last name were populated when we logged into udacity
                                    var localStudentInfo = Model.sharedInstance().getThisStudent()
                                    localStudentInfo?.latitude = dictionary["latitude"]?.description
                                    localStudentInfo?.longitude = dictionary["longitude"]?.description
                                    localStudentInfo?.mapString = dictionary["mapString"] as! String
                                    localStudentInfo?.mediaURL = dictionary["mediaURL"] as! String
                                    localStudentInfo?.objectId = dictionary["objectId"] as! String
                                    localStudentInfo?.createdAt = dictionary["createdAt"] as! String
                                    Model.sharedInstance().setThisStudent(localStudentInfo!)
                                }
                            }
                            completionHandlerFromGetAllStudents(true, nil)
                        } else {
                            completionHandlerFromGetAllStudents(false, error)
                        }
                    } // end of self.parseResult(data)
                } else { // Guard checks failed
                    completionHandlerFromGetAllStudents(false, error)
                }
            } // End of guard checks
        })  // end oftask
        task.resume()
    }

    // Posting New Student information to server
    func postThisStudentLocation(_ student: StudentInformation, completionHandlerForPost: @escaping (_ success: Bool, _ error: NSError?) -> Void ) {
        var request = NSMutableURLRequest(url: URL(string: "\(Constants.URL)/StudentLocation")!)
        request.httpMethod = "POST"
        request = formatRequest(request, student: student)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            self.guardChecks(data, response: response, error: error as NSError?){
                (requestSuccess, error) -> Void in
                if requestSuccess {
                    self.parseResult(data) {
                        (dict, error) -> Void in
                        if error == nil {
                            guard let newObjectId = dict?["objectId"] as! String?,
                                let newCreationTime = dict?["createdAt"] as! String? else {
                                    let domain = "com.jamesjongs.onthemap.ErrorDomain"
                                    let code: Int = 256
                                    let userInfo: [AnyHashable:Any] = [NSLocalizedDescriptionKey: "Error posting new student"]
                                    let error = NSError(domain: domain, code: code, userInfo:
                                        userInfo)
                                    completionHandlerForPost(false, NSError(domain: domain, code: code, userInfo: userInfo))
                                    return
                            }
                            // Set the new ObjectId for the student.
                            var mutableStudent = student
                            mutableStudent.objectId = newObjectId
                            self.updatedOurStudentInforamtionUpdatedAtTime(mutableStudent, updateTime: newCreationTime)
                            completionHandlerForPost(true, nil)
                        } else {
                            completionHandlerForPost(false, error)
                        }
                    }
                } else { // Guard checks failed
                    completionHandlerForPost(false, error)
                }
            }
        }) 
        task.resume()
    }
    
    // Update this student's location information
    func updateThisStudentLocation(_ student: StudentInformation, completionHandlerForUpdate: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        let urlString = "\(Constants.URL)/StudentLocation/\(Model.sharedInstance().getThisStudent().objectId!)"
        let url = URL(string: urlString)
        var request = NSMutableURLRequest(url: url!)
        request.httpMethod = "PUT"
        request = formatRequest(request,student: student)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            self.guardChecks(data, response: response, error: error as NSError?){
                (requestSuccess, error) -> Void in
                if requestSuccess {
                    self.parseResult(data) {
                        (dict, error) -> Void in
                        if error == nil {
                            let returnUpdatedTime: String = dict!["updatedAt"] as! String
                            self.updatedOurStudentInforamtionUpdatedAtTime(student, updateTime: returnUpdatedTime)
                            completionHandlerForUpdate(true, nil)
                        } else {
                            completionHandlerForUpdate(false, error)
                        }
                    }
                } else { // Guard checks failed
                    completionHandlerForUpdate(false, error)
                }
            }
        }) 
        task.resume()
    }
    
    // Update the student's informatin timestamp
    func updatedOurStudentInforamtionUpdatedAtTime(_ inputStudent: StudentInformation, updateTime: String){
        // Update the isolated version
        var updatedStudent = inputStudent
        updatedStudent.updatedAt = updateTime
        Model.sharedInstance().setThisStudent(updatedStudent)
        // Update the annotated version
        var allStudents = Model.sharedInstance().getStudents()
        for (index,info) in allStudents.enumerated(){
            if info.objectId == updatedStudent.objectId {
                allStudents[index] = updatedStudent
            }
        }
        Model.sharedInstance().setStudents(allStudents)
    }
    
    // Generic parsing function
    fileprivate func parseResult(_ data: Data?, completionHandlerForParsingData: (_ parsedDictionary: NSDictionary?, _ error: NSError?)-> Void) {
        var parsedResult: NSDictionary
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
            completionHandlerForParsingData(parsedResult, nil)
            return
        } catch {
            let userInfo : [AnyHashable: Any]? = [NSLocalizedDescriptionKey: "Error Parsing Information\nPlease Try again"]
            completionHandlerForParsingData(nil, NSError(domain: "ParseClient", code: 1, userInfo: userInfo))
            return
        }
    }
    
    fileprivate func guardChecks(_ data: Data?, response: URLResponse?, error: NSError?, completionHandlerForGuardChecks: @escaping (_ requestSuccess: Bool, _ error: NSError?)-> Void){
        
        func sendError(_ error: String) {
            let userInfo = [NSLocalizedDescriptionKey : error]
            completionHandlerForGuardChecks(false, NSError(domain: "ParseClient", code: 1, userInfo: userInfo))
        }
        
        // GUARD: For any error
        guard (error == nil) else { // Handle error...
            sendError((error!.localizedDescription))
            return
        }
        
        // GUARD: There was no error from server; however server did not take further action
        guard (response as! HTTPURLResponse).statusCode != 403 else {
            sendError("Server not responding to request")
            return
        }
        
        // GUARD: Did we get successful 2XX response?
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
            sendError("Your request returned a status code other than 2xx \((response as? HTTPURLResponse)!.statusCode)")
            return
        }
        
        // GUARD: Was there data returned?
        guard let _ = data else {
            sendError("No data was returned by the request!")
            return
        }
        
        completionHandlerForGuardChecks(true, nil)
    }
    
    // MARK: - Singleton Implementation
    fileprivate init(){}
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}
