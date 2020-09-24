import Foundation
import HyperTrack

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
    @unknown default:
      type = "Unknown development error"
      message = ""
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
    @unknown default:
      type = "Unknown production error"
      message = ""
    }
  }
  return (type, message)
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
    @unknown default:
      type = "Unknown Restorable Error"
      message = ""
    }
  case let .unrestorableError(unrestorableError):
    switch unrestorableError {
    case .invalidPublishableKey:
      type = "Invalid Publishable Key"
      message = "Publishable Key wan't found in HyperTrack's database."
    case .motionActivityPermissionsDenied:
      type = "Motion Activity Permissions Denied"
      message = "Please grant motion permissions in Settings.app"
    @unknown default:
      type = "Unknown Unrestorable Error"
      message = ""
    }
  }
  return (type, message)
}
