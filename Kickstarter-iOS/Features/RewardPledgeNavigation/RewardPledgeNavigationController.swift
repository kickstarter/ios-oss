import Library
import Prelude
import UIKit

final class RewardPledgeNavigationController: UINavigationController {
  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self.navigationBar
      ?|> \.standardAppearance .~ self.navigationBarAppearance
      ?|> \.scrollEdgeAppearance .~ self.navigationBarAppearance
      ?|> \.isTranslucent .~ false
      ?|> \.shadowImage .~ UIImage()
  }

  private var navigationBarAppearance: UINavigationBarAppearance {
    let navBarAppearance = UINavigationBarAppearance()
    navBarAppearance.configureWithOpaqueBackground()
    navBarAppearance.backgroundColor = .ksr_white

    return navBarAppearance
  }
}
