import UIKit
import HyperTrackCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        initializeHyperTrackSDK()
        
        return true
    }
    
    
    /// To initialize the SDK you need to set your own Publishable Key
    func initializeHyperTrackSDK() {
        HyperTrackCore.initialize(publishableKey: "<#Paste your Publishable Key here#>") { (error) in
            
            if let message = error?.errorMessage {
                DispatchQueue.main.async { [weak self] in
                    let alert = UIAlertController(title: "Failed to register this device", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Retry", style: UIAlertAction.Style.default, handler: { [weak self] _ in
                        self?.initializeHyperTrackSDK()
                    }))
                    self?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

