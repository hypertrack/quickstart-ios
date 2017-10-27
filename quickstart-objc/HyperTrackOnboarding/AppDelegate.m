//
//  AppDelegate.m
//  HyperTrackOnboarding
//
//  Created by Piyush on 09/05/17.
//  Copyright © 2017 Hypertrack. All rights reserved.
//

#import "AppDelegate.h"
@import HyperTrack;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [HyperTrack initialize:@"YOUR_PUBLISHABLE_KEY"];
//    [HyperTrack registerForNotifications];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Initialize HyperTrack SDK with your Publishable Key here
    // Refer to documentation at
    // https://docs.hypertrack.com/gettingstarted/authentication.html
    // @NOTE: Add **YOUR_PUBLISHABLE_KEY_HERE** here for SDK to be
    // authenticated with HyperTrack Server
    
    // Request for Always Location Authorization
    // Request For Location Always Usage authorization before proceeding
    // further with identifying user.
    // @NOTE: Before this, Make sure to go to the Info tab in your app settings
    // and add permission strings for "Privacy - Location Always
    // Usage Description" and "Privacy - Motion Usage Description"
    // Refer to https://docs.hypertrack.com/sdks/ios/setup.html for more info.
//    [HyperTrack requestAlwaysAuthorization];
//    [HyperTrack requestMotionAuthorization];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
