import UIKit
import HyperTrack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
    
    /// Determine if the app was killed in the background and then restarted from a significant
    /// location update or launched by the user
    let continueTracking: Bool
    /// The app launches with the `.location` key if it was launched by the OS location services
    if let keys = launchOptions?.keys, keys.contains(.location) {
      /// This control branch executes if the app was launched by the OS. This means that the app
      /// was tracking location in the background but was killed in the process by RAM shortage or
      /// by the bug in iOS 12.0-12.1.4 that kills background apps every ~48 hours. In this case we
      /// need to continue tracking.
      continueTracking = true
    } else {
      /// This control branch executes if the app was launched by the user
      continueTracking = false
    }
    /// Set your Publishable Key here
    HyperTrack.initialize(
      publishableKey: "<#Paste your publishable key here#>",
      delegate: self,
      startsTracking: continueTracking,
      requestsPermissions: continueTracking)
    
    /// Register for remote notifications to allow bi-directional communication model with the
    /// server. This enables the SDK to run on a variable frequency model, which balances the
    /// fine trade-off between low latency tracking and battery efficiency, and improves robustness.
    /// This includes the methods below in the Remote Notifications section
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

/// It's best to assign HyperTrack delegate once when you want to start tracking and to not
/// reassign it in the process. This way you won't miss any errors.
/// We assign the delegate right in the AppDelegate so we can continue tracking and receiving
/// errors if any occur when tracking is relaunched in the background.
extension AppDelegate: HyperTrackDelegate {
  /// This delegate method receives critical errors that need explicit handling. After an error is
  /// received tracking is stopped. You need to call `startTracking()` to try again with the same
  /// initialization settings or call `initizalize()` with new Publishable Key.
  func hyperTrack(
    _ hyperTrack: AnyClass,
    didEncounterCriticalError criticalError: HyperTrackCriticalError
    ) {
    displayError(criticalError)
  }
  /// For this simple example we display alerts with an ability to try to start tracking again.
  func displayError(_ error:HyperTrackCriticalError) {
    
    guard let window = self.window,
      let viewController = window.rootViewController else { return }
    
    let alert = UIAlertController(
      title: "Error",
      message: error.errorMessage,
      preferredStyle: .alert)
    
    alert.addAction(
      UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    )
    
    alert.addAction(
      UIAlertAction(
        title: "Try again",
        style: UIAlertAction.Style.default,
        handler: { _ in
          HyperTrack.startTracking()
        }
      )
    )
    viewController.present(alert, animated: true, completion: nil)
  }
}
