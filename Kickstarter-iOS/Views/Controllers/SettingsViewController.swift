import KsApi
import Library
import MessageUI
import SafariServices
import UIKit

internal final class SettingsViewController: UIViewController {
  private let viewModel: SettingsViewModelType = SettingsViewModel()

  @IBOutlet private weak var backingsButton: UIButton!
  @IBOutlet private weak var commentsButton: UIButton!
  @IBOutlet private weak var creatorStackView: UIStackView!
  @IBOutlet private weak var followerButton: UIButton!
  @IBOutlet private weak var friendActivityButton: UIButton!
  @IBOutlet private weak var gamesNewsletterSwitch: UISwitch!
  @IBOutlet private weak var happeningNewsletterSwitch: UISwitch!
  @IBOutlet private weak var mobileBackingsButton: UIButton!
  @IBOutlet private weak var mobileCommentsButton: UIButton!
  @IBOutlet private weak var mobileFollowerButton: UIButton!
  @IBOutlet private weak var mobileFriendActivityButton: UIButton!
  @IBOutlet private weak var mobilePostLikesButton: UIButton!
  @IBOutlet private weak var mobileUpdatesButton: UIButton!
  @IBOutlet private weak var postLikesButton: UIButton!
  @IBOutlet private weak var projectNotificationsCountLabel: UILabel!
  @IBOutlet private weak var promoNewsletterSwitch: UISwitch!
  @IBOutlet private weak var updatesButton: UIButton!
  @IBOutlet private weak var weeklyNewsletterSwitch: UISwitch!
  @IBOutlet private weak var versionLabel: UILabel!

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()
    self.viewModel.inputs.canSendEmail(MFMailComposeViewController.canSendMail())
    self.view.backgroundColor = .ksr_grey_100
  }

  // swiftlint:disable function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.goToAppStoreRating
      .observeForUI()
      .observeNext { [weak self] link in self?.goToAppStore(link: link) }

    self.viewModel.outputs.goToHelpType
      .observeForUI()
      .observeNext { [weak self] helpType in self?.goToHelpType(helpType) }


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

    self.backingsButton.rac.selected = self.viewModel.outputs.backingsSelected
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
    self.projectNotificationsCountLabel.rac.text = self.viewModel.outputs.projectNotificationsCount
    self.promoNewsletterSwitch.rac.on = self.viewModel.outputs.promoNewsletterOn
    self.updatesButton.rac.selected = self.viewModel.outputs.updatesSelected
    self.weeklyNewsletterSwitch.rac.on = self.viewModel.outputs.weeklyNewsletterOn
    self.versionLabel.rac.text = self.viewModel.outputs.versionText
  }

  private func goToAppStore(link link: String) {
    guard let url = NSURL(string: link) else { return }
    UIApplication.sharedApplication().openURL(url)
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
    switch helpType {
    case .Contact:
      let controller = MFMailComposeViewController.support()
      controller.mailComposeDelegate = self
      self.presentViewController(controller, animated: true, completion: nil)
    default:
      let svc = SFSafariViewController.help(helpType, baseURL: ServerConfig.production.webBaseUrl)
      self.presentViewController(svc, animated: true, completion: nil)
    }
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

    logoutAlert.addAction(UIAlertAction(title: cancel, style: .Cancel, handler: nil))

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

  @IBAction private func logoutTapped() {
    self.viewModel.inputs.logoutTapped()
  }

  @IBAction private func backingsTapped(button: UIButton) {
    self.viewModel.inputs.backingsTapped(selected: !button.selected)
  }

  @IBAction private func commentsTapped(button: UIButton) {
    self.viewModel.inputs.commentsTapped(selected: !button.selected)
  }

  @IBAction private func contactTapped() {
    self.viewModel.inputs.helpTypeTapped(helpType: .Contact)
  }

  @IBAction private func cookiePolicyTapped() {
    self.viewModel.inputs.helpTypeTapped(helpType: .Cookie)
  }

  @IBAction private func faqTapped() {
    self.viewModel.inputs.helpTypeTapped(helpType: .FAQ)
  }

  @IBAction private func findFriendsTapped() {
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

  @IBAction private func howKickstarterWorksTapped() {
    self.viewModel.inputs.helpTypeTapped(helpType: .HowItWorks)
  }

  @IBAction private func manageProjectNotificationsTapped() {
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

  @IBAction private func privacyPolicyTapped() {
    self.viewModel.inputs.helpTypeTapped(helpType: .Privacy)
  }

  @IBAction private func promoNewsletterTapped(newsletterSwitch: UISwitch) {
    self.viewModel.inputs.promoNewsletterTapped(on: newsletterSwitch.on)
  }

  @IBAction private func rateUsTapped() {
    self.viewModel.inputs.rateUsTapped()
  }

  @IBAction private func termsOfUseTapped() {
    self.viewModel.inputs.helpTypeTapped(helpType: .Terms)
  }

  @IBAction private func updatesTapped(button: UIButton) {
    self.viewModel.inputs.updatesTapped(selected: !button.selected)
  }

  @IBAction private func weeklyNewsletterTapped(newsletterSwitch: UISwitch) {
    self.viewModel.inputs.weeklyNewsletterTapped(on: newsletterSwitch.on)
  }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
  internal func mailComposeController(controller: MFMailComposeViewController,
                                      didFinishWithResult result: MFMailComposeResult,
                                      error: NSError?) {

    if result == MFMailComposeResultSent {
      self.viewModel.inputs.contactEmailSent()
    }

    controller.dismissViewControllerAnimated(true, completion: nil)
  }
}
