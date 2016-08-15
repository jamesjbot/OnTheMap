//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by James Jongsurasithiwat on 5/24/16.
//  Copyright © 2016 James Jongs. All rights reserved.
//

import Foundation

class Model{

     private var students: [StudentInformation]!
     private var thisStudentInformation: StudentInformation!
    
    // MARK: - Singleton Implementation
    
    private init(){
        students = [StudentInformation]()
        thisStudentInformation = StudentInformation()
    }
    
    func getThisStudent() -> StudentInformation! {
        return thisStudentInformation
    }
    
    func setThisStudent(input: StudentInformation) -> Bool {
        thisStudentInformation = input
        return true
    }
    
    func getStudents() -> [StudentInformation] {
        return students
    }
    
    func setStudents(input: [StudentInformation]) -> Bool {
        students = input
        return true
    }
    
    func deleteAllStudents() -> Bool {
         students = [StudentInformation]()
        return true
    }
    
    func appendStudent(input: StudentInformation) -> Bool {
        students.append(input)
        return true
    }
    
    class func sharedInstance() -> Model {

        struct Singleton {
            static var sharedInstance = Model()
        }
        return Singleton.sharedInstance
    }
    

}

struct StudentInformation {
    var createdAt: String!
    var firstName: String!
    var lastName: String!
    var latitude: String!
    var longitude: String!
    var mapString: String!
    var mediaURL: String!
    var objectId: String!
    var uniqueKey: String!
    var updatedAt: String!
    
    
    init( id: [ String: AnyObject ]){
        createdAt = (id["createdAt"] ?? "") as! String
        firstName = (id["firstName"] ?? "") as! String
        lastName = (id["lastName"] ?? "") as! String
        latitude = ((id["latitude"] ?? 0) as! NSNumber).description
        longitude = ((id["longitude"] ?? 0) as! NSNumber).description
        mapString = (id["mapString"] ?? "") as! String
        mediaURL = (id["mediaURL"] ?? "") as! String
        objectId = (id["objectId"] ?? "") as! String
        uniqueKey = (id["uniqueKey"] ?? "") as! String
        updatedAt = (id["updatedAt"] ?? "") as! String
    }

    init(){
        createdAt = nil
        firstName = nil
        lastName  = nil
        latitude = nil
        longitude = nil
        mapString = nil
        mediaURL = nil
        objectId = nil
        uniqueKey = nil
        updatedAt = nil
        
    }

}
