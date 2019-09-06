import UIKit
import HyperTrack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
    
    /// Set your Publishable Key here
    HyperTrack.publishableKey = "<#Paste your Publishable Key here#>"
    
    /// React to critical tracking errors
    NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.reactToCriticalError(_:)),
        name: Notification.Name.HyperTrackDidEncounterCriticalError,
        object: nil)
    
    /// Register for remote notifications
    HyperTrack.registerForRemoteNotifications()
    return true
  }
    
    @objc func reactToCriticalError(_ notification: NSNotification) {
        displayError(notification.hyperTrackError())
    }
    
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
