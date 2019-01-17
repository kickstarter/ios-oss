import KsApi
import Library
import Prelude
import UIKit

internal protocol SettingsNewslettersCellDelegate: class {
  func didUpdate(user: User)
  func failedToUpdateUser(_ message: String)
  func shouldShowOptInAlert(_ newsletterName: String)
}

internal final class SettingsNewslettersCell: UITableViewCell, ValueCell {

  private let viewModel: SettingsNewslettersCellViewModelType = SettingsNewsletterCellViewModel()

  @IBOutlet fileprivate weak var newslettersDescriptionLabel: UILabel!
  @IBOutlet fileprivate weak var newslettersLabel: UILabel!
  @IBOutlet fileprivate weak var newslettersSwitch: UISwitch!
  @IBOutlet fileprivate var separatorViews: [UIView]!

  public weak var delegate: SettingsNewslettersCellDelegate?

  override func awakeFromNib() {
    super.awakeFromNib()

    _ = self
      |> \.accessibilityElements .~ [self.newslettersSwitch]
  }

  func configureWith(value: (newsletter: Newsletter, user: User)) {
    self.viewModel.inputs.configureWith(value: value)

    _ = self.newslettersSwitch
      |> \.accessibilityLabel .~ value.newsletter.displayableName
      |> \.accessibilityHint .~ value.newsletter.displayableDescription

    _ = self.newslettersLabel
      |> \.text .~ value.newsletter.displayableName

    _ = self.newslettersDescriptionLabel
      |> \.text .~ value.newsletter.displayableDescription
  }

  override func bindStyles() {
    _ = self.separatorViews
      ||> separatorStyle

    _ = self.newslettersDescriptionLabel
      |> settingsDescriptionLabelStyle

    _ = self.newslettersLabel
      |> settingsTitleLabelStyle

    _ = self.newslettersSwitch
      |> settingsSwitchStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.newslettersSwitch.rac.on = self.viewModel.outputs.switchIsOn.skipNil()

    self.viewModel.outputs.showOptInPrompt
      .observeForControllerAction()
      .observeValues { [weak self] newsletter in
        self?.delegate?.shouldShowOptInAlert(newsletter)
    }

    self.viewModel.outputs.unableToSaveError
      .observeForUI()
      .observeValues { [weak self] in
        self?.delegate?.failedToUpdateUser($0)
    }

    self.viewModel.outputs.updateCurrentUser
      .observeForUI()
      .observeValues { [weak self] in
        self?.delegate?.didUpdate(user: $0)
    }
  }

  @IBAction func newslettersSwitchTapped(_ sender: UISwitch) {
    self.viewModel.inputs.newslettersSwitchTapped(on: sender.isOn)
  }
}
