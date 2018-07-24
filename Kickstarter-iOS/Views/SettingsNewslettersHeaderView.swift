import Library
import Prelude
import UIKit

protocol SettingsNewslettersHeaderViewDelegate: class {
  func didChangeNewslettersSetting(_ isOn: Bool)
}

final internal class SettingsNewslettersHeaderView: UITableViewHeaderFooterView {

  let viewModel: SettingsNewslettersCellViewModelType = SettingsNewsletterCellViewModel()

  @IBOutlet fileprivate weak var descriptionLabel: UILabel!
  @IBOutlet fileprivate weak var newsletterSwitch: UISwitch!
  @IBOutlet fileprivate weak var titleLabel: UILabel!
  @IBOutlet fileprivate var separatorViews: [UIView]!

  public weak var delegate: SettingsNewslettersHeaderViewDelegate?

  override func awakeFromNib() {
    super.awakeFromNib()
    self.viewModel.inputs.awakeFromNib()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.descriptionLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.font .~ .ksr_body(size: 13)
      |> UILabel.lens.numberOfLines .~ 0
      |> UILabel.lens.text %~ { _ in
        Strings.Sign_up_newsletter()
    }

    _ = self.newsletterSwitch
      |> UISwitch.lens.onTintColor .~ .ksr_green_800

    _ = self.separatorViews
      ||> separatorStyle

    _ = self.titleLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_newsletter_subscribe_all() }
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.updateCurrentUser
      .observeForUI()
      .observeValues { user in
        AppEnvironment.updateCurrentUser(user)
    }

    self.newsletterSwitch.rac.on = self.viewModel.outputs.subscribeToAllSwitchIsOn.skipNil()
  }

  @IBAction func newsletterSwitchTapped(_ sender: UISwitch) {
    self.viewModel.inputs.allNewslettersSwitchTapped(on: sender.isOn)
  }
}
