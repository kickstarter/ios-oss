import KsApi
import Library
import Prelude
import ReactiveExtensions
import ReactiveSwift
import UIKit

internal protocol SettingsPrivacyDeleteOrRequestCellDelegate: AnyObject {
  func settingsPrivacyDeleteOrRequestCellTapped(_ cell: SettingsPrivacyDeleteOrRequestCell, with url: URL)
}

internal final class SettingsPrivacyDeleteOrRequestCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: SettingsDeleteOrRequestCellViewModelType = SettingsDeleteOrRequestCellViewModel()
  internal weak var delegate: SettingsPrivacyDeleteOrRequestCellDelegate?

  internal enum CellType {
    case delete
    case request
  }

  @IBOutlet fileprivate var deleteAccountButton: UIButton!
  @IBOutlet fileprivate var deleteAccountLabel: UILabel!
  @IBOutlet fileprivate var separatorView: [UIView]!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    _ = self
      |> \.accessibilityElements .~ [self.deleteAccountButton].compact()

    self.deleteAccountButton.addTarget(self, action: #selector(self.deleteAccountTapped), for: .touchUpInside)
  }

  internal func configureWith(value: (user: User, cellType: CellType)) {
    self.viewModel.inputs.configureWith(user: value.user)

    switch value.cellType {
    case .request:
      self.deleteAccountLabel.textColor = .ksr_support_700
      self.deleteAccountLabel.text = Strings.Request_my_personal_data()
      self.deleteAccountButton.accessibilityLabel = Strings.Request_my_personal_data()
    case .delete:
      self.deleteAccountLabel.textColor = .ksr_alert
      self.deleteAccountLabel.text = Strings.Delete_my_Kickstarter_Account()
      self.deleteAccountButton.accessibilityLabel = Strings.Delete_my_Kickstarter_Account()
    }
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
      |> UILabel.lens.font .~ .ksr_body()
      |> UILabel.lens.numberOfLines .~ 2
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.notifyDeleteAccountTapped
      .observeForUI()
      .observeValues { [weak self] url in
        guard let _self = self else { return }
        self?.delegate?.settingsPrivacyDeleteOrRequestCellTapped(_self, with: url)
      }
  }

  @objc fileprivate func deleteAccountTapped() {
    self.viewModel.inputs.deleteAccountTapped()
  }
}
