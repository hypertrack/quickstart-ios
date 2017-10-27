 //
 //  HTRequestManager.swift
 //  HyperTrack
 //
 //  Created by Tapan Pandita on 24/02/17.
 //  Copyright © 2017 HyperTrack, Inc. All rights reserved.
 //
 
 import Foundation
 import Alamofire
 import MapKit
 import Gzip
 import CocoaLumberjack
 
 struct JSONArrayEncoding: ParameterEncoding {
    /// Returns a `JSONArrayEncoding` instance with default writing options.
    public static var `default`: JSONArrayEncoding { return JSONArrayEncoding() }
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = urlRequest.urlRequest
        let array = parameters?["array"]
        
        let data = try JSONSerialization.data(withJSONObject: array as! [Any], options: [])
        
        if urlRequest?.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        urlRequest?.httpBody = data
        
        return urlRequest!
    }
 }
 
 struct GZippedJSONEncoding: ParameterEncoding {
    public static var `default`: GZippedJSONEncoding { return GZippedJSONEncoding() }
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var encodedRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        encodedRequest.setValue("gzip", forHTTPHeaderField: "Content-Encoding")
        encodedRequest.httpBody = try encodedRequest.httpBody?.gzipped()
        return encodedRequest
    }
 }
 
 struct GZippedJSONArrayEncoding: ParameterEncoding {
    public static var `default`: GZippedJSONArrayEncoding { return GZippedJSONArrayEncoding() }
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var encodedRequest = try JSONArrayEncoding.default.encode(urlRequest, with: parameters)
        encodedRequest.setValue("gzip", forHTTPHeaderField: "Content-Encoding")
        encodedRequest.httpBody = try encodedRequest.httpBody?.gzipped()
        return encodedRequest
    }
 }
 
 class HTTPRequest {
    var arrayParams:[Any]?
    var jsonParams:[String:Any]?
    var urlParams:[String:String]?
    let method:HTTPMethod
    var headers:[String:String]
    let urlPath:String
    let baseURL:String = "https://api.hypertrack.com/api/v1/"
    let sdkVersion:String = Settings.sdkVersion
    let osVersion:String = UIDevice.current.systemVersion
    let appId:String = Bundle.main.bundleIdentifier!
    let deviceId:String = Settings.uniqueInstallationID
    
    init(method:HTTPMethod, urlPath:String, jsonParams:[String:Any]) {
        self.jsonParams = jsonParams
        self.method = method
        self.urlPath = urlPath
        
        let publishableKey = Settings.getPublishableKey()! as String
        self.headers = [
            "Authorization": "token \(publishableKey)",
            "Content-Type": "application/json",
            "User-Agent": "HyperTrack iOS SDK/\(sdkVersion) (\(osVersion))",
            "App-ID": "\(appId )",
            "Device-ID": "\(deviceId)",
            "Timezone": TimeZone.current.identifier
        ]
    }
    
    init(method:HTTPMethod, urlPath:String, arrayParams:[Any]) {
        self.arrayParams = arrayParams
        self.method = method
        self.urlPath = urlPath
        
        let publishableKey = Settings.getPublishableKey()! as String
        self.headers = [
            "Authorization": "token \(publishableKey)",
            "Content-Type": "application/json",
            "User-Agent": "HyperTrack iOS SDK/\(sdkVersion) (\(osVersion))",
            "App-ID": "\(appId )",
            "Device-ID": "\(Settings.uniqueInstallationID)",
            "Timezone": TimeZone.current.identifier
        ]
    }
    
    init(method:HTTPMethod, urlPath:String, urlParams:[String:String]) {
        self.urlParams = urlParams
        self.method = method
        self.urlPath = urlPath
        
        let publishableKey = Settings.getPublishableKey()! as String
        self.headers = [
            "Authorization": "token \(publishableKey)",
            "Content-Type": "application/json",
            "User-Agent": "HyperTrack iOS SDK/\(sdkVersion) (\(osVersion))",
            "App-ID": "\(appId )",
            "Device-ID": "\(Settings.uniqueInstallationID)",
            "Timezone": TimeZone.current.identifier
        ]
    }
    
    func buildURL() -> String {
        return self.baseURL + self.urlPath
    }
    
    func makeRequest(completionHandler: @escaping (DataResponse<Any>) -> Void) {
        if let array = self.arrayParams {
            Alamofire.request(
                self.buildURL(),
                method: self.method,
                parameters:["array":array],
                encoding:GZippedJSONArrayEncoding.default,
                headers:self.headers
                ).validate().responseJSON(completionHandler:completionHandler)
        } else if let json = self.jsonParams {
            Alamofire.request(
                self.buildURL(),
                method:self.method,
                parameters:json,
                encoding:GZippedJSONEncoding
                    .default,
                headers:self.headers
                ).validate().responseJSON(completionHandler:completionHandler)
        }
    }
 }
 
 class RequestManager {
    var timer: Timer
    let serialQueue: DispatchQueue
    var isPostingEvents = false
    
    init() {
        self.timer = Timer()
        self.serialQueue = DispatchQueue(label: "requestsQueue")
    }
    
    func startTimer() {
        let (requestBatchInterval, _) = HyperTrackSDKControls.getControls()
        self.resetTimer(batchDuration: requestBatchInterval)
    }
    
    func resetTimer(batchDuration: Double) {
        if self.timer.isValid {
            self.stopTimer()
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: batchDuration, target: self, selector: #selector(self.postEvents) , userInfo: Date(), repeats: true)
    }
    
    func stopTimer() {
        self.timer.invalidate()
    }
    
    func stopIfNotTracking() {
        if !Settings.getTracking() {
            self.stopTimer()
        }
    }
    
    func fire() {
        self.timer.fire()
    }
    
    func getPublishableKey() -> (String?,HyperTrackError?){
        if let publishableKey = Settings.getPublishableKey(){
            return (publishableKey,nil)
        }
        
        let error = HyperTrackError(HyperTrackErrorType.publishableKeyError)
        return (nil,error)
    }
    
    
    @objc func postEvents(flush:Bool = true) {
        // Post device logs to server
        if !isPostingEvents{
            self.isPostingEvents = true
            DDLogInfo("posting events")
            guard let userId = Settings.getUserId() else { return }
            guard let events = EventsDatabaseManager.sharedInstance.getEvents(userId: userId) else {
                DDLogDebug("no events to post")
                self.isPostingEvents = false
                return }
            
            var eventsDict:[[String:Any]] = []
            var eventIds:[Int64] = []
            
            for (id, event) in events {
                eventsDict.append(event.toDict())
                eventIds.append(id)
            }
            
            if eventsDict.isEmpty {
                self.isPostingEvents = false
                DDLogDebug("no events to post")
                self.stopIfNotTracking()
                return
            }
            
            if let error = self.getPublishableKey().1 {
                self.isPostingEvents = false
                DDLogError("post events fails as publishable Key is not set : " + error.description)
                return
            }
            
            HTTPRequest(method:.post, urlPath:"sdk_events/bulk/", arrayParams:eventsDict).makeRequest { response in
                self.isPostingEvents = false
                
                switch response.result {
                case .success:
                    EventsDatabaseManager.sharedInstance.bulkDelete(ids: eventIds)
                    DDLogInfo("Events pushed successfully: \(String(describing: eventIds.count))")
                    
                    // Flush data
                    if flush {
                        self.postEvents(flush:true)
                    }
                case .failure(let error):
                    DDLogError("Error while postEvents: \(String(describing: error))  with response: \(String(describing: response))")
                    
                    // Delete Events for 4xx errors to prevent unnecessary retries
                    if ((response.response != nil) && (response.response?.statusCode)! >= 400 && (response.response?.statusCode)! < 500 ) {
                        EventsDatabaseManager.sharedInstance.bulkDelete(ids: eventIds)
                    }else {
                        if flush {
                            DDLogInfo("retrying the payload as post events failed")
                            self.postEvents(flush:true)
                        }
                    }
                }
            }
        }else{
            DDLogDebug("not sending events as we are already sending a payload")
        }
    }
    
    func getAction(_ actionId: String, completionHandler: @escaping (_ action: HyperTrackAction?, _ error: HyperTrackError?) -> Void) {
        let urlPath = "actions/\(actionId)/detailed/"
        
        if let error = self.getPublishableKey().1 {
            DDLogError("getAction fails as publishable Key is not set")
            completionHandler(nil, error)
            return
        }
        
        HTTPRequest(method:.get, urlPath:urlPath, jsonParams:[:]).makeRequest { response in
            switch response.result {
            case .success:
                let action = HyperTrackAction.fromJson(data: response.data)
                completionHandler(action, nil)
            case .failure:
                if response.response?.statusCode == 403 {
                    // handle auth error
                    let htError = HyperTrackError(HyperTrackErrorType.authorizationFailedError)
                    DDLogError("Error while getAction: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
                else {
                    let htError = HyperTrackError(HyperTrackErrorType.serverError)
                    DDLogError("Error while getAction: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
            }
        }
    }
    
    func getActionFromShortCode(_ shortCode:String ,completionHandler: @escaping (_ actions: [HyperTrackAction]?, _ error: HyperTrackError?) -> Void)  {
        
        let urlPath = "actions/?short_code=\(shortCode)"
        if let error = self.getPublishableKey().1 {
            DDLogError("getActionFromShortCode fails as publishable Key is not set")
            completionHandler(nil, error)
            return
        }
        
        HTTPRequest(method:.get, urlPath:urlPath, jsonParams:[:]).makeRequest { response in
            switch response.result {
            case .success:
                let actions = HyperTrackAction.multiActionsFromJSONData(data: response.data)
                completionHandler(actions, nil)
            case .failure:
                if response.response?.statusCode == 403 {
                    // handle auth error
                    let htError = HyperTrackError(HyperTrackErrorType.authorizationFailedError)
                    DDLogError("Error while getActionFromShortCode: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
                else {
                    let htError = HyperTrackError(HyperTrackErrorType.serverError)
                    DDLogError("Error while getActionFromShortCode: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
            }
        }
    }
    
    func fetchDetailsForActions(_ actionIDs: [String], completionHandler: @escaping (_ users: [HTTrackedUser]?, _ error: HyperTrackError?) -> Void) {
        
        let actionsToTrack = actionIDs.joined(separator: ",")
        let urlPath = "actions/track/?id=\(actionsToTrack)"
        
        if let error = self.getPublishableKey().1 {
            DDLogError("fetchDetailsForActions fails as publishable Key is not set")
            completionHandler(nil, error)
            return
        }
        
        HTTPRequest(method:.get, urlPath:urlPath, jsonParams:[:]).makeRequest { response in
            switch response.result {
            case .success:
                let users = HTTrackedUser.usersFromJSONData(data: response.data)
                completionHandler(users, nil)
                
            case .failure:
                if response.response?.statusCode == 403 {
                    // handle auth error
                    let htError = HyperTrackError(HyperTrackErrorType.authorizationFailedError)
                    DDLogError("Error while fetchDetailsForActions: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
                else {
                    
                    let htError = HyperTrackError(HyperTrackErrorType.serverError)
                    DDLogError("Error while fetchDetailsForActions: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
            }
        }
    }
    
    func fetchDetailsForActionsByShortCodes(_ shortCodes: [String],
                                            completionHandler: @escaping (_ users: [HTTrackedUser]?, _ error: HyperTrackError?) -> Void) {
        
        let actionsToTrack = shortCodes.joined(separator: ",")
        let urlPath = "actions/track/?short_code=\(actionsToTrack)"
        
        if let error = self.getPublishableKey().1 {
            DDLogError("fetchDetailsForActionsByShortCodes fails as publishable Key is not set")
            completionHandler(nil, error)
            return
        }
        
        HTTPRequest(method:.get, urlPath:urlPath, jsonParams:[:]).makeRequest { response in
            switch response.result {
            case .success:
                let users =  HTTrackedUser.usersFromJSONData(data: response.data)
                completionHandler(users, nil)
                
            case .failure:
                if response.response?.statusCode == 403 {
                    // handle auth error
                    let htError = HyperTrackError(HyperTrackErrorType.authorizationFailedError)
                    DDLogError("Error while fetchDetailsForActionsByShortCodes: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
                else {
                    
                    let htError = HyperTrackError(HyperTrackErrorType.serverError)
                    DDLogError("Error while fetchDetailsForActionsByShortCodes: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
            }
        }
    }
    
    func fetchDetailsForActionsByLookUpId(_ lookUpId: String, completionHandler: @escaping (_ users: [HTTrackedUser]?, _ error: HyperTrackError?) -> Void) {
        
        let urlPath = "actions/track/?lookup_id=\(lookUpId)"
        
        if let error = self.getPublishableKey().1 {
            DDLogError("fetchDetailsForActionsByLookUpId fails as publishable Key is not set")
            completionHandler(nil, error)
            return
        }
        
        HTTPRequest(method:.get, urlPath:urlPath, jsonParams:[:]).makeRequest { response in
            switch response.result {
            case .success:
                let users =  HTTrackedUser.usersFromJSONData(data: response.data)
                completionHandler(users, nil)
                
            case .failure:
                if response.response?.statusCode == 403 {
                    // handle auth error
                    let htError = HyperTrackError(HyperTrackErrorType.authorizationFailedError)
                    DDLogError("Error while fetchDetailsForActionsByLookUpId: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
                else {
                    
                    let htError = HyperTrackError(HyperTrackErrorType.serverError)
                    DDLogError("Error while fetchDetailsForActionsByLookUpId: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
            }
        }
    }
    
    func fetchDetailsForActionsByCollectionId(_ collectionId: String, completionHandler: @escaping (_ users: [HTTrackedUser]?, _ error: HyperTrackError?) -> Void) {
        
        let urlPath = "actions/track/?collection_id=\(collectionId)"
        
        if let error = self.getPublishableKey().1 {
            DDLogError("fetchDetailsForActionsByCollectionId fails as publishable Key is not set")
            completionHandler(nil, error)
            return
        }
        
        HTTPRequest(method:.get, urlPath:urlPath, jsonParams:[:]).makeRequest { response in
            switch response.result {
            case .success:
                let users =  HTTrackedUser.usersFromJSONData(data: response.data)
                completionHandler(users, nil)
                
            case .failure:
                if response.response?.statusCode == 403 {
                    // handle auth error
                    let htError = HyperTrackError(HyperTrackErrorType.authorizationFailedError)
                    DDLogError("Error while fetchDetailsForActionsByCollectionId: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
                else {
                    let htError = HyperTrackError(HyperTrackErrorType.serverError)
                    DDLogError("Error while fetchDetailsForActionsByCollectionId: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
            }
        }
    }
    
    
    func fetchUserDetailsForActions(_ actionIDs: [String], completionHandler: @escaping (_ actions: [HTTrackedUser]?, _ error: HyperTrackError?) -> Void) {
        
        if let error = self.getPublishableKey().1 {
            DDLogError("fetchUserDetailsForActions fails as publishable Key is not set")
            completionHandler(nil, error)
            return
        }
        
        let actionsToTrack = actionIDs.joined(separator: ",")
        let urlPath = "actions/track/?id=\(actionsToTrack)"
        HTTPRequest(method:.get, urlPath:urlPath, jsonParams:[:]).makeRequest { response in
            switch response.result {
            case .success:
                let users =  HTTrackedUser.usersFromJSONData(data: response.data)                
                completionHandler(users, nil)
            case .failure:
                if response.response?.statusCode == 403 {
                    // handle auth error
                    let htError = HyperTrackError(HyperTrackErrorType.authorizationFailedError)
                    DDLogError("Error while fetchUserDetailsForActions: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
                else {
                    
                    let htError = HyperTrackError(HyperTrackErrorType.serverError)
                    DDLogError("Error while fetchUserDetailsForActions: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
            }
        }
    }
    
    func createAndAssignAction(_ action:[String:Any], completionHandler: @escaping (_ action: HyperTrackAction?, _ error: HyperTrackError?) -> Void) {
        
        if let error = self.getPublishableKey().1 {
            DDLogError("createAndAssignAction fails as publishable Key is not set")
            completionHandler(nil, error)
            return
        }
        
        HTTPRequest(method:.post, urlPath:"actions/", jsonParams:action).makeRequest { response in
            switch response.result {
            case .success:
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data!, options:[])
                    guard let jsonDict = json as? [String : Any] else {
                        let htError = HyperTrackError(HyperTrackErrorType.jsonError)
                        completionHandler(nil, htError)
                        return
                    }
                    
                    let action = HyperTrackAction.fromDict(dict: jsonDict)
                    completionHandler(action, nil)
                } catch {
                    DDLogError("Error serializing action: \(error.localizedDescription)")
                }
            case .failure:
                if response.response?.statusCode == 403 {
                    // handle auth error
                    let htError = HyperTrackError(HyperTrackErrorType.authorizationFailedError)
                    DDLogError("Error while createAndAssignAction: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
                else {
                    let htError = HyperTrackError(HyperTrackErrorType.serverError)
                    if let data = response.data {
                        if let errorMessage =  String(data:data, encoding:.utf8) {
                            htError.errorMessage = errorMessage
                        }
                    }
                    DDLogError("Error while createAndAssignAction: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
            }
        }
    }
    
    func assignActions(userId: String, _ params: [String:Any], completionHandler: @escaping (_ action: HyperTrackUser?,
        _ error: HyperTrackError?) -> Void) {
        
        if let error = self.getPublishableKey().1 {
            DDLogError("assignActions fails as publishable Key is not set")
            completionHandler(nil, error)
            return
        }
        
        let url = "users/" + userId + "/assign_actions/"
        HTTPRequest(method:.post, urlPath:url, jsonParams:params).makeRequest { response in
            switch response.result {
            case .success:
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data!, options:[])
                    guard let jsonDict = json as? [String : Any] else {
                        let htError = HyperTrackError(HyperTrackErrorType.jsonError)
                        completionHandler(nil, htError)
                        return
                    }
                    
                    let user = HyperTrackUser.fromDict(dict: jsonDict)
                    completionHandler(user, nil)
                } catch {
                    DDLogError("Error serializing user: \(error.localizedDescription)")
                }
            case .failure:
                if response.response?.statusCode == 403 {
                    // handle auth error
                    let htError = HyperTrackError(HyperTrackErrorType.authorizationFailedError)
                    DDLogError("Error while assignActions: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
                else {
                    let htError = HyperTrackError(HyperTrackErrorType.serverError)
                    if let data = response.data {
                        if let errorMessage =  String(data:data, encoding:.utf8) {
                            htError.errorMessage = errorMessage
                        }
                    }
                    DDLogError("Error while assignActions: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
            }
        }
    }
    
    
    func patchActionInSynch(_ actionId:String,_ params: [String:Any],_ completionHandler: @escaping (_ action: HyperTrackAction?, _ error: HyperTrackError?) -> Void){
        
        if let error = self.getPublishableKey().1 {
            DDLogError("patchActionInSynch fails as publishable Key is not set")
            completionHandler(nil, error)
            return
        }
        
        let url = "actions/" + actionId  + "/"
        HTTPRequest(method:.patch, urlPath:url, jsonParams:params).makeRequest { response in
            switch response.result {
            case .success:
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data!, options:[])
                    guard let jsonDict = json as? [String : Any] else {
                        let htError = HyperTrackError(HyperTrackErrorType.jsonError)
                        completionHandler(nil, htError)
                        return
                    }
                    
                    let action = HyperTrackAction.fromDict(dict: jsonDict)
                    completionHandler(action, nil)
                } catch {
                    DDLogError("Error serializing action: \(error.localizedDescription)")
                }
            case .failure:
                if response.response?.statusCode == 403 {
                    // handle auth error
                    let htError = HyperTrackError(HyperTrackErrorType.authorizationFailedError,responseData: response.data)
                    DDLogError("Error while patchActionInSynch: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
                else {
                    let htError = HyperTrackError(HyperTrackErrorType.serverError,responseData: response.data)
                    DDLogError("Error while patchActionInSynch: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
            }
        }
        
    }
    
    func completeActionInSynch(_ actionId:String,_ params: [String:Any], completionHandler: @escaping (_ action: HyperTrackAction?, _ error: HyperTrackError?) -> Void){
        let url = "actions/" + actionId  + "/complete/"
        
        if let error = self.getPublishableKey().1 {
            DDLogError("completeActionInSynch fails as publishable Key is not set")
            completionHandler(nil, error)
            return
        }
        
        HTTPRequest(method:.post, urlPath:url, jsonParams:params).makeRequest { response in
            switch response.result {
            case .success:
                let action = HyperTrackAction.fromJson(data: response.data)
                completionHandler(action, nil)
            case .failure:
                if response.response?.statusCode == 403 {
                    // handle auth error
                    let htError = HyperTrackError(HyperTrackErrorType.authorizationFailedError, responseData: response.data)
                    DDLogError("Error while complete action: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
                else {
                    let htError = HyperTrackError(HyperTrackErrorType.serverError, responseData: response.data)
                    DDLogError("Error while complete action: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
            }
        }
    }
    
    func createUser(_ user:[String:Any], completionHandler: ((_ user: HyperTrackUser?, _ error: HyperTrackError?) -> Void)?) {
        
        if let error = self.getPublishableKey().1 {
            DDLogError("createUser fails as publishable Key is not set")
            completionHandler?(nil, error)
            return
        }
        
        HTTPRequest(method:.post, urlPath:"users/", jsonParams:user).makeRequest { response in
            switch response.result {
            case .success:
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data!, options:[])
                    guard let jsonDict = json as? [String : Any] else {
                        let htError = HyperTrackError(HyperTrackErrorType.jsonError, responseData: response.data)
                        guard let completionHandler = completionHandler else { return }
                        completionHandler(nil, htError)
                        return
                    }
                    
                    let user = HyperTrackUser.fromDict(dict: jsonDict)
                    guard let completionHandler = completionHandler else { return }
                    completionHandler(user, nil)
                } catch {
                    DDLogError("Error serializing user: \(error.localizedDescription)")
                }
            case .failure:
                if response.response?.statusCode == 403 {
                    // handle auth error
                    let htError = HyperTrackError(HyperTrackErrorType.authorizationFailedError, responseData: response.data)
                    DDLogError("Error while createUser: \(htError.errorMessage)")
                    guard let completionHandler = completionHandler else { return }
                    completionHandler(nil, htError)
                }
                else {
                    let htError = HyperTrackError(HyperTrackErrorType.serverError, responseData: response.data)
                    DDLogError("Error while createUser: \(htError.errorMessage)")
                    guard let completionHandler = completionHandler else { return }
                    completionHandler(nil, htError)
                }
            }
        }
    }
    
    
    func updateUser(_ user:[String:Any], completionHandler: ((_ user: HyperTrackUser?, _ error: HyperTrackError?) -> Void)?) {
        
        if let error = self.getPublishableKey().1 {
            DDLogError("updateUser fails as publishable Key is not set")
            completionHandler?(nil, error)
            return
        }
        
        HTTPRequest(method:.patch, urlPath:"users/", jsonParams:user).makeRequest { response in
            switch response.result {
            case .success:
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data!, options:[])
                    guard let jsonDict = json as? [String : Any] else {
                        let htError = HyperTrackError(HyperTrackErrorType.jsonError, responseData: response.data)
                        guard let completionHandler = completionHandler else { return }
                        completionHandler(nil, htError)
                        return
                    }
                    
                    let user = HyperTrackUser.fromDict(dict: jsonDict)
                    guard let completionHandler = completionHandler else { return }
                    completionHandler(user, nil)
                } catch {
                    DDLogError("Error serializing user: \(error.localizedDescription)")
                }
            case .failure:
                // TODO: Generate better error here depending on response code
                if response.response?.statusCode == 403 {
                    // handle auth error
                    let htError = HyperTrackError(HyperTrackErrorType.authorizationFailedError, responseData: response.data)
                    DDLogError("Error while updateUser: \(htError.errorMessage)")
                    guard let completionHandler = completionHandler else { return }
                    completionHandler(nil, htError)
                }else {
                    let htError = HyperTrackError(HyperTrackErrorType.serverError, responseData: response.data)
                    DDLogError("Error while updateUser: \(htError.errorMessage)")
                    guard let completionHandler = completionHandler else { return }
                    completionHandler(nil, htError)
                }
            }
        }
    }
    
    
    func getETA(currentLocationCoordinates: CLLocationCoordinate2D,
                expectedPlaceCoordinates: CLLocationCoordinate2D,
                vehicleType: String,
                completionHandler: @escaping (_ eta: NSNumber?, _ error: HyperTrackError?) -> Void) {
        
        if let error = self.getPublishableKey().1 {
            DDLogError("getETA fails as publishable Key is not set")
            completionHandler(nil, error)
            return
        }
        
        
        let currentLocationParam: String = String(currentLocationCoordinates.latitude)
            + "," + String(currentLocationCoordinates.longitude)
        let expectedPlaceParam: String = String(expectedPlaceCoordinates.latitude)
            + "," + String(expectedPlaceCoordinates.longitude)
        let url = "get_eta/?origin=" + currentLocationParam + "&destination=" +
            expectedPlaceParam + "&vehicle_type=" + vehicleType
        
        HTTPRequest(method:.get, urlPath:url, jsonParams:[:]).makeRequest { response in
            switch response.result {
            case .success:
                if let etaResponse = response.result.value as? [String : AnyObject],
                    let etaInSeconds = etaResponse["duration"] as? NSNumber,
                    etaInSeconds.doubleValue >= 0.0 {
                    completionHandler(etaInSeconds, nil)
                    return
                }
                
                let htError = HyperTrackError(HyperTrackErrorType.invalidETAError, responseData: response.data)
                DDLogError("Error while getETA: \(htError.errorMessage)")
                completionHandler(nil, htError)
                
            case .failure:
                if response.response?.statusCode == 403 {
                    // handle auth error
                    let htError = HyperTrackError(HyperTrackErrorType.authorizationFailedError, responseData: response.data)
                    DDLogError("Error while createUser: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
                else {
                    
                    let htError = HyperTrackError(HyperTrackErrorType.serverError, responseData: response.data)
                    DDLogError("Error while getETA: \(htError.errorMessage)")
                    completionHandler(nil, htError)
                }
            }
        }
    }
    
    func cancelActions(userId: String, completionHandler: ((_ user: HyperTrackUser?, _ error: HyperTrackError?) -> Void)?) {
        
        if let error = self.getPublishableKey().1 {
            DDLogError("getETA fails as publishable Key is not set")
            completionHandler?(nil, error)
            return
        }
        
        HTTPRequest(method:.post, urlPath:"users/\(userId)/cancel_actions/", jsonParams:[:]).makeRequest {
            response in switch response.result {
            case .success:
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data!, options: [])
                    guard let jsonDict = json as? [String : Any] else {
                        let htError = HyperTrackError(HyperTrackErrorType.jsonError, responseData: response.data)
                        guard let completionHandler = completionHandler else { return }
                        completionHandler(nil, htError)
                        return
                    }
                    
                    let user = HyperTrackUser.fromDict(dict: jsonDict)
                    guard let completionHandler = completionHandler else { return }
                    completionHandler(user, nil)
                } catch {
                    DDLogError("Error serializing user: \(error.localizedDescription)")
                }
            case .failure:
                if response.response?.statusCode == 403 {
                    // handle auth error
                    let htError = HyperTrackError(HyperTrackErrorType.authorizationFailedError, responseData: response.data)
                    DDLogError("Error while cancelActions: \(htError.errorMessage)")
                    guard let completionHandler = completionHandler else { return }
                    completionHandler(nil, htError)
                }
                else {
                    let htError = HyperTrackError(HyperTrackErrorType.serverError, responseData: response.data)
                    DDLogError("Error while cancelActions: \(htError.errorMessage)")
                    guard let completionHandler = completionHandler else { return }
                    completionHandler(nil, htError)}
            }
        }
    }
    
   
    func registerDeviceToken(userId: String, deviceId: String, registrationId: String, completionHandler: ((_ error: HyperTrackError?) -> Void)?) {
        
        if let error = self.getPublishableKey().1 {
            DDLogError("getETA fails as publishable Key is not set")
            completionHandler?(error)
            return
        }
        
        var json = [String: String]()
        json["user_id"] = userId
        json["device_id"] = deviceId
        json["registration_id"] = registrationId
        
        HTTPRequest(method:.post, urlPath:"apnsdevices/", jsonParams:json).makeRequest { response in
            switch response.result {
            case .success:
                guard let completionHandler = completionHandler else { return }
                completionHandler(nil)
            case .failure:
                if response.response?.statusCode == 403 {
                    // handle auth error
                    let htError = HyperTrackError(HyperTrackErrorType.authorizationFailedError, responseData: response.data)
                    DDLogError("Error while registerDeviceToken: \(htError.errorMessage)")
                    guard let completionHandler = completionHandler else { return }
                    completionHandler(htError)
                }
                else {
                    let htError = HyperTrackError(HyperTrackErrorType.serverError, responseData: response.data)
                    DDLogError("Error while registerDeviceToken: \(htError.errorMessage)")
                    guard let completionHandler = completionHandler else { return }
                    completionHandler(htError)}
            }
        }
    }
    
    func getSDKControls(userId: String, completionHandler: ((_ controls: HyperTrackSDKControls?, _ error: HyperTrackError?) -> Void)?) {
        let urlPath = "users/\(userId)/controls/"
        
        if let error = self.getPublishableKey().1 {
            DDLogError("getSDKControls fails as publishable Key is not set")
            completionHandler?(nil,error)
            return
        }
        
        HTTPRequest(method:.get, urlPath:urlPath, jsonParams:[:]).makeRequest { response in
            switch response.result {
            case .success:
                let controls = HyperTrackSDKControls.fromJson(data: response.data)
                guard let completionHandler = completionHandler else { return }
                completionHandler(controls, nil)
            case .failure:
                if response.response?.statusCode == 403 {
                    // handle auth error
                    let htError = HyperTrackError(HyperTrackErrorType.authorizationFailedError, responseData: response.data)
                    DDLogError("Error while getSDKControls: \(htError.errorMessage)")
                    guard let completionHandler = completionHandler else { return }
                    completionHandler(nil, htError)
                }
                else {
                    let htError = HyperTrackError(HyperTrackErrorType.serverError, responseData: response.data)
                    DDLogError("Error while getSDKControls: \(htError.errorMessage)")
                    guard let completionHandler = completionHandler else { return }
                    completionHandler(nil, htError)
                }
            }
        }
    }
    
    func getSimulatePolyline(originLatlng: String,destinationLatLong:String? = nil,completionHandler: ((_ polyline: String?, _ error: HyperTrackError?) -> Void)?) {
        
        if let error = self.getPublishableKey().1 {
            DDLogError("getSimulatePolyline fails as publishable Key is not set")
            completionHandler?(nil,error)
            return
        }
        
        var urlPath = "simulate/?origin=\(originLatlng)"
        if destinationLatLong != nil {
            urlPath = "simulate/?origin=\(originLatlng)&destination=\(destinationLatLong ?? "")"
            
        }
        HTTPRequest(method:.get, urlPath:urlPath, jsonParams:[:]).makeRequest { response in
            switch response.result {
            case .success:
                let result = response.result.value as! [String:String]
                let polyline = result["time_aware_polyline"]
                guard let completionHandler = completionHandler else { return }
                completionHandler(polyline, nil)
            case .failure:
                if response.response?.statusCode == 403 {
                    // handle auth error
                    let htError = HyperTrackError(HyperTrackErrorType.authorizationFailedError, responseData: response.data)
                    DDLogError("Error while getSimulatePolyline: \(htError.errorMessage)")
                    guard let completionHandler = completionHandler else { return }
                    completionHandler(nil, htError)
                }
                else {
                    
                    let htError = HyperTrackError(HyperTrackErrorType.serverError, responseData: response.data)
                    DDLogError("Error while getSimulatePolyline: \(htError.errorMessage)")
                    guard let completionHandler = completionHandler else { return }
                    completionHandler(nil, htError)}
            }
        }
    }
    
    
    func findPlaces(searchText:String?, cordinate: CLLocationCoordinate2D? , completionHandler: ((_ places: [HyperTrackPlace]?, _ error: HyperTrackError?) -> Void)?){
        
        if let error = self.getPublishableKey().1 {
            DDLogError("findPlaces fails as publishable Key is not set")
            completionHandler?(nil,error)
            return
        }
        
        let escapedString = searchText?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        var urlPath = "places/search/?q=" + escapedString!
        if(cordinate != nil){
            urlPath = urlPath + "&lat=" + (cordinate?.latitude.description)! + "&lon=" + (cordinate?.longitude.description)!
        }
        
        HTTPRequest(method:.get, urlPath:urlPath, jsonParams:[:]).makeRequest { response in
            switch response.result {
            case .success:
                let places  = HyperTrackPlace.multiPlacesFromJson(data:response.data)
                completionHandler!(places, nil)
                break
                
            case .failure:
                if response.response?.statusCode == 403 {
                    // handle auth error
                    let htError = HyperTrackError(HyperTrackErrorType.authorizationFailedError, responseData: response.data)
                    DDLogError("Error while findPlaces: \(htError.errorMessage)")
                    guard let completionHandler = completionHandler else { return }
                    completionHandler(nil, htError)
                }
                else {
                    let htError = HyperTrackError(HyperTrackErrorType.serverError, responseData: response.data)
                    DDLogError("Error while findPlaces: \(htError.errorMessage)")
                    guard let completionHandler = completionHandler else { return }
                    completionHandler(nil, htError)}
            }
        }
        
    }
    
    func createPlace(geoJson : HTGeoJSONLocation,completionHandler: ((_ place: HyperTrackPlace?, _ error: HyperTrackError?) -> Void)?){
        let urlPath = "places/"
        var json = [String: String]()
        json["location"] = geoJson.toJson()
        
        if let error = self.getPublishableKey().1 {
            DDLogError("createPlace fails as publishable Key is not set")
            completionHandler?(nil,error)
            return
        }
        
        HTTPRequest(method:.post, urlPath:urlPath, jsonParams:json).makeRequest { response in
            switch response.result {
            case .success:
                let places  = HyperTrackPlace.fromJson(text: String.init(data: response.data!, encoding: .utf8)!)
                completionHandler!(places, nil)
                break
                
            case .failure:
                if response.response?.statusCode == 403 {
                    // handle auth error
                    let htError = HyperTrackError(HyperTrackErrorType.authorizationFailedError, responseData: response.data)
                    DDLogError("Error while createPlace: \(htError.errorMessage)")
                    guard let completionHandler = completionHandler else { return }
                    completionHandler(nil, htError)
                }
                else {
                    let htError = HyperTrackError(HyperTrackErrorType.serverError, responseData: response.data)
                    DDLogError("Error while createPlace: \(htError.errorMessage)")
                    completionHandler!(nil, htError)}
                
            }
        }
    }
    
    
    func getUserPlaceline(date: Date? = nil, userId: String, completionHandler: ((_ controls: HyperTrackPlaceline?, _ error: HyperTrackError?) -> Void)?) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var dateString = formatter.string(from: Date())
        
        if let date = date {
            dateString = formatter.string(from: date)
        }
        
        if let error = self.getPublishableKey().1 {
            DDLogError("getUserPlaceline fails as publishable Key is not set")
            completionHandler?(nil,error)
            return
        }
        
        let urlPath = "users/\(userId)/placeline/?date=\(dateString)"
        HTTPRequest(method:.get, urlPath:urlPath, jsonParams:[:]).makeRequest { response in
            switch response.result {
            case .success:
                let placeline = HyperTrackPlaceline.fromJson(data: response.data!)
                guard let completionHandler = completionHandler else { return }
                completionHandler(placeline, nil)
            case .failure:
                if response.response?.statusCode == 403 {
                    // handle auth error
                    let htError = HyperTrackError(HyperTrackErrorType.authorizationFailedError, responseData: response.data)
                    DDLogError("Error while getUserPlaceline: \(htError.errorMessage)")
                    guard let completionHandler = completionHandler else { return }
                    completionHandler(nil, htError)
                }
                else {
                    let htError = HyperTrackError(HyperTrackErrorType.serverError, responseData: response.data)
                    DDLogError("Error while getUserPlaceline: \(htError.errorMessage)")
                    guard let completionHandler = completionHandler else { return }
                    completionHandler(nil, htError)}
            }
        }
    }
    
 }
