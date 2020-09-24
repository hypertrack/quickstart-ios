import HyperTrack
import SwiftUI

struct ContentView: View {
  let deviceID: String
  
  @State var isTracking: Bool = false
  @State var error: (title: String, message: String)? = nil
  
  var body: some View {
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
      if let error = error {
        Text(error.title)
          .bold()
          .padding()
        Text(error.message)
          .padding()
        Spacer()
      }
      Text(isTracking ? "Tracking" : "Not Tracking")
        .foregroundColor(Color.white)
        .bold()
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(isTracking ? Color.green : Color.black)
        .padding(.horizontal, 20)
        .animation(/*@START_MENU_TOKEN@*/.easeIn/*@END_MENU_TOKEN@*/)
    }
    .onReceive(
      NotificationCenter.default.publisher(
        for: HyperTrack.startedTrackingNotification
      )
    ) { _ in
      self.isTracking = true
      self.error = nil
    }
    .onReceive(
      NotificationCenter.default.publisher(
        for: HyperTrack.stoppedTrackingNotification
      )
    ) { _ in
      self.isTracking = false
    }
    .onReceive(
      NotificationCenter.default.publisher(
        for: HyperTrack.didEncounterRestorableErrorNotification
      ),
      perform: updateErrorFromNotification
    )
    .onReceive(
      NotificationCenter.default.publisher(
        for: HyperTrack.didEncounterUnrestorableErrorNotification
      ),
      perform: updateErrorFromNotification
    )
  }
  
  func updateErrorFromNotification(_ notification: Notification) {
    if isTracking, let trackingError = notification.hyperTrackTrackingError() {
      let (type, message) = convertTrackingErrorToUIMessage(trackingError)
      error = (type, message)
    } else {
      error = nil
    }
  }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(deviceID: "DEVICEID-ISAU-UIDS-TRIN-GRFC4122VER4")
  }
}
#endif
