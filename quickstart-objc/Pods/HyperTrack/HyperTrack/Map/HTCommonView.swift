//
//  HTCommonView.swift
//  Pods
//
//  Created by Ravi Jain on 7/24/17.
//
//

import UIKit
import MapKit

class HTCommonView: UIView {

    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var reFocusButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var destinationView: UIView!

    var lastPosition: CLLocationCoordinate2D?
    var currentHeading: CLLocationDegrees = 0.0

    weak var interactionViewDelegate: HTViewInteractionInternalDelegate?
    weak var customizationDelegate: HTViewCustomizationInternalDelegate?

    var isDestinationMarkerShown: Bool = true
    var isDestinationEditable : Bool = false
    var isTrailingPolylineEndabled : Bool = false
    
    var mapProvider: MapProviderProtocol?
    var isCardExpanded = false
    var mapViewDataSource: HTMapViewDataSource?
    var useCase = HTConstants.UseCases.TYPE_SINGLE_USER_SINGLE_ACTION

    var lastPlottedTimeMap = [String:Date]()
    var showConfirmLocationButton = false
    var currentAction : HyperTrackAction? = nil
    var isAnimating = false
    
    func zoomMapTo(visibleRegion: MKCoordinateRegion, animated: Bool){
        
    }

    
    func clearView() {
    
    
    }
    
    func reloadCarousel(){
        

    }
    
    func updateInfoView(statusInfo : HTStatusCardInfo){

    }
    
    func updateAddressView(isAddressViewShown: Bool, destinationAddress: String? ,action:HyperTrackAction) {

    }
    
    func updateReFocusButton(isRefocusButtonShown: Bool) {
    }
    
    func updateBackButton(isBackButtonShown: Bool) {

    }
    
    func updateViewFocus(isInfoViewCardExpanded: Bool, isDestinationViewVisible: Bool){
        
    }
    
    func clearMap(){
        self.mapProvider?.clearMap()
    }
    
    func resetView(){
        
    }
    
    func updatePolyline(polyline: String){
       
    }
    
    func updatePolyline(polyline: String,startMarkerImage:UIImage?){

    }
    
    func updateDestinationMarker(showDestination: Bool, destinationAnnotation: HTMapAnnotation?,place : HyperTrackPlace?){
        
        
    }
    
    func updateHeroMarker(userId: String, actionID: String, heroAnnotation: HTMapAnnotation, disableHeroMarkerRotation: Bool){
        
    }
    
    func reFocusMap(isInfoViewCardExpanded: Bool, isDestinationViewVisible: Bool){
        
    }
   
    func updatePhoneButton(isPhoneShown: Bool) {
               
    }
    
    func confirmLocation()-> HyperTrackPlace?{
        return nil
    }
    
