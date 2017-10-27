//
//  MapProviderProtocol.swift
//  HyperTrack
//
//  Created by Anil Giri on 27/04/17.
//  Copyright © 2017 HyperTrack. All rights reserved.
//

import Foundation
import MapKit

@objc public protocol MapProviderProtocol : class  {
    
    var mapCustomizationDelegate : MapCustomizationDelegate? {get set}
    
    func getMapView() -> UIView
    func setMapFrame(frame:CGRect)
    
    func addMarker(annotation: HTMapAnnotation)
    func updatePositionForMarker(annotation : HTMapAnnotation, coordinate : CLLocationCoordinate2D)
    func updateBearingForMarker(annotation: HTMapAnnotation, bearing: CLLocationDirection)
    func removeMarker(annotation : HTMapAnnotation)
    func removeAllAnnotations()
    func getViewForMaker(annotation : HTMapAnnotation) -> MKAnnotationView?
    func getCameraHeading() -> CLLocationDirection
    func zoomTo(visibleRegion: MKCoordinateRegion, animated: Bool)
    func addPolyline(encodedPolyline: String,identifier:String)
    func removePolylineWithIdentifier(identifier: String)
    func updatePolyline(polyline: String)
    func updatePolyline(polyline: String,startMarkerImage:UIImage?)
    func updatePolyline(polyline: String,startMarkerImage:UIImage?,destinationImage:UIImage?)
    func enableTrafficView()
    func disableTrafficView()
    func updateViewFocus(mapEdgePadding:UIEdgeInsets)
    func clearMap()
}



@objc public protocol MapCustomizationDelegate : class {
   @objc optional func annotationView(_ mapView: MKMapView, annotation: HTMapAnnotation) -> MKAnnotationView?
   @objc optional func imageView(_ mapView: MKMapView, annotation: HTMapAnnotation) -> UIImage?
   @objc optional func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool)
   @objc optional func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)
   @objc optional func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
}

