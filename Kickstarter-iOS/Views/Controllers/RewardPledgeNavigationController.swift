import Prelude
import UIKit

final class RewardPledgeNavigationController: UINavigationController {
  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.delegate .~ self
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
      return RewardPledgePopTransitionAnimator()
    default:
      return nil
    }
  }
}
