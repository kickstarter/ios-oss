import KsApi
import Library
import Prelude
import Prelude_UIKit
import ReactiveSwift
import UIKit

public protocol SettingsPrivacyCellDelegate: class {
  /// Called when follow switch is tapped
  func notifyDelegateShowFollowPrivacyPrompt()
}

internal final class SettingsPrivacyCell: UITableViewCell, ValueCell {
  fileprivate let viewModel = SettingsPrivacyCellViewModel()
  internal weak var delegate: SettingsPrivacyCellDelegate?

  @IBOutlet fileprivate weak var separatorView: UIView!
  @IBOutlet fileprivate weak var privacySwitch: UISwitch!
  @IBOutlet fileprivate weak var privacySettingLabel: UILabel!
  @IBOutlet fileprivate weak var privacyStackView: UIStackView!

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
      |> separatorStyle

    _ = self.privacySettingLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Following() }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.showPrivacyFollowingPrompt
      .observeForUI()
      .observeValues { [weak self] in
        self?.delegate?.notifyDelegateShowFollowPrivacyPrompt()
    }

    self.privacySwitch.rac.on = self.viewModel.outputs.followingPrivacyOn
  }

  @IBAction func followingPrivacySwitchTapped(_ followingPrivacySwitch: UISwitch) {
    self.viewModel.inputs.followTapped()
  }
}
