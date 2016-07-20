//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by James Jongsurasithiwat on 5/24/16.
//  Copyright © 2016 James Jongs. All rights reserved.
//

import Foundation

class Model{

    var students: [StudentInformation] = [StudentInformation]()
    var thisStudentInformation: StudentInformation = StudentInformation()
    
    // MARK: - Singleton Implementation
    
    private init(){}
    
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
        createdAt = id["createdAt"] as! String
        firstName = id["firstName"] as! String
        lastName = id["lastName"] as! String
        latitude = id["latitude"] as! String
        longitude = id["longitude"] as! String
        mapString = id["mapString"] as! String
        mediaURL = id["mediaURL"] as! String
        objectId = id["objectID"] as! String
        uniqueKey = id["uniqueKey"] as! String
        updatedAt = id["updatedAt"] as! String
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
