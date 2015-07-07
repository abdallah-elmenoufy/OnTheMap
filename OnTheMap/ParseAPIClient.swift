//
//  ParseAPIClient.swift
//  OnTheMap
//
//  Created by Abdallah ElMenoufy on 6/21/15.
//  Copyright (c) 2015 Abdallah ElMenoufy. All rights reserved.
//

import Foundation

class ParseAPIClient: NSObject {
    
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        
        super.init()
    }
    
    // Implementing taskForGETMethod "as usual, removing repeated chunks of network-calls related code into functions for better MVC design"
    func taskForGETMethod(secureBaseURLAndMethod: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        // Will be passed through parameters, in the function body
        
        /* 2/3. Build the URL and configure the request */
        let urlString = secureBaseURLAndMethod + ParseAPIClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: Constants.ParseApplicationID_KEY)
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: Constants.RESTAPIKey_KEY)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler */
            if let error = downloadError {
                let newError = ParseAPIClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: error)
            } else {
                ParseAPIClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // taskForPOSTMethod
    func taskForPOSTMethod(secureBaseURLAndMethod: String, jsonBody: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        // No required parameters as instructed into Parse documentations
        
        /* 2. The NSURL */
        let url = NSURL(string: secureBaseURLAndMethod)!
        
        /* 3. Configure the request */
        var jsonifyError: NSError? = nil
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: Constants.ParseApplicationID_KEY)
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: Constants.RESTAPIKey_KEY)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                
                let newError = ParseAPIClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: error)
                
            } else {
                ParseAPIClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the task */
        task.resume()
        
        return task
    }
    
    // taskForPUTMethod
    func taskForPUTMethod(secureBaseURLAndMethod: String, objectID: String, jsonBody: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        // In parameters
        
        /* 2. Build the URL */
        let urlString = secureBaseURLAndMethod + "/" + objectID
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        var jsonifyError: NSError? = nil
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PUT"
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: Constants.ParseApplicationID_KEY)
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: Constants.RESTAPIKey_KEY)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            /* 5/6. Parse the data and use the data (happens in completion hander) */
            if let error = error {
                
                let newError = ParseAPIClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: error)
                
            } else {
                ParseAPIClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the task */
        task.resume()
        
        return task
    }
    
    // taskForDELETEMethod
    func taskForDELETEMethod(baseURLAndMethod: String, objectID: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        // Will be passed through parameters, in the function body
        
        /* 2. Build the URL */
        let urlString = baseURLAndMethod + "/" + objectID
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: Constants.ParseApplicationID_KEY)
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: Constants.RESTAPIKey_KEY)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            /* 5/6. Parse the data and use the data (happens in completion hander) */
            if let error = error {
                
                let newError = ParseAPIClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: error)
                
            } else {
                ParseAPIClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the task */
        task.resume()
        
        return task
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it in case limit parameter only */
            if key == "limit" {
                urlVars += [key + "=" + "\(escapedValue!)"]
                
            } else {
                return ""
            }
        }
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }

}