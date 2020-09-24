import HyperTrack
import SwiftUI

struct FailureView: View {
  let title: String
  let message: String
  
  init(fatalError: HyperTrack.FatalError) {
    let (title, message) = convertFatalErrorToUIMessage(fatalError)
    self.title = title
    self.message = message
  }
  
  var body: some View {
    VStack {
      Text(title)
        .bold()
        .padding()
      Text(message)
        .padding()
    }
  }
}

struct FailureView_Previews: PreviewProvider {
  static var previews: some View {
    FailureView(fatalError: .productionError(.locationServicesUnavalible))
  }
}

