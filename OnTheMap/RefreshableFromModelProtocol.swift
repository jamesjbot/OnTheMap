//
//  RefreshableFromModelProtocol.swift
//  OnTheMap
//
//  Created by James Jongsurasithiwat on 6/15/16.
//  Copyright © 2016 James Jongs. All rights reserved.
//

import Foundation

protocol RefreshableFromModelProtocol {

    var locations: [StudentInformation] { get set}
    
    func updateStudentLocationsInView()
    
}