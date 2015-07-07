//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Abdallah ElMenoufy on 6/21/15.
//  Copyright (c) 2015 Abdallah ElMenoufy. All rights reserved.
//

import Foundation

struct StudentInformation {
    
    // Student basic information
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    var latitude: Double
    var longitude: Double
    let uniqueKey: String
    
    /* Construct a Student object from a dictionary */
    init(dictionary: [String : AnyObject]) {
        
        firstName = dictionary[ParseAPIClient.JSONResponseKeys.FirstName] as! String
        lastName = dictionary[ParseAPIClient.JSONResponseKeys.LastName] as! String
        mapString = dictionary[ParseAPIClient.JSONResponseKeys.MapString] as! String
        mediaURL = dictionary[ParseAPIClient.JSONResponseKeys.MediaURL] as! String
        latitude = dictionary[ParseAPIClient.JSONResponseKeys.Latitude] as! Double
        longitude = dictionary[ParseAPIClient.JSONResponseKeys.Longitude] as! Double
        uniqueKey = dictionary[ParseAPIClient.JSONResponseKeys.UniqueKey] as! String
    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of Student objects */
    static func studentsFromResults(results: [[String : AnyObject]]) -> [StudentInformation] {
        
        var students = [StudentInformation]()
        for result in results {
            students.append(StudentInformation(dictionary: result))
        }
        
        return students
    }

    
    
}