//
//  UdacityAPIConvenience.swift
//  OnTheMap
//
//  Created by Abdallah ElMenoufy on 6/20/15.
//  Copyright (c) 2015 Abdallah ElMenoufy. All rights reserved.
//

import Foundation

extension UdacityAPIClient {

    // Authenticate with Facebook
    func loginWithFacebook(completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        // Set the json body
        let jsonBody = [
            UdacityAPIClient.Constants.FacebookMobile: [
                UdacityAPIClient.Constants.AccessToken: FetchedData.sharedInstance().facebookAccessToken
            ]
        ]
        
        UdacityAPIClient.sharedInstance().getUserID(jsonBody) { userID, error in
            
            if let userID = userID {
                FetchedData.sharedInstance().userID = userID
                completionHandler(success: true, error: nil)
                
            } else {
                completionHandler(success: false, error: NSError(domain: "getUserID", code: error!.code, userInfo: [NSLocalizedDescriptionKey: error!.userInfo![NSLocalizedDescriptionKey]!]))
            }
        }
    }

    
    // Authenticate with Udacity username and password
    func authenticateWithUdacity(completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        let jsonBody =
                [UdacityAPIClient.JSONBodyKeys.Udacity:
                    [
                        UdacityAPIClient.JSONBodyKeys.Username: "\(FetchedData.sharedInstance().username!)",
                        UdacityAPIClient.JSONBodyKeys.Password: "\(FetchedData.sharedInstance().password!)"
                    ]
                ]
        
        self.getUserID(jsonBody) {userID, error in
            if let userID = userID {
                FetchedData.sharedInstance().userID = userID
                completionHandler(success: true, error: nil)
                
            } else {
                completionHandler(success: false, error: NSError(domain: "getUserID", code: error!.code, userInfo: [NSLocalizedDescriptionKey: error!.userInfo![NSLocalizedDescriptionKey]!]))
            }
        }
    }

    
    func getUserID(jsonBody: [String : AnyObject], completionHandler: (userID: String?, error: NSError?) -> Void) {
        
        /* 1. JSON body for the post method */
        // passed jsonBody in function arguments
        
        /* 2. Make the request */
        let task = self.taskForPOSTMethod(UdacityAPIClient.Methods.Session, jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                
                completionHandler(userID: nil, error: NSError(domain: "getUserID", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network Error"]))
                
            } else {
                
                if let statusCode = JSONResult.valueForKey(JSONResponseKeys.StatusCode) as? Int {
                    if statusCode == 403 {
                        let udacityError = JSONResult.valueForKey(JSONResponseKeys.Error) as! String
                        completionHandler(userID: nil, error: NSError(domain: "getUserID", code: 1, userInfo: [NSLocalizedDescriptionKey: udacityError]))
                    }
                    
                } else {
                    
                    if let account = JSONResult.valueForKey(JSONResponseKeys.Account) as? NSDictionary {
                        if let userID = account.valueForKey(JSONResponseKeys.Key) as? String {
                            completionHandler(userID: userID, error: nil)
                            
                        } else {
                            completionHandler(userID: nil, error: NSError(domain: "getUserID", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not parse userID as String"]))
                        }
                        
                    } else {
                        completionHandler(userID: nil, error: NSError(domain: "getUserID", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not parse account dictinaory"]))
                    }
                }
            }
        }
    }

    
    func getStudentPublicData(completionHandler: (error: NSError?) -> Void) {
        
        /* 1. Specify parameters */
        // userID
        
        /* 2. Make the request */
        let task = self.taskForGETMethod(UdacityAPIClient.Methods.PublicData, userID: FetchedData.sharedInstance().userID!) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                
                completionHandler(error: NSError(domain: "getStudentPublicData", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network Error"]))
            } else {
                
                if let user = JSONResult.valueForKey(JSONResponseKeys.User) as? NSDictionary {
                    if let userLastName = user.valueForKey(JSONResponseKeys.UserLastName) as? String {
                        FetchedData.sharedInstance().userLastName = userLastName
                        
                        if let userFirstName = user.valueForKey(JSONResponseKeys.UserFirstName) as? String {
                            FetchedData.sharedInstance().userFirstName = userFirstName
                            
                            // Set previousLocationsExist to true
                            FetchedData.sharedInstance().previousLocationsExist = true
                            
                            completionHandler(error: nil)
                            
                        } else {
                            completionHandler(error: NSError(domain: "getStudentPublicData", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not parse userFirstName as String"]))
                        }
                        
                    } else {
                        completionHandler(error: NSError(domain: "getStudentPublicData", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not parse userLastName as String"]))
                    }
                    
                } else {
                    completionHandler(error: NSError(domain: "getStudentPublicData", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not parse user dictionary"]))
                }
            }
        }
    }
    
    func logOutUdacity(completionHandler: ((success: Bool, error: NSError?) -> Void)) {
        
        /* Specify the parameters */
        let method = Methods.Session
        
        /* 2. Make the request */
        let task = self.taskForDELETEMethod(method) { JSONResult, error in
            
            /* 3. Send the desited value(s) to completion handler */
            if let error = error {
                
                completionHandler(success: false, error: NSError(domain: "logOutUdacity", code: 0, userInfo: [NSLocalizedDescriptionKey: "network error"]))
                
            } else {
                if let sessionDictioanry = JSONResult.valueForKey(JSONResponseKeys.Session) as? NSDictionary {
                    if let id = sessionDictioanry.valueForKey(JSONResponseKeys.ID) as? String {
                        completionHandler(success: true, error: nil)
       
                    } else {
                        completionHandler(success: false, error: NSError(domain: "logOutUdacity", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not parse id string"]))
                    }
                    
                } else {
                    completionHandler(success: false, error: NSError(domain: "logOutUdacity", code: 2, userInfo: [NSLocalizedDescriptionKey: "could not parse session dictinoary"]))
                }
            }
        }
    }


    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
            if let errorMessage = parsedResult[UdacityAPIClient.JSONResponseKeys.StatusMessage] as? String {
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "Udacity error", code: 0, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        /* Remove the first 5 characters of each response, they are included by Udacity for security purposes */
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }

    
}
