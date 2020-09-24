import UIKit
import HyperTrack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    window = UIWindow(frame: UIScreen.main.bounds)
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    /// Set your Publishable Key here
    let publishableKey = HyperTrack.PublishableKey(<#"PASTE_YOUR_PUBLISHABLE_KEY_HERE"#>)!
    switch HyperTrack.makeSDK(publishableKey: publishableKey) {
    
    case let .success(hyperTrack):
      let viewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
      viewController.hyperTrack = hyperTrack
      window?.rootViewController = viewController
    
    case let .failure(fatalError):
      let errorViewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController") as! ErrorViewController
      errorViewController.error = fatalError
      window?.rootViewController = errorViewController
    }
    window?.makeKeyAndVisible()
    /// Register for remote notifications
    HyperTrack.registerForRemoteNotifications()
    
    return true
  }
  
  // MARK: Remote Notifications
  
  func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    HyperTrack.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
  }
  

  func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    HyperTrack.didFailToRegisterForRemoteNotificationsWithError(error)
  }
  

  func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable : Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    HyperTrack.didReceiveRemoteNotification(userInfo, fetchCompletionHandler: completionHandler)
  }
}
