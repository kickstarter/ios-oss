import KsApi
import Library
import Prelude
import UIKit

internal final class SettingsNotificationsViewController: UIViewController {

  
  @IBOutlet fileprivate weak var manageProjectNotificationsButton: UIButton!
  @IBOutlet fileprivate weak var manageProjectNotificationsLabel: UILabel!
  @IBOutlet fileprivate weak var mobileUpdatesButton: UIButton!

  @IBOutlet fileprivate weak var projectNotificationsCountView: CountBadgeView!
  @IBOutlet fileprivate weak var projectsYouBackTitleLabel: UILabel!
  @IBOutlet fileprivate weak var projectUpdatesLabel: UILabel!

  @IBOutlet fileprivate weak var updatesButton: UIButton!

  @IBOutlet fileprivate var emailNotificationButtons: [UIButton]!
  @IBOutlet fileprivate var pushNotificationButtons: [UIButton]!
  @IBOutlet fileprivate var separatorViews: [UIView]!

  internal static func instantiate() -> SettingsNotificationsViewController {
    return Storyboard.SettingsNotifications.instantiate(SettingsNotificationsViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.manageProjectNotificationsButton.addTarget(self,
                                                    action: #selector(manageProjectNotificationsTapped),
                                                    for: .touchUpInside)
   // self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
      |> UIViewController.lens.title %~ { _ in Strings.profile_settings_navbar_title() }

    _ = self.emailNotificationButtons
      ||> settingsNotificationIconButtonStyle
      ||> UIButton.lens.image(for: .normal)
      .~ UIImage(named: "email-icon", in: .framework, compatibleWith: nil)
      ||> UIButton.lens.image(for: .selected)
      .~ image(named: "email-icon", tintColor: .ksr_green_700, inBundle: Bundle.framework)
      ||> UIButton.lens.accessibilityLabel %~ { _ in Strings.Email_notifications() }

    _ = self.manageProjectNotificationsLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_backer_notifications() }

    _ = self.projectUpdatesLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_backer_project_updates() }

    _ = self.projectsYouBackTitleLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Projects_youve_backed() }

    _ = self.pushNotificationButtons
      ||> settingsNotificationIconButtonStyle
      ||> UIButton.lens.image(for: .normal)
      .~ UIImage(named: "mobile-icon", in: .framework, compatibleWith: nil)
      ||> UIButton.lens.image(for: .selected)
      .~ image(named: "mobile-icon", tintColor: .ksr_green_700, inBundle: Bundle.framework)
      ||> UIButton.lens.accessibilityLabel %~ { _ in Strings.Push_notifications() }

    _ = self.separatorViews
      ||> separatorStyle
  }

  @IBAction fileprivate func updatesTapped(_ button: UIButton) {
    //self.viewModel.inputs.updatesTapped(selected: !button.isSelected)
  }

  @objc fileprivate func manageProjectNotificationsTapped() {
    //self.viewModel.inputs.manageProjectNotificationsTapped()
  }

}
