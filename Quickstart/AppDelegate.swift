import UIKit
import HyperTrackCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        HyperTrackCore.initialize(publishableKey: "pk_06f18a899893ad7588a9294fe2ead708946c16c0") { (error) in
            /// perform post initialization actions
            /// handle error if any
            print(error?.errorMessage ?? "initialized")
        }
        
        return true
    }
}

