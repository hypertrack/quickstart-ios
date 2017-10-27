//
//  HTUserPreferences.swift
//  HyperTrack
//
//  Created by Tapan Pandita on 23/02/17.
//  Copyright © 2017 HyperTrack, Inc. All rights reserved.
//

import Foundation
import CocoaLumberjack


class Settings {
    static let publishableKeyString = "HyperTrackPublishableKey"
    static let userIdString = "HyperTrackUserId"
    static let lookupIdString = "HyperTrackLookupId"
    static let trackingString = "HyperTrackIsTracking"
    static let mockTrackingString = "HyperTrackIsMockTracking"
    static let stopIdString = "HyperTrackStopId"
    static let eventSavedAtString = "HyperTrackLastEventSavedAt"
    
    static let activityString = "HyperTrackActivityString"
    static let activityRecordedAtString = "HyperTrackActivityRecordedAt"
    static let activityConfidenceString = "HyperTrackActivityConfidence"
    static let activityLocationString = "HyperTrackActivityLocationString"
    
    static let lastKnownLocationString = "HyperTrackLastKnownLocation"
    static let isAtStopString = "HyperTrackIsAtStop"
    static let stopStartTimeString = "HyperTrackStopStartTime"
    static let stopLocationString = "HyperTrackStopLocation"
    
    static let pushNotificationTokenString = "HyperTrackDeviceToken"
    static let registeredTokenString = "HyperTrackDeviceTokenRegistered"
    static let kUniqueInstallationID = "HyperTrackUniqueInstallationID"
    
    static let minimumDurationString = "HyperTrackMinimumDuration"
    static let minimumDisplacementString = "HyperTrackMinimumDisplacement"
    static let batchDurationString = "HyperTrackBatchDuration"
    
    static let mockCoordinatesString = "HyperTrackMockCoordinates"
    static let savedPlacesString = "HyperTrackSavedPlaces"
    static let savedUser = "HyperTrackSavedUser"
    
    static func getBundle() -> Bundle? {
        let bundleRoot = Bundle(for: HyperTrack.self)
        return Bundle(path: "\(bundleRoot.bundlePath)/HyperTrack.bundle")
    }
    
    
    static var sdkVersion:String {
        get {
            if let bundle = Settings.getBundle() {
                let dictionary = bundle.infoDictionary!
                let version = dictionary["CFBundleShortVersionString"] as! String
                return version
            }
            
            return ""
        }
    }
    
    static var uniqueInstallationID: String {
        get {
            var uniqueID = ""
            let hypertrackUserDefaults = HypertrackUserDefaults.standard
            var UUID = hypertrackUserDefaults.object(forKey: kUniqueInstallationID)
            if let UUID = UUID {
                uniqueID = UUID as! String
            } else {
                UUID = NSUUID().uuidString
                hypertrackUserDefaults.set(UUID, forKey: kUniqueInstallationID)
                hypertrackUserDefaults.synchronize()
            }
            return uniqueID
        }
    }
    
    static var isAtStop:Bool {
        get {
            return HypertrackUserDefaults.standard.bool(forKey: isAtStopString)
        }
        
        set {
            HypertrackUserDefaults.standard.set(newValue, forKey: isAtStopString)
            HypertrackUserDefaults.standard.synchronize()
        }
    }
    
    static var stopStartTime:Date? {
        get {
            let dateString = HypertrackUserDefaults.standard.string(forKey: stopStartTimeString)
            return dateString?.dateFromISO8601
        }
        
        set {
            HypertrackUserDefaults.standard.set(newValue?.iso8601, forKey: stopStartTimeString)
            HypertrackUserDefaults.standard.synchronize()
        }
    }
    
    static var stopLocation: HyperTrackLocation? {
        get {
            guard let htLocationString = HypertrackUserDefaults.standard.string(forKey: stopLocationString) else { return nil }
            return HyperTrackLocation.fromJson(text: htLocationString)
        }
        
        set {
            let htLocationString = newValue?.toJson()
            HypertrackUserDefaults.standard.set(htLocationString, forKey: stopLocationString)
            HypertrackUserDefaults.standard.synchronize()
        }
    }
    
    static func clearTrackingState() {}
    
    static func setPublishableKey(publishableKey:String) {
        HypertrackUserDefaults.standard.set(publishableKey, forKey: publishableKeyString)
        HypertrackUserDefaults.standard.synchronize()
    }
    
    static func getPublishableKey() -> String? {
        return HypertrackUserDefaults.standard.string(forKey: publishableKeyString)
    }
    
    static func setUserId(userId:String) {
        HypertrackUserDefaults.standard.set(userId, forKey: userIdString)
        HypertrackUserDefaults.standard.synchronize()
    }
    
