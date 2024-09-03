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

struct OrderViewModel {
  let orderHandle: String
  let isInsideGeofence: String
}

extension OrderViewModel: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.orderHandle == rhs.orderHandle && lhs.isInsideGeofence == rhs.isInsideGeofence
  }
}

extension OrderViewModel: Comparable {
  static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.orderHandle < rhs.orderHandle
  }
}

struct OrderRowView: View {
  var order: OrderViewModel
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Order Handle: \(order.orderHandle)")
        .font(.headline)
      Text("Is Inside Geofence: \(order.isInsideGeofence)")
        .font(.subheadline)
    }
  }
}

struct ContentView: View {
  @State private var deviceID = HyperTrack.deviceID
  @State private var isTracking = HyperTrack.isTracking
  @State private var errors: [ErrorViewModel] = []
  @State private var orders: [OrderViewModel] = []
  @State private var subscribeToErrorsCancellable: HyperTrack.Cancellable!
  @State private var subscribeToIsTrackingCancellable: HyperTrack.Cancellable!
  @State private var subscribeToOrdersCancellable: HyperTrack.Cancellable!

  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
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
        List(errors, id: \.title) { error in
          ErrorRowView(error: error)
        }
        Spacer()
        List(orders, id: \.orderHandle) { order in
          OrderRowView(order: order)
        }
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

      orders = HyperTrack.orders
        .map { viewModel($0) }
        .sorted()
      subscribeToOrdersCancellable = HyperTrack.subscribeToOrders {
        orders = Array($0)
          .map { viewModel($0) }
      }

      /// `worker_handle` is used to link the device and the worker.
      /// You can use any unique user identifier here.
      /// The recommended way is to set it on app login in set it to null on logout
      /// (to remove the link between the device and the worker)
      HyperTrack.workerHandle = "test_worker_quickstart_ios"
      HyperTrack.name = "Quickstart iOS"
      let metadata = toJSON([
        /// You can add any custom data to the metadata.
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
      subscribeToIsTrackingCancellable.cancel()
      subscribeToOrdersCancellable.cancel()
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

// MARK: - Order handling

func viewModel(_ order: HyperTrack.Order) -> OrderViewModel {
  switch order.isInsideGeofence {
    case .success(let value):
      return .init(orderHandle: order.orderHandle, isInsideGeofence: value ? "true" : "false")
    case .failure(let locationError):
      switch locationError {
        case .errors(let errors):
            let errorsText = errors.map {
                switch $0 {
                case .blockedFromRunning:
                    "Blocked from running"
                case .invalidPublishableKey:
                    "Invalid publishable key"
                case .location(let location):
                    switch location {
                    case .mocked:
                        "Location mocked"
                    case .servicesDisabled:
                        "Location services disabled"
                    case .signalLost:
                        "Location signal lost"
                    }
                case .permissions(let permissions):
                    switch permissions {
                    case .location(let location):
                        switch location {
                        case .denied:
                            "Location permissions denied"
                        case .insufficientForBackground:
                            "Location permissions insufficient for background"
                        case .notDetermined:
                            "Location permissions not determined"
                        case .provisional:
                            "Location permissions provisional"
                        case .reducedAccuracy:
                            "Location permissions reduced accuracy"
                        case .restricted:
                            "Location permissions restricted"
                        }
                    }
                }
            }.joined(separator: "\n")
            return .init(orderHandle: order.orderHandle, isInsideGeofence: errorsText)
        case .notRunning:
            return .init(orderHandle: order.orderHandle, isInsideGeofence: "Not running")
        case .starting:
            return .init(orderHandle: order.orderHandle, isInsideGeofence: "Starting")
      }
  }
}
