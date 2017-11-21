import KsApi
import Library
import Prelude
import UIKit

internal final class CreatorDigestSettingsViewController: UIViewController {
  fileprivate let viewModel: CreatorDigestSettingsViewModelType = CreatorDigestSettingsViewModel()

  @IBOutlet fileprivate var separatorViews: [UIView]!
  @IBOutlet fileprivate weak var individualEmailsLabel: UILabel!
  @IBOutlet fileprivate weak var individualEmailsSwitch: UISwitch!
  @IBOutlet fileprivate weak var dailyDigestLabel: UILabel!
  @IBOutlet fileprivate weak var dailyDigestSwitch: UISwitch!

  internal static func configureWith(user: User) -> CreatorDigestSettingsViewController {
    let vc = Storyboard.Settings.instantiate(CreatorDigestSettingsViewController.self)
    vc.viewModel.inputs.configureWith(user: user)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.viewModel.inputs.viewDidLoad()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.separatorViews
      ||> separatorStyle

    _ = self.individualEmailsLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Individual_Emails() }

    _ = self.dailyDigestLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Daily_digest() }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.updateCurrentUser
      .observeForUI()
      .observeValues { user in AppEnvironment.updateCurrentUser(user) }

    self.viewModel.outputs.unableToSaveError
      .observeForControllerAction()
      .observeValues { [weak self] message in
        self?.present(UIAlertController.genericError(message), animated: true, completion: nil)
    }

    self.dailyDigestSwitch.rac.on = self.viewModel.outputs.dailyDigestSelected
    self.individualEmailsSwitch.rac.on = self.viewModel.outputs.individualEmailSelected
  }

  @IBAction func individualEmailsTapped(_ notificationSwitch: UISwitch) {
    self.viewModel.inputs.individualEmailsTapped(on: notificationSwitch.isOn)
  }

  @IBAction fileprivate func dailyDigestTapped(_ notificationSwitch: UISwitch) {
    self.viewModel.inputs.dailyDigestTapped(on: notificationSwitch.isOn)
  }
}
