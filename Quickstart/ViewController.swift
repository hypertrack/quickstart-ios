import UIKit
import HyperTrack

class ViewController: UIViewController {
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
      name: Notification.Name.trackingStarted,
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.setTrackingButtonActionToStart),
      name: Notification.Name.trackingStopped,
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.updateTrackingButtonTitle),
      name: UIApplication.willEnterForegroundNotification,
      object: nil)
    /// Use this property to obtain the unique Device ID that HyperTrack uses to identify a device
    /// on Dashboard
    deviceID.text = HyperTrack.deviceID
    
    updateTrackingButtonTitle()
  }
  
  // MARK: Tracking button
  
  @objc func updateTrackingButtonTitle() {
    if HyperTrack.isTracking {
      setTrackingButtonActionToStop()
    } else {
      setTrackingButtonActionToStart()
    }
  }
  
  @IBAction func trackingButtonClicked() {
    if HyperTrack.isTracking {
      HyperTrack.stopTracking()
      setTrackingButtonActionToStart()
    } else {
      HyperTrack.startTracking()
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
}
