//
//  FetchedData.swift
//  OnTheMap
//
//  Created by Abdallah ElMenoufy on 6/20/15.
//  Copyright (c) 2015 Abdallah ElMenoufy. All rights reserved.
//

import MapKit
import Foundation

class FetchedData: NSObject {

    // Username and Password enterned by students are saved here for later use in taskForPOSTMethod calls
    var username: String!
    var password: String!
    
    // Retreived data from network calls made to authenticate with Udacity
    var userID: String!
    var userFirstName: String!
    var userLastName: String!
    
    // For Information Posting VC
    var mapString: String!
    var mediaURL: String!
    var region: MKCoordinateRegion!
    
    // Retreived data from network calls made to Parse
    var previousLocationsExist: Bool!
    var objectID: String!
    var foundObjectIDs: [String]!
    
    // Get a copy of a Student-Saved-Information from StudentInformation struct
    var studentsInformation: [StudentInformation]!
    
    // Save the access token recevied from facebook, for login with fb option
    var facebookAccessToken: String!

    
    
    // Allow other class to reference a common shared instance of the FetchedData class, for memory saving purposes
    class func sharedInstance() -> FetchedData {
        struct Singleton {
            static var sharedInstance = FetchedData()
        }
        return Singleton.sharedInstance
    }

}
