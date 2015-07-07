//
//  UdacityAPIClient.swift
//  OnTheMap
//
//  Created by Abdallah ElMenoufy on 6/19/15.
//  Copyright (c) 2015 Abdallah ElMenoufy. All rights reserved.
//

import Foundation

class UdacityAPIClient: NSObject {
    
    
    /* Shared session */
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }

    // Abstract repeated code chunks from dozens of network calls, into methods and naming them with their proper HTTP-related actions; GET, POST, DELETE, and so on ... code is almost similar to lesson 4 TheMovieManager app.
    
    // MARK:- Task for POST method
    func taskForPOSTMethod(method: String, jsonBody: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        // Done in argument "jsonBody"
        
        /* 2. Build the URL */
        let urlString = Constants.BaseSecureURL + method
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        var jsonifyError: NSError? = nil
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                
                let newError = UdacityAPIClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
                
            } else {
                UdacityAPIClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }

    // MARK:- Task for GET method
    func taskForGETMethod(method: String, userID: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        // userID
        
        /* 2. Build the URL */
        let urlString = Constants.BaseSecureURL + method + userID
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                let newError = UdacityAPIClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                UdacityAPIClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    
    // MARK:- Task for DELETE method
    func taskForDELETEMethod(mehod: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        // No parameters
        
        /* 2. Build the URL */
        let urlString = Constants.BaseSecureURL + mehod
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
                let newError = UdacityAPIClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                UdacityAPIClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task

    }


    
    // Create a Singleton shared-instance of the Udacity API Client to save memory when making many network calls
    class func sharedInstance() -> UdacityAPIClient {
        struct Singleton {
            static var sharedInstance = UdacityAPIClient()
        }
        return Singleton.sharedInstance
    }
}


