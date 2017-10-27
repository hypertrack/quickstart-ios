//
//  AppleMapsProvider.swift
//  HyperTrack
//
//  Created by Anil Giri on 28/04/17.
//  Copyright © 2017 HyperTrack. All rights reserved.
//

import Foundation
import MapKit


class HTImageAnnotation: MKPointAnnotation {
    var markerView: UIView
    
    init(markerView: UIView) {
        self.markerView = markerView
        super.init()
    }
}

class AppleMapsProvider: NSObject, MapProviderProtocol, UIGestureRecognizerDelegate {
    
    var mapCustomizationDelegate: MapCustomizationDelegate?
    
    let mapView: MKMapView
    var reFocusDisabledByUserInteraction: Bool = false
    var polylines = [String:MKPolyline]()
    
    required override init( ) {
        let mapView = MKMapView()
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isRotateEnabled = false
        mapView.isScrollEnabled = true
        self.mapView = mapView
        super.init()
        self.mapView.delegate = self
        self.mapView.showsPointsOfInterest = true
    }
    
    func getMapView() -> UIView{
        return self.mapView
    }
    
    func embedMapViewIn(view:UIView){
        view.addSubview(self.mapView)
    }
    
    func setMapFrame(frame:CGRect){
        self.mapView.frame = frame
    }
    
    func addMarker(annotation : HTMapAnnotation){
        self.mapView.addAnnotation(annotation)
    }
    
    func updatePositionForMarker(annotation : HTMapAnnotation, coordinate : CLLocationCoordinate2D){
        annotation.coordinate = coordinate
    }
    
    func updateBearingForMarker(annotation: HTMapAnnotation, bearing: CLLocationDirection){
        if let view = self.getViewForMaker(annotation: annotation) {
            view.transform = CGAffineTransform(rotationAngle: CGFloat(bearing * Double.pi / 180.0))
        }
    }
    
    func removeMarker(annotation : HTMapAnnotation){
        self.mapView.removeAnnotation(annotation)
    }
    
    func showUserLocation(){
        self.mapView.showsUserLocation  = true
    }
    func disableUserLocation(){
        self.mapView.showsUserLocation = false
    }
    
