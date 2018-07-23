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

  @IBOutlet fileprivate weak var separatorView: UIView!
  @IBOutlet fileprivate weak var privacySwitch: UISwitch!
  @IBOutlet fileprivate weak var privacySettingLabel: UILabel!
  @IBOutlet fileprivate weak var privacyStackView: UIStackView!

  internal weak var delegate: SettingsPrivacyCellDelegate?

  internal func configureWith(value user: User) {
    self.viewModel.inputs.configureWith(user: user)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.privacySettingLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Following() }

    _ = self.separatorView
      |> separatorStyle
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.notifyDelegateShowFollowPrivacyPrompt
      .observeForUI()
      .observeValues { [weak self] in
        self?.delegate?.notifyDelegateShowFollowPrivacyPrompt()
    }

    //switches go here
    self.privacySwitch.rac.on = self.viewModel.outputs.followingPrivacyOn
  }

  @IBAction func followingPrivacySwitchTapped(_ followingPrivacySwitch: UISwitch) {
    self.viewModel.inputs.followingSwitchTapped(on: followingPrivacySwitch.isOn, didShowPrompt: false)
  }
}
