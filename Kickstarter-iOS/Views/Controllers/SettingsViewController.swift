import KsApi
import Library
import MessageUI
import Prelude
import SafariServices
import UIKit

// swiftlint:disable file_length
// swiftlint:disable type_body_length
internal final class SettingsViewController: UIViewController {
  fileprivate let viewModel: SettingsViewModelType = SettingsViewModel()
  fileprivate let helpViewModel: HelpViewModelType = HelpViewModel()

  @IBOutlet fileprivate weak var backingsButton: UIButton!
  @IBOutlet fileprivate weak var betaDebugPushNotificationsButton: UIButton!
  @IBOutlet fileprivate weak var betaFeedbackButton: UIButton!
  @IBOutlet fileprivate weak var betaTitleLabel: UILabel!
  @IBOutlet fileprivate weak var betaToolsStackView: UIStackView!
  @IBOutlet fileprivate weak var commentsButton: UIButton!
  @IBOutlet fileprivate weak var contactButton: UIButton!
  @IBOutlet fileprivate weak var contactLabel: UILabel!
  @IBOutlet fileprivate weak var cookiePolicyButton: UIButton!
  @IBOutlet fileprivate weak var cookiePolicyLabel: UILabel!
  @IBOutlet fileprivate weak var creatorNotificationsTitleLabel: UILabel!
  @IBOutlet fileprivate weak var creatorStackView: UIStackView!
  @IBOutlet fileprivate weak var faqButton: UIButton!
  @IBOutlet fileprivate weak var faqLabel: UILabel!
  @IBOutlet fileprivate weak var findFriendsButton: UIButton!
  @IBOutlet fileprivate weak var findFriendsLabel: UILabel!
  @IBOutlet fileprivate weak var followerButton: UIButton!
  @IBOutlet fileprivate weak var friendActivityButton: UIButton!
  @IBOutlet fileprivate weak var friendActivityLabel: UILabel!
  @IBOutlet fileprivate weak var gamesNewsletterSwitch: UISwitch!
  @IBOutlet fileprivate weak var happeningNewsletterSwitch: UISwitch!
  @IBOutlet fileprivate weak var happeningNowLabel: UILabel!
  @IBOutlet fileprivate weak var helpTitleLabel: UILabel!
  @IBOutlet fileprivate weak var howKsrWorksButton: UIButton!
  @IBOutlet fileprivate weak var howKsrWorksLabel: UILabel!
  @IBOutlet fileprivate weak var ksrLovesGamesLabel: UILabel!
  @IBOutlet fileprivate weak var ksrNewsAndEventsLabel: UILabel!
  @IBOutlet fileprivate weak var logoutButton: UIButton!
  @IBOutlet fileprivate weak var manageProjectNotificationsButton: UIButton!
  @IBOutlet fileprivate weak var manageProjectNotificationsLabel: UILabel!
  @IBOutlet fileprivate weak var mobileBackingsButton: UIButton!
  @IBOutlet fileprivate weak var mobileCommentsButton: UIButton!
  @IBOutlet fileprivate weak var mobileFollowerButton: UIButton!
  @IBOutlet fileprivate weak var mobileFriendActivityButton: UIButton!
  @IBOutlet fileprivate weak var mobilePostLikesButton: UIButton!
  @IBOutlet fileprivate weak var mobileUpdatesButton: UIButton!
  @IBOutlet fileprivate weak var newCommentsLabel: UILabel!
  @IBOutlet fileprivate weak var newFollowersLabel: UILabel!
  @IBOutlet fileprivate weak var newLikesLabel: UILabel!
  @IBOutlet fileprivate weak var newPledgesLabel: UILabel!
  @IBOutlet fileprivate weak var newslettersTitleLabel: UILabel!
  @IBOutlet fileprivate weak var postLikesButton: UIButton!
  @IBOutlet fileprivate weak var privacyPolicyButton: UIButton!
  @IBOutlet fileprivate weak var privacyPolicyLabel: UILabel!
  @IBOutlet fileprivate weak var projectNotificationsCountView: CountBadgeView!
  @IBOutlet fileprivate weak var projectUpdatesLabel: UILabel!
  @IBOutlet fileprivate weak var projectsWeLoveLabel: UILabel!
  @IBOutlet fileprivate weak var projectsYouBackTitleLabel: UILabel!
  @IBOutlet fileprivate weak var promoNewsletterSwitch: UISwitch!
  @IBOutlet fileprivate weak var rateUsButton: UIButton!
  @IBOutlet fileprivate weak var rateUsLabel: UILabel!
  @IBOutlet fileprivate weak var socialNotificationsTitleLabel: UILabel!
  @IBOutlet fileprivate weak var termsOfUseButton: UIButton!
  @IBOutlet fileprivate weak var termsOfUseLabel: UILabel!
  @IBOutlet fileprivate weak var updatesButton: UIButton!
  @IBOutlet fileprivate weak var weeklyNewsletterSwitch: UISwitch!
  @IBOutlet fileprivate weak var wereAllEarsTitleLabel: UILabel!
  @IBOutlet fileprivate weak var versionLabel: UILabel!

