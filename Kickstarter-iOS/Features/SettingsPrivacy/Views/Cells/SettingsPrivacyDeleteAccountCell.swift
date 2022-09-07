import KsApi
import Library
import Prelude
import ReactiveExtensions
import ReactiveSwift
import UIKit

internal protocol SettingsPrivacyDeleteAccountCellDelegate: AnyObject {
  func settingsPrivacyDeleteAccountCellTapped(_ cell: SettingsPrivacyDeleteAccountCell, with url: URL)
}

internal final class SettingsPrivacyDeleteAccountCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: SettingsDeleteAccountCellViewModelType = SettingsDeleteAccountCellViewModel()
  internal weak var delegate: SettingsPrivacyDeleteAccountCellDelegate?

  @IBOutlet fileprivate var deleteAccountButton: UIButton!
  @IBOutlet fileprivate var deleteAccountLabel: UILabel!
  @IBOutlet fileprivate var separatorView: [UIView]!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    _ = self
      |> \.accessibilityElements .~ [self.deleteAccountButton].compact()

    _ = self.deleteAccountButton
      |> \.accessibilityLabel %~ { _ in Strings.Delete_my_Kickstarter_Account() }

    self.deleteAccountButton.addTarget(self, action: #selector(self.deleteAccountTapped), for: .touchUpInside)
  }

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

    _ = self.deleteAccountLabel
      |> UILabel.lens.textColor .~ .ksr_alert
      |> UILabel.lens.font .~ .ksr_body()
      |> UILabel.lens.numberOfLines .~ 2
      |> UILabel.lens.text %~ { _ in Strings.Delete_my_Kickstarter_Account() }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.notifyDeleteAccountTapped
      .observeForUI()
      .observeValues { [weak self] url in
        guard let _self = self else { return }
        self?.delegate?.settingsPrivacyDeleteAccountCellTapped(_self, with: url)
      }
  }

  @objc fileprivate func deleteAccountTapped() {
    self.viewModel.inputs.deleteAccountTapped()
  }
}
