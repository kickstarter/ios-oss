import KsApi
import Library
import MessageUI
import Prelude
import SafariServices
import UIKit

// swiftlint:disable file_length
// swiftlint:disable type_body_length
internal final class SettingsViewController: UIViewController {
  private let viewModel: SettingsViewModelType = SettingsViewModel()
  private let helpViewModel: HelpViewModelType = HelpViewModel()

  @IBOutlet private weak var backingsButton: UIButton!
  @IBOutlet private weak var betaFeedbackButton: UIButton!
  @IBOutlet private weak var commentsButton: UIButton!
  @IBOutlet private weak var contactButton: UIButton!
  @IBOutlet private weak var contactLabel: UILabel!
  @IBOutlet private weak var cookiePolicyButton: UIButton!
  @IBOutlet private weak var cookiePolicyLabel: UILabel!
  @IBOutlet private weak var creatorNotificationsTitleLabel: UILabel!
  @IBOutlet private weak var creatorStackView: UIStackView!
  @IBOutlet private weak var faqButton: UIButton!
  @IBOutlet private weak var faqLabel: UILabel!
  @IBOutlet private weak var findFriendsButton: UIButton!
  @IBOutlet private weak var findFriendsLabel: UILabel!
  @IBOutlet private weak var followerButton: UIButton!
  @IBOutlet private weak var friendActivityButton: UIButton!
  @IBOutlet private weak var friendActivityLabel: UILabel!
  @IBOutlet private weak var gamesNewsletterSwitch: UISwitch!
  @IBOutlet private weak var happeningNewsletterSwitch: UISwitch!
  @IBOutlet private weak var happeningNowLabel: UILabel!
  @IBOutlet private weak var helpTitleLabel: UILabel!
  @IBOutlet private weak var howKsrWorksButton: UIButton!
  @IBOutlet private weak var howKsrWorksLabel: UILabel!
  @IBOutlet private weak var ksrLovesGamesLabel: UILabel!
  @IBOutlet private weak var ksrNewsAndEventsLabel: UILabel!
  @IBOutlet private weak var logoutButton: UIButton!
  @IBOutlet private weak var manageProjectNotificationsButton: UIButton!
  @IBOutlet private weak var manageProjectNotificationsLabel: UILabel!
  @IBOutlet private weak var mobileBackingsButton: UIButton!
  @IBOutlet private weak var mobileCommentsButton: UIButton!
  @IBOutlet private weak var mobileFollowerButton: UIButton!
  @IBOutlet private weak var mobileFriendActivityButton: UIButton!
  @IBOutlet private weak var mobilePostLikesButton: UIButton!
  @IBOutlet private weak var mobileUpdatesButton: UIButton!
  @IBOutlet private weak var newCommentsLabel: UILabel!
  @IBOutlet private weak var newFollowersLabel: UILabel!
  @IBOutlet private weak var newLikesLabel: UILabel!
  @IBOutlet private weak var newPledgesLabel: UILabel!
  @IBOutlet private weak var newslettersTitleLabel: UILabel!
  @IBOutlet private weak var postLikesButton: UIButton!
  @IBOutlet private weak var privacyPolicyButton: UIButton!
  @IBOutlet private weak var privacyPolicyLabel: UILabel!
  @IBOutlet private weak var projectNotificationsCountView: CountBadgeView!
  @IBOutlet private weak var projectUpdatesLabel: UILabel!
  @IBOutlet private weak var projectsWeLoveLabel: UILabel!
  @IBOutlet private weak var projectsYouBackTitleLabel: UILabel!
  @IBOutlet private weak var promoNewsletterSwitch: UISwitch!
  @IBOutlet private weak var rateUsButton: UIButton!
  @IBOutlet private weak var rateUsLabel: UILabel!
  @IBOutlet private weak var socialNotificationsTitleLabel: UILabel!
  @IBOutlet private weak var termsOfUseButton: UIButton!
  @IBOutlet private weak var termsOfUseLabel: UILabel!
  @IBOutlet private weak var updatesButton: UIButton!
  @IBOutlet private weak var weeklyNewsletterSwitch: UISwitch!
  @IBOutlet private weak var wereAllEarsTitleLabel: UILabel!
  @IBOutlet private weak var versionLabel: UILabel!

