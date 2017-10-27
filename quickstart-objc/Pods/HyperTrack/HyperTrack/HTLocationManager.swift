//
//  HTLocationManager.swift
//  HyperTrack
//
//  Created by Tapan Pandita on 21/02/17.
//  Copyright © 2017 HyperTrack, Inc. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import CoreMotion
import CocoaLumberjack

protocol LocationEventsDelegate : class {
    func locationManager(_ manager: LocationManager, didEnterRegion region: CLRegion)
    func locationManager(_ manager: LocationManager, didExitRegion region: CLRegion)
    func locationManager(_ manager: LocationManager,didUpdateLocations locations: [CLLocation])
    func locationManager(_ manager: LocationManager,
                         didVisit visit: CLVisit)
    func locationManager(_ manager: LocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus)
}
enum LocationInRegion : String {
    case BELONGS_TO_REGION = "BELONGS_TO_REGION"
    case BELONGS_OUTSIDE_REGION =  "BELONGS_OUTSIDE_REGION"
    case CANNOT_DETERMINE = "CANNOT_DETERMINE"
}


class LocationManager: NSObject {
    // Constants
    let kFilterDistance: Double = 50
    let kHeartbeat: TimeInterval = 10
    
    // Managers
    let locationManager = CLLocationManager()
    var requestManager: RequestManager
    
    // State variables
    var isHeartbeatSetup: Bool = false
    var isFirstLocation: Bool = false
    let pedometer = CMPedometer()
    
    var locationPermissionCompletionHandler : ((_ isAuthorized: Bool) -> Void)? = nil
    weak var locationEventsDelegate : LocationEventsDelegate? = nil
    weak var eventDelegate : HTEventsDelegate?
    
    var isTracking:Bool {
        get {
            return Settings.getTracking()
        }
        
        set {
            Settings.setTracking(isTracking: newValue)
        }
    }
    
    //MARK: - Setup
    
