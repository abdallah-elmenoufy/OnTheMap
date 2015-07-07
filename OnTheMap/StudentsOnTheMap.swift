//
//  StudentsOnTheMap.swift
//  OnTheMap
//
//  Created by Abdallah ElMenoufy on 6/22/15.
//  Copyright (c) 2015 Abdallah ElMenoufy. All rights reserved.
//

import UIKit
import MapKit

class StudentsOnTheMap: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var studentsPinsMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the MapView delegate to self
        studentsPinsMapView.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set the NavigationBarButtons
        UIConfiguration.sharedInstance().setNavBarButtons(self)
        
        // Call Parse API and load the earlier-posted students-locations on the MapView
        ParseAPIClient.sharedInstance().getStudentsLocations { students, error in
            
        if let students = students {
            dispatch_async(dispatch_get_main_queue()) {
                
                FetchedData.sharedInstance().studentsInformation = students
                
                let annotations = Annotations.annotationsFromStudents(FetchedData.sharedInstance().studentsInformation)
                if (self.studentsPinsMapView.annotations != nil) {
                        self.studentsPinsMapView.removeAnnotations(self.studentsPinsMapView.annotations)
                    }
                    self.studentsPinsMapView.addAnnotations(annotations)
                }
            
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                
                    if error!.code == 0 {
                        
                        let title = "Network Error"
                        let message = "Error communicating to Parse, please check your internet connection"
                        let actionTitle = "OK"
                        
                        UIConfiguration.setAlertController(self, title: title, message: message, actionTitle: actionTitle)
                        
                    } else {
                        
                        let title = "Error!"
                        let message = "Faile to get students information from Parse"
                        let actionTitle = "OK"
                        
                        UIConfiguration.setAlertController(self, title: title, message: message, actionTitle: actionTitle)
                    }
                }
            }
        }

    }
    
    // MARK: - MapView DelegateMethods
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if let annotation = annotation as? Annotations {
            
            let identifier = "pin"
            var view: MKPinAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                    
                    dequeuedView.annotation = annotation
                    view = dequeuedView
                    
            } else {
                
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
            }
            
            return view
        }
        
        return nil
    }
    
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        
        let annotation = view.annotation as! Annotations
        
        // Open Safari "system's browser" to the URL written by student at the annotatio subtitle sting
        
        if UIConfiguration.verifyAGivenURL(annotation.subtitle!) {
            UIApplication.sharedApplication().openURL(NSURL(string: annotation.subtitle!)!)
            
        } else {
            
            // Call the pre-configured AlertController with the following paramters
            let title = ""
            let message = "Failed, link cannot be opened"
            let actionTitle = "OK"
            
            UIConfiguration.setAlertController(self, title: title, message: message, actionTitle: actionTitle)
        }
    }

    
}