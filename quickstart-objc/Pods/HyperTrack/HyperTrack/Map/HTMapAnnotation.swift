//
//  HTMapAnnotation.swift
//  Pods
//
//  Created by Ravi Jain on 05/06/17.
//
//

import UIKit
import MapKit

@objc public enum MarkerType: Int {
    case DESTINATION_MARKER = 0
    case HERO_MARKER = 1
    case HERO_MARKER_WITH_ETA = 2
}

@objc public class HTMapAnnotation: MKPointAnnotation {
  
    var id : String?
    dynamic var disableRotation: Bool = false
    var image: UIImage?
    public var type = MarkerType.HERO_MARKER
    var action : HyperTrackAction? = nil
    var location : CLLocation? = nil
    var place : HyperTrackPlace? = nil
    var currentHeading : CLLocationDirection? = nil

    override init() {
        super.init()
        self.image = nil
    }
}