    static func getUserId() -> String? {
        return HypertrackUserDefaults.standard.string(forKey: userIdString)
    }
    
    static func setDeviceToken(deviceToken:String) {
        HypertrackUserDefaults.standard.set(deviceToken, forKey: pushNotificationTokenString)
        HypertrackUserDefaults.standard.synchronize()
    }
    
    static func getDeviceToken() -> String? {
        return HypertrackUserDefaults.standard.string(forKey: pushNotificationTokenString)
    }
    
    static func setRegisteredToken(deviceToken:String) {
        HypertrackUserDefaults.standard.set(deviceToken, forKey: registeredTokenString)
        HypertrackUserDefaults.standard.synchronize()
    }
    
    static func getRegisteredToken() -> String? {
        return HypertrackUserDefaults.standard.string(forKey: registeredTokenString)
    }
    
    static func setLookupId(lookupId:String) {
        HypertrackUserDefaults.standard.set(lookupId, forKey: lookupIdString)
        HypertrackUserDefaults.standard.synchronize()
    }
    
    static func getLookupId() -> String? {
        return HypertrackUserDefaults.standard.string(forKey: lookupIdString)
    }
    
    static func setTracking(isTracking:Bool) {
        HypertrackUserDefaults.standard.set(isTracking, forKey: trackingString)
        HypertrackUserDefaults.standard.synchronize()
    }
    
    static func getTracking() -> Bool {
        return HypertrackUserDefaults.standard.bool(forKey: trackingString)
    }
    
    static func setMockTracking(isTracking:Bool) {
        HypertrackUserDefaults.standard.set(isTracking, forKey: mockTrackingString)
        HypertrackUserDefaults.standard.synchronize()
    }
    
    static func getMockTracking() -> Bool {
        return HypertrackUserDefaults.standard.bool(forKey: mockTrackingString)
    }
    
    static func setStopId(stopId:String) {
        HypertrackUserDefaults.standard.set(stopId, forKey: stopIdString)
        HypertrackUserDefaults.standard.synchronize()
    }
    
    static func getStopId() -> String? {
        return HypertrackUserDefaults.standard.string(forKey: stopIdString)
    }
    
    static func setStopLocation() {
        // TODO
    }
    
    static func getStopLocation() {
        // TODO
    }
    
    static func setLastEventSavedAt(eventSavedAt:Date) {
        let eventSavedAtISO = eventSavedAt.iso8601
        HypertrackUserDefaults.standard.set(eventSavedAtISO, forKey: eventSavedAtString)
        HypertrackUserDefaults.standard.synchronize()
    }
    
    static func getLastEventSavedAt() -> Date? {
        let eventSavedAtISO = HypertrackUserDefaults.standard.string(forKey: eventSavedAtString)
        return eventSavedAtISO?.dateFromISO8601
    }
    
    static func setActivity(activity: String) {
        HypertrackUserDefaults.standard.set(activity, forKey: activityString)
        HypertrackUserDefaults.standard.synchronize()
    }
    
    static func getActivity() -> String? {
        return HypertrackUserDefaults.standard.string(forKey: activityString)
    }
    
    static func setActivityLocation(location:HyperTrackLocation) {
        let locationJSON = location.toJson()
        HypertrackUserDefaults.standard.set(locationJSON, forKey: activityLocationString)
        HypertrackUserDefaults.standard.synchronize()
    }
    
    static func getActivityLocation() -> HyperTrackLocation? {
        guard let locationString = HypertrackUserDefaults.standard.string(forKey: lastKnownLocationString) else { return nil}
        let htLocation = HyperTrackLocation.fromJson(text: locationString)
        return htLocation
    }
    
    static func setActivityRecordedAt(activityRecordedAt: Date) {
        HypertrackUserDefaults.standard.set(activityRecordedAt.iso8601, forKey: activityRecordedAtString)
        HypertrackUserDefaults.standard.synchronize()
    }
    
    static func getActivityRecordedAt() -> Date? {
        return HypertrackUserDefaults.standard.string(forKey: activityRecordedAtString)?.dateFromISO8601
    }
    
    static func setActivityConfidence(confidence:Int) {
        HypertrackUserDefaults.standard.set(confidence, forKey: activityConfidenceString)
        HypertrackUserDefaults.standard.synchronize()
    }
    
    static func getActivityConfidence() -> Int? {
        return HypertrackUserDefaults.standard.integer(forKey: activityConfidenceString)
    }
    
    static func setLastKnownLocation(location:HyperTrackLocation) {
        let locationJSON = location.toJson()
        HypertrackUserDefaults.standard.set(locationJSON, forKey: lastKnownLocationString)
        HypertrackUserDefaults.standard.synchronize()
    }
    
