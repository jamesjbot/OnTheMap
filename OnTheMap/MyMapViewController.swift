//
//  MyMapViewController.swift
//  OnTheMap
//
//  Created by James Jongsurasithiwat on 4/30/16.
//  Copyright © 2016 James Jongs. All rights reserved.
//

import MapKit
import UIKit

class MyMapViewController: UIViewController, UINavigationBarDelegate, MKMapViewDelegate, RefreshableFromModelProtocol {
    
    // MARK: - Variables
    
    var locations: [[String : AnyObject]] = [[String : AnyObject]]()
    let model = Model.sharedInstance()
    
    // MARK: - IB elements
    
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - IBActions
    
    // This is the target of unwinds to map annotation displays
    @IBAction func unwindToAnnotationDisplayReceiver(segue: UIStoryboardSegue){
    }
    
    @IBAction func refreshPositions(sender: UIBarButtonItem) {
        myActivityIndicator.startAnimating()
        getStudentLocationsFromParseClient()
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
        mapView.delegate = self
        // Increase the size of Spinner
        myActivityIndicator.transform = CGAffineTransformMakeScale(5, 5)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getStudentLocationsFromParseClient()
    }
    
    
    // Tell the parseClient to update the global student locations model and update my mapview
    func getStudentLocationsFromParseClient() {
        myActivityIndicator.startAnimating()
        parseClient.getAllStudentLocationsAndRefreshView(){
            (success, error) -> Void in
            // Whenever we comeback from a request lets stop animating
            self.stopAnimating()
            if success {
                self.updateStudentLocationsInView()
            } else {
                self.displayAlertWindow("Map View Students Request", msg: (error?.localizedDescription)!, actions: [self.dismissAction()])
            }
        }
    }
    
    
    // Method that will grab the student locations from the parseclient mode and update all student pin positions in the mapview
    func updateStudentLocationsInView(){
        performUIUpdatesOnMain(){()-> Void in
            self.mapView.removeAnnotations(self.mapView.annotations)
            var annotations = [MKPointAnnotation]()
            // FIXME I should read the student information from the array of student informations in the model
            self.locations = model.students
            for dictionary in self.locations {
                let lat = CLLocationDegrees(dictionary["latitude"] as! Double)
                let long = CLLocationDegrees(dictionary["longitude"] as! Double)
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let first = dictionary["firstName"] as! String
                let last = dictionary["lastName"] as! String
                let mediaURL = dictionary["mediaURL"] as! String
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL
                annotations.append(annotation)
            }
            // Update the map
            self.mapView.addAnnotations(annotations)
            self.stopAnimating()
        }
    }
    
    // MARK: - Function to help stop animating on completionHandlers
    private func stopAnimating(){
        performUIUpdatesOnMain(){()-> Void in
            self.myActivityIndicator.stopAnimating()
        }
    }
    
    
    // MARK: - MKMapViewDelegate Methods
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let url: String = (view.annotation?.subtitle!)!
            openURL(url)
        }
    }
    
}


