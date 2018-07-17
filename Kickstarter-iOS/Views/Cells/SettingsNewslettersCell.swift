import KsApi
import Library
import Prelude
import UIKit

internal protocol SettingsNewslettersCellDelegate: class {
  func shouldShowOptInAlert(_ newsletterName: String)
}

internal final class SettingsNewslettersCell: UITableViewCell, ValueCell {

  private let viewModel: SettingsNewslettersCellViewModelType = SettingsNewsletterCellViewModel()

  @IBOutlet fileprivate weak var newslettersDescriptionLabel: UILabel!
  @IBOutlet fileprivate weak var newslettersLabel: UILabel!
  @IBOutlet fileprivate weak var newslettersSwitch: UISwitch!

  public weak var delegate: SettingsNewslettersCellDelegate?

  func configureWith(value: Newsletter) {

    self.viewModel.inputs.configureWith(value: value)

    _ = self.newslettersLabel
      |> UILabel.lens.text %~ { _ in value.displayableName }

    _ = self.newslettersDescriptionLabel
      |> UILabel.lens.text %~ { _ in value.displayableDescription }
  }

  override func awakeFromNib() {
      super.awakeFromNib()
  }

  override func bindStyles() {

    _ = self.newslettersDescriptionLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.font .~ .ksr_body(size: 13)

    _ = self.newslettersLabel
      |> settingsSectionLabelStyle

    _ = self.newslettersSwitch
      |> UISwitch.lens.onTintColor .~ .ksr_green_800
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.newslettersSwitch.rac.on = self.viewModel.outputs.switchIsOn

    self.viewModel.outputs.showOptInPrompt
      .observeForControllerAction()
      .observeValues { [weak self] newsletter in self?.showOptInPrompt(newsletter) }
  }

  fileprivate func showOptInPrompt(_ newsletter: String) {
    self.delegate?.shouldShowOptInAlert(newsletter)
  }

  @IBAction func newslettersSwitchTapped(_ sender: UISwitch) {
    self.viewModel.inputs.newslettersSwitchTapped(on: sender.isOn)
  }
}
