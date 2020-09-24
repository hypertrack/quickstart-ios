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
}