    static func getLastKnownLocation() -> HyperTrackLocation? {
        guard let locationString = HypertrackUserDefaults.standard.string(forKey: lastKnownLocationString) else { return nil}
        let htLocation = HyperTrackLocation.fromJson(text: locationString)
        return htLocation
    }
    
    static func setControls(controls: HyperTrackSDKControls) {
        if let duration = controls.minimumDuration {
            HypertrackUserDefaults.standard.set(duration, forKey: minimumDurationString)
        }
        
        if let displacement = controls.minimumDisplacement {
            HypertrackUserDefaults.standard.set(displacement, forKey: minimumDisplacementString)
        }
        
        if let duration = controls.batchDuration {
            HypertrackUserDefaults.standard.set(duration, forKey: batchDurationString)
        }
        
        HypertrackUserDefaults.standard.synchronize()
    }
    
    static func getMinimumDuration() -> Double? {
        return HypertrackUserDefaults.standard.double(forKey: minimumDurationString)
    }
    
    static func getMinimumDisplacement() -> Double? {
        return HypertrackUserDefaults.standard.double(forKey: minimumDisplacementString)
    }
    
    static func getBatchDuration() -> Double? {
        return HypertrackUserDefaults.standard.double(forKey: batchDurationString)
    }
    
    static func clearSDKControls() {
        HypertrackUserDefaults.standard.removeObject(forKey: batchDurationString)
        HypertrackUserDefaults.standard.removeObject(forKey: minimumDurationString)
        HypertrackUserDefaults.standard.removeObject(forKey: minimumDisplacementString)
        HypertrackUserDefaults.standard.synchronize()
    }
    
    static func setMockCoordinates(coordinates: [TimedCoordinates]) {
        HypertrackUserDefaults.standard.set(timedCoordinatesToStringArray(coordinates: coordinates), forKey: mockCoordinatesString)
    }
    
    static func getMockCoordinates() -> [TimedCoordinates]? {
        if let object = HypertrackUserDefaults.standard.string(forKey: mockCoordinatesString) {
            return timedCoordinatesFromStringArray(coordinatesString: object)
        }
        return nil
    }
    
    
    
    static func addPlaceToSavedPlaces(place : HyperTrackPlace){
        var savedPlaces = getAllSavedPlaces()
        if(savedPlaces != nil){
            if(!HTGenericUtils.checkIfContains(places: savedPlaces!, inputPlace: place)){
                savedPlaces?.append(place)
            }else{
                var frequency = HypertrackUserDefaults.standard.integer(forKey: place.getIdentifier())
                frequency = frequency + 1
                HypertrackUserDefaults.standard.set(frequency, forKey: place.getIdentifier())
                HypertrackUserDefaults.standard.synchronize()
            }
        }else{
            savedPlaces = [place]
        }
        
        var savedPlacesDictArray = [[String:Any]]()
        for htPlace in savedPlaces! {
            let htPlaceDict = htPlace.toDict()
            savedPlacesDictArray.append(htPlaceDict)
            
        }
        
        var jsonDict = [String : Any]()
        jsonDict["results"] = savedPlacesDictArray
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
            HypertrackUserDefaults.standard.set(jsonData,forKey:savedPlacesString)
            HypertrackUserDefaults.standard.synchronize()
        } catch {
            DDLogError("Error in getting actions from json: " + error.localizedDescription)
        }
    }
    
    
    static func getAllSavedPlaces() -> [HyperTrackPlace]?{
        if let jsonData = HypertrackUserDefaults.standard.data(forKey: savedPlacesString){
            var htPlaces = HyperTrackPlace.multiPlacesFromJson(data: jsonData)
            htPlaces = htPlaces?.reversed()
            var placeToFrequencyMap = [HyperTrackPlace:Int]()
            for place in htPlaces!{
                let frequency = HypertrackUserDefaults.standard.integer(forKey: place.getIdentifier())
                placeToFrequencyMap[place] = frequency
            }
            
            let sortedKeys = Array(placeToFrequencyMap.keys).sorted(by: {placeToFrequencyMap[$1]! < placeToFrequencyMap[$0]!})
            return sortedKeys
        }
        return []
    }
    
    static func saveUser(user: HyperTrackUser){
        let jsonData = user.toJson()
        HypertrackUserDefaults.standard.set(jsonData,forKey:savedUser)
        HypertrackUserDefaults.standard.synchronize()
    }
    
    static func getUser() -> HyperTrackUser? {
        if let jsonData = HypertrackUserDefaults.standard.string(forKey: savedUser){
            return HyperTrackUser.fromJson(text: jsonData)
        }
        return nil
    }
}
