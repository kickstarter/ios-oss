import KsApi
import Library
import Prelude
import Prelude_UIKit
import ReactiveSwift
import UIKit

public protocol SettingsPrivacyCellDelegate: class {
  func goToDeleteAccount()
  func goToDownloadData()
  /// Called when follow switch is tapped
  func notifyDelegateShowFollowPrivacyPrompt()
}

internal final class SettingsPrivacyCell: UITableViewCell, ValueCell {
  fileprivate let viewModel = SettingsPrivacyCellViewModel()

  @IBOutlet fileprivate weak var privacySwitch: UISwitch!
  @IBOutlet fileprivate weak var privacySettingLabel: UILabel!
  @IBOutlet fileprivate weak var privacyStackView: UIStackView!

  internal weak var delegate: SettingsPrivacyCellDelegate?

  internal func configureWith(value user: User) {
    self.viewModel.inputs.configureWith(user: user)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(4), leftRight: Styles.grid(20))
          : .init(topBottom: Styles.grid(10), leftRight: Styles.grid(3))
    }

    _ = self.privacySettingLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in "Following" }

    _ = self.privacyStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)
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
