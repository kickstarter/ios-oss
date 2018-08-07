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

  func configureWith(value: (newsletter: Newsletter, user: User)) {

    self.viewModel.inputs.configureWith(value: value)

    _ = self.newslettersLabel
      |> UILabel.lens.text %~ { _ in value.newsletter.displayableName }

    _ = self.newslettersDescriptionLabel
      |> UILabel.lens.text %~ { _ in value.newsletter.displayableDescription }
  }

  override func bindStyles() {

    _ = self.separatorViews
      ||> separatorStyle

    _ = self.newslettersDescriptionLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.font .~ .ksr_body(size: 13)
      |> UILabel.lens.numberOfLines .~ 0
      |> UILabel.lens.textColor .~ .ksr_dark_grey_400

    _ = self.newslettersLabel
      |> settingsSectionLabelStyle

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
