import HyperTrack
import SwiftUI

let publishableKey = HyperTrack.PublishableKey(<#"PASTE_YOUR_PUBLISHABLE_KEY_HERE"#>)!

@main
struct Quickstart: App {
  @UIApplicationDelegateAdaptor(PushNotifications.self) var pushNotifications
  
    var body: some Scene {
        WindowGroup {
          switch HyperTrack.makeSDK(publishableKey: publishableKey) {
          case let .success(hyperTrack):
            ContentView(deviceID: hyperTrack.deviceID)
          case let .failure(fatalError):
            FailureView(fatalError: fatalError)
          }
        }
    }
}
