//
//  ListViewController.swift
//  OnTheMap
//
//  Created by James Jongsurasithiwat on 4/30/16.
//  Copyright © 2016 James Jongs. All rights reserved.
//

import Foundation

import UIKit

class ListViewController: UIViewController, UINavigationBarDelegate, UITableViewDataSource, UITableViewDelegate, RefreshableFromModelProtocol { //Add TableView Delegates  {
    
    // MARK: - Variables
    
    var locations: [StudentInformation] = [StudentInformation]()
    let myPinImage:UIImage! = nil
    var model = Model.sharedInstance()
    
    
    // MARK: - IB elements
    
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var myTableView: UITableView!
    
    
    // MARK: - IBActions
    
    // This is the target of unwinds to map annotation displays
    @IBAction func unwindToAnnotationDisplayReceiver(_ segue: UIStoryboardSegue){
    }
    
    @IBAction func refreshStudents(_ sender: AnyObject) {
        myActivityIndicator.startAnimating()
        parseClient.getAllStudentLocationsAndRefreshView(){
            (success, error) -> Void in
            self.stopAnimating()
            if success {
                performUIUpdatesOnMain{
                    self.updateStudentLocationsInView()
                }
            } else{
                self.displayAlertWindow("TableView Student Locations", msg: (error?.localizedDescription)!, actions: [self.dismissAction()])
            }
        }
    }
    
    @IBAction func informationPosting(_ sender: AnyObject) {
        myActivityIndicator.startAnimating()
        checkStudentPostingStatusAndShowPostingScreen(){
            (success, present, error) -> Void in
            self.stopAnimating()
            if (success && present! == true ){
                let action1 = UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.destructive)
                    { (UIAlertAction) in self.performSegue(withIdentifier: "moveToInformationPosting", sender: nil)}
                let action2 = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil)
                self.displayAlertWindow("Post/Update Alert", msg: "You have already posted a student location. Would you like to overwrite your current location", actions: [action1,action2])
            } else if (error != nil){
                self.displayAlertWindow("Information Posting", msg: (error?.localizedDescription)!, actions: [self.dismissAction()])
            } else if (success && !(present == true)){
                //completionHandlerCheckStudentPosting(displayOverwriteWarning: false, error: nil)
                self.performSegue(withIdentifier: "moveToInformationPosting", sender: nil)
            }
        }
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        myActivityIndicator.startAnimating()
        logoutAsynchronously()
    }
    
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register as datasource as delegate
        myTableView.dataSource = self
        myTableView.delegate = self
        // Increase the size of Spinner
        myActivityIndicator.transform = CGAffineTransform(scaleX: 5, y: 5)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myActivityIndicator.startAnimating()
        parseClient.getAllStudentLocationsAndRefreshView(){
            (success, error) -> Void in
            self.stopAnimating()
            if success {
                    self.updateStudentLocationsInView()
            } else{
                self.displayAlertWindow("TableView Student Locations", msg: (error?.localizedDescription)!, actions: [self.dismissAction()])
            }
        }
    }
    
    func updateStudentLocationsInView(){
        locations = model.getStudents()
        performUIUpdatesOnMain{
            self.myTableView.reloadData()
        }
        stopAnimating()
    }
    
    
    // MARK: - Function to help stop animating on completionHandlers
    fileprivate func stopAnimating(){
        performUIUpdatesOnMain(){()-> Void in
            self.myActivityIndicator.stopAnimating()
        }
    }
    
    
    // MARK:  Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "mytableviewcell") as! MyTableViewCell?
        let student : StudentInformation = locations[(indexPath as NSIndexPath).row]
        let firstname = student.firstName ?? ""
        let lastname = student.lastName ?? ""
        let mapstring = student.mapString ?? ""
        
        // Setting the cell properties
        // Set the name and image
        cell?.personName.text = "\((indexPath as NSIndexPath).row+1). \(firstname) \(lastname) at \(mapstring)"
        let myPinImage = UIImage.init(named: "pin")
        let imageView = UIImageView(image: myPinImage )
        cell?.cellPinImage.image = imageView.image
        cell?.weblink.text = student.mediaURL
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alocation : StudentInformation = locations[(indexPath as NSIndexPath).row]
        let personURL: String = alocation.mediaURL
        // Unselect entry on table
        tableView.deselectRow(at: indexPath, animated: true)
        openURL(personURL)
    }

}

