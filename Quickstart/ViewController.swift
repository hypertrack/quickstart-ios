import UIKit
import HyperTrack
import CoreLocation
import CoreMotion

class ViewController: UIViewController {
  
  var hyperTrack: HyperTrack!
  /// The label displaying user's Device ID
  @IBOutlet var deviceID: SRCopyableLabel!
  /// Tracking indicator that shows the tracking status
  @IBOutlet var trackingStatus: UIButton!
  /// Location manager used for asking permissions
  let locationManager: CLLocationManager = CLLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    /// Register for notifications to update the tracking indicator state
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.setTrackingIndicatorToTracking),
      name: HyperTrack.startedTrackingNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.setTrackingIndicatorToNotTracking),
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
    
    askForLocationPermissions()
    askForMotionPermissions()
  }
  
  // MARK: Permissions
  
  func askForLocationPermissions() {
    self.locationManager.requestAlwaysAuthorization()
  }
  
  func askForMotionPermissions() {
    if CMMotionActivityManager.isActivityAvailable() {

      let motionActivityManager = CMMotionActivityManager()
      let motionActivityQueue = OperationQueue()

      motionActivityManager.queryActivityStarting(
        from: Date.distantPast, to: Date(), to: motionActivityQueue
      ) { (activities, error) in
        if error != nil {
          print("Motion Activity permissions denied")
        } else if activities != nil || error == nil {
          print("Motion Activity permissions authorized")
        }
      }
    } else {
      print("This is not an iPhone, and it doesn't have Motion Activity hardware")
    }
  }
  
  // MARK: Tracking indicator
  
  @objc func setTrackingIndicatorToNotTracking() {
    trackingStatus.setTitle("Not Tracking", for: .normal)
    trackingStatus.backgroundColor = UIColor.black
  }
  
  @objc func setTrackingIndicatorToTracking() {
    trackingStatus.setTitle("Tracking", for: .normal)
    trackingStatus.backgroundColor = UIColor(red: 0.00, green: 0.79, blue: 0.29, alpha: 1.00)
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
      case .locationPermissionsNotDetermined:
        type = "Location Permissions Not Determined"
        message = "The user has not chosen whether the app can use location services."
      case .locationPermissionsCantBeAskedInBackground:
        type = "Location Permissions Can't Be Asked In Background"
        message = "The user has not chosen whether the app can use location services."
      case .locationPermissionsRestricted:
        type = "Location Permissions Restricted"
        message = "The app is not authorized to use location services."
      case .locationPermissionsDenied:
        type = "Location Permissions Denied"
        message = "The user denied location permissions."
      case .locationPermissionsInsufficientForBackground:
        type = "Location Permissions Insufficient For Background"
        message = "Can't start tracking in background with When In Use location permissions."
      case .locationServicesDisabled:
        type = "Location Services Disabled"
        message = "The user disabled location services systemwide."
      case .motionActivityServicesDisabled:
        type = "Motion Activity Services Disabled"
        message = "The user disabled motion services systemwide."
      case .networkConnectionUnavailable:
        type = "Network Connection Unavailable"
        message = "There was no network connection for 12 hours. Stopped collecting tracking data."
      case .trialEnded:
        type = "Trial Ended"
        message = "HyperTrack's trial period has ended."
      case .paymentDefault:
        type = "Payment Default"
        message = "There was an error processing your payment."
      
      case .motionActivityPermissionsNotDetermined:
        type = "Motion Activity Permissions Not Determined"
        message = "The user has not chosen whether the app can use motion activity services."
      case .motionActivityPermissionsCantBeAskedInBackground:
        type = "Motion Activity Permissions Can't Be Asked In Background"
        message = "The user has not chosen whether the app can use motion activity services."
      case .motionActivityPermissionsRestricted:
        type = "Motion Activity Permissions Restricted"
        message = "Motion access is denied due to system-wide restrictions."
      }
    case let .unrestorableError(unrestorableError):
      switch unrestorableError {
      case .invalidPublishableKey:
        type = "Invalid Publishable Key"
        message = "Publishable Key wan't found in HyperTrack's database."
      case .motionActivityPermissionsDenied:
        type = "Motion Activity Permissions Denied"
        message = "Please grant motion permissions in Settings.app"
      }
    }
    return (type, message)
  }
}