  @IBOutlet fileprivate var emailNotificationButtons: [UIButton]!
  @IBOutlet fileprivate var pushNotificationButtons: [UIButton]!
  @IBOutlet fileprivate var separatorViews: [UIView]!

  internal static func instantiate() -> SettingsViewController {
    return Storyboard.Settings.instantiate(SettingsViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.helpViewModel.inputs.configureWith(helpContext: .settings)
    self.helpViewModel.inputs.canSendEmail(MFMailComposeViewController.canSendMail())

    if let _ = self.presentingViewController {
      self.navigationItem.leftBarButtonItem = .close(self, selector: #selector(closeButtonPressed))
    }

    self.betaFeedbackButton.addTarget(self,
                                      action: #selector(betaFeedbackButtonTapped),
                                      for: .touchUpInside)

    self.betaDebugPushNotificationsButton.addTarget(self,
                                                    action: #selector(betaDebugPushNotificationsButtonTapped),
                                                    for: .touchUpInside)

    self.contactButton.addTarget(self, action: #selector(contactTapped), for: .touchUpInside)

    self.cookiePolicyButton.addTarget(self,
                                      action: #selector(cookiePolicyTapped),
                                      for: .touchUpInside)

    self.faqButton.addTarget(self, action: #selector(faqTapped), for: .touchUpInside)

    self.findFriendsButton.addTarget(self,
                                     action: #selector(findFriendsTapped),
                                     for: .touchUpInside)

    self.howKsrWorksButton.addTarget(self,
                                     action: #selector(howKickstarterWorksTapped),
                                     for: .touchUpInside)

    self.logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)

    self.manageProjectNotificationsButton.addTarget(self,
                                                    action: #selector(manageProjectNotificationsTapped),
                                                    for: .touchUpInside)

    self.termsOfUseButton.addTarget(self,
                                    action: #selector(termsOfUseTapped),
                                    for: .touchUpInside)

    self.privacyPolicyButton.addTarget(self,
                                       action: #selector(privacyPolicyTapped),
                                       for: .touchUpInside)

    self.rateUsButton.addTarget(self, action: #selector(rateUsTapped), for: .touchUpInside)

    self.viewModel.inputs.viewDidLoad()
  }

  // swiftlint:disable function_body_length
  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
      |> UIViewController.lens.title %~ { _ in Strings.profile_settings_navbar_title() }

    _ = self.betaDebugPushNotificationsButton
      |> UIButton.lens.titleColor(forState: .normal) .~ .ksr_text_navy_700
      |> UIButton.lens.titleLabel.font .~ .ksr_body()
      |> UIButton.lens.contentHorizontalAlignment .~ .left

    _ = self.betaFeedbackButton
      |> greenButtonStyle
      |> UIButton.lens.title(forState: .normal) .~ "Submit feedback for beta"

    _ = self.betaTitleLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text .~ "Beta tools"

    _ = self.contactButton
      |> settingsSectionButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.profile_settings_about_contact() }
      |> UIButton.lens.accessibilityHint %~ { _ in Strings.Opens_email_composer() }

    _ = self.contactLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_about_contact() }

    _ = self.cookiePolicyButton
      |> settingsSectionButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.profile_settings_about_cookie() }

    _ = self.cookiePolicyLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_about_cookie() }

