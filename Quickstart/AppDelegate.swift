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
    
    return true
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
    NotificationCenter.default.post(
      Notification(name: Notification.Name.trackingStopped))
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
          NotificationCenter.default.post(
            Notification(name: Notification.Name.trackingStarted))
        }
      )
    )
    viewController.present(alert, animated: true, completion: nil)
  }
}

/// Here we use Notifications to push tracking statuses to every controller that needs to update
/// it's UI.
extension Notification.Name {
  /// Tracking stopped notification
  static let trackingStopped = Notification.Name("HyperTrackStoppedTracking")
  /// Tracking started notification
  static let trackingStarted = Notification.Name("HyperTrackStartedTracking")
}
