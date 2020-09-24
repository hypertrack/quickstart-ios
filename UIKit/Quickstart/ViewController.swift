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
}
