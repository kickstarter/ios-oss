import Library
import Prelude
import UIKit

final class RewardPledgeNavigationController: UINavigationController {
  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self.navigationBar
      ?|> \.barTintColor .~ .ksr_support_100
      ?|> \.isTranslucent .~ false
      ?|> \.shadowImage .~ UIImage()
  }
}
