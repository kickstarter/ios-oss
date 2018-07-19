import KsApi
import Library
import Prelude
import Prelude_UIKit
import ReactiveSwift
import UIKit

public protocol SettingsPrivacyCellDelegate: class {
  func goToDeleteAccount()
  func goToDownloadData()
}

internal final class SettingsPrivacyCell: UITableViewCell, ValueCell {
  fileprivate let viewModel = SettingsPrivacyCellViewModel()

  @IBOutlet fileprivate weak var toggleOn: UISwitch!
  @IBOutlet fileprivate weak var privacySettingLabel: UILabel!
  @IBOutlet fileprivate weak var privacyStackView: UIStackView!

  internal weak var delegate: SettingsPrivacyCellDelegate?

  internal func configureWith(value user: User) {
    self.viewModel.inputs.configureWith(user: user)
  }

  internal override func bindStyles() {
    super.bindStyles()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    //switches go here


  }
}
