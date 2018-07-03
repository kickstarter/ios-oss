import KsApi
import Library
import Prelude
import UIKit

internal final class SettingsNotificationsViewController: UIViewController {

  private let viewModel: SettingsViewModelType = SettingsViewModel()

  @IBOutlet fileprivate weak var findFriendsButton: UIButton!
  @IBOutlet fileprivate weak var findFriendsLabel: UILabel!
  @IBOutlet fileprivate weak var followerButton: UIButton!
  @IBOutlet fileprivate weak var friendActivityButton: UIButton!
  @IBOutlet fileprivate weak var friendActivityLabel: UILabel!
  @IBOutlet fileprivate weak var messagesLabel: UILabel!
  @IBOutlet fileprivate weak var messagesButton: UIButton!
  @IBOutlet fileprivate weak var mobileFollowerButton: UIButton!
  @IBOutlet fileprivate weak var mobileFriendActivityButton: UIButton!
  @IBOutlet fileprivate weak var mobileMessagesButton: UIButton!
  @IBOutlet fileprivate weak var newFollowersLabel: UILabel!
  @IBOutlet fileprivate weak var manageProjectNotificationsButton: UIButton!
  @IBOutlet fileprivate weak var manageProjectNotificationsLabel: UILabel!
  @IBOutlet fileprivate weak var mobileUpdatesButton: UIButton!

  @IBOutlet fileprivate weak var projectNotificationsCountView: CountBadgeView!
  @IBOutlet fileprivate weak var projectsYouBackTitleLabel: UILabel!
  @IBOutlet fileprivate weak var projectUpdatesLabel: UILabel!
  @IBOutlet fileprivate weak var socialNotificationsTitleLabel: UILabel!
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

    self.findFriendsButton.addTarget(self,
                                                    action: #selector(findFriendsTapped),
                                                    for: .touchUpInside)

   self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
      |> UIViewController.lens.title %~ { _ in Strings.Push_notifications() }

    _ = self.emailNotificationButtons
      ||> settingsNotificationIconButtonStyle
      ||> UIButton.lens.image(for: .normal)
      .~ UIImage(named: "email-icon", in: .framework, compatibleWith: nil)
      ||> UIButton.lens.image(for: .selected)
      .~ image(named: "email-icon", tintColor: .ksr_green_700, inBundle: Bundle.framework)
      ||> UIButton.lens.accessibilityLabel %~ { _ in Strings.Email_notifications() }

    _ = self.findFriendsButton
      |> settingsSectionButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.profile_settings_social_find_friends() }

    _ = self.findFriendsLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_social_find_friends() }

    _ = self.friendActivityLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_social_friend_backs() }

    _ = self.manageProjectNotificationsLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_backer_notifications() }

    _ = self.manageProjectNotificationsButton
      |> settingsSectionButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.profile_settings_backer_notifications() }

    _ = self.newFollowersLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_social_followers() }

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

    _ = self.socialNotificationsTitleLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_social_title() }

  }

  @IBAction fileprivate func emailProjectUpdates(_ button: UIButton) {
    self.viewModel.inputs.emailProjectUpdates(selected: !button.isSelected)
  }

  @IBAction fileprivate func mobileUpdatesTapped(_ sender: UIButton) {
    self.viewModel.inputs.mobileUpdatesTapped(selected: !sender.isSelected)
  }

  @IBAction func emailNewFollowersTapped(_ sender: UIButton) {
    self.viewModel.inputs.emailNewFollowersTapped(selected: !sender.isSelected)
  }

  @IBAction func mobileNewFollowersTapped(_ sender: UIButton) {
    self.viewModel.inputs.mobileNewFollowersSelected(selected: !sender.isSelected)
  }
  
  @IBAction func emailFriendsActivityTapped(_ sender: UIButton) {
    self.viewModel.inputs.emailFriendActivityTapped(selected: !sender.isSelected)
  }

  @IBAction func mobileFriendsActivityTapped(_ sender: UIButton) {
    self.viewModel.inputs.mobileFriendsActivityTapped(selected: !sender.isSelected)
  }

  @objc fileprivate func findFriendsTapped() {
    self.viewModel.inputs.findFriendsTapped()
  }

  @objc fileprivate func manageProjectNotificationsTapped() {
    self.viewModel.inputs.manageProjectNotificationsTapped()
  }
}
