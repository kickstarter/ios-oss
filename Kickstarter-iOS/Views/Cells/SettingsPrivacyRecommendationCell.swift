import KsApi
import Library
import Prelude
import Prelude_UIKit
import ReactiveSwift
import UIKit

internal final class SettingsPrivacyRecommendationCell: UITableViewCell, ValueCell {
  fileprivate let viewModel = SettingsRecommendationsCellViewModel()

  @IBOutlet fileprivate weak var recommendationsSwitch: UISwitch!
  @IBOutlet fileprivate weak var recommendationsLabel: UILabel!
  @IBOutlet fileprivate weak var separatorView: UIView!

  internal func configureWith(value user: User) {
    self.viewModel.inputs.configureWith(user: user)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = self.separatorView
      |> separatorStyle

    _ = self.recommendationsLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Recommendations() }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.recommendationsSwitch.rac.on = self.viewModel.outputs.recommendationsOn
  }
}
