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

  internal static func instantiate() -> CreatorDigestSettingsViewController {
    return Storyboard.Settings.instantiate(CreatorDigestSettingsViewController.self)
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
      |> UILabel.lens.text .~ Strings.Individual_Emails()

    _ = self.dailyDigestLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text .~ Strings.Daily_digest()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.dailyDigestSwitch.rac.on = self.viewModel.outputs.dailyDigestSelected
    self.individualEmailsSwitch.rac.on = self.viewModel.outputs.individualEmailSelected
  }

  @IBAction fileprivate func individualEmailsTapped(_ individualEmailSwitch: UISwitch) {
    self.viewModel.inputs.individualEmailsTapped(on: individualEmailsSwitch.isOn)
  }

  @IBAction fileprivate func dailyDigestTapped(_ digestSwitch: UISwitch) {
    self.viewModel.inputs.dailyDigestTapped(on: digestSwitch.isOn)
  }
}
