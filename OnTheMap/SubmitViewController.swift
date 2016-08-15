//
//  SubmitViewController.swift
//  OnTheMap
//
//  Created by James Jongsurasithiwat on 5/30/16.
//  Copyright © 2016 James Jongs. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class SubmitViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    // MARK: - Variables
    
    var locationString: String!
    
    var incomingCoordinate : CLLocationCoordinate2D!
    
    
    // MARK: - IB elements
    
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var myMapView: MKMapView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var linkTextField: UITextField!
    
    
    // #MARK: - IBActions
    
    @IBAction func submit(sender: UIButton) {
        myActivityIndicator.startAnimating()
        // Get the last instance of this students informatin and update position, link, and display text
        var passableStudentInformation: StudentInformation = Model.sharedInstance().getThisStudent()
        passableStudentInformation.latitude = incomingCoordinate.latitude.description
        passableStudentInformation.longitude = incomingCoordinate.longitude.description
        passableStudentInformation.mediaURL = linkTextField.text == "Enter Link Address" ? "" : linkTextField.text
        passableStudentInformation.mapString = locationString
        
        // Decide to post or update this student's information
        if Model.sharedInstance().getThisStudent().objectId != nil {
            parseClient.updateThisStudentLocation(passableStudentInformation){
                (success, error) -> Void in
                self.stopAnimating()
                if success {
                    self.exitToAnnotation()
                } else {
                    self.displayAlertWindow("Submit Error", msg: "(error?.localizedDescription)!\n Submit again", actions: [self.dismissAction()])
                }
            }
        } else {
            parseClient.postThisStudentLocation(passableStudentInformation){
                (success, error) -> Void in
                self.stopAnimating()
                if success {
                    self.exitToAnnotation()
                } else {
                    self.displayAlertWindow("Submit Error", msg: "(error?.localizedDescription)!\n Submit again", actions: [self.dismissAction()])
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        linkTextField.delegate = self
        // Increase the size of Spinner
        myActivityIndicator.transform = CGAffineTransformMakeScale(5, 5)
        let annotation = MKPointAnnotation()
        if incomingCoordinate != nil {
            annotation.coordinate = incomingCoordinate
        }
        myMapView.showAnnotations([annotation as MKAnnotation], animated: true)
    }
    
    
    // Exit to last annotation display
    private func exitToAnnotation() {
        performUIUpdatesOnMain {
            self.performSegueWithIdentifier(ParseClient.Constants.ReturnToAnnotationDisplay, sender: nil)
        }
    }
    
    
    // MARK: - Function to help stop animating on completionHandlers
    private func stopAnimating(){
        performUIUpdatesOnMain(){()-> Void in
            self.myActivityIndicator.stopAnimating()
        }
    }
    
    
    // MARK: - Mapview Delegate method
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
    
    // MARK: - UITextField Delegate methods
    
    // Return button on soft keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}
