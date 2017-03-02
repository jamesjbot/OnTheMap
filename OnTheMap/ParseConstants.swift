//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by James Jongsurasithiwat on 6/11/16.
//  Copyright © 2016 James Jongs. All rights reserved.
//

import Foundation
extension ParseClient{
    
    
    
    struct Constants{
        static let ApplicationID: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RestAPIKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ReturnToAnnotationDisplay: String = "ReturnToAnnotationDisplayID"
        static let URL: String = "https://parse.udacity.com/parse/classes"
    }

    struct Method{
        static let StudentLocations: String = "/StudentLocation"
    }
    
    struct MethodParameters {
        static let Limit100: String = "limit=100"
        static let ReverseCreationDateOrder : String = "order=-updatedAt"
    }

    struct Keys{
        static let UpdatedAt: String = "updatedAt"
    }

    struct BodyParameters {
        static let UK: String = "uniqueKey"
        static let FN: String = "firstName"
        static let LN: String = "lastName"
        static let MS: String = "mapString"
        static let MU: String = "mediaURL"
        static let LA: String = "latitude"
        static let LO: String = "longitude"
    }
    
}
