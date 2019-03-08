import UIKit
import HyperTrack

class ViewController: UIViewController {
    
    @IBOutlet var deviceID: SRCopyableLabel!
    @IBOutlet var locationPermissionButton: UIButton!
    @IBOutlet var activityPermissionButton: UIButton!
    @IBOutlet var trackingButton: UIButton!

    var trackingEnabled = false {
        didSet {
            updateTrackingButtonTitle()
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HyperTrack.setServiceStatusUpdatesDelegate(self)
        
        deviceID.text = HyperTrack.getDeviceId()
    }
    
    // MARK: Button actions
    
    @IBAction func locationPermissionButtonClicked() {
        locationPermissionButton.isUserInteractionEnabled = false
        HyperTrack.requestLocationPermission(completionHandler: nil)
    }
    
    @IBAction func activityPermissionButtonClicked() {
        activityPermissionButton.isUserInteractionEnabled = false
        HyperTrack.requestActivityPermission(completionHandler: nil)
    }
    
    @IBAction func resumeTrackingButtonClicked() {
        if trackingEnabled {
            trackingEnabled = false
            HyperTrack.pauseTracking()
        } else {
            HyperTrack.resumeTracking()
        }
        updateTrackingButtonTitle()
    }
    
    // MARK: Utitliy
    
    func updateTrackingButtonTitle() {
        trackingButton.setTitle(trackingEnabled ? "Pause Tracking" : "Resume Tracking", for: .normal)
    }
}

// MARK: Update button states based on service status

extension ViewController: ServiceStatusUpdateDelegate {
    
    func serviceStatusUpdated(_ type: Config.Services.ServiceType, status: ServiceStatus) {
        let serviceEnabled = status == .started ? true : false
        switch type {
        case .activity:
            let title = (serviceEnabled ? "Activity Service Running" : (HyperTrack.checkActivityPermission() ? "Activity Service Paused" : "Enable Activity Permission"))
            updateServiceButtonState(button: activityPermissionButton, serviceEnabled: serviceEnabled, title: title)
        case .location:
            let title = (serviceEnabled ? "Location Service Running" : (HyperTrack.checkLocationPermission() ? "Location Service Paused" : "Enable Location Permission"))
            updateServiceButtonState(button: locationPermissionButton, serviceEnabled: serviceEnabled, title: title)
        default:
            break
        }
    }
    
    func updateServiceButtonState(button: UIButton, serviceEnabled: Bool, title: String) {
        if serviceEnabled {
            button.backgroundColor = UIColor(red: 0.00, green: 0.79, blue: 0.29, alpha: 1.00)
        } else {
            button.backgroundColor = UIColor.black
        }
        let enableButton = self.trackingEnabled || serviceEnabled
        button.setTitle(title, for: .normal)
        button.isUserInteractionEnabled = !serviceEnabled
        
        self.trackingEnabled = (enableButton && HyperTrack.checkActivityPermission() && HyperTrack.checkLocationPermission())
    }
}
