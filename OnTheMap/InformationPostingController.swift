//
//  InformationPostingController.swift
//  OnTheMap
//
//  Created by James Jongsurasithiwat on 5/27/16.
//  Copyright © 2016 James Jongs. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingController: UIViewController , UITextViewDelegate {
    
    // MARK: - Variables
    
    var ipcCoordinate: CLLocationCoordinate2D!
    
    
    // MARK: - IB elements
    
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var locationString: UITextView!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - IBActions
    
    @IBAction func findOnMapPressed(_ sender: AnyObject) {
        if locationString.text == "Enter Your Location Here" || locationString.text == "" {
            performUIUpdatesOnMain {
                let alertwindow:UIAlertController = UIAlertController(title: "", message: "You Must Enter a Location", preferredStyle: UIAlertControllerStyle.alert)
                alertwindow.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertwindow, animated: true, completion: nil)
            }
        } else {
            encodeAddress(locationString.text)
        }
    }
    
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationString.delegate = self
        // Increase the size of Spinner
        myActivityIndicator.transform = CGAffineTransform(scaleX: 5, y: 5)        
        subscribeToKeyboardShowNotifications()
    }
    
    func encodeAddress(_ input:String) {
        myActivityIndicator.startAnimating()
        CLGeocoder().geocodeAddressString(input) { (placemarksarray, error) -> Void in
            self.myActivityIndicator.stopAnimating()
            if error != nil {
                self.displayAlertWindow("Geocoding Error", msg: "\(input) Failed Please try again", actions: [self.dismissAction()])
            } else {
                let placemark: CLPlacemark = placemarksarray![0] as CLPlacemark
                self.ipcCoordinate = placemark.location!.coordinate
                self.performSegue(withIdentifier: "continuetolink", sender: self)
            }
        }// end of geocoder completion handler
    }
    
    // This Uses Depdency injector pattern to send information to the SubmitViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is SubmitViewController {
            let referenceToSubmitView = segue.destination as! SubmitViewController
            referenceToSubmitView.incomingCoordinate = ipcCoordinate
            referenceToSubmitView.locationString = self.locationString.text
        }
    }
    
    
    // MARK: UITextViewDelegate methods
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") { //new line
            textView.resignFirstResponder()
            return false
        } else { // replace old text
            return true
        }
    }
    
    // This clears the textView when the user begins editting the text view
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.text = ""
        return true
    }
    
}