    override init() {
        self.requestManager = RequestManager()
        super.init()
        locationManager.distanceFilter = kFilterDistance
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
        locationManager.activityType = CLActivityType.automotiveNavigation
        if #available(iOS 11.0, *) {
            //            locationManager.showsBackgroundLocationIndicator = false
        } else {
            // Fallback on earlier versions
        }
    }
    
    func allowBackgroundLocationUpdates() {
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    func requestLocation(){
        if #available(iOS 9.0, *) {
            self.locationManager.requestLocation()
        } else {
            // Fallback on earlier versions
        }
    }
    
    func updateLocationManager(filterDistance: CLLocationDistance, pausesLocationUpdatesAutomatically: Bool = false) {
        locationManager.distanceFilter = filterDistance
        locationManager.pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically
        if false == pausesLocationUpdatesAutomatically {
            startLocationTracking()
        }
    }
    
    func getLastKnownLocation() -> CLLocation? {
        return self.locationManager.location
    }
    
    func getLastKnownHeading() -> CLHeading?{
        return self.locationManager.heading
    }
    
    func setRegularLocationManager() {
        self.updateLocationManager(filterDistance: kFilterDistance)
    }
    
    func updateRequestTimer(batchDuration: Double) {
        self.requestManager.resetTimer(batchDuration: batchDuration)
    }
    
    func startLocationTracking() {
        self.locationManager.startMonitoringVisits()
        self.locationManager.startMonitoringSignificantLocationChanges()
        self.locationManager.startUpdatingLocation()
        NotificationCenter.default.addObserver(self, selector: #selector(onAppTerminate(_:)), name: Notification.Name.UIApplicationWillTerminate, object: nil)
        
    }
    
    func onAppTerminate(_ notification: Notification){
        self.locationManager.startUpdatingLocation()
    }
    
    func stopLocationTracking() {
        self.locationManager.stopMonitoringSignificantLocationChanges()
        self.locationManager.stopMonitoringVisits()
        self.locationManager.stopUpdatingLocation()
        NotificationCenter.default.removeObserver(self)
    }
    
    func startPassiveTrackingService() {
        self.startLocationTracking()
    }
    
    func canStartPassiveTracking() -> Bool {
        // TODO: Fix this
        return true
    }
    
    
    func stopPassiveTrackingService() {
        self.stopLocationTracking()
    }
    
    func setupHeartbeatMonitoring() {
        isHeartbeatSetup = true
        DispatchQueue.main.asyncAfter(deadline: .now() + kHeartbeat, execute: {
            self.isHeartbeatSetup = false
            // TODO: For iOS 8, Figure out Heartbeat monitoring to detect
            //       if the user is at a stop or not
            if #available(iOS 9.0, *) {
                self.locationManager.requestLocation()
            }
        })
    }
    
    // Request location permissions
    func requestWhenInUseAuthorization() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func requestAlwaysAuthorization() {
        self.locationManager.requestAlwaysAuthorization()
    }
    
    func requestAlwaysAuthorization(completionHandler: @escaping (_ isAuthorized: Bool) -> Void) {
        locationPermissionCompletionHandler  = completionHandler
        self.locationManager.requestAlwaysAuthorization()
    }
    
    func doesLocationBelongToRegion(stopLocation:HyperTrackLocation,radius:Int,identifier : String) -> LocationInRegion{
        let clLocation = stopLocation.clLocation
        let monitoringRegion = CLCircularRegion(center:clLocation.coordinate, radius: CLLocationDistance(radius), identifier:identifier)
        if let location = self.getLastKnownLocation(){
            if (location.timestamp.timeIntervalSince1970 > (Date().timeIntervalSince1970 - 120)){
                if location.horizontalAccuracy < 100 {
                    if(monitoringRegion.contains(location.coordinate)){
                        DDLogInfo("user coordinate is in monitoringRegion" + location.description)
                        return LocationInRegion.BELONGS_TO_REGION
                    }else{
                        return LocationInRegion.BELONGS_OUTSIDE_REGION
                    }
                }else{
                    DDLogInfo("user coordinate is not accurate so not considering for geofenceing")
                }
            }else{
                DDLogInfo("user coordinate is very old so not using for geofencing requesting location")
            }
        }else{
            DDLogInfo("user coordinate does not belong to monitoringRegion" + stopLocation.description)
        }
        self.requestLocation()
        
        return LocationInRegion.CANNOT_DETERMINE
    }
    
    func startMonitoringForEntryAtPlace(place: HyperTrackPlace, radius:CLLocationDistance, identifier:String){
        
        if let placeLocation = place.location{
            let circularRegion = CLCircularRegion(center:placeLocation.toCoordinate2d(), radius: CLLocationDistance(radius), identifier:identifier)
            
            if let location = self.getLastKnownLocation(){
                if (location.timestamp.timeIntervalSince1970 > (Date().timeIntervalSince1970 - 120)){
                    if location.horizontalAccuracy < 100 {
                        if(circularRegion.contains(location.coordinate)){
                            if let eventDelegate = self.eventDelegate{
                                eventDelegate.didEnterMonitoredRegion?(region: circularRegion)
                            }
                            
                            return
                            
                        }
                    }
                }
            }
            
            var clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
            if clampedRadius < 100 {
                clampedRadius = 100
            }
            
            DDLogInfo("starting monitoring for region having identifier : " + identifier  + " radius : " + clampedRadius.description)
            let monitoringRegion = CLCircularRegion(center: (placeLocation.toCoordinate2d()), radius: clampedRadius, identifier: identifier)
            DDLogInfo("startMonitorForPlace having identifier: \(identifier ) ")
            monitoringRegion.notifyOnEntry = true
            monitoringRegion.notifyOnExit = false
            
            locationManager.startMonitoring(for: monitoringRegion)
            self.requestLocation()
            
        }
        
        
        
    }
    
    func startMonitoringExitForLocation(location : CLLocation , identifier : String? = nil ){
        
        DDLogInfo("startMonitoringExitForLocation having identifier: \(identifier ?? "") ")
        
        var tag = identifier
        if (identifier == nil){
            tag = getLocationIdentifier(location: location)
        }
        
        let monitoringRegion = CLCircularRegion(center:location.coordinate, radius: 50, identifier: tag!)
        monitoringRegion.notifyOnExit = true
        monitoringRegion.notifyOnEntry = false
        locationManager.startMonitoring(for: monitoringRegion)
        self.requestLocation()
    }
    
    
    func getLocationIdentifier(location :CLLocation) -> String{
        return location.coordinate.latitude.description + location.coordinate.longitude.description
    }
    
    
}

//MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    
    func filterLocationsWithDistance(locations:[CLLocation],
                                     distanceFilter:CLLocationDistance) -> [CLLocation] {
        var filteredLocations:[CLLocation] = []
        var index = 0
        var nextIndex = 0
        
        filteredLocations.append(locations[index])
        
        while nextIndex < locations.count - 1 {
            nextIndex = nextIndex + 1
            let distance = locations[index].distance(from: locations[nextIndex])
            
            if distance > distanceFilter {
                filteredLocations.append(locations[nextIndex])
                index = nextIndex
            } else {
                continue
            }
        }
        
        return filteredLocations
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        if let locationEventDelegate = self.locationEventsDelegate{
            locationEventDelegate.locationManager(self, didChangeAuthorization: status)
        }
        
        DDLogInfo("Did change authorization: \(status)")
        let nc = NotificationCenter.default
        nc.post(name:Notification.Name(rawValue:HTConstants.HTLocationPermissionChangeNotification),
                object: nil,
                userInfo: nil)
        if(locationPermissionCompletionHandler != nil){
            if(status == .authorizedAlways){
                locationPermissionCompletionHandler!(true)
                locationPermissionCompletionHandler = nil
            }else if (status != .notDetermined){
                locationPermissionCompletionHandler!(false)
                locationPermissionCompletionHandler = nil
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didVisit visit: CLVisit) {
        
        if !Settings.getTracking() {
            // This method can be called after the location manager is stopped
            // Hence, to not save those locations, the method checks for a live
            // tracking session
            return
        }
        
        if let locationEventDelegate = self.locationEventsDelegate{
            locationEventDelegate.locationManager(self, didVisit: visit)
        }
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name(rawValue:HTConstants.HTLocationChangeNotification),
                object: nil,
                userInfo: nil)
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        DDLogInfo("Did pause location updates")
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        DDLogInfo("Did resume location updates")
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        
        if !Settings.getTracking() {
            // This method can be called after the location manager is stopped
            // Hence, to not save those locations, the method checks for a live
            // tracking session
            return
        }
        if let clLocation = locations.last {
            if (clLocation.timestamp.timeIntervalSince1970 > (Date().timeIntervalSince1970 - 600)){
                if clLocation.horizontalAccuracy <= 100{
                    for monitoringRegion in locationManager.monitoredRegions{
                        if let circularRegion = monitoringRegion as? CLCircularRegion{
                            if(circularRegion.contains(clLocation.coordinate)){
                                if circularRegion.notifyOnEntry {
                                    DDLogInfo("entered region due to a location update , identifier : " + monitoringRegion.identifier)
                                    if let locationEventDelegate = self.locationEventsDelegate{
                                        locationEventDelegate.locationManager(self, didEnterRegion: circularRegion)
                                    }
                                    
                                    if let eventDelegate = self.eventDelegate{
                                        eventDelegate.didEnterMonitoredRegion?(region: circularRegion)
                                    }
                                    
                                    locationManager.stopMonitoring(for: monitoringRegion)
                                }
                            }else if circularRegion.notifyOnExit{
                                DDLogInfo("exited region due to a location update , identifier : " + monitoringRegion.identifier)
                                
                                if let locationEventDelegate = self.locationEventsDelegate{
                                    locationEventDelegate.locationManager(self, didExitRegion: monitoringRegion)
                                }
                                
                                locationManager.stopMonitoring(for: monitoringRegion)
                                
                            }
                            
                        }
                    }
                }
            }
        }
        
        if let locationEventDelegate = self.locationEventsDelegate{
            locationEventDelegate.locationManager(self, didUpdateLocations: locations)
        }
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name(rawValue:HTConstants.HTLocationChangeNotification),
                object: nil,
                userInfo: nil)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        DDLogError("Did fail with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading){
        if newHeading.headingAccuracy < 0 { return }
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name(rawValue:HTConstants.HTLocationHeadingChangeNotification),
                object: nil,
                userInfo: ["heading":newHeading])
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion){
        DDLogInfo(" location manager didEnterRegion " + region.identifier)
        if let locationEventDelegate = self.locationEventsDelegate{
            locationEventDelegate.locationManager(self, didEnterRegion: region)
        }
        
        if let eventDelegate = self.eventDelegate{
            eventDelegate.didEnterMonitoredRegion?(region: region)
        }
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name(rawValue:HTConstants.HTMonitoredRegionEntered),
                object: nil,
                userInfo: ["region":region])
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion){
        
        if let locationEventDelegate = self.locationEventsDelegate{
            locationEventDelegate.locationManager(self, didExitRegion: region)
        }
        
        DDLogInfo("First location didExitRegion")
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name(rawValue:HTConstants.HTMonitoredRegionExited),
                object: nil,
                userInfo: ["region":region])
    }
    
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error){
        if (region != nil){
            DDLogInfo(" location manager monitoringDidFailFor " + (region?.identifier)!)
        }
    }
}

