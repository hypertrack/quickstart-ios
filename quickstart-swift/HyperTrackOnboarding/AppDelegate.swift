//
//  AppDelegate.swift
//  HyperTrackOnboarding
//
//  Created by Arjun Attam on 09/05/17.
//  Copyright © 2017 Hypertrack. All rights reserved.
//

import UIKit
import HyperTrack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initialize HyperTrack SDK with your Publishable Key here
        // Refer to documentation at
        // https://docs.hypertrack.com/gettingstarted/authentication.html
        // @NOTE: Add **YOUR_PUBLISHABLE_KEY_HERE** here for SDK to be
        // authenticated with HyperTrack Server
        HyperTrack.initialize("YOUR_PUBLISHABLE_KEY")
        
        // Request For Location Always Usage authorization before proceeding
        // further with identifying user.
        // @NOTE: Before this, Make sure to go to the Info tab in your app settings
        // and add permission strings for "Privacy - Location Always 
        // Usage Description" and "Privacy - Motion Usage Description"
        // Refer to https://docs.hypertrack.com/sdks/ios/setup.html for more info.
        HyperTrack.requestAlwaysAuthorization()
        HyperTrack.requestMotionAuthorization()
        
        HyperTrack.registerForNotifications()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

// Remote Notification
extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        HyperTrack.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if (HyperTrack.isHyperTrackNotification(userInfo: userInfo)){
            HyperTrack.didReceiveRemoteNotification(userInfo: userInfo)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        HyperTrack.didFailToRegisterForRemoteNotificationsWithError(error: error)
    }
}

