//
//  UIConfiguration.swift
//  OnTheMap
//
//  Created by Abdallah ElMenoufy on 6/23/15.
//  Copyright (c) 2015 Abdallah ElMenoufy. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class UIConfiguration: NSObject, UIAlertViewDelegate {
    
    // I'm using this class to set some UI properties programatically as storyboard won't allow it, such as the 3 bar buttons at the MapView, and the TableView
    
    // First:- Declear the target view property to be called when assigning the needed buttons through code
    var targetView: UIViewController!
    
    // Use facebook LoginManager to handle facebook logout session
    let facebookLoginManager = FBSDKLoginManager()
    
    // Set the navigation bar buttons with their associated actions
    func setNavBarButtons(viewController: UIViewController) {
        targetView = viewController
        
        // LogoutButton
        let logoutButton = UIBarButtonItem(
            title: "Logout",
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: "logout")
        
        // RefreshButton
        let refreshButton = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.Refresh,
            target: self,
            action: "refreshStudentsPins")
        
        // PinButton
        let pinButton = UIBarButtonItem(
            image: UIImage(named: "pin"),
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: "checkForPreviousLocations")
        
        // Set the buttons once view appeared
        viewController.parentViewController!.navigationItem.leftBarButtonItem = logoutButton
        viewController.parentViewController!.navigationItem.rightBarButtonItems = [ refreshButton, pinButton ]
    }
    
    
    // Set a single function for UIAlertController to be called many times later instead of creting many of them inside the app
    class func setAlertController(viewController: UIViewController, title: String, message: String, actionTitle: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }

    
    // Verify that a given url is matching the safe ASCII characher-set for successful opening in Safari
    class func verifyAGivenURL(urlString: String) -> Bool {
        
        if let url = NSURL(string: urlString) {
            if UIApplication.sharedApplication().canOpenURL(url) {
                return true
            }
        }
        
        return false
    }
    
    
    // Refersh the Map and Table view controllers
    func refreshStudentsPins() {
        
        if self.targetView is StudentsOnTheMap {
            self.targetView!.viewWillAppear(true)
            
        } else if self.targetView is StudentsOnTableView {
            
            // Call ParseAPI again to get the latest students locations updates
            ParseAPIClient.sharedInstance().getStudentsLocations { students, error in
                
                if let students = students {
                    dispatch_async(dispatch_get_main_queue()) {
                        FetchedData.sharedInstance().studentsInformation = students
                        
                        // Relaod the table data
                        self.targetView!.viewWillAppear(true)
                    }
                    
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        if error!.code == 0 {
                            
                            let title = "Network Error"
                            let message = "Failed communicating to Parse, please check your Internet connection"
                            let actionTitle = "OK"
                            
                            UIConfiguration.setAlertController(self.targetView, title: title, message: message, actionTitle: actionTitle)
                        }
                    }
                }
            }
        }
    }

    
    // Check for any previous locations posted by the student and propmt an alert controller if true, before attempting to post a new location pin
    func checkForPreviousLocations() {
        
        let userID = FetchedData.sharedInstance().userID!
        
        ParseAPIClient.sharedInstance().studentLocationsExist { success, error in
            
            if success {
                
                // Setup an alert view
                let alertController = UIAlertController(title: "", message: "You have already posted one or more locations, would you like to overwrite the previous location(s)?", preferredStyle: UIAlertControllerStyle.Alert)
                let overwriteButton = UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in self.getStudentPublicDataAndSegueToInformationPostingViewController { error in
                    
                    if let error = error {
                        
                        println("error info: \(error.userInfo![NSLocalizedDescriptionKey]!)")
                        
                    } else {
                        
                        self.segueToInformationPostingViewController()
                    }}
                })
                
                let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in alertController.dismissViewControllerAnimated(true, completion: nil)})
                alertController.addAction(overwriteButton)
                alertController.addAction(cancelButton)
                
                self.targetView.presentViewController(alertController, animated: true, completion: nil)
                
            } else if (!success && (error == nil)) {
                
                // Lets submit a new location
                self.getStudentPublicDataAndSegueToInformationPostingViewController { error in
                    
                    if let error = error {
                       
                        println("error info: \(error.userInfo![NSLocalizedDescriptionKey]!)")
                    }
                }
                
            } else if let error = error {
                
                println("error info: \(error.userInfo![NSLocalizedDescriptionKey]!)")
            }
        }
    }

    
    func getStudentPublicDataAndSegueToInformationPostingViewController(completionHandler: (error: NSError?) -> Void) {
        
        UdacityAPIClient.sharedInstance().getStudentPublicData { error in
            
            // In case error ?
            if let error = error {
                
                // Prompt student to retry again
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if error.code == 0 {
                        
                        let title = "Network Error!"
                        let message = "Failed connecting to Udacity, check your Internet connection"
                        let actionTitle = "OK"
                        
                        UIConfiguration.setAlertController(self.targetView!, title: title, message: message, actionTitle: actionTitle)
                    }
                }
            } else {
                
                self.segueToInformationPostingViewController()
            }
        }
    }
    
    
    func segueToInformationPostingViewController() {
        
        // Segue to Information Posting View Controller
        dispatch_async(dispatch_get_main_queue()) {
            
            let informationPostingViewContorller = self.targetView.storyboard!.instantiateViewControllerWithIdentifier("StudentsInformationPosting") as! StudentsInformationPosting
            
            self.targetView!.presentViewController(informationPostingViewContorller, animated: true, completion: nil)
        }
    }


    func logout() {
        
        // Check to see if student was logged in using facebook, to logout from fb first
        if FetchedData.sharedInstance().facebookAccessToken != nil {
            facebookLoginManager.logOut()
            self.targetView!.dismissViewControllerAnimated(true, completion: nil)
        }
        
        // Log out using Udacity's DELETE session
        UdacityAPIClient.sharedInstance().logOutUdacity { success, error in
            
            if success {
                self.targetView!.dismissViewControllerAnimated(true, completion: nil)
                
            } else {
                // Let student try again
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if error!.code == 0 {
                        
                        let title = "Network error"
                        let message = "Failed connecting to Udacity, check your internet connection"
                        let actionTitle = "OK"
                        
                        UIConfiguration.setAlertController(self.targetView, title: title, message: message, actionTitle: actionTitle)
                    }
                }
            }
        }
    }

    
    
    // Setup a singleton instance of UI class to be called from many classes
    class func sharedInstance() -> UIConfiguration {
        struct Singleton {
            static var sharedInstance = UIConfiguration()
        }
        
        return Singleton.sharedInstance
    }
    
}
