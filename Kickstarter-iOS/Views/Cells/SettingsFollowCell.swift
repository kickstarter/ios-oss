import KsApi
import Library
import Prelude
import Prelude_UIKit
import ReactiveSwift
import UIKit

internal protocol SettingsFollowCellDelegate: class {
  /// Called when follow switch is tapped
  func settingsFollowCellDidDisableFollowing(_ cell: SettingsFollowCell)
}

internal final class SettingsFollowCell: UITableViewCell, ValueCell {
  fileprivate let viewModel = SettingsFollowCellViewModel()
  internal weak var delegate: SettingsFollowCellDelegate?

  @IBOutlet fileprivate weak var followingLabel: UILabel!
  @IBOutlet fileprivate weak var followStackView: UIStackView!
  @IBOutlet fileprivate weak var followingSwitch: UISwitch!
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
          : .init(topBottom: Styles.grid(1), leftRight: Styles.grid(2))
    }

    _ = self.separatorView
      ||> settingsSeparatorStyle

    _ = self.followingLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Following() }
      |> UILabel.lens.numberOfLines .~ 1
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.showPrivacyFollowingPrompt
      .observeForUI()
      .observeValues { [weak self] in
        guard let _self = self else { return }
        self?.delegate?.settingsFollowCellDidDisableFollowing(_self)
    }

    self.followingSwitch.rac.on = self.viewModel.outputs.followingPrivacyOn
    self.followingSwitch.rac.enabled = self.viewModel.outputs.followingPrivacySwitchIsEnabled
  }

  @IBAction func followingPrivacySwitchTapped(_ followingPrivacySwitch: UISwitch) {
    self.viewModel.inputs.followTapped()
  }
}
