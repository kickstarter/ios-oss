import KsApi
import Library
import Prelude
import UIKit

internal final class CreatorDigestSettingsViewController: UIViewController {
  fileprivate let viewModel: CreatorDigestSettingsViewModelType = CreatorDigestSettingsViewModel()
  @IBOutlet fileprivate var separatorViews: [UIView]!
  @IBOutlet fileprivate weak var individualEmailsLabel: UILabel!
  @IBOutlet fileprivate weak var dailyDigestLabel: UILabel!

  internal static func instantiate() -> CreatorDigestSettingsViewController {
    return Storyboard.Settings.instantiate(CreatorDigestSettingsViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()
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

  }
}
