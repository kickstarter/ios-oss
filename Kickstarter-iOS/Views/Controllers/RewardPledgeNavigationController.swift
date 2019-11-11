import Library
import Prelude
import UIKit

final class RewardPledgeNavigationController: UINavigationController {
  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.delegate .~ self

    _ = self.navigationBar
      ?|> \.isTranslucent .~ false
      ?|> \.shadowImage .~ UIImage()
  }
}

extension RewardPledgeNavigationController: UINavigationControllerDelegate {
  func navigationController(
    _: UINavigationController,
    animationControllerFor operation: UINavigationController.Operation,
    from fromVC: UIViewController,
    to toVC: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    switch (operation, fromVC, toVC) {
    case (.push, is RewardPledgeTransitionAnimatorDelegate, is PledgeViewController):
      return RewardPledgePushTransitionAnimator()
    case (.pop, is PledgeViewController, is RewardPledgeTransitionAnimatorDelegate):
      return nil
    default:
      return nil
    }
  }

  func navigationController(
    _: UINavigationController, willShow viewController: UIViewController, animated _: Bool
  ) {
    _ = self.navigationBar
      ?|> \.barTintColor .~ .ksr_grey_300
      ?|> \.shadowImage .~ UIImage()
  }
}
