//
//  HTLogger.swift
//  HyperTrack
//
//  Created by Piyush on 28/06/17.
//  Copyright © 2017 HyperTrack. All rights reserved.
//

import Foundation
import CocoaLumberjack

public final class HTLogger :NSObject {
    
    let ddloglevel = DDLogLevel.verbose
    public static let shared = HTLogger()
    
    let timeStampKey = "timestamp"
    let fileManager : HTBackgroundUploadService
    override init() {
        let formatter = Formatter()
        DDTTYLogger.sharedInstance.logFormatter = formatter
        DDLog.add(DDTTYLogger.sharedInstance)
        fileManager = HTBackgroundUploadService.init()
        let fileLogger = DDFileLogger.init(logFileManager: fileManager)
        fileLogger?.logFormatter = formatter
        DDLog.add(fileLogger!)
        super.init()
    }
    
    func initialize(){
        DispatchQueue.main.async {
            self.fileManager.postLogsToServer()
        }
    }

}
