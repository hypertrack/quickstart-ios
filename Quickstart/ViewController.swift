import UIKit
import HyperTrackCore

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HyperTrackCore.requestLocationPermission { (error) in
            print(error?.errorMessage ?? "location permissions granted")
        }
        HyperTrackCore.requestActivityPermission { (error) in
            print(error?.errorMessage ?? "motion permissions granted")
        }
    }
}
