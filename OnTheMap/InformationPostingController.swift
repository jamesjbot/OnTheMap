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
    
    @IBAction func findOnMapPressed(sender: AnyObject) {
        if locationString.text == "Enter Your Location Here" || locationString.text == "" {
            performUIUpdatesOnMain {
                let alertwindow:UIAlertController = UIAlertController(title: "", message: "You Must Enter a Location", preferredStyle: UIAlertControllerStyle.Alert)
                alertwindow.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertwindow, animated: true, completion: nil)
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
        myActivityIndicator.transform = CGAffineTransformMakeScale(5, 5)
        
        
        print("location maxY,\(locationString.frame.maxY)")
        print("location miny,\(locationString.frame.minY)")
        
        subscribeToKeyboardShowNotifications()
    }
    
    func encodeAddress(input:String) {
        myActivityIndicator.startAnimating()
        CLGeocoder().geocodeAddressString(input) { (placemarksarray, error) -> Void in
            self.myActivityIndicator.stopAnimating()
            if error != nil {
                self.displayAlertWindow("Geocoding Error", msg: input, actions: [self.dismissAction()])
            } else {
                let placemark: CLPlacemark = placemarksarray![0] as CLPlacemark
                self.ipcCoordinate = placemark.location!.coordinate
                self.performSegueWithIdentifier("continuetolink", sender: self)
            }
        }// end of geocoder completion handler
    }
    
    // This passes information to the SubmitViewController so this is for forward segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is SubmitViewController {
            let referenceToSubmitView = segue.destinationViewController as! SubmitViewController
            referenceToSubmitView.incomingCoordinate = ipcCoordinate
            referenceToSubmitView.locationString = self.locationString.text
        }
    }
    
    
    // MARK: UITextViewDelegate methods
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") { //new line
            textView.resignFirstResponder()
            return false
        } else { // replace old text
            return true
        }
    }
}