  @IBOutlet var emailNotificationButtons: [UIButton]!
  @IBOutlet var pushNotificationButtons: [UIButton]!
  @IBOutlet var separatorViews: [UIView]!

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.helpViewModel.inputs.configureWith(helpContext: .settings)
    self.helpViewModel.inputs.canSendEmail(MFMailComposeViewController.canSendMail())

    self.betaFeedbackButton.addTarget(self,
                                      action: #selector(betaFeedbackButtonTapped),
                                      forControlEvents: .TouchUpInside)

    self.contactButton.addTarget(self, action: #selector(contactTapped), forControlEvents: .TouchUpInside)

    self.cookiePolicyButton.addTarget(self,
                                      action: #selector(cookiePolicyTapped),
                                      forControlEvents: .TouchUpInside)

    self.faqButton.addTarget(self, action: #selector(faqTapped), forControlEvents: .TouchUpInside)

    self.findFriendsButton.addTarget(self,
                                     action: #selector(findFriendsTapped),
                                     forControlEvents: .TouchUpInside)

    self.howKsrWorksButton.addTarget(self,
                                     action: #selector(howKickstarterWorksTapped),
                                     forControlEvents: .TouchUpInside)

    self.logoutButton.addTarget(self, action: #selector(logoutTapped), forControlEvents: .TouchUpInside)

    self.manageProjectNotificationsButton.addTarget(self,
                                                    action: #selector(manageProjectNotificationsTapped),
                                                    forControlEvents: .TouchUpInside)

    self.termsOfUseButton.addTarget(self,
                                    action: #selector(termsOfUseTapped),
                                    forControlEvents: .TouchUpInside)

    self.privacyPolicyButton.addTarget(self,
                                       action: #selector(privacyPolicyTapped),
                                       forControlEvents: .TouchUpInside)



    self.rateUsButton.addTarget(self, action: #selector(rateUsTapped), forControlEvents: .TouchUpInside)

    self.viewModel.inputs.viewDidLoad()
  }

  // swiftlint:disable function_body_length
  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseControllerStyle()
      |> UIViewController.lens.title %~ { _ in Strings.profile_settings_navbar_title() }

    self.betaFeedbackButton
      |> greenButtonStyle
      |> UIButton.lens.title(forState: .Normal) .~ "Submit feedback for beta"

    self.contactLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_about_contact() }

    self.cookiePolicyLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_about_cookie() }

    self.creatorNotificationsTitleLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_creator_title() }

    self.emailNotificationButtons
      ||> settingsEmailIconButton
      ||> UIButton.lens.image(forState: .Normal)
        .~ UIImage(named: "email-icon", inBundle: .framework, compatibleWithTraitCollection: nil)
      ||> UIButton.lens.image(forState: .Selected)
        .~ image(named: "email-icon", tintColor: .ksr_green_400, inBundle: NSBundle.framework)

