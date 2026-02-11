import KsApi
import Library
import Prelude
import Prelude_UIKit
import ReactiveSwift
import UIKit

internal final class SettingsPrivacyRecommendationCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: SettingsRecommendationsCellViewModelType = SettingsRecommendationsCellViewModel()

  @IBOutlet fileprivate var recommendationsLabel: UILabel!
  @IBOutlet fileprivate var recommendationsSwitch: UISwitch!
  @IBOutlet fileprivate var separatorView: [UIView]!

  override func awakeFromNib() {
    super.awakeFromNib()

    _ = self
      |> \.accessibilityElements .~ [self.recommendationsSwitch].compact()

    _ = self.recommendationsSwitch
      |> \.accessibilityLabel %~ { _ in Strings.Recommendations() }
  }

  internal func configureWith(value: SettingsPrivacyStaticCellValue) {
    self.viewModel.inputs.configureWith(user: value.user)

    _ = self.recommendationsSwitch
      |> \.accessibilityHint .~ value.cellType.description
  }

  internal override func bindStyles() {
    super.bindStyles()
    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(2), leftRight: Styles.grid(20))
          : .init(topBottom: Styles.grid(1), leftRight: Styles.grid(2))
      }

    _ = self.separatorView
      ||> settingsSeparatorStyle

    _ = self.recommendationsSwitch
      |> settingsSwitchStyle

    _ = self.recommendationsLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Recommendations() }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.postNotification
      .observeForUI()
      .observeValues { NotificationCenter.default.post($0) }

    self.viewModel.outputs.updateCurrentUser
      .observeForUI()
      .observeValues { user in AppEnvironment.updateCurrentUser(user) }

    self.recommendationsSwitch.rac.on = self.viewModel.outputs.recommendationsOn
  }

  @IBAction func recommendationsSwitch(_ recommendationsSwitch: UISwitch) {
    self.viewModel.inputs.recommendationsTapped(on: recommendationsSwitch.isOn)
  }
}
