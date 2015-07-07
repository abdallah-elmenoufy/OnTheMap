//
//  Annotations.swift
//  OnTheMap
//
//  Created by Abdallah ElMenoufy on 6/23/15.
//  Copyright (c) 2015 Abdallah ElMenoufy. All rights reserved.
//

import UIKit
import MapKit

class Annotations: NSObject, MKAnnotation {
    
    let title: String
    var subtitle: String?
    let coordinate: CLLocationCoordinate2D
    
    init(latitude: Double, longitude: Double, firstName: String, lastName: String, mediaURL: String?) {
        
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        self.title = firstName + " " + lastName
        
        if let mediaURL = mediaURL {
            
            self.subtitle = mediaURL
            
        } else {
            
            self.subtitle = nil
        }
        
        super.init()
    }
    
    // Helper: Given an array of StudentInformation objects, convert them to an array of Annotations objects
    class func annotationsFromStudents(students: [StudentInformation]) -> [Annotations] {
        
        var annotations = [Annotations]()
        
        for student in students {
            
            let annotation = Annotations (
                latitude: student.latitude,
                longitude: student.longitude,
                firstName: student.firstName,
                lastName: student.lastName,
                mediaURL: student.mediaURL
            )
            annotations.append(annotation)
        }
        
        return annotations
    }
 
    
}

