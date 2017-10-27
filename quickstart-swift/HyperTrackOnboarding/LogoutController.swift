//
//  LogoutController.swift
//  HyperTrackOnboarding
//
//  Created by Arjun Attam on 09/05/17.
//  Copyright © 2017 Hypertrack. All rights reserved.
//

import UIKit
import HyperTrack
import CoreLocation

class LogoutController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapAcceptOrderButton(_ sender: Any) {
        // Check if the user is already on an order or not
        if UserDefaults.standard.string(forKey: "hypertrack_action_id") != nil {
            self.showAlert(message: "Please compelete assigned action before assigning another")
            return
        }
        
        // You can specify a lookup_id to Actions which maps to your internal id of the
        // order that is going to be tracked. This will help you search for the order on
        // HyperTrack dashboard, and get custom views for the specific order tracking.
        //
        // @NOTE: A randomly generated UUID is used as the lookup_id here. This will be the actual
        // orderID in your case which will be fetched from either your server or generated locally.
        let orderID: String = UUID().uuidString
        
        // Accept the order by creating a deliver action for the orderID
        acceptOrder(orderID: orderID)
    }
    
    func acceptOrder(orderID: String) {
        // Construct a place object for Action's expected place.
        // @NOTE: Pass either the address or the location for the expected place.
        // Both have been passed here only to show how it can be done, in case
        // the data is available.
        let expectedPlace: HyperTrackPlace = HyperTrackPlace().setAddress(address:
            "2200 Sand Hill Road, Menlo Park, CA, USA")
        
        // Create ActionParams object specifying the Delivery Type Action parameters including ExpectedPlace,
        // ExpectedAt time and Lookup_id.
        let htActionParams = HyperTrackActionParams()
        htActionParams.expectedPlace = expectedPlace
        htActionParams.type = "delivery"
        htActionParams.lookupId = orderID
        
        // Call createAndAssignAction to assign Delivery action to the current
        // user configured in the SDK using the Place object created above.
        HyperTrack.createAndAssignAction(htActionParams) { action, error in
            
            if let error = error {
                // Handle createAndAssignAction API error here
                print(error.type.rawValue)
                self.showAlert(message: error.type.rawValue)
                return
            }
            
            if let action = action {
                // Handle createAndAssignAction API success here
                print(action)
                self.showAlert(message: "You have create an action. Mark it complete once it is completed!")
                
                // Save Action id and use this to query the stats of the action later.
                UserDefaults.standard.set(action.id!, forKey: "hypertrack_action_id")
            }
        }
    }
    
    @IBAction func didTapCompleteOrderButton(_ sender: Any) {
        // Get saved ActionId corresponding to the ongoing order
        let actionId = UserDefaults.standard.string(forKey: "hypertrack_action_id")
        
        // Check if the user is already on an order or not
        if actionId == nil {
            self.showAlert(message: "Please create an action before trying to completing it.")
            return
        }
        
        // Complete Action when the order is marked complete using the saved ActionId
        HyperTrack.completeAction(actionId!)
        
        // Clear saved ActionId
        UserDefaults.standard.removeObject(forKey: "hypertrack_action_id")
        self.showAlert(message: "Your action is completed")
    }
    
    @IBAction func didTapLogOutButton(_ sender: Any) {
        // Check if the user is already on an order or not
        if UserDefaults.standard.string(forKey: "hypertrack_action_id") != nil {
            self.showAlert(message: "Please complete ongoing action before logging out.")
            return
        }
        
        // Stop tracking the user on successful logout. This indicates the user
        // is now offline.
        HyperTrack.stopTracking()
        
        // End user session by navigating to ViewController
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "login")
        self.present(vc!, animated: true, completion: nil)
    }
    
    private func showAlert(message: String) {
        // create the alert
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}
