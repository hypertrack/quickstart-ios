import CoreLocation
import HyperTrack
import SwiftUI

struct ErrorViewModel {
  let title: String
  let message: String
  let resolve: (() -> Void)?
}

extension ErrorViewModel: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.title == rhs.title
  }
}

extension ErrorViewModel: Comparable {
  static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.title < rhs.title
  }
}

struct ErrorRowView: View {
  var error: ErrorViewModel
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(error.title)
        .font(.headline)
      Text(error.message)
        .font(.subheadline)
      if let resolveAction = error.resolve {
        Button(action: resolveAction) {
          Text("Resolve")
        }
        .buttonStyle(DefaultButtonStyle())
      }
    }
  }
}

struct ContentView: View {
  @State private var deviceID = HyperTrack.deviceID
  @State private var isTracking = HyperTrack.isTracking
  @State private var errors: [ErrorViewModel] = []
  @State private var subscribeToErrorsCancellable: HyperTrack.Cancellable!
  @State private var subscribeToIsTrackingCancellable: HyperTrack.Cancellable!

  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        VStack {
          Text("Device ID (long press to copy)")
            .bold()
            .padding(.top)
          Text(deviceID)
            .padding(.horizontal)
            .contextMenu {
              Button {
                UIPasteboard.general.string = deviceID
              } label: {
                Text("Copy to clipboard")
                Image(systemName: "doc.on.doc")
              }
            }
          Spacer()
        }
        .frame(height: geometry.size.height / 3)
        VStack {
          Spacer()
          Button {
            var updatedIsTracking = HyperTrack.isTracking
            updatedIsTracking.toggle()
            HyperTrack.isTracking = updatedIsTracking
            isTracking = updatedIsTracking
          } label: {
            Text(isTracking ? "Tracking" : "Not Tracking")
              .foregroundColor(Color.white)
              .bold()
              .frame(maxWidth: .infinity)
              .padding(.vertical, 20)
              .background(isTracking ? Color.green : Color.black)
              .padding(.horizontal, 20)
              .animation(/*@START_MENU_TOKEN@*/ .easeIn/*@END_MENU_TOKEN@*/)
          }
          Spacer()
        }
        .frame(height: geometry.size.height / 3)
        Spacer()
        List(errors, id: \.title) { error in
          ErrorRowView(error: error)
        }
        .frame(height: geometry.size.height / 3)
      }
    }
    .onAppear {
      let locationManager = CLLocationManager()
      errors = HyperTrack.errors
        .map { viewModel($0, locationManager: locationManager) }
        .sorted()
      subscribeToErrorsCancellable = HyperTrack.subscribeToErrors {
        errors = Array($0)
          .map { viewModel($0, locationManager: locationManager) }
          .sorted()
      }
      subscribeToIsTrackingCancellable = HyperTrack.subscribeToIsTracking {
        isTracking = $0
      }

      HyperTrack.name = "Quickstart iOS"
      let metadata = toJSON([
        /// `driver_handle` is used to link the device and the driver.
        /// You can use any unique user identifier here.
        /// The recommended way is to set it on app login in set it to null on logout
        /// (to remove the link between the device and the driver)
        "driver_handle": "test_driver_quickstart_ios",
        /// You can also add any custom data to the metadata.
        "source": "iOS",
        "employee_id": Int.random(in: 0 ..< 10000),
      ])

      guard let metadata = metadata else {
        /// Make sure to check if toJSON result is non-nil and properly handle this error
        /// (it is nil when the provided data is not JSON-compatible)
        preconditionFailure("Metadata is nil")
      }
      HyperTrack.metadata = metadata
    }
    .onDisappear {
      subscribeToErrorsCancellable.cancel()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

// MARK: - Error handling

func viewModel(_ error: HyperTrack.Error, locationManager: CLLocationManager) -> ErrorViewModel {
  let openSettings = { UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) }
  switch error {
  case .blockedFromRunning: return .init(
      title: "Blocked from running",
      message: "The SDK was remotely blocked from running.",
      resolve: nil
    )
  case .invalidPublishableKey: return .init(
      title: "Invalid publishable key",
      message: "HyperTrack Publishable key is invalid.",
      resolve: nil
    )
  case let .location(location):
    switch location {
    case .mocked: return .init(
        title: "Location mocked",
        message: "The user enabled mock location app while mocking locations is prohibited.",
        resolve: nil
      )
    case .servicesDisabled: return .init(
        title: "Location services disabled",
        message: "The user disabled location services systemwide.",
        resolve: nil
      )
    case .signalLost: return .init(
        title: "Location signal lost",
        message: "GPS satellites are not in view.",
        resolve: nil
      )
    @unknown default:
      fatalError()
    }
  case let .permissions(permissions):
    switch permissions {
    case let .location(location):
      switch location {
      case .denied: return .init(
          title: "Location permissions denied",
          message: "The user denied location permissions.",
          resolve: openSettings
        )
      case .insufficientForBackground: return .init(
          title: "Location permissions insufficient for background",
          message: "Can't start tracking in background with When In Use location permissions. SDK will automatically start tracking when app will return to foreground.",
          resolve: nil
        )
      case .notDetermined: return .init(
          title: "Location permissions not determined",
          message: "The user has not chosen whether the app can use location services.",
          resolve: { locationManager.requestWhenInUseAuthorization() }
        )
      case .provisional: return .init(
          title: "Location permissions provisional",
          message: "The app is in Provisional Always authorization state, which stops sending locations when app is in background.",
          resolve: openSettings
        )
      case .reducedAccuracy: return .init(
          title: "Location permissions reduced accuracy",
          message: "The user didn't grant precise location permissions or downgraded permissions to imprecise.",
          resolve: openSettings
        )
      case .restricted: return .init(
          title: "Location permissions restricted",
          message: "The app is not authorized to use location services.",
          resolve: nil
        )
      @unknown default:
        fatalError()
      }
    @unknown default:
      fatalError()
    }
  @unknown default:
    fatalError()
  }
}