    _ = self.creatorNotificationsTitleLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_creator_title() }

    _ = self.emailNotificationButtons
      ||> settingsNotificationIconButtonStyle
      ||> UIButton.lens.image(forState: .normal)
        .~ UIImage(named: "email-icon", in: .framework, compatibleWith: nil)
      ||> UIButton.lens.image(forState: .selected)
        .~ image(named: "email-icon", tintColor: .ksr_green_400, inBundle: Bundle.framework)
      ||> UIButton.lens.accessibilityLabel %~ { _ in Strings.Email_notifications() }

    _ = self.faqButton
      |> settingsSectionButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.profile_settings_about_faq() }

    _ = self.faqLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_about_faq() }

    _ = self.findFriendsButton
      |> settingsSectionButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.profile_settings_social_find_friends() }

    _ = self.findFriendsLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_social_find_friends() }

    _ = self.friendActivityLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_social_friend_backs() }

    _ = self.happeningNowLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_newsletter_happening() }

    _ = self.helpTitleLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_about_title() }

    _ = self.howKsrWorksButton
      |> settingsSectionButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.profile_settings_about_how_it_works() }

    _ = self.howKsrWorksLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_about_how_it_works() }

    _ = self.ksrLovesGamesLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_newsletter_games() }

    _ = self.ksrNewsAndEventsLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_newsletter_promo() }

    _ = self.logoutButton |> settingsLogoutButtonStyle

    _ = self.manageProjectNotificationsButton
      |> settingsSectionButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.profile_settings_backer_notifications() }

    _ = self.manageProjectNotificationsLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_backer_notifications() }

    _ = self.newCommentsLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_creator_comments() }

    _ = self.newFollowersLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_social_followers() }

    _ = self.newLikesLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_creator_likes() }

    _ = self.newPledgesLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_creator_pledges() }

    _ = self.newslettersTitleLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_newsletter_title() }

    _ = self.privacyPolicyButton
      |> settingsSectionButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.profile_settings_about_privacy() }

    _ = self.privacyPolicyLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_about_privacy() }

    _ = self.projectUpdatesLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_backer_project_updates() }

    _ = self.projectsWeLoveLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_newsletter_weekly() }

    _ = self.projectsYouBackTitleLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_backer_title() }

    _ = self.pushNotificationButtons
      ||> settingsNotificationIconButtonStyle
      ||> UIButton.lens.image(forState: .normal)
        .~ UIImage(named: "phone-icon", in: .framework, compatibleWith: nil)
      ||> UIButton.lens.image(forState: .selected)
        .~ image(named: "phone-icon", tintColor: .ksr_green_400, inBundle: Bundle.framework)
      ||> UIButton.lens.accessibilityLabel %~ { _ in Strings.Push_notifications() }

    _ = self.rateUsButton
      |> settingsSectionButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.profile_settings_rating_rate_us() }

    _ = self.rateUsLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_rating_rate_us() }

    _ = self.separatorViews
      ||> separatorStyle

    _ = self.socialNotificationsTitleLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_social_title() }

    _ = self.termsOfUseButton
      |> settingsSectionButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.profile_settings_about_terms() }

    _ = self.termsOfUseLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_about_terms() }

    _ = self.versionLabel
      |> UILabel.lens.textColor .~ .ksr_navy_600
      |> UILabel.lens.font .~ .ksr_caption1()
      |> UILabel.lens.numberOfLines .~ 0

    _ = self.wereAllEarsTitleLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_rating_title() }
  }
  // swiftlint:enable function_body_length

  // swiftlint:disable function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.goToAppStoreRating
      .observeForControllerAction()
      .observeValues { [weak self] link in self?.goToAppStore(link: link) }

    self.viewModel.outputs.goToManageProjectNotifications
      .observeForControllerAction()
      .observeValues { [weak self] _ in self?.goToManageProjectNotifications() }

    self.viewModel.outputs.logoutWithParams
      .observeForControllerAction()
      .observeValues { [weak self] in self?.logout(params: $0) }

    self.viewModel.outputs.showConfirmLogoutPrompt
      .observeForControllerAction()
      .observeValues { [weak self] (message, cancel, confirm) in
        self?.showLogoutPrompt(message: message, cancel: cancel, confirm: confirm)
    }

    self.viewModel.outputs.showOptInPrompt
      .observeForControllerAction()
      .observeValues { [weak self] newsletter in self?.showOptInPrompt(newsletter) }

    self.viewModel.outputs.unableToSaveError
      .observeForControllerAction()
      .observeValues { [weak self] message in
        self?.present(UIAlertController.genericError(message), animated: true, completion: nil)
    }

    self.viewModel.outputs.updateCurrentUser
      .observeForUI()
      .observeValues { user in AppEnvironment.updateCurrentUser(user) }

    self.viewModel.outputs.goToFindFriends
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.goToFindFriends()
    }

    self.viewModel.outputs.goToBetaFeedback
      .observeForControllerAction()
      .observeValues { [weak self] in self?.goToBetaFeedback() }

    self.helpViewModel.outputs.showMailCompose
      .observeForControllerAction()
      .observeValues { [weak self] in
        guard let _self = self else { return }
        let controller = MFMailComposeViewController.support()
        controller.mailComposeDelegate = _self
        _self.present(controller, animated: true, completion: nil)
    }

    self.helpViewModel.outputs.showNoEmailError
      .observeForControllerAction()
      .observeValues { [weak self] alert in
        self?.present(alert, animated: true, completion: nil)
    }

    self.helpViewModel.outputs.showWebHelp
      .observeForControllerAction()
      .observeValues { [weak self] helpType in
        self?.goToHelpType(helpType)
    }

    self.backingsButton.rac.selected = self.viewModel.outputs.backingsSelected
    self.betaToolsStackView.rac.hidden = self.viewModel.outputs.betaToolsHidden
    self.commentsButton.rac.selected = self.viewModel.outputs.commentsSelected
    self.creatorStackView.rac.hidden = self.viewModel.outputs.creatorNotificationsHidden
    self.followerButton.rac.selected = self.viewModel.outputs.followerSelected
    self.friendActivityButton.rac.selected = self.viewModel.outputs.friendActivitySelected
    self.gamesNewsletterSwitch.rac.on = self.viewModel.outputs.gamesNewsletterOn
    self.happeningNewsletterSwitch.rac.on = self.viewModel.outputs.happeningNewsletterOn
    self.manageProjectNotificationsButton.rac.accessibilityHint =
      self.viewModel.outputs.manageProjectNotificationsButtonAccessibilityHint
    self.mobileBackingsButton.rac.selected = self.viewModel.outputs.mobileBackingsSelected
    self.mobileCommentsButton.rac.selected = self.viewModel.outputs.mobileCommentsSelected
    self.mobileFollowerButton.rac.selected = self.viewModel.outputs.mobileFollowerSelected
    self.mobileFriendActivityButton.rac.selected = self.viewModel.outputs.mobileFriendActivitySelected
    self.mobilePostLikesButton.rac.selected = self.viewModel.outputs.mobilePostLikesSelected
    self.mobileUpdatesButton.rac.selected = self.viewModel.outputs.mobileUpdatesSelected
    self.postLikesButton.rac.selected = self.viewModel.outputs.postLikesSelected
    self.projectNotificationsCountView.label.rac.text = self.viewModel.outputs.projectNotificationsCount
    self.promoNewsletterSwitch.rac.on = self.viewModel.outputs.promoNewsletterOn
    self.updatesButton.rac.selected = self.viewModel.outputs.updatesSelected
    self.weeklyNewsletterSwitch.rac.on = self.viewModel.outputs.weeklyNewsletterOn
    self.versionLabel.rac.text = self.viewModel.outputs.versionText
  }
  // swiftlint:enable function_body_length

  fileprivate func goToAppStore(link: String) {
    guard let url = URL(string: link) else { return }
    UIApplication.shared.openURL(url)
  }

  fileprivate func goToBetaFeedback() {
    guard MFMailComposeViewController.canSendMail() else { return }

    let userName = AppEnvironment.current.currentUser?.name ?? "Logged out user"
    let userId = AppEnvironment.current.currentUser?.id ?? 0
    let version = AppEnvironment.current.mainBundle.version
    let shortVersion = AppEnvironment.current.mainBundle.shortVersionString
    let device = UIDevice.current

    let controller = MFMailComposeViewController()
    controller.setToRecipients([Secrets.fieldReportEmail])
    controller.setSubject("Field report: ")
    controller.setMessageBody(
      "\(userName) | \(userId) | \(version) | \(shortVersion) | " +
        "\(device.systemVersion) | \(device.modelCode)\n\n" +
        "Describe the bug here. Attach images if it helps!\n" +
        "---------------------------\n\n\n\n\n\n",
      isHTML: false
    )

    controller.mailComposeDelegate = self
    self.present(controller, animated: true, completion: nil)
  }

  fileprivate func goToFindFriends() {
    let vc = FindFriendsViewController.configuredWith(source: .settings)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  fileprivate func goToHelpType(_ helpType: HelpType) {
    let vc = HelpWebViewController.configuredWith(helpType: helpType)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  fileprivate func goToManageProjectNotifications() {
    let vc = ProjectNotificationsViewController.instantiate()
    self.navigationController?.pushViewController(vc, animated: true)
  }

  fileprivate func showLogoutPrompt(message: String, cancel: String, confirm: String) {
    let logoutAlert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

    logoutAlert.addAction(
      UIAlertAction(
        title: cancel,
        style: .cancel,
        handler: { [weak self] _ in
          self?.viewModel.inputs.logoutCanceled()
        }
      )
    )

    logoutAlert.addAction(
      UIAlertAction(
        title: confirm,
        style: .default,
        handler: { [weak self] _ in
          self?.viewModel.inputs.logoutConfirmed()
        }
      )
    )

    self.present(logoutAlert, animated: true, completion: nil)
  }

  fileprivate func logout(params: DiscoveryParams) {
    AppEnvironment.logout()

    self.view.window?.rootViewController
      .flatMap { $0 as? RootTabBarViewController }
      .doIfSome { root in
        UIView.transition(with: root.view, duration: 0.3, options: [.transitionCrossDissolve], animations: {
          root.switchToDiscovery(params: params)
          }, completion: { _ in
            NotificationCenter.default.post(.init(name: .ksr_sessionEnded))
        })
    }
  }

  fileprivate func showOptInPrompt(_ newsletter: String) {
    let optInAlert = UIAlertController.newsletterOptIn(newsletter)
    self.present(optInAlert, animated: true, completion: nil)
  }

  @objc fileprivate func logoutTapped() {
    self.viewModel.inputs.logoutTapped()
  }

  @IBAction fileprivate func backingsTapped(_ button: UIButton) {
    self.viewModel.inputs.backingsTapped(selected: !button.isSelected)
  }

  @IBAction fileprivate func commentsTapped(_ button: UIButton) {
    self.viewModel.inputs.commentsTapped(selected: !button.isSelected)
  }

  @objc fileprivate func contactTapped() {
    self.helpViewModel.inputs.helpTypeButtonTapped(.contact)
  }

  @objc fileprivate func cookiePolicyTapped() {
    self.helpViewModel.inputs.helpTypeButtonTapped(.cookie)
  }

  @objc fileprivate func faqTapped() {
    self.helpViewModel.inputs.helpTypeButtonTapped(.faq)
  }

  @objc fileprivate func findFriendsTapped() {
    self.viewModel.inputs.findFriendsTapped()
  }

  @IBAction fileprivate func followerTapped(_ button: UIButton) {
    self.viewModel.inputs.followerTapped(selected: !button.isSelected)
  }

  @IBAction fileprivate func friendActivityTapped(_ button: UIButton) {
    self.viewModel.inputs.friendActivityTapped(selected: !button.isSelected)
  }

  @IBAction fileprivate func gamesNewsletterTapped(_ newsletterSwitch: UISwitch) {
    self.viewModel.inputs.gamesNewsletterTapped(on: newsletterSwitch.isOn)
  }

  @IBAction fileprivate func happeningNewsletterTapped(_ newsletterSwitch: UISwitch) {
    self.viewModel.inputs.happeningNewsletterTapped(on: newsletterSwitch.isOn)
  }

  @objc fileprivate func howKickstarterWorksTapped() {
    self.helpViewModel.inputs.helpTypeButtonTapped(.howItWorks)
  }

  @objc fileprivate func manageProjectNotificationsTapped() {
    self.viewModel.inputs.manageProjectNotificationsTapped()
  }

  @IBAction fileprivate func mobileBackingsTapped(_ button: UIButton) {
    self.viewModel.inputs.mobileBackingsTapped(selected: !button.isSelected)
  }

  @IBAction fileprivate func mobileCommentsTapped(_ button: UIButton) {
    self.viewModel.inputs.mobileCommentsTapped(selected: !button.isSelected)
  }

  @IBAction fileprivate func mobileFollowerTapped(_ button: UIButton) {
    self.viewModel.inputs.mobileFollowerTapped(selected: !button.isSelected)
  }

  @IBAction fileprivate func mobileFriendActivityTapped(_ button: UIButton) {
    self.viewModel.inputs.mobileFriendActivityTapped(selected: !button.isSelected)
  }

  @IBAction fileprivate func mobilePostLikesTapped(_ button: UIButton) {
    self.viewModel.inputs.mobilePostLikesTapped(selected: !button.isSelected)
  }

  @IBAction fileprivate func mobileUpdatesTapped(_ button: UIButton) {
    self.viewModel.inputs.mobileUpdatesTapped(selected: !button.isSelected)
  }

  @IBAction fileprivate func postLikesTapped(_ button: UIButton) {
    self.viewModel.inputs.postLikesTapped(selected: !button.isSelected)
  }

  @objc fileprivate func privacyPolicyTapped() {
    self.helpViewModel.inputs.helpTypeButtonTapped(.privacy)
  }

  @IBAction fileprivate func promoNewsletterTapped(_ newsletterSwitch: UISwitch) {
    self.viewModel.inputs.promoNewsletterTapped(on: newsletterSwitch.isOn)
  }

  @objc fileprivate func rateUsTapped() {
    self.viewModel.inputs.rateUsTapped()
  }

  @objc fileprivate func termsOfUseTapped() {
    self.helpViewModel.inputs.helpTypeButtonTapped(.terms)
  }

  @IBAction fileprivate func updatesTapped(_ button: UIButton) {
    self.viewModel.inputs.updatesTapped(selected: !button.isSelected)
  }

  @IBAction fileprivate func weeklyNewsletterTapped(_ newsletterSwitch: UISwitch) {
    self.viewModel.inputs.weeklyNewsletterTapped(on: newsletterSwitch.isOn)
  }

  @objc fileprivate func betaFeedbackButtonTapped() {
    self.viewModel.inputs.betaFeedbackButtonTapped()
  }

  @objc fileprivate func closeButtonPressed() {
    self.dismiss(animated: true, completion: nil)
  }

  @objc fileprivate func betaDebugPushNotificationsButtonTapped() {
    self.navigationController?.pushViewController(
      Storyboard.DebugPushNotifications.instantiate(DebugPushNotificationsViewController.self),
      animated: true
    )
  }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
  internal func mailComposeController(_ controller: MFMailComposeViewController,
                                      didFinishWith result: MFMailComposeResult,
                                      error: Error?) {
    self.helpViewModel.inputs.mailComposeCompletion(result: result)
    controller.dismiss(animated: true, completion: nil)
  }
}
