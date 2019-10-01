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

    self.navigationBar.shadowImage = UIImage()
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

  func navigationController(
    _: UINavigationController, willShow viewController: UIViewController, animated _: Bool
  ) {
    let barTintColor: UIColor

    if viewController is RewardsCollectionViewController {
      barTintColor = .ksr_grey_400
    } else {
      barTintColor = .ksr_grey_300
    }

    _ = self.navigationBar ?|> \.barTintColor .~ barTintColor
  }
}
