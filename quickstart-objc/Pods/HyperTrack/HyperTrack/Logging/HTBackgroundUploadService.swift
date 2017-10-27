//
//  HTBackgroundUploadService.swift
//  HyperTrack
//
//  Created by ravi on 10/6/17.
//  Copyright © 2017 HyperTrack. All rights reserved.
//

import UIKit
import CocoaLumberjack
import Foundation
import Alamofire

class HTBackgroundUploadService: DDLogFileManagerDefault,
URLSessionDelegate,URLSessionTaskDelegate  {
    
    var isDiscretionary = true
    public var backgroundSessionManager: Alamofire.SessionManager
    let sdkVersion:String = Settings.sdkVersion
    let osVersion:String = UIDevice.current.systemVersion
    let appId:String = Bundle.main.bundleIdentifier!
    let deviceId:String = Settings.uniqueInstallationID
    var isUploadInProgress = false;
    
    public init(){
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.hypertrack.logs.upload")
        configuration.isDiscretionary =  isDiscretionary
        backgroundSessionManager = Alamofire.SessionManager(configuration: configuration)

        super.init(logsDirectory:self.logDirectory())
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onForegroundNotification), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.onBackGroundNotification), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)

    }
    
    public init(isDiscretionary:Bool){
        self.isDiscretionary = isDiscretionary
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.hypertrack.logs.upload")
        configuration.isDiscretionary =  isDiscretionary
        backgroundSessionManager = Alamofire.SessionManager(configuration: configuration)
        super.init(logsDirectory:self.logDirectory())
    }
    
    func logDirectory() -> String? {
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        if let baseDir = path.first{
            if let logDirUrl = NSURL(fileURLWithPath: baseDir).appendingPathComponent("Logs"){
                let logDir = logDirUrl.path
                return logDir
            }
        }
        return ""
    }
    
    func onForegroundNotification(_ notification: Notification){
       postLogsToServer()
    }
    
    func onBackGroundNotification(_ notification: Notification){
        postLogsToServer()
    }
    
    public func canUploadLogFiles() -> Bool{
        let timeStamp = Date()
        var shouldUpload  = true
        if let lastLogsTimeStamp  = HypertrackUserDefaults.standard.object(forKey: "lastLogTimeStamp") as? Date {
            if (timeStamp.timeIntervalSince1970 - lastLogsTimeStamp.timeIntervalSince1970) < 86400 {
                shouldUpload = false
            }
        }
        
        return shouldUpload && !isUploadInProgress
    }

    public func postLogsToServer(){
        if(Settings.getUserId() != nil && Settings.getTracking()){
            let baseUrl = URL.init(string: "https://api.hypertrack.com/api/v1/logs_file/")
            if FileManager.default.fileExists(atPath: self.logDirectory()!){
                let fileNames = try! FileManager.default.contentsOfDirectory(atPath: self.logDirectory()!)
                var logDir = ""
                var file = ""
                for fileName in fileNames {
                    if let logDirUrl = NSURL(fileURLWithPath: self.logDirectory()!).appendingPathComponent(fileName){
                        logDir = logDirUrl.path
                        file = fileName
                        DDLogVerbose(logDir)
                        if canUploadLogFiles(){
                            uploadFileAtPath(fileName:file , logFilePath: logDir, toUrl: baseUrl!)
                        }
                    }
                }
            }
        }
    }
    
    func uploadFileAtPath(fileName:String, logFilePath:String, toUrl:URL){
        isUploadInProgress = true
        
        if  let publishableKey = Settings.getPublishableKey(){
            let headers = [
                "Authorization": "token \(publishableKey)",
                "Content-Type":"multipart/form-data",
                "User-Agent": "HyperTrack iOS SDK/\(sdkVersion) (\(osVersion))",
                "App-ID": "\(appId )",
                "Device-ID": "\(deviceId)",
                "Timezone": TimeZone.current.identifier,
                "Content-Disposition": "attachment; filename=\(fileName)"
            ]
            
            let fileUrl = URL.init(fileURLWithPath: logFilePath)
            
            backgroundSessionManager.upload(multipartFormData: { (multipartData) in
                // multipart setup
                multipartData.append(fileUrl, withName: "ios_log_file")
                
            }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: toUrl, method: .post, headers: headers, encodingCompletion: { encodingResult in
                switch (encodingResult) {
                    
                // encodingResult success
                case .success(let request, _, _):
                    // upload progress closure
                    request.uploadProgress(closure: { (progress) in
                        
                    })
                    
                    // response handler
                    request.responseJSON(completionHandler: { response in
                        switch response.result {
                        case .success( _):
                            self.isUploadInProgress = false
                            HypertrackUserDefaults.standard.set(Date(), forKey:"lastLogTimeStamp")
                            DDLogInfo(response.description)
                            self.deleteFileAtPath(filePath: logFilePath)
                        case .failure(let error):
                            self.isUploadInProgress = false
                            DDLogError(error.localizedDescription)
                        }
                    })
                    
                // encodingResult failure
                case .failure(let error):
                    self.isUploadInProgress = false
                    DDLogError(error.localizedDescription)
                    
                }
            })
        }
     
    }
    
    func deleteFileAtPath(filePath:String){
        do {
            try FileManager.default.removeItem(atPath: filePath)
        }
        catch{
            DDLogError("Error deleting files: \(error.localizedDescription)")
        }
    }
}
