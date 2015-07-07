//
//  ParseAPIConvenience.swift
//  OnTheMap
//
//  Created by Abdallah ElMenoufy on 6/21/15.
//  Copyright (c) 2015 Abdallah ElMenoufy. All rights reserved.
//

import Foundation

extension ParseAPIClient {
    
    func getStudentsLocations(completionHandler: (result: [StudentInformation]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [
            ParseAPIClient.Constants.Limit : 100
        ]
        
        /* 2. Make the request */
        taskForGETMethod(Methods.SecureBaseURLAndMethod, parameters: parameters) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(result: nil, error: NSError(domain: "getStudentsLocations", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network Error"]))
                
            } else {
                if let results = JSONResult.valueForKey(ParseAPIClient.JSONResponseKeys.Results) as? [[String : AnyObject]] {
                    
                    var students = StudentInformation.studentsFromResults(results)
                    completionHandler(result: students, error: nil)
                    
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getStudentsLocations", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not parse results array"]))
                }
            }
        }
    }
    
    
    func postStudentLocation(completionHandler: (data: AnyObject!, error: NSError?) -> Void) {
        
        /* 1. Specify the JSON body */
        let jsonBody: [String : AnyObject] = [
            JSONResponseKeys.UniqueKey: FetchedData.sharedInstance().userID,
            JSONResponseKeys.FirstName: FetchedData.sharedInstance().userFirstName,
            JSONResponseKeys.LastName: FetchedData.sharedInstance().userLastName,
            JSONResponseKeys.MapString: FetchedData.sharedInstance().mapString,
            JSONResponseKeys.MediaURL: FetchedData.sharedInstance().mediaURL,
            JSONResponseKeys.Latitude: FetchedData.sharedInstance().region.center.latitude,
            JSONResponseKeys.Longitude: FetchedData.sharedInstance().region.center.longitude
        ]
        
        /* 2. Make the request */
        let task = self.taskForPOSTMethod(Methods.SecureBaseURLAndMethod, jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(data: nil, error: NSError(domain: "postStudentLocation", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network Error"]))
            } else {
                if let objectID = JSONResult.valueForKey(JSONResponseKeys.ObjectId) as? String {
                    FetchedData.sharedInstance().objectID = objectID
                    completionHandler(data: JSONResult, error: nil)
                } else {
                    completionHandler(data: nil, error: NSError(domain: "postStudentLocation", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not parse object id as String"]))
                }
            }
        }
    }
    
    
    func updateStudentLocations(completionHandler: (data: AnyObject!, error: NSError?) -> Void) {
        
        /* 1. Specify the parameters and the JSON body */
        let jsonBody: [String : AnyObject] = [
            JSONResponseKeys.UniqueKey: FetchedData.sharedInstance().userID,
            JSONResponseKeys.FirstName: FetchedData.sharedInstance().userFirstName,
            JSONResponseKeys.LastName: FetchedData.sharedInstance().userLastName,
            JSONResponseKeys.MapString: FetchedData.sharedInstance().mapString,
            JSONResponseKeys.MediaURL: FetchedData.sharedInstance().mediaURL,
            JSONResponseKeys.Latitude: FetchedData.sharedInstance().region.center.latitude,
            JSONResponseKeys.Longitude: FetchedData.sharedInstance().region.center.longitude
        ]
        
        // 2. Make the request
        for foundObjectID in FetchedData.sharedInstance().foundObjectIDs {
            
            let task = self.taskForPUTMethod(Methods.SecureBaseURLAndMethod, objectID: foundObjectID, jsonBody: jsonBody) { JSONResult, error in
                
                /* 3. Send the desired value(s) to completion handler */
                if let error = error {
                    completionHandler(data: nil, error: NSError(domain: "updateStudentLocations", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network Error"]))
                    
                } else {
                    if let updatedAt = JSONResult.valueForKey(JSONResponseKeys.UpdatedAt)  as? String {
                        completionHandler(data: JSONResult, error: nil)
                        
                    } else {
                        completionHandler(data: nil, error: NSError(domain: "updateStudentLocations", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not parse updatedAt as String"]))
                    }
                }
            }
        }
    }
    
    
    func queryStudentLocations(completionHandler: (data: AnyObject!, success: Bool, error: NSError?) -> Void) {
        
        /* 1. Set the parameters */
        let parameters = [
            "" : ""
        ]
        
       // And the method
        let method = "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22" + FetchedData.sharedInstance().userID! + "%22%7D"
        
        /* 2. Make the request */
        let task = self.taskForGETMethod(method, parameters: parameters) { JSONResult, error in
            
            if let error = error {
                completionHandler(data: nil, success: false, error: NSError(domain: "queryStudentsLocations", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network Error"]))
                
            } else {
                
                if let resultsArray = JSONResult.valueForKey(JSONResponseKeys.Results) as? NSArray {
                    
                    var foundObjectIDs = [String]()
                    
                    for result in resultsArray {
                        
                        if let foundObjectID = result.valueForKey(JSONResponseKeys.ObjectId) as? String {
                                foundObjectIDs.append(foundObjectID)
                            
                        } else {
                            completionHandler(data: nil, success: false, error: NSError(domain: "queryStudentsLocations", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not parse the found object ID to String"]))
                        }
                    }
                    
                    if foundObjectIDs.isEmpty {
                        
                        FetchedData.sharedInstance().previousLocationsExist = false
                        completionHandler(data: JSONResult, success: false, error: nil)
                        
                    } else {
                        
                        FetchedData.sharedInstance().previousLocationsExist = true
                        completionHandler(data: JSONResult, success: true, error: nil)
                    }
                    
                    FetchedData.sharedInstance().foundObjectIDs = foundObjectIDs
                    
                } else {
                    
                    completionHandler(data: nil, success: false, error: NSError(domain: "queryStudentsLocations", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not parse results array"]))
                }
            }
        }
    }
    
    
    // Check if student has posted some locations earlier or not ?
    func studentLocationsExist(completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        ParseAPIClient.sharedInstance().queryStudentLocations { result, success, error in
            
            if let error = error {
                completionHandler(success: false, error: error)
                
            } else {
                
                if success {
                    completionHandler(success: true, error: nil)
                    
                } else {
                    completionHandler(success: false, error: nil)
                }
            }
        }
    }
    
    
    
    func deleteStudentLocations(objectIDs: [String]) {
        
        if objectIDs.count > 1 {
            
            // Delete all except one!
            for x in 1...(objectIDs.count - 1) {
                
                self.taskForDELETEMethod(Methods.SecureBaseURLAndMethod, objectID: objectIDs[x]) { result, error in
                    
                    if let error = error {
                        
                        println("erorr description: \(error.localizedDescription)")
                        
                    } else {
                        
                        // Nothing in particullay here, as all steps are done in taskForDELETEMethod, I'm practicing for moving all possible-repeated code chunks into funtions, lke Jarrod didin the MovieManager app :)
                        
                        println("result: \(result)")
                    }
                }
            }
        }
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult[ParseAPIClient.JSONResponseKeys.StatusMessage] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "Parse Error", code: 1, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> ParseAPIClient {
        struct Singleton {
            static var sharedInstance = ParseAPIClient()
        }
        
        return Singleton.sharedInstance
    }

    
}