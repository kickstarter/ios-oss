import Library
import Prelude
import UIKit

final class ManageViewPledgeRewardReceivedViewController: ToggleViewController {
  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.titleLabel
      |> checkoutTitleLabelStyle
      |> \.text %~ { _ in "Reward received" }

    _ = self.toggle
      |> checkoutSwitchControlStyle
  }
}
