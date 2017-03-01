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
    
    var locations: [StudentInformation] = [StudentInformation]()
    let model = Model.sharedInstance()

    // MARK: - IB elements
    
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - IBActions
    
    // This is the target of unwinds to map annotation displays
    @IBAction func unwindToAnnotationDisplayReceiver(_ segue: UIStoryboardSegue){
    }
    
    @IBAction func refreshPositions(_ sender: UIBarButtonItem) {
        myActivityIndicator.startAnimating()
        getStudentLocationsFromParseClient()
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
        mapView.delegate = self
        // Increase the size of Spinner
        myActivityIndicator.transform = CGAffineTransform(scaleX: 5, y: 5)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
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
            let locations = self.model.getStudents()
            for student in locations {
                let lat = CLLocationDegrees((Double(student.latitude))!)
                let long = CLLocationDegrees((Double(student.longitude))!)
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let first = student.firstName
                let last = student.lastName
                let mediaURL = student.mediaURL
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first ?? "")  \(last ?? "")"
                annotation.subtitle = mediaURL ?? ""
                annotations.append(annotation)
            }
            // Update the map
            self.mapView.addAnnotations(annotations)
            self.stopAnimating()
        }
    }
    
    // MARK: - Function to help stop animating on completionHandlers
    fileprivate func stopAnimating(){
        performUIUpdatesOnMain(){()-> Void in
            self.myActivityIndicator.stopAnimating()
        }
    }
    
    
    // MARK: - MKMapViewDelegate Methods
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let url: String = (view.annotation?.subtitle!)!
            openURL(url)
        }
    }
    
}


