import UIKit
import HyperTrackCore

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HyperTrackCore.requestLocationPermission { (error) in
            print(error?.errorMessage ?? "error requesting location permissions")
        }
        HyperTrackCore.requestActivityPermission { (error) in
            print(error?.errorMessage ?? "error requestiong motion permissions")
        }
    }
}
