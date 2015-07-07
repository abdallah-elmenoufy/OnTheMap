//
//  StudentsOnTableView.swift
//  OnTheMap
//
//  Created by Abdallah ElMenoufy on 6/23/15.
//  Copyright (c) 2015 Abdallah ElMenoufy. All rights reserved.
//

import UIKit

class StudentsOnTableView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var studentsTableList: UITableView!
    
    // MARK: - Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the Table View Delegate and Data Source
        studentsTableList.delegate = self
        studentsTableList.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set the naviagation bar buttons
        UIConfiguration.sharedInstance().setNavBarButtons(self)
        
        // Reload table data
        studentsTableList.reloadData()
    }

    
    // MARK: - TableView Delegate and DataSource Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection seciont: Int) -> Int {
        
        return FetchedData.sharedInstance().studentsInformation.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Configure the cell
        let cellReuseIdentifier = "StudentPin"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! UITableViewCell
        let student = FetchedData.sharedInstance().studentsInformation[indexPath.row]
        
        
        cell.textLabel!.text = student.firstName + " " + student.lastName
        cell.detailTextLabel!.text = student.mediaURL
        cell.imageView!.image = UIImage(named: "pin")
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let student = FetchedData.sharedInstance().studentsInformation[indexPath.row]
        
        // Open Safari "system's browser" with the written url
        if UIConfiguration.verifyAGivenURL(student.mediaURL) {
            UIApplication.sharedApplication().openURL(NSURL(string: student.mediaURL)!)
            
        } else {
            let title = ""
            let message = "Failed, link cannot be opened"
            let actionTitle = "OK"
            
            UIConfiguration.setAlertController(self, title: title, message: message, actionTitle: actionTitle)
        }
    }

    
}
