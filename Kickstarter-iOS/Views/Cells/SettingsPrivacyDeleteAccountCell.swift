import KsApi
import Library
import Prelude
import ReactiveExtensions
import ReactiveSwift
import UIKit

public protocol SettingsPrivacyDeleteAccountCellDelegate: class {
  func goToDeleteAccount(url: URL)
}

internal final class SettingsPrivacyDeleteAccountCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: SettingsDeleteAccountCellViewModelType = SettingsDeleteAccountCellViewModel()
  internal weak var delegate: SettingsPrivacyDeleteAccountCellDelegate?

  @IBOutlet fileprivate weak var deleteAccountLabel: UILabel!
  @IBOutlet fileprivate weak var separatorView: UIView!
  @IBOutlet fileprivate weak var deleteAccountButton: UIButton!

  internal func configureWith(value user: User) {
    self.viewModel.inputs.configureWith(user: user)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.separatorView
      |> separatorStyle

    _ = self.deleteAccountLabel
      |> UILabel.lens.textColor .~ .ksr_red_400
      |> UILabel.lens.font .~ .ksr_body()
      |> UILabel.lens.numberOfLines .~ 2
      |> UILabel.lens.text %~ { _ in Strings.Delete_my_Kickstarter_Account() }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.notifyDeleteAccountTapped
      .observeForControllerAction()
      .observeValues { [weak self] url in
        self?.delegate?.goToDeleteAccount(url: url)
    }
  }

  @IBAction func tappedDeleteButton(_ sender: Any) {
    self.viewModel.inputs.deleteAccountTapped()
  }
}
