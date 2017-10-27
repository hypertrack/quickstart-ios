//
//  HTMockLocationParams.swift
//  HyperTrack
//
//  Created by ravi on 9/24/17.
//  Copyright © 2017 HyperTrack. All rights reserved.
//

import UIKit
import CoreLocation

@objc public class HTMockLocationParams: NSObject {
    public let origin:CLLocationCoordinate2D
    public let destination: CLLocationCoordinate2D
    
    public init(origin:CLLocationCoordinate2D,destination:CLLocationCoordinate2D) {
        self.origin = origin
        self.destination = destination
    }
    
    public init(destination:CLLocationCoordinate2D) {
        self.destination = destination
        if let location = Transmitter.sharedInstance.locationManager.getLastKnownLocation() {
            self.origin = location.coordinate
        } else {
            self.origin = CLLocationCoordinate2DMake(28.556446, 77.174095)
        }
    }
}
