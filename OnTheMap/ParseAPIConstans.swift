//
//  ParseAPIConstans.swift
//  OnTheMap
//
//  Created by Abdallah ElMenoufy on 6/21/15.
//  Copyright (c) 2015 Abdallah ElMenoufy. All rights reserved.
//

import Foundation

extension ParseAPIClient {
 
    // Constants
    struct Constants {
        
        static let ParseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RESTAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ParseApplicationID_KEY = "X-Parse-Application-Id"
        static let RESTAPIKey_KEY = "X-Parse-REST-API-Key"
        static let Limit = "limit"
        static let Where = "where"
    }
    
    // Methods
    struct Methods {
        
        static let SecureBaseURLAndMethod = "https://api.parse.com/1/classes/StudentLocation"
    }
    
    // JSON Resonse Keys
    struct JSONResponseKeys {
        
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Code = "code"
        static let UpdatedAt = "updatedAt"
        
        static let StatusMessage = "status_message"
        static let Results = "results"
        
        /*
        YOU DO NOT HAVE TO WORRY ABOUT PARSING DATE OR ACL TYPES.
        */
    }

    
    
}