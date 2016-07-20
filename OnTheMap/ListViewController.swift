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
    
    var locations: [[String : AnyObject]] = [[String : AnyObject]]()
    let myPinImage:UIImage! = nil
    
    
    // MARK: - IB elements
    
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var myTableView: UITableView!
    
    
    // MARK: - IBActions
    
    // This is the target of unwinds to map annotation displays
    @IBAction func unwindToAnnotationDisplayReceiver(segue: UIStoryboardSegue){
    }
    
    @IBAction func refreshStudents(sender: AnyObject) {
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
    
    @IBAction func informationPosting(sender: AnyObject) {
        myActivityIndicator.startAnimating()
        checkStudentPostingStatusAndShowPostingScreen(){
            (success, present, error) -> Void in
            self.stopAnimating()
            if (success && present!.boolValue == true ){
                let action1 = UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.Destructive)
                    { (UIAlertAction) in self.performSegueWithIdentifier("moveToInformationPosting", sender: nil)}
                let action2 = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)
                self.displayAlertWindow("Post/Update Alert", msg: "You have already posted a student location. Would you like to overwrite your current location", actions: [action1,action2])
            } else if (error != nil){
                self.displayAlertWindow("Information Posting", msg: (error?.localizedDescription)!, actions: [self.dismissAction()])
            } else if (success && !(present?.boolValue == true)){
                //completionHandlerCheckStudentPosting(displayOverwriteWarning: false, error: nil)
                self.performSegueWithIdentifier("moveToInformationPosting", sender: nil)
            }
        }
    }
    
    @IBAction func logout(sender: UIBarButtonItem) {
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
        myActivityIndicator.transform = CGAffineTransformMakeScale(5, 5)
    }
    
    override func viewWillAppear(animated: Bool) {
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
        locations = ParseClient.sharedInstance().parseLocations
        performUIUpdatesOnMain{
            self.myTableView.reloadData()
        }
        stopAnimating()
    }
    
    
    // MARK: - Function to help stop animating on completionHandlers
    private func stopAnimating(){
        performUIUpdatesOnMain(){()-> Void in
            self.myActivityIndicator.stopAnimating()
        }
    }
    
    
    // MARK:  Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return locations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("mytableviewcell") as! MyTableViewCell?
        let alocation : [String : AnyObject] = locations[indexPath.row]
        let firstname = alocation["firstName"] as! String
        let lastname = alocation["lastName"] as! String
        let mapstring = alocation["mapString"]  as! String
        
        // Setting the cell properties
        // Set the name and image
        cell?.personName.text = "\(indexPath.row+1). \(firstname) \(lastname) at \(mapstring)"
        let myPinImage = UIImage.init(named: "pin")
        let imageView = UIImageView(image: myPinImage )
        cell?.cellPinImage.image = imageView.image
        cell?.weblink.text = alocation["mediaURL"] as? String
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let alocation : [String : AnyObject] = locations[indexPath.row]
        let personURL: String = alocation["mediaURL"] as! String
        openURL(personURL)


    }

}

