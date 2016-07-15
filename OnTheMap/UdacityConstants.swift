//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by James Jongsurasithiwat on 5/4/16.
//  Copyright © 2016 James Jongs. All rights reserved.
//

import Foundation
extension UdacityLoginClient{
    
    // MARK: Constants
    struct Constants {
        
        // MARK: API Key
        static let ApiKey : String = "4e8bdccc3bb63cefbec21f936eca5651"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
        static let UdacityURL : String = "https://www.udacity.com/api"
    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Account
        static let Users = "/users"
        
        // MARK: Authentication
        static let Session = "/session"
        
    }
    
}