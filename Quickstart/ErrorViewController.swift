import UIKit
import HyperTrack

class ErrorViewController: UIViewController {

  var error: HyperTrack.FatalError!
  
  @IBOutlet var errorTitle: UILabel!
  @IBOutlet var errorMessage: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let (title, message) = convertFatalErrorToUIMessage(error)
    self.errorTitle.text = title
    self.errorMessage.text = message
  }
  
  func convertFatalErrorToUIMessage(_ fatalError: HyperTrack.FatalError) -> (type: String, message: String) {
    let type: String
    let message: String
    
    switch fatalError {
    case let .developmentError(developmentError):
      switch developmentError {
      case .missingLocationUpdatesBackgroundModeCapability:
        type = "Missing Location Updates Background Mode Capability"
        message = #"Location updates" mode is not set in your target's "Signing & Capabilities"#
      case .runningOnSimulatorUnsupported:
        type = "Running On Simulator Unsupported"
        message = "You are running the SDK on the iOS simulator, which currently does not support CoreMotion services. You can test the SDK on real iOS devices only."
      }
    case let .productionError(productionError):
      switch productionError {
      case .locationServicesUnavalible:
        type = "Location Services Unavalible"
        message = "The device doesn't have GPS capabilities, or it is malfunctioning."
      case .motionActivityServicesUnavalible:
        type = "Motion Activity Services Unavalible"
        message = "The device doesn't have Motion capabilities, or it is malfunctioning."
      case .motionActivityPermissionsDenied:
        type = "Motion Activity Permissions Denied"
        message = "Motion activity permissions denied before SDK initialization. Granting them will restart the app, so in effect, they are denied during this app's session."
      }
    }
    return (type, message)
  }
}
