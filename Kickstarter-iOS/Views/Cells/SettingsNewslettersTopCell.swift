import KsApi
import Library
import Prelude
import UIKit

protocol SettingsNewslettersTopCellDelegate: class {
  func didUpdateAllNewsletters(user: User)
  func failedToUpdateAllNewsletters(_ message: String)
}

final internal class SettingsNewslettersTopCell: UITableViewCell, ValueCell {

  private let viewModel: SettingsNewslettersCellViewModelType = SettingsNewsletterCellViewModel()

  @IBOutlet fileprivate weak var descriptionLabel: UILabel!
  @IBOutlet fileprivate weak var newsletterSwitch: UISwitch!
  @IBOutlet fileprivate weak var titleLabel: UILabel!

  @IBOutlet fileprivate var separatorViews: [UIView]!

  public weak var delegate: SettingsNewslettersTopCellDelegate?

  override func awakeFromNib() {
    super.awakeFromNib()

    _ = self
      |> \.accessibilityElements .~ [self.newsletterSwitch]

    _ = self.descriptionLabel
      |> \.text %~ { _ in Strings.Stay_up_to_date_newsletter() }

    _ = self.newsletterSwitch
      |> \.accessibilityLabel %~ { _ in Strings.profile_settings_newsletter_subscribe_all() }
      |> \.accessibilityHint %~ { _ in Strings.Stay_up_to_date_newsletter() }

    _ = self.titleLabel
      |> \.text %~ { _ in Strings.profile_settings_newsletter_subscribe_all() }
  }

  func configureWith(value: User) {
    self.viewModel.inputs.configureWith(value: value)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.descriptionLabel
      |> settingsDescriptionLabelStyle

    _ = self.newsletterSwitch
      |> settingsSwitchStyle

    _ = self.separatorViews
      ||> separatorStyle

    _ = self.titleLabel
      |> settingsTitleLabelStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.updateCurrentUser
      .observeForUI()
      .observeValues { [weak self] in
         self?.delegate?.didUpdateAllNewsletters(user: $0)
    }

    self.viewModel.outputs.unableToSaveError
      .observeForUI()
      .observeValues { [weak self] in
        self?.delegate?.failedToUpdateAllNewsletters($0)
    }

    self.newsletterSwitch.rac.on = self.viewModel.outputs.subscribeToAllSwitchIsOn.skipNil()
  }

  @IBAction func newsletterSwitchTapped(_ sender: UISwitch) {
    self.viewModel.inputs.allNewslettersSwitchTapped(on: sender.isOn)
  }
}
