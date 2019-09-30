import Library
import Prelude
import UIKit

final class ManageViewPledgeRewardReceivedViewController: ToggleViewController {
  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.titleLabel
      |> checkoutTitleLabelStyle
      |> \.text %~ { _ in localizedString(key: "Reward_received", defaultValue: "Reward received") }

    _ = self.toggle
      |> checkoutSwitchControlStyle
      |> \.accessibilityLabel %~ {
        _ in localizedString(key: "Reward_received", defaultValue: "Reward received")
      }
  }
}
