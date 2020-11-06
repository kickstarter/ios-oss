import Library
import Prelude
import Prelude_UIKit
import UIKit

internal final class InterstitialViewController: UIViewController{
  
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