    self.faqLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_about_faq() }

    self.findFriendsLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_social_find_friends() }

    self.friendActivityLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_social_friend_backs() }

    self.happeningNowLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_newsletter_happening() }

    self.helpTitleLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_about_title() }

    self.howKsrWorksLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_about_how_it_works() }

    self.ksrLovesGamesLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_newsletter_games() }

    self.ksrNewsAndEventsLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_newsletter_promo() }

    self.logoutButton |> settingsLogoutButtonStyle

    self.manageProjectNotificationsLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_backer_notifications() }

    self.newCommentsLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_creator_comments() }

    self.newFollowersLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_social_followers() }

    self.newLikesLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_creator_likes() }

    self.newPledgesLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_creator_pledges() }

    self.newslettersTitleLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_newsletter_title() }

    self.privacyPolicyLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_about_privacy() }

    self.projectUpdatesLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_backer_project_updates() }

    self.projectsWeLoveLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_newsletter_weekly() }

    self.projectsYouBackTitleLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_backer_title() }

    self.pushNotificationButtons
      ||> settingsPhoneIconButton
      ||> UIButton.lens.image(forState: .Normal)
      .~ UIImage(named: "phone-icon", inBundle: .framework, compatibleWithTraitCollection: nil)
      ||> UIButton.lens.image(forState: .Selected)
      .~ image(named: "phone-icon", tintColor: .ksr_green_400, inBundle: NSBundle.framework)

    self.rateUsLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_rating_rate_us() }

    self.separatorViews
      ||> separatorStyle

    self.socialNotificationsTitleLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_social_title() }

    self.termsOfUseLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_about_terms() }

    self.versionLabel
      |> UILabel.lens.textColor .~ .ksr_navy_600
      |> UILabel.lens.font .~ .ksr_subhead()

    self.wereAllEarsTitleLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_rating_title() }
  }
  // swiftlint:enable function_body_length

  // swiftlint:disable function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.goToAppStoreRating
      .observeForUI()
      .observeNext { [weak self] link in self?.goToAppStore(link: link) }

    self.viewModel.outputs.goToManageProjectNotifications
      .observeForUI()
      .observeNext { [weak self] _ in self?.goToManageProjectNotifications() }

    self.viewModel.outputs.logout
      .observeForUI()
      .observeNext { [weak self] in self?.logout() }

    self.viewModel.outputs.showConfirmLogoutPrompt
      .observeForUI()
      .observeNext { [weak self] (message, cancel, confirm) in
        self?.showLogoutPrompt(message: message, cancel: cancel, confirm: confirm)
    }

    self.viewModel.outputs.showOptInPrompt
      .observeForUI()
      .observeNext { [weak self] newsletter in self?.showOptInPrompt(newsletter) }

    self.viewModel.outputs.unableToSaveError
      .observeForUI()
      .observeNext { [weak self] message in
        self?.presentViewController(UIAlertController.genericError(message), animated: true, completion: nil)
    }

    self.viewModel.outputs.updateCurrentUser
      .observeNext { user in AppEnvironment.updateCurrentUser(user) }

    self.viewModel.outputs.goToFindFriends
      .observeForUI()
      .observeNext { [weak self] in
        self?.goToFindFriends()
    }

    self.viewModel.outputs.goToBetaFeedback
      .observeForUI()
      .observeNext { [weak self] in self?.goToBetaFeedback() }

    self.helpViewModel.outputs.showMailCompose
      .observeForUI()
      .observeNext { [weak self] in
        guard let _self = self else { return }
        let controller = MFMailComposeViewController.support()
        controller.mailComposeDelegate = _self
        _self.presentViewController(controller, animated: true, completion: nil)
    }

    self.helpViewModel.outputs.showNoEmailError
      .observeForUI()
      .observeNext { [weak self] alert in
        self?.presentViewController(alert, animated: true, completion: nil)
    }

    self.helpViewModel.outputs.showWebHelp
      .observeForUI()
      .observeNext { [weak self] helpType in
        self?.goToHelpType(helpType)
    }

    self.backingsButton.rac.selected = self.viewModel.outputs.backingsSelected
    self.betaFeedbackButton.rac.hidden = self.viewModel.outputs.betaFeedbackButtonHidden
    self.commentsButton.rac.selected = self.viewModel.outputs.commentsSelected
    self.creatorStackView.rac.hidden = self.viewModel.outputs.creatorNotificationsHidden
    self.followerButton.rac.selected = self.viewModel.outputs.followerSelected
    self.friendActivityButton.rac.selected = self.viewModel.outputs.friendActivitySelected
    self.gamesNewsletterSwitch.rac.on = self.viewModel.outputs.gamesNewsletterOn
    self.happeningNewsletterSwitch.rac.on = self.viewModel.outputs.happeningNewsletterOn
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

  private func goToAppStore(link link: String) {
    guard let url = NSURL(string: link) else { return }
    UIApplication.sharedApplication().openURL(url)
  }

  private func goToBetaFeedback() {
    guard MFMailComposeViewController.canSendMail() else { return }

    let userName = AppEnvironment.current.currentUser?.name ?? "Logged out user"
    let userId = AppEnvironment.current.currentUser?.id ?? 0
    let version = AppEnvironment.current.mainBundle.version ?? "0"
    let shortVersion = AppEnvironment.current.mainBundle.shortVersionString ?? "0"
    let device = UIDevice.currentDevice()

    let controller = MFMailComposeViewController()
    controller.setToRecipients(["***REMOVED***"])
    controller.setSubject("Field report: ")
    controller.setMessageBody(
      "\(userName) | \(userId) | \(version) | \(shortVersion) | " +
        "\(device.systemVersion) | \(device.modelCode)\n\n" +
        "Describe the bug here. Attach images if it helps!\n" +
        "---------------------------\n\n\n\n\n\n",
      isHTML: false
    )

    controller.mailComposeDelegate = self
    self.presentViewController(controller, animated: true, completion: nil)
  }

  private func goToFindFriends() {
    guard let friendVC = UIStoryboard(name: "Friends", bundle: .framework)
      .instantiateInitialViewController() as? FindFriendsViewController
    else {
      fatalError("Could not instantiate FindFriendsViewController.")
    }

    friendVC.configureWith(source: .settings)
    self.navigationController?.pushViewController(friendVC, animated: true)
  }

  private func goToHelpType(helpType: HelpType) {
    guard let helpVC = UIStoryboard(name: "Help", bundle: .framework)
      .instantiateViewControllerWithIdentifier("HelpWebViewController") as? HelpWebViewController else {
        fatalError("Could not instantiate HelpWebViewController")
    }

    helpVC.configureWith(helpType: helpType)
    self.navigationController?.pushViewController(helpVC, animated: true)
  }

  private func goToManageProjectNotifications() {
    guard let projectNotificationsViewController =
      self.storyboard?.instantiateViewControllerWithIdentifier("ProjectNotificationsViewController")
        as? ProjectNotificationsViewController else {
          fatalError("Could not instantiate ProjectNotificationsViewController.")
    }

    self.navigationController?.pushViewController(projectNotificationsViewController, animated: true)
  }

  private func showLogoutPrompt(message message: String, cancel: String, confirm: String) {
    let logoutAlert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)

    logoutAlert.addAction(
      UIAlertAction(
        title: cancel,
        style: .Cancel,
        handler: { [weak self] _ in
          self?.viewModel.inputs.logoutCanceled()
        }
      )
    )

    logoutAlert.addAction(
      UIAlertAction(
        title: confirm,
        style: .Default,
        handler: { [weak self] _ in
          self?.viewModel.inputs.logoutConfirmed()
        }
      )
    )

    self.presentViewController(logoutAlert, animated: true, completion: nil)
  }

  private func logout() {
    AppEnvironment.logout()
    NSNotificationCenter.defaultCenter().postNotification(
      NSNotification(name: CurrentUserNotifications.sessionEnded, object: nil)
    )
  }

  private func showOptInPrompt(newsletter: String) {
    let optInAlert = UIAlertController.newsletterOptIn(newsletter)
    self.presentViewController(optInAlert, animated: true, completion: nil)
  }

  @objc private func logoutTapped() {
    self.viewModel.inputs.logoutTapped()
  }

  @IBAction private func backingsTapped(button: UIButton) {
    self.viewModel.inputs.backingsTapped(selected: !button.selected)
  }

  @IBAction private func commentsTapped(button: UIButton) {
    self.viewModel.inputs.commentsTapped(selected: !button.selected)
  }

  @objc private func contactTapped() {
    self.helpViewModel.inputs.helpTypeButtonTapped(.contact)
  }

  @objc private func cookiePolicyTapped() {
    self.helpViewModel.inputs.helpTypeButtonTapped(.cookie)
  }

  @objc private func faqTapped() {
    self.helpViewModel.inputs.helpTypeButtonTapped(.faq)
  }

  @objc private func findFriendsTapped() {
    self.viewModel.inputs.findFriendsTapped()
  }

  @IBAction private func followerTapped(button: UIButton) {
    self.viewModel.inputs.followerTapped(selected: !button.selected)
  }

  @IBAction private func friendActivityTapped(button: UIButton) {
    self.viewModel.inputs.friendActivityTapped(selected: !button.selected)
  }

  @IBAction private func gamesNewsletterTapped(newsletterSwitch: UISwitch) {
    self.viewModel.inputs.gamesNewsletterTapped(on: newsletterSwitch.on)
  }

  @IBAction private func happeningNewsletterTapped(newsletterSwitch: UISwitch) {
    self.viewModel.inputs.happeningNewsletterTapped(on: newsletterSwitch.on)
  }

  @objc private func howKickstarterWorksTapped() {
    self.helpViewModel.inputs.helpTypeButtonTapped(.howItWorks)
  }

  @objc private func manageProjectNotificationsTapped() {
    self.viewModel.inputs.manageProjectNotificationsTapped()
  }

  @IBAction private func mobileBackingsTapped(button: UIButton) {
    self.viewModel.inputs.mobileBackingsTapped(selected: !button.selected)
  }

  @IBAction private func mobileCommentsTapped(button: UIButton) {
    self.viewModel.inputs.mobileCommentsTapped(selected: !button.selected)
  }

  @IBAction private func mobileFollowerTapped(button: UIButton) {
    self.viewModel.inputs.mobileFollowerTapped(selected: !button.selected)
  }

  @IBAction private func mobileFriendActivityTapped(button: UIButton) {
    self.viewModel.inputs.mobileFriendActivityTapped(selected: !button.selected)
  }

  @IBAction private func mobilePostLikesTapped(button: UIButton) {
    self.viewModel.inputs.mobilePostLikesTapped(selected: !button.selected)
  }

  @IBAction private func mobileUpdatesTapped(button: UIButton) {
    self.viewModel.inputs.mobileUpdatesTapped(selected: !button.selected)
  }

  @IBAction private func postLikesTapped(button: UIButton) {
    self.viewModel.inputs.postLikesTapped(selected: !button.selected)
  }

  @objc private func privacyPolicyTapped() {
    self.helpViewModel.inputs.helpTypeButtonTapped(.privacy)
  }

  @IBAction private func promoNewsletterTapped(newsletterSwitch: UISwitch) {
    self.viewModel.inputs.promoNewsletterTapped(on: newsletterSwitch.on)
  }

  @objc private func rateUsTapped() {
    self.viewModel.inputs.rateUsTapped()
  }

  @objc private func termsOfUseTapped() {
    self.helpViewModel.inputs.helpTypeButtonTapped(.terms)
  }

  @IBAction private func updatesTapped(button: UIButton) {
    self.viewModel.inputs.updatesTapped(selected: !button.selected)
  }

  @IBAction private func weeklyNewsletterTapped(newsletterSwitch: UISwitch) {
    self.viewModel.inputs.weeklyNewsletterTapped(on: newsletterSwitch.on)
  }

  @objc private func betaFeedbackButtonTapped() {
    self.viewModel.inputs.betaFeedbackButtonTapped()
  }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
  internal func mailComposeController(controller: MFMailComposeViewController,
                                      didFinishWithResult result: MFMailComposeResult,
                                      error: NSError?) {
    self.helpViewModel.inputs.mailComposeCompletion(result: result)
    controller.dismissViewControllerAnimated(true, completion: nil)
  }
}
