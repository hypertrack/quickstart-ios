import UIKit
import HyperTrackCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        initializeHyperTrackSDK()
        
        return true
    }
    
    func initializeHyperTrackSDK() {
        HyperTrackCore.initialize(publishableKey: "pk_06f18a899893ad7588a9294fe2ead708946c16c0") { (error) in
            
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

