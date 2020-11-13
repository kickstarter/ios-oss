import Library
import Prelude
import Prelude_UIKit
import UIKit

internal final class InterstitialViewController: UIViewController{
  
  @IBOutlet fileprivate var mailIcon: UIImageView!
  @IBOutlet fileprivate var laterButton: UIButton!
  @IBOutlet fileprivate var resendEmailButton: UIButton!
  @IBOutlet fileprivate var verifyEmailLable: UILabel!
  @IBOutlet fileprivate var checkInboxLable: UILabel!

  
  fileprivate let viewModel: InterstitialViewModel = InterstitialViewModel()
  
  internal static func instantiate() -> InterstitialViewController {
    let vc = Storyboard.Login.instantiate(InterstitialViewController.self)
    return vc
  }
  
  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()
  }

  internal override func bindViewModel() {
    
  }
  
}
