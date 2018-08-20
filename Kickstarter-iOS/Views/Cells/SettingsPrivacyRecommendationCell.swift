import KsApi
import Library
import Prelude
import Prelude_UIKit
import ReactiveSwift
import UIKit

internal final class SettingsPrivacyRecommendationCell: UITableViewCell, ValueCell {
  fileprivate let viewModel = SettingsRecommendationsCellViewModel()

  @IBOutlet fileprivate weak var recommendationsLabel: UILabel!
  @IBOutlet fileprivate weak var recommendationsSwitch: UISwitch!
  @IBOutlet fileprivate var separatorView: [UIView]!

  internal func configureWith(value user: User) {
    self.viewModel.inputs.configureWith(user: user)
  }

  internal override func bindStyles() {
    super.bindStyles()
    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(2), leftRight: Styles.grid(20))
          : .init(topBottom: Styles.grid(1), leftRight: Styles.grid(2)) }

    _ = self.separatorView
      ||> UIView.lens.backgroundColor .~ .ksr_grey_500
      ||> UIView.lens.accessibilityElementsHidden .~ true

    _ = self.recommendationsLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Recommendations() }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.updateCurrentUser
      .observeForUI()
      .observeValues { user in AppEnvironment.updateCurrentUser(user) }

    self.recommendationsSwitch.rac.on = self.viewModel.outputs.recommendationsOn
  }

  @IBAction func recommendationsSwitch(_ recommendationsSwitch: UISwitch) {
    self.viewModel.inputs.recommendationsTapped(on: recommendationsSwitch.isOn)
  }
}
