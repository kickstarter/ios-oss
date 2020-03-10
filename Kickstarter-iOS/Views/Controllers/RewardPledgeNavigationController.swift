import Library
import Prelude
import UIKit

final class RewardPledgeNavigationController: UINavigationController {
  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self.navigationBar
      ?|> \.barTintColor .~ .ksr_grey_300
      ?|> \.isTranslucent .~ false
      ?|> \.shadowImage .~ UIImage()
  }
}
