//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by James Jongsurasithiwat on 5/24/16.
//  Copyright © 2016 James Jongs. All rights reserved.
//

import Foundation

struct StudentInformation {
    var createdAt: String!// = "2016-04-26T00:04:35.930Z";
    var firstName: String!// = Steven;
    var lastName: String!// = Xu;
    var latitude: String!// = "43.4677963";
    var longitude: String!// = "-80.54235009999999";
    var mapString: String!// = "university of Waterloo ";
    var mediaURL: String!// = "https://sxu.ca";
    var objectId: String!// = Hjb7hYIaEm;
    var uniqueKey: String!// = 643038755;
    var updatedAt: String!// = "2016-04-26T00:04:35.930Z";
    
    
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