    func enableTrafficView(){
        if #available(iOS 9.0, *) {
            self.mapView.showsTraffic = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    func disableTrafficView(){
        if #available(iOS 9.0, *) {
            self.mapView.showsTraffic = false
        } else {
            // Fallback on earlier versions
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func zoomTo(visibleRegion: MKCoordinateRegion, animated: Bool = false)  {
        self.mapView.setRegion(visibleRegion, animated: animated)
    }
    
    
    // MARK: MapView Delegate methods
    func mapMarkerForHero(annotation : HTMapAnnotation) -> MKAnnotationView{
        let bundle = Settings.getBundle()!
        var marker = self.mapView.dequeueReusableAnnotationView(withIdentifier: "map.marker.hero")
        if marker == nil {
            marker = MKAnnotationView()
        }
        
        let markerView: MarkerView?
        // Construct HeroAnnotation for Live Location Sharing use case
        if (annotation.type == MarkerType.HERO_MARKER_WITH_ETA) {
            markerView = bundle.loadNibNamed("MarkerETAView", owner: self, options: nil)?.first as? MarkerView
            markerView!.annotationLabel.text = annotation.title
            markerView!.subtitleLabel.text = annotation.subtitle
        } else {
            
            // Construct HeroAnnotation for order tracking use case
            markerView = bundle.loadNibNamed("MarkerView", owner: self, options: nil)?.first as? MarkerView
        }
        
        return mapMarkerForView(markerView: markerView!)
    }
    
    // MARK: Helper methods
    func mapMarkerForDestination() -> MKAnnotationView {
        let bundle = Settings.getBundle()!
        let markerView: DestinationMarkerView = bundle.loadNibNamed("DestinationMarkerView", owner: self, options: nil)?.first as! DestinationMarkerView
        return mapMarkerForView(markerView: markerView)
    }
    
    func mapMarkerForView(markerView: UIView) -> MKAnnotationView {
        let marker = MKAnnotationView()
        let adjustedOrigin = CGPoint(x: -markerView.frame.size.width / 2, y: -markerView.frame.size.height / 2)
        markerView.frame = CGRect(origin: adjustedOrigin, size: markerView.frame.size)
        
        marker.addSubview(markerView)
        marker.bringSubview(toFront: markerView)
        return marker
    }
    
    
    func updateInfoWindowOfMarker(annotation:HTMapAnnotation){
        let view = self.mapView.view(for: annotation)
        if let view = view {
            // Update HeroMarker's title and subtitle
            if (annotation.type == MarkerType.HERO_MARKER_WITH_ETA) {
                if let markerView = view.subviews.first as? MarkerView {
                    markerView.subtitleLabel.text = annotation.subtitle
                }
            }
        }
    }
    
    
    func updatePolyline(polyline: String) {
        mapPolylineFor(encodedPolyline: polyline)
    }
    
    func updatePolyline(polyline: String,startMarkerImage:UIImage?){
        mapPolylineFor(encodedPolyline: polyline,startMarkerImage:startMarkerImage)
    }
    
    func updatePolyline(polyline: String,startMarkerImage:UIImage?,destinationImage:UIImage?){
        mapPolylineFor(encodedPolyline: polyline,startMarkerImage:startMarkerImage,destinationImage: destinationImage)
    }
    
    func mapPolylineFor(encodedPolyline: String, startMarkerImage:UIImage? = nil, destinationImage:UIImage? = nil) {
        let coordinates = PolylineUtils.decodePolyline(encodedPolyline)
        
        let polyline = MKPolyline(coordinates: coordinates!, count: coordinates!.count)
        self.mapView.add(polyline)
        let bundle = Settings.getBundle()!
        
        // Add circle and square at the start and end of the polyline
        if let first = coordinates?.first {
            let markerView: StartMarkerView = bundle.loadNibNamed("StartMarkerView", owner: self, options: nil)?.first as! StartMarkerView
            if (startMarkerImage != nil){
                markerView.startMarkerImage.image = startMarkerImage
            }
            
            let startAnnotation = HTImageAnnotation(markerView: markerView)
            startAnnotation.coordinate = first
            self.mapView.addAnnotation(startAnnotation)
        }
        
        if let last = coordinates?.last {
            let markerView: DestinationMarkerView = bundle.loadNibNamed("DestinationMarkerView", owner: self, options: nil)?.first as! DestinationMarkerView
            let startAnnotation = HTImageAnnotation(markerView: markerView)
            if (destinationImage != nil){
                markerView.markerImage.image = destinationImage
            }
            
            startAnnotation.coordinate = last
            self.mapView.addAnnotation(startAnnotation)
        }
    }
    
    func addPolyline(encodedPolyline: String,identifier:String){
        let coordinates = PolylineUtils.decodePolyline(encodedPolyline)
        let polylineOverlay = MKPolyline(coordinates: coordinates!, count: coordinates!.count)
        polylineOverlay.title  = identifier
        self.mapView.add(polylineOverlay)
        polylines[identifier] = polylineOverlay
    }
    
    
    func removePolylineWithIdentifier(identifier: String) {
        if let polyline = polylines[identifier]{
            self.mapView.remove(polyline)
        }
    }
    
    
    func reFocusMap(mapEdgePadding:UIEdgeInsets){
        self.reFocusDisabledByUserInteraction = false
        self.updateViewFocus(mapEdgePadding:mapEdgePadding)
    }
    
    func updateViewFocus(mapEdgePadding:UIEdgeInsets){
        
        if (self.reFocusDisabledByUserInteraction == true) {
            return
        }
        
        var annotationsForFocus = self.mapView.annotations
        var overlaysForFocus = self.mapView.overlays
        
        var zoomRect:MKMapRect = MKMapRectNull
        
        for index in 0..<annotationsForFocus.count {
            let annotation = annotationsForFocus[index]
            let aPoint:MKMapPoint = MKMapPointForCoordinate(annotation.coordinate)
            let rect:MKMapRect = MKMapRectMake(aPoint.x, aPoint.y, 0.1, 0.1)
            
            if MKMapRectIsNull(zoomRect) {
                zoomRect = rect
            } else {
                zoomRect = MKMapRectUnion(zoomRect, rect)
            }
        }
        
        for index in 0..<overlaysForFocus.count {
            let overlay = overlaysForFocus[index]
            let rect = overlay.boundingMapRect
            
            if MKMapRectIsNull(zoomRect) {
                zoomRect = rect
            } else {
                zoomRect = MKMapRectUnion(zoomRect, rect)
            }
        }
        
        mapView.setVisibleMapRect(zoomRect, edgePadding: mapEdgePadding, animated: true)
        
    }
    
    func focusMarkers(markers : [HTMapAnnotation?]){
        
        var zoomRect:MKMapRect = MKMapRectNull
        
        for index in 0..<markers.count {
            if let annotation =  markers[index]{
                let aPoint:MKMapPoint = MKMapPointForCoordinate(annotation.coordinate)
                let rect:MKMapRect = MKMapRectMake(aPoint.x, aPoint.y, 0.1, 0.1)
                if MKMapRectIsNull(zoomRect) {
                    zoomRect = rect
                } else {
                    zoomRect = MKMapRectUnion(zoomRect, rect)
                }
            }
        }
        if(!MKMapRectIsNull(zoomRect)){
            let mapEdgePadding = UIEdgeInsets(top: 160, left: 40, bottom: 140, right: 40)
            mapView.setVisibleMapRect(zoomRect, edgePadding: mapEdgePadding, animated: true)
            
        }
    }
    
    func focusMarkers(markers : [HTMapAnnotation?], insets:UIEdgeInsets){
        
        var zoomRect:MKMapRect = MKMapRectNull
        
        for index in 0..<markers.count {
            if let annotation = markers[index]{
                let aPoint:MKMapPoint = MKMapPointForCoordinate(annotation.coordinate)
                let rect:MKMapRect = MKMapRectMake(aPoint.x, aPoint.y, 0.1, 0.1)
                if MKMapRectIsNull(zoomRect) {
                    zoomRect = rect
                } else {
                    zoomRect = MKMapRectUnion(zoomRect, rect)
                }
            }
        }
        if(!MKMapRectIsNull(zoomRect)){
            mapView.setVisibleMapRect(zoomRect, edgePadding: insets, animated: true)
        }
    }
    
    
    
    func clearMap() {
        let allAnnotations = self.mapView.annotations
        let allOverlays = self.mapView.overlays
        self.mapView.removeAnnotations(allAnnotations)
        self.mapView.removeOverlays(allOverlays)
    }
    
    public func removeAllAnnotations(){
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
    
    
    func setVisibleMapRect(_ mapRect: MKMapRect, edgePadding insets: UIEdgeInsets, animated animate: Bool){
        self.mapView.setVisibleMapRect(mapRect, edgePadding: insets, animated: animate)
    }
    
    func focusAllMarkers(insets:UIEdgeInsets){
        var zoomRect:MKMapRect = MKMapRectNull
        
        for annotation in self.mapView.annotations {
            let aPoint:MKMapPoint = MKMapPointForCoordinate(annotation.coordinate)
            let rect:MKMapRect = MKMapRectMake(aPoint.x, aPoint.y, 0.1, 0.1)
            if MKMapRectIsNull(zoomRect) {
                zoomRect = rect
            } else {
                zoomRect = MKMapRectUnion(zoomRect, rect)
            }
        }
        if(!MKMapRectIsNull(zoomRect)){
            mapView.setVisibleMapRect(zoomRect, edgePadding: insets, animated: true)
            
        }
    }
    
    func getViewForMaker(annotation : HTMapAnnotation) -> MKAnnotationView? {
        return self.mapView.view(for: annotation)
    }
    
    func getCameraHeading() -> CLLocationDirection {
        return self.mapView.camera.heading
    }
    
}


extension AppleMapsProvider:  MKMapViewDelegate{
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        guard let tileOverlay = overlay as? MKTileOverlay else {
            return MKOverlayRenderer(overlay: overlay)
        }
        return MKTileOverlayRenderer(tileOverlay: tileOverlay)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let renderer = mapCustomizationDelegate?.mapView?(mapView, rendererFor: overlay){
            return renderer
        }
        
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }
        
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.lineWidth = 3.0
        renderer.strokeColor = htBlack
        
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if(annotation is HTMapAnnotation){
            let mapAnnotation = annotation as! HTMapAnnotation
            if let annotationView = mapCustomizationDelegate?.annotationView?(self.mapView,annotation: mapAnnotation){
                return annotationView
            }
            
            if let image = mapCustomizationDelegate?.imageView?(self.mapView, annotation: mapAnnotation){
                let marker = MKAnnotationView()
                marker.frame = CGRect(x:0,y:0,width:image.size.width ,height:image.size.height)
                marker.image =  image
                marker.annotation = annotation
                return marker
            }
            
            // Check if annotation is destinationAnnotation
            if (mapAnnotation.type == MarkerType.DESTINATION_MARKER) {
                let annotationView = self.mapMarkerForDestination()
                let label = UILabel.init(frame: CGRect(x:0,y:0,width:30.0,height:10.0))
                label.text = mapAnnotation.title
                annotationView.rightCalloutAccessoryView = label
                annotationView.canShowCallout = true
                annotationView.isEnabled = true
                return annotationView
                
            } else {
                let annotationView =  self.mapMarkerForHero(annotation:mapAnnotation)
                return annotationView
            }
        }
        
        if annotation is HTImageAnnotation {
            let imageAnnotation = annotation as! HTImageAnnotation
            return self.mapMarkerForView(markerView: imageAnnotation.markerView)
            
        } else {
            
            let marker = MKAnnotationView()
            marker.frame = CGRect(x:0,y:0,width:30.0,height:30.0)
            let bundle = Bundle(for: AppleMapsProvider.self)
            marker.image =  UIImage.init(named: "triangle", in: bundle, compatibleWith: nil)?.resizeImage(newWidth: 30.0)
            marker.annotation = annotation
            return marker
            //   return self.mapMarkerForDestination()
        }
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        self.mapCustomizationDelegate?.mapView?(mapView, regionDidChangeAnimated: animated)
    }
    
    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool){
        self.mapCustomizationDelegate?.mapView?(mapView, regionWillChangeAnimated: animated)
    }
}

extension UIImage {
    func resizeImage(newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