     func processTimeAwarePolyline(userId : String, timeAwarePolyline:String?,disableHeroMarkerRotation:Bool){
        // Decode updated TimeAwarePolyine
        var deocodedLocations: [TimedCoordinates] = []
        if (timeAwarePolyline != nil) {
            if let timedCoordinates = timedCoordinatesFrom(polyline: timeAwarePolyline!) {
                deocodedLocations = timedCoordinates
            }
        }
        
        if (self.lastPlottedTimeMap[userId] == nil){
            self.lastPlottedTimeMap[userId]  = Date.distantPast
        }
        
        let lastPlottedTime = self.lastPlottedTimeMap[userId]
        // Get new locations from decodedLocations
        let newLocations = deocodedLocations.filter{$0.timeStamp > lastPlottedTime!}
        var coordinates = newLocations.map{$0.location}
        
        if coordinates.count > 50 {
            coordinates = Array(coordinates.suffix(from: coordinates.count - 50))
        }
        
        self.setUpHeroMarker(userId: userId, coordinates: coordinates,disableHeroMarkerRotation:disableHeroMarkerRotation)
        
        // Update lastPlottedTime to reflect latest animated point
        if let lastPoint = newLocations.last {
            self.lastPlottedTimeMap[userId]  = lastPoint.timeStamp
        }
    }
    
    
    func setUpHeroMarker(userId: String, coordinates: [CLLocationCoordinate2D],disableHeroMarkerRotation:Bool) {
        
        let user = HTConsumerClient.sharedInstance.getUser(userId: userId)
        if let  action = user?.actions?.last as? HyperTrackAction {
            
            // Check if action has been completed for order tracking use-case
            if (self.useCase == HTConstants.UseCases.TYPE_SINGLE_USER_SINGLE_ACTION), (action.display != nil), (action.display?.showSummary == true) {
                return
            }
            
            var heroAnnotation = self.mapViewDataSource?.getMapViewModel(userId: userId)?.heroMarker
            if (heroAnnotation == nil) {
                heroAnnotation = HTMapAnnotation()
                heroAnnotation?.action = action
                heroAnnotation!.type = MarkerType.HERO_MARKER
                heroAnnotation!.disableRotation = disableHeroMarkerRotation
                if let coordinate = coordinates.first as CLLocationCoordinate2D? {
                    heroAnnotation!.coordinate = coordinate
                }
                
                self.mapProvider?.addMarker(annotation: heroAnnotation!)
            }
            
            heroAnnotation?.action = action
            heroAnnotation!.subtitle = getSubtitleDisplayText(action: action)?.capitalized
            self.mapViewDataSource?.setHeroMarker(userId: userId,
                                                  annotation: heroAnnotation)
            
            self.updateTrailingPolylineForUser(userId: userId)
            // TODO - Update eta on hero marker for LLS use-case
            
            if coordinates.count > 0  && !isAnimating {
                let unitAnimationDuration = 5.0 / Double(coordinates.count)
                isAnimating = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.animateMarker(annotation: heroAnnotation!, locations: coordinates, currentIndex: 0, duration: unitAnimationDuration, disableHeroMarkerRotation: heroAnnotation!.disableRotation)
                }
            }
        }
        
    }
    
    func animateMarker(annotation: HTMapAnnotation,
                       locations: [CLLocationCoordinate2D],
                       currentIndex: Int, duration: TimeInterval,
                       disableHeroMarkerRotation: Bool) {
        
        if let coordinates = locations as [CLLocationCoordinate2D]?, coordinates.count >= 1 {
            let currentLocation = coordinates[currentIndex]
            
            UIView.animate(withDuration: duration, animations: {
                self.mapProvider?.updatePositionForMarker(annotation: annotation, coordinate: currentLocation)
            }, completion: { (finished) in
               
                if(currentIndex < coordinates.count - 1) {
                    
                    if let lastPosition = self.lastPosition {
                        self.currentHeading = HTMapUtils.headingFrom(lastPosition, next: currentLocation)
                    }
                    
                    self.lastPosition = currentLocation
                    if (disableHeroMarkerRotation == false) {
                        if coordinates.count > 1 {
                            let adjustedHeading = (self.mapProvider?.getCameraHeading())! + self.currentHeading
                            CATransaction.begin()
                            CATransaction.setAnimationDuration(duration/2.0);
                            self.mapProvider?.updateBearingForMarker(annotation: annotation, bearing: adjustedHeading)
                            CATransaction.commit()
                        }else {
                            if (annotation.action?.user) != nil{
                                if let userId = annotation.action?.user?.id{
                                    if let user = HTConsumerClient.sharedInstance.getUser(userId: userId){
                                           if let adjustedHeading = user.expandedUser?.lastLocation?.bearing{
                                            self.mapProvider?.updateBearingForMarker(annotation: annotation, bearing: adjustedHeading)

                                        }

                                    }

                                }

                            }
                            
                        }
                    }
                    
                    self.animateMarker(annotation: annotation,
                                       locations: coordinates,
                                       currentIndex: currentIndex + 1,
                                       duration: duration, disableHeroMarkerRotation: disableHeroMarkerRotation)
                }else{
                    self.isAnimating = false
                }
            })
        }
    }
    
    
    
    func updateTrailingPolylineForUser(userId:String){

        if let user = HTConsumerClient.sharedInstance.getUser(userId: userId){
            
            if self.isTrailingPolylineEndabled{
                if let polyline = user.expandedUser?.encodedPolyline {
                    self.mapProvider?.removePolylineWithIdentifier(identifier: (user.expandedUser?.id)!)
                    self.mapProvider?.addPolyline(encodedPolyline: polyline, identifier: (user.expandedUser?.id)!)
                }
            }
            else{
                self.mapProvider?.removePolylineWithIdentifier(identifier: (user.expandedUser?.id)!)
            }
        }
    }
    
    
    func getSubtitleDisplayText(action:HyperTrackAction) -> String?{
        
        var subtitle = ""
        
        if let action = action as HyperTrackAction?, let actionStatus = action.status {
            if actionStatus == "completed" {
                subtitle = "completed"
                return subtitle
            }else if (actionStatus == "suspended"){
                subtitle = "suspended"
                return subtitle
            }
        }
        
        if let actionDisplay = action.display {
            if let duration = actionDisplay.durationRemaining {
                let timeRemaining = duration
                let etaMinutes = Double(timeRemaining / 60)
                let eta:String = String(format:"%.0f", etaMinutes)
                subtitle = eta.description + " min"
                return subtitle
            }
            
            if let statusText = actionDisplay.statusText {
                return statusText
            }
        }
        return subtitle
    }
    

    func resetDestinationMarker(_ actionIdToBeUpdated: String?, showExpectedPlacelocation:Bool) {
        var actionId = actionIdToBeUpdated
        if (actionId == nil) {
            actionId = HTConsumerClient.sharedInstance.getActionIds().last
        }
        
        let action: HyperTrackAction = HTConsumerClient.sharedInstance.getAction(actionId: actionId!)!
        self.currentAction = action
        // Check if action has been completed for order tracking use-case
        if (self.useCase == HTConstants.UseCases.TYPE_SINGLE_USER_SINGLE_ACTION), (action.display != nil), (action.display?.showSummary == true) {
            return
        }
        
        if let expectedPlaceCoordinates = HTConsumerClient.sharedInstance.getExpectedPlaceLocation(actionId: action.id!) {
            // Handle destinationMarker customization
            self.isDestinationMarkerShown = showExpectedPlacelocation
            
            // Get annotation for destinationMarker
            let destinationAnnotation = HTMapAnnotation()
            destinationAnnotation.coordinate = expectedPlaceCoordinates
            destinationAnnotation.title = HTGenericUtils.getPlaceName(place: action.expectedPlace)
            destinationAnnotation.type = MarkerType.DESTINATION_MARKER
            destinationAnnotation.action = action
            
            self.updateDestinationMarker(showDestination: self.isDestinationMarkerShown, destinationAnnotation: destinationAnnotation, place: action.expectedPlace)
            
        } else{
            self.updateDestinationMarker(showDestination: false, destinationAnnotation: nil, place: nil)
        }
    }

}
