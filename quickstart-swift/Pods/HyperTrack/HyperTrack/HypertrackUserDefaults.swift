//
//  HypertrackUserDefaults.swift
//  HyperTrack
//
//  Created by ravi on 10/6/17.
//  Copyright © 2017 HyperTrack. All rights reserved.
//

import UIKit

class HypertrackUserDefaults: NSObject {

    static let standard = HypertrackUserDefaults()
    
    var hyperTrackUserDefaults = UserDefaults.init(suiteName: "com.hypertrack.HyperTrack")
    
    func object(forKey defaultName: String) -> Any? {
        if let object = hyperTrackUserDefaults?.object(forKey: defaultName){
            return object
        }
        return UserDefaults.standard.object(forKey: defaultName)
    }
    
    func set(_ value: Any?, forKey defaultName: String){
        hyperTrackUserDefaults?.set(value, forKey: defaultName)
        UserDefaults.standard.set(value, forKey: defaultName)
    }
    
    func removeObject(forKey defaultName: String){
        hyperTrackUserDefaults?.removeObject(forKey: defaultName)
        UserDefaults.standard.removeObject(forKey: defaultName)
    }
    
    func string(forKey defaultName: String) -> String?{
        if let string = hyperTrackUserDefaults?.string(forKey: defaultName){
            return string
        }
        return UserDefaults.standard.string(forKey: defaultName)
    }
    
    func array(forKey defaultName: String) -> [Any]?{
        if let array = hyperTrackUserDefaults?.array(forKey: defaultName){
            return array
        }
        return UserDefaults.standard.array(forKey: defaultName)
    }
    
    func dictionary(forKey defaultName: String) -> [String : Any]?{
        if let dictionary = hyperTrackUserDefaults?.dictionary(forKey:defaultName){
            return dictionary
        }
        return UserDefaults.standard.dictionary(forKey:defaultName)
    }
    
    func data(forKey defaultName: String) -> Data?{
        if let data = hyperTrackUserDefaults?.data(forKey:defaultName){
            return data
        }
        return UserDefaults.standard.data(forKey:defaultName)
    }
    
    
    func stringArray(forKey defaultName: String) -> [String]?{
        if let stringArray =  hyperTrackUserDefaults?.stringArray(forKey:defaultName){
            return stringArray
        }
        return UserDefaults.standard.stringArray(forKey:defaultName)
    }
    
    
    func integer(forKey defaultName: String) -> Int{
        if let value = hyperTrackUserDefaults?.integer(forKey:defaultName){
            return value
        }
        return UserDefaults.standard.integer(forKey:defaultName)
    }
    
    
    func float(forKey defaultName: String) -> Float{
        if let value = hyperTrackUserDefaults?.float(forKey:defaultName){
            return value
        }
        return UserDefaults.standard.float(forKey:defaultName)
    }
    
    
    func double(forKey defaultName: String) -> Double{
        if let value = hyperTrackUserDefaults?.double(forKey:defaultName){
            return value
        }
        return UserDefaults.standard.double(forKey:defaultName)
    }
    
    
    func bool(forKey defaultName: String) -> Bool{
        if let value = hyperTrackUserDefaults?.bool(forKey:defaultName){
            return value
        }
        return UserDefaults.standard.bool(forKey:defaultName)
    }
    
    
    func url(forKey defaultName: String) -> URL?{
        if let url = hyperTrackUserDefaults?.url(forKey:defaultName){
            return url
        }
        return UserDefaults.standard.url(forKey:defaultName)
    }

    func synchronize() {
         hyperTrackUserDefaults?.synchronize()
         UserDefaults.standard.synchronize()
    }

}
