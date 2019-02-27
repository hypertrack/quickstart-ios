import UIKit
import HyperTrackCore

class ViewController: UIViewController {
    
    @IBOutlet var deviceID: UILabel!
    @IBOutlet var locationPermissionButton: UIButton!
    @IBOutlet var activityPermissionButton: UIButton!
    @IBOutlet var trackingButton: UIButton!
    
    var trackingEnabled = false {
        didSet {
            updateTrackingButtonTitle()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HyperTrackCore.setServiceStatusUpdatesDelegate(self)
        
        deviceID.text = HyperTrackCore.getDeviceId()
    }
    
    @IBAction func locationPermissionButtonClicked() {
        locationPermissionButton.isUserInteractionEnabled = false
        HyperTrackCore.requestLocationPermission(completionHandler: nil)
    }
    
    @IBAction func activityPermissionButtonClicked() {
        activityPermissionButton.isUserInteractionEnabled = false
        HyperTrackCore.requestActivityPermission(completionHandler: nil)
    }
    
    
    @IBAction func resumeTrackingButtonClicked() {
        if trackingEnabled {
            trackingEnabled = false
            HyperTrackCore.pauseTracking()
        } else {
            HyperTrackCore.resumeTracking()
        }
        updateTrackingButtonTitle()
    }
    
    func updateTrackingButtonTitle() {
        trackingButton.setTitle(trackingEnabled ? "Pause Tracking" : "Resume Tracking", for: .normal)
    }
}


extension ViewController: ServiceStatusUpdateDelegate {
    
    func serviceStatusUpdated(_ type: Config.Services.ServiceType, status: ServiceStatus) {
        let serviceEnabled = status == .started ? true : false
        switch type {
        case .activity:
            let title = (serviceEnabled ? "Activity Service Running" : (HyperTrackCore.checkActivityPermission() ? "Activity Service Paused" : "Enable Activity Permission"))
            updateServiceButtonState(button: activityPermissionButton, serviceEnabled: serviceEnabled, title: title)
        case .location:
            let title = (serviceEnabled ? "Location Service Running" : (HyperTrackCore.checkLocationPermission() ? "Location Service Paused" : "Enable Location Permission"))
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
        
        self.trackingEnabled = (enableButton && HyperTrackCore.checkActivityPermission() && HyperTrackCore.checkLocationPermission())
    }
}
