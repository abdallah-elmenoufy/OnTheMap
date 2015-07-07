//
//  StudentsInformationPosting.swift
//  OnTheMap
//
//  Created by Abdallah ElMenoufy on 6/23/15.
//  Copyright (c) 2015 Abdallah ElMenoufy. All rights reserved.
//

import UIKit
import MapKit

class StudentsInformationPosting: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate, UITextViewDelegate {
    
// MARK: - Declaring Outlets
    
    @IBOutlet weak var linkTextView: UITextView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var locationMapView: MKMapView!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var geocodingActivityIndicator: UIActivityIndicatorView!
    
    
// MARK: - View life cycles
    
    override func viewDidLoad() {
        
        // Set the delegates to (self)
        linkTextView!.delegate = self
        locationMapView!.delegate = self
        locationTextField!.delegate = self
        
        // Add Tap Gesture Recognizer
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
        
        geocodingActivityIndicator!.hidesWhenStopped = true
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Disable posting links before posting the location
        linkTextView!.editable = false
        
        // Hide the map until location string is posted
        locationMapView!.hidden = true
    }
    
    
// MARK: - Actions
    
    // Get the submitted location string, on the map view
    @IBAction func findOnTheMapTouchUp(sender: UIButton) {
        
        if sender.currentTitle! == "Find on the Map" {
            
            if locationTextField.text == "Enter your location here" || locationTextField.text.isEmpty {
                
                let title = "Hello :)"
                let message = "Enter your location in the correct format"
                let actionTitle = "OK"
                
                UIConfiguration.setAlertController(self, title: title, message: message, actionTitle: actionTitle)
                
            } else if locationTextField.text != "Enter your location here" && !locationTextField.text.isEmpty {
                
                // Animating the activity indicator
                geocodingActivityIndicator.startAnimating()
                
                // Start geocoding the address
                let geocoder = CLGeocoder()
                
                geocoder.geocodeAddressString(FetchedData.sharedInstance().mapString!) { placemarks, error in
                    
                    if let error = error {
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            // Inform the user this location could not be found using Maps
                            let title = "Unknown location to Maps"
                            let message = "The location you entered is unkown to Maps, please try again with corret-formatted address"
                            let actionTitle = "OK"
                            
                            UIConfiguration.setAlertController(self, title: title, message: message, actionTitle: actionTitle)
                            
                            // Stop the activity indicator
                            self.geocodingActivityIndicator.stopAnimating()
                        }
                        
                    } else {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            let placemarks = placemarks as! [CLPlacemark]
                            FetchedData.sharedInstance().region = self.structTheRegion(placemarks)
                            self.performViewChanges()
                            
                            let annotation = Annotations (
                                latitude: FetchedData.sharedInstance().region.center.latitude,
                                longitude: FetchedData.sharedInstance().region.center.longitude,
                                firstName: FetchedData.sharedInstance().userFirstName!,
                                lastName: FetchedData.sharedInstance().userLastName!, mediaURL: nil)
                            
                            self.locationMapView.setRegion(FetchedData.sharedInstance().region, animated: true)
                            self.locationMapView.addAnnotation(annotation)
                            
                            // Stop the activity indicator
                            self.geocodingActivityIndicator.stopAnimating()
                        }
                    }
                }
            }
        }
    }

    // Share the link along with the submitted location
    @IBAction func shareLink(sender: UIButton) {
        
        if sender.currentTitle! == "Share Link" {
            
            if linkTextView.text! == "Share a link of your interest, please make sure to prefix your link with http(s)://" || linkTextView.text.isEmpty {
                
                let title = "Share a link"
                let message = "Please share a link, to submit your location"
                let actionTitle = "OK"
                
                UIConfiguration.setAlertController(self, title: title, message: message, actionTitle: actionTitle)
                
            } else if linkTextView.text! != "Share a link of your interest" && !linkTextView.text.isEmpty {
                
                if FetchedData.sharedInstance().previousLocationsExist! {
                    
                    self.updateStudentLocations()
                    
                } else {
                    
                    self.submitNewLoaction()
                }
            }
        }
    }

    // Cancel posting a new location or sharing a link
    @IBAction func cancelPostingOnTheMap(sender: UIButton) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
// MARK: - Helper functions
    
    // Dismiss keyboard when user taps one tap
    func handleSingleTap(recognizer: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    
    // Update the current student-posted location with the newly shared link
    func updateStudentLocations() {
        ParseAPIClient.sharedInstance().updateStudentLocations { result, error in
            if let error = error {
                if error.code == 0 {
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        let title = "Network Error"
                        let message = "Error communicating to Parse, check your internet connection"
                        let actionTitle = "OK"
                        
                        UIConfiguration.setAlertController(self, title: title, message: message, actionTitle: actionTitle)
                    }
                }
                
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    
    // Submit a new student location 
    func submitNewLoaction() {
        ParseAPIClient.sharedInstance().postStudentLocation { result, error in
            if let error = error {
                dispatch_async(dispatch_get_main_queue()) {
                    if error.code == 0 {
                        
                        let title = "Network Error"
                        let message = "Error communicating to Parse, check your internet connection"
                        let actionTitle = "OK"
                        
                        UIConfiguration.setAlertController(self, title: title, message: message, actionTitle: actionTitle)
                    }
                }
                
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }

    
    // Struct the region
    func structTheRegion(placemarks: [CLPlacemark]) -> MKCoordinateRegion? {
        
        var regions = [MKCoordinateRegion]()
        
        for placemark in placemarks {
            
            let coordinate: CLLocationCoordinate2D = placemark.location.coordinate
            let latitude: CLLocationDegrees = placemark.location.coordinate.latitude
            let longitude: CLLocationDegrees = placemark.location.coordinate.longitude
            let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            
            regions.append(MKCoordinateRegion(center: coordinate, span: span))
        }
        
        return regions[0]
    }
    
    
    // Perform some view-changes when pressing FindOnTheMap button 
    func performViewChanges() {
        
        locationTextField.hidden = true
        locationMapView.hidden = false
        findOnTheMapButton.setTitle("Share Link", forState: UIControlState.Normal)
        linkTextView.editable = true
        linkTextView.textColor = UIColor.blueColor()
        linkTextView.text = "Share a link of your interest, please make sure to prefix your link with http(s)://"
    }

    
    
// MARK: - Delegate methods
    
    // FIRST:- Tap Gesture Recognizer Delegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        return linkTextView!.isFirstResponder() || locationTextField!.isFirstResponder()
    }
    
    
    
    // SECOND:- textField Delegates
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        textField.text = ""
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        FetchedData.sharedInstance().mapString = textField.text!
    }


    // THIRD:- textView Delegates
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            
            textView.resignFirstResponder()
            
            return false
        }
        
        return true
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        textView.text = ""
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        if linkTextView!.text.isEmpty {
            
            // Propmt the student to enter a link of his/her interest to process the geocoding successfully
            linkTextView!.text = "Share a link of your interest, please make sure to prefix your link with http(s)://"
            
        } else {
            
            // Store the shared link to mediaURL variable
            FetchedData.sharedInstance().mediaURL = textView.text!
        }
    }

    
}
