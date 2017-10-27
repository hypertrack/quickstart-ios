//
//  Formatter.swift
//  Lumberjack
//
//  Created by C.W. Betts on 10/3/14.
//
//

import Foundation
import CocoaLumberjack

class Formatter:NSObject, DDLogFormatter {
    func format(message logMessage: DDLogMessage) -> String? {
        let logLevel: String
        switch logMessage.flag {
        case DDLogFlag.error:
            logLevel = "ERROR"
        case DDLogFlag.warning:
            logLevel = "WARNING"
        case DDLogFlag.info:
            logLevel = "INFO"
        case DDLogFlag.debug:
            logLevel = "DEBUG"
        default:
            logLevel = "VERBOSE"
        }
        
        let dt = dateFormmater.string(from: logMessage.timestamp)
        let logMsg = logMessage.message
        let lineNumber = logMessage.line
        let file = logMessage.fileName
        let functionName = logMessage.function
        let threadId = logMessage.threadID
        let userId = Settings.getUserId() ?? ""
        let deviceId = Settings.uniqueInstallationID 
        let sdkVersion:String = Settings.sdkVersion

        return "\(dt)[\(sdkVersion)][\(userId)] [\(deviceId)] [\(threadId)] [\(logLevel)] [\(file):\(lineNumber)]\(functionName ?? "") - \(logMsg)"

    }
    
    
    let dateFormmater = DateFormatter()
    
    public override init() {
        super.init()
        dateFormmater.dateFormat = "yyyy/MM/dd HH:mm:ss:SSS"
    }
    
    //MARK: - DDLogFormatter

}
