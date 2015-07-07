//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Abdallah ElMenoufy on 6/16/15.
//  Copyright (c) 2015 Abdallah ElMenoufy. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    // Connecting outlets
    @IBOutlet weak var connectingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var udacityUsernameTextField: UITextField!
    @IBOutlet weak var udacityPasswordTextField: UITextField!
    @IBOutlet weak var loginWithUdacityButton: UIButton!
    @IBOutlet weak var debugLabel: UILabel!
    
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    // Variables will be used to adjust keyboard showing/hidding when wirting-down Udacity credentials at first login
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    
// MARK: - App's viewLifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.connectingActivityIndicator!.hidden = true
        self.connectingActivityIndicator!.hidesWhenStopped = true
        
        facebookLoginButton.delegate = self
    }
 
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.debugLabel!.textColor = UIColor.whiteColor()
        self.debugLabel!.text = "Login with your Udacity credentials"
        
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
        
        // Check to see if the student has already logged in via facebook, to auto-proceed to StudentsOnTheMap
        if FBSDKAccessToken.currentAccessToken() != nil {
            
            // Authenticate to Udacity with Facebook current accessToken
            self.connectingActivityIndicator!.hidden = false
            self.connectingActivityIndicator!.startAnimating()
            
            self.debugLabel!.textColor = UIColor.greenColor()
            debugLabel.text = "Logged in with Facebook ..."
            
            FetchedData.sharedInstance().facebookAccessToken = FBSDKAccessToken.currentAccessToken().tokenString
            UdacityAPIClient.sharedInstance().loginWithFacebook { success, error in
                
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.completeLogin()
                    }
                    
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayError(error)
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
    }
    
// MARK: - Actions
    
    // Facebook logging - Delegate methods
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if let error = error {
            debugLabel.text! = error.localizedDescription
        }
            
        else {
            
            FetchedData.sharedInstance().facebookAccessToken = FBSDKAccessToken.currentAccessToken().tokenString
            UdacityAPIClient.sharedInstance().loginWithFacebook { success, error in
                
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.completeLogin()
                    }
                    
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.displayError(error)
                    }
                }
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    // Implementing loginWithUdacity button touch up
    @IBAction func loginTouchUp(sender: UIButton) {
        
        // Disable the button to prevent students from accedently pressing it twice in a row
        self.loginWithUdacityButton.enabled = false
        
        // Verfiy if a username and password are enterned
        if (self.udacityUsernameTextField.text.isEmpty || self.udacityPasswordTextField.text.isEmpty) {
            
            self.debugLabel!.textColor = UIColor.redColor()
            self.debugLabel!.text = "You must enter username and password"
            
            // Set the button enabled back to true, to allow students to try again
            self.loginWithUdacityButton!.enabled = true
            
        } else {
        
            self.debugLabel!.text = "Connecting ..."
            self.debugLabel!.textColor = UIColor.greenColor()
        
            // Show and animate the acitivity indicator
            self.connectingActivityIndicator!.hidden = false
            self.connectingActivityIndicator!.startAnimating()
            
            // Store the given username and password in the FetchedData class for the next authentication call
            FetchedData.sharedInstance().username = self.udacityUsernameTextField!.text!
            FetchedData.sharedInstance().password = self.udacityPasswordTextField!.text!
            
            // Call the UdacityAPIClient convenience methods to authenticate with Udacity backend and get a uesrKey, and PublicData
            UdacityAPIClient.sharedInstance().authenticateWithUdacity() {success, error in
             
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.udacityUsernameTextField.text! = ""
                        self.udacityPasswordTextField.text! = ""
                        self.loginWithUdacityButton.enabled = true
                        self.completeLogin()
                    }

                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayError(error)
                    }
                }
            }
        }
    }
    
    // Complete the login process and show OnTheMap view when username and password are correct
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue()) {
            
            self.connectingActivityIndicator!.stopAnimating()

            self.view.endEditing(true)
            
            self.performSegueWithIdentifier("OnTheMap", sender: self)
        }
    }

    // Interrupt login process and show the error message associated with the network call response received from Udacity
    func displayError(error: NSError?) {
        dispatch_async(dispatch_get_main_queue()) {
            
             self.connectingActivityIndicator.stopAnimating()
            
            if let error = error {
                
                switch error.code {
                case 0:
                    self.debugLabel!.text = "Connection lost, check your internet connection"
                case 1:
                    self.debugLabel!.text = "Invalid username and/or password, try again"
                default:
                    self.debugLabel!.text = "Error logging in, please try again"
                }
                
                self.view.endEditing(true)
                self.connectingActivityIndicator!.stopAnimating()
                self.loginWithUdacityButton.enabled = true
            }
        }
    }
   
    // Open Safari "the system's browser", take student to Udacity signup page for creating a new account
    @IBAction func signUpTapped(sender: UIButton) {
        
        let signUpURL = NSURL(string: "https://www.udacity.com/account/auth#!/signin")!
        UIApplication.sharedApplication().openURL(signUpURL)
    }
     
    


}


// MARK: - Keyboard adjustments

extension LoginViewController {
    
    func configureUI() {
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            self.view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
}

