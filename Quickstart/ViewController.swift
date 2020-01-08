import UIKit
import HyperTrack

class ViewController: UIViewController {
  
  var hyperTrack: HyperTrack!
  /// The label displaying user's Device ID
  @IBOutlet var deviceID: SRCopyableLabel!
  /// Button that starts or stops tracking
  @IBOutlet var trackingButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    /// Register for notifications to update the tracking button state
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.setTrackingButtonActionToStop),
      name: HyperTrack.startedTrackingNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.setTrackingButtonActionToStart),
      name: HyperTrack.stoppedTrackingNotification,
      object: nil
    )
    
    /// These notifications are used to display errors that can happen at runtime
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(trackingError(notification:)),
      name: HyperTrack.didEncounterUnrestorableErrorNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(trackingError(notification:)),
      name: HyperTrack.didEncounterRestorableErrorNotification,
      object: nil
    )
    
    /// Use this property to obtain the unique Device ID that HyperTrack uses to identify a device
    /// on Dashboard
    let yourDeviceID = hyperTrack.deviceID
    deviceID.text = yourDeviceID
    // You can copy it from the console or from the phone
    print("Your device ID:\n\(yourDeviceID)")
    
    updateTrackingButtonTitle()
  }
  
  // MARK: Tracking button
  
  @objc func updateTrackingButtonTitle() {
    if hyperTrack.isRunning {
      setTrackingButtonActionToStop()
    } else {
      setTrackingButtonActionToStart()
    }
  }
  
  @IBAction func trackingButtonClicked() {
    if hyperTrack.isRunning {
      hyperTrack.stop()
      setTrackingButtonActionToStart()
    } else {
      hyperTrack.start()
      setTrackingButtonActionToStop()
    }
  }
  
  @objc func setTrackingButtonActionToStart() {
    trackingButton.setTitle("Start Tracking", for: .normal)
    trackingButton.backgroundColor = UIColor.black
  }
  
  @objc func setTrackingButtonActionToStop() {
    trackingButton.setTitle("Stop Tracking", for: .normal)
    trackingButton.backgroundColor = UIColor(red: 0.00, green: 0.79, blue: 0.29, alpha: 1.00)
  }
  
  // MARK: - Showing runtime errors
  
  @objc func trackingError(notification: Notification) {
    if let trackingError = notification.hyperTrackTrackingError() {
      let (type, message) = convertTrackingErrorToUIMessage(trackingError)
      
      let alert = UIAlertController(
        title: type,
        message: message,
        preferredStyle: .alert)
      
      alert.addAction(
        UIAlertAction(title: "OK", style: .default, handler: nil)
      )

      present(alert, animated: true, completion: nil)
    }
  }
  
  func convertTrackingErrorToUIMessage(_ trackingError: HyperTrack.TrackingError) -> (type: String, message: String) {
    let type: String
    let message: String
    
    switch trackingError {
    case let .restorableError(restorableError):
      switch restorableError {
      case .locationPermissionsDenied:
        type = "Location Permissions Denied"
        message = "The user denied location permissions."
      case .locationServicesDisabled:
        type = "Location Services Disabled"
        message = "The user disabled location services systemwide."
      case .motionActivityServicesDisabled:
        type = "Motion Activity Services Disabled"
        message = "The user disabled motion services systemwide."
      case .networkConnectionUnavailable:
        type = "Network Connection Unavailable"
        message = "There was no network connection for 12 hours."
      case .trialEnded:
        type = "Trial Ended"
        message = "HyperTrack's trial period has ended."
      case .paymentDefault:
        type = "Payment Default"
        message = "There was an error processing your payment."
      }
    case let .unrestorableError(unrestorableError):
      switch unrestorableError {
      case .invalidPublishableKey:
        type = "Invalid Publishable Key"
        message = "Publishable Key wan't found in HyperTrack's database."
      case .motionActivityPermissionsDenied:
        type = "Motion Activity Permissions Denied"
        message = "Motion activity permissions denied after SDK's initialization. Granting them will restart the app, so in effect, they are denied during this app's session."
      }
    }
    return (type, message)
  }
}
