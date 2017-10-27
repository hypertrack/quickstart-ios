//
//  ViewController.swift
//  HyperTrackOnboarding
//
//  Created by Arjun Attam on 09/05/17.
//  Copyright © 2017 Hypertrack. All rights reserved.
//

import UIKit
import HyperTrack

class ViewController: UIViewController {

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    
    override func viewDidAppear(_ animated: Bool) {
        // Check if user is logged in already
        if (HyperTrack.isTracking) {
            // Start User Session by starting LogoutViewController
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "action")
            self.present(vc!, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        HyperTrack.getPlacelineView(frame: self.view.frame,forDate: Date())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     * This method is called when User Login button is tapped.
     * Note that this method is linked with Main.Storyboard file using this
     * button's "Touch up inside" sent event.
     *
     * @param sender
     */
    @IBAction func didTapUserLoginButton(_ sender: UIButton) {
        // Get User details, if specified
        let userName = userNameField.text ?? ""
        let phoneNumber = phoneNumberField.text
        let lookupID = phoneNumber
        
        /**
         * Get or Create a User for given lookupId on HyperTrack Server here to
         * login your user & configure HyperTrack SDK with this generated
         * HyperTrack UserId.
         * OR
         * Implement your API call for User Login and get back a HyperTrack
         * UserId from your API Server to be configured in the HyperTrack SDK.
         */
        HyperTrack.getOrCreateUser(userName, _phone: phoneNumber!, lookupID!) { (user, error) in
            if (error != nil) {
                // Handle getOrCreateUser API error here
                self.showAlert("Error", message: (error?.type.rawValue)!)
                return
            }
            
            if (user != nil) {
                // Handle getOrCreateUser API success here
                self.onLoginSuccess()
            }
        }
    }
    
    /**
     * Call this method when user has successfully logged in
     */
    func onLoginSuccess() {
       
        // Start tracking the user on successful login. This indicates the user 
        // is online.
        HyperTrack.startTracking()
        
        // Start user session by navigating to LogOutViewController
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "action")
        self.present(vc!, animated: true, completion: nil)
    }

    func showAlert(_ title: String = "Alert", message: String) {
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}
