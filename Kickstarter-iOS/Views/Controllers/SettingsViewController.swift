import KsApi
import Library
import MessageUI
import Prelude
import SafariServices
import UIKit

internal final class SettingsViewController: UIViewController {
  fileprivate let viewModel: SettingsViewModelType = SettingsViewModel()
  fileprivate let helpViewModel: HelpViewModelType = HelpViewModel()

  @IBOutlet fileprivate weak var contactButton: UIButton!
  @IBOutlet fileprivate weak var contactLabel: UILabel!
  @IBOutlet fileprivate weak var cookiePolicyButton: UIButton!
  @IBOutlet fileprivate weak var cookiePolicyLabel: UILabel!
  @IBOutlet fileprivate weak var deleteAccountButton: UIButton!
  @IBOutlet fileprivate weak var deleteAccountLabel: UILabel!
  @IBOutlet fileprivate weak var exportDataButton: UIButton!
  @IBOutlet fileprivate weak var exportDataActivityIndicator: UIActivityIndicatorView!
  @IBOutlet fileprivate weak var exportDataExpirationText: UILabel!
  @IBOutlet fileprivate weak var exportDataLabel: UILabel!
  @IBOutlet fileprivate weak var exportChevron: UIImageView!
  @IBOutlet fileprivate weak var followingPrivacyInfoButton: UIButton!
  @IBOutlet fileprivate weak var followingPrivacyLabel: UILabel!
  @IBOutlet fileprivate weak var followingPrivacySwitch: UISwitch!
  @IBOutlet fileprivate weak var helpCenterButton: UIButton!
  @IBOutlet fileprivate weak var helpCenterLabel: UILabel!
  @IBOutlet fileprivate weak var helpTitleLabel: UILabel!
  @IBOutlet fileprivate weak var howKsrWorksButton: UIButton!
  @IBOutlet fileprivate weak var howKsrWorksLabel: UILabel!
  @IBOutlet fileprivate weak var logoutButton: UIButton!
  @IBOutlet fileprivate weak var newslettersLabel: UILabel!
  @IBOutlet fileprivate weak var notificationsLabel: UILabel!
  @IBOutlet fileprivate weak var privacyButton: UIButton!
  @IBOutlet fileprivate weak var privacyLabel: UILabel!
  @IBOutlet fileprivate weak var privacyTitleLabel: UILabel!
  @IBOutlet fileprivate weak var privacyPolicyButton: UIButton!
  @IBOutlet fileprivate weak var privacyPolicyLabel: UILabel!
  @IBOutlet fileprivate weak var rateUsButton: UIButton!
  @IBOutlet fileprivate weak var rateUsLabel: UILabel!
  @IBOutlet fileprivate weak var recommendationsInfoButton: UIButton!
  @IBOutlet fileprivate weak var recommendationsLabel: UILabel!
  @IBOutlet fileprivate weak var recommendationsSwitch: UISwitch!
  @IBOutlet fileprivate weak var termsOfUseButton: UIButton!
  @IBOutlet fileprivate weak var termsOfUseLabel: UILabel!
  @IBOutlet fileprivate weak var versionLabel: UILabel!
  @IBOutlet fileprivate weak var privateProfileSwitch: UISwitch!
  @IBOutlet fileprivate weak var privateProfileLabel: UILabel!
  @IBOutlet fileprivate weak var privateProfileMoreInfoButton: UIButton!
  @IBOutlet fileprivate var separatorViews: [UIView]!

  internal static func instantiate() -> SettingsViewController {
    return Storyboard.Settings.instantiate(SettingsViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.helpViewModel.inputs.configureWith(helpContext: .settings)
    self.helpViewModel.inputs.canSendEmail(MFMailComposeViewController.canSendMail())

    if self.presentingViewController != nil {
      self.navigationItem.leftBarButtonItem = .close(self, selector: #selector(closeButtonPressed))
    }

    self.privacyButton.addTarget(self,
                                        action: #selector(privacyTapped),
                                        for: .touchUpInside)

    self.contactButton.addTarget(self, action: #selector(contactTapped), for: .touchUpInside)

    self.cookiePolicyButton.addTarget(self,
                                      action: #selector(cookiePolicyTapped),
                                      for: .touchUpInside)

    self.deleteAccountButton.addTarget(self,
                                    action: #selector(deleteAccountTapped),
                                    for: .touchUpInside)

    self.exportDataButton.addTarget(self, action: #selector(exportDataTapped), for: .touchUpInside)

    self.followingPrivacyInfoButton.addTarget(self,
                                              action: #selector(followingPrivacyInfoTapped),
                                              for: .touchUpInside)

    self.helpCenterButton.addTarget(self, action: #selector(helpCenterTapped), for: .touchUpInside)

    self.howKsrWorksButton.addTarget(self,
                                     action: #selector(howKickstarterWorksTapped),
                                     for: .touchUpInside)

    self.logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)

    self.termsOfUseButton.addTarget(self,
                                    action: #selector(termsOfUseTapped),
                                    for: .touchUpInside)

    self.privacyPolicyButton.addTarget(self,
                                       action: #selector(privacyPolicyTapped),
                                       for: .touchUpInside)

    self.rateUsButton.addTarget(self, action: #selector(rateUsTapped), for: .touchUpInside)

    self.recommendationsInfoButton.addTarget(self,
                                             action: #selector(recommendationsInfoTapped),
                                             for: .touchUpInside)

    self.viewModel.inputs.viewDidLoad()
  }

    internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
      |> UIViewController.lens.title %~ { _ in Strings.profile_settings_navbar_title() }

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

    _ = self.deleteAccountLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Delete_my_Kickstarter_Account() }

    _ = self.exportDataExpirationText
      |> UILabel.lens.font .~ .ksr_body(size: 13)
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400

    _ = self.exportDataActivityIndicator
      |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true

    _ = self.exportDataLabel
      |> settingsSectionLabelStyle

    _ = self.followingPrivacyLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Following() }

    _ = self.followingPrivacyInfoButton
      |> UIButton.lens.image(for: .normal)
      .~ image(named: "icon--info", tintColor: .ksr_grey_500, inBundle: Bundle.framework)
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.Following_More_Info() }

    _ = self.helpCenterButton
      |> settingsSectionButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.Help_center() }

    _ = self.helpCenterLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Help_center() }

    _ = self.helpTitleLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_about_title() }

    _ = self.howKsrWorksButton
      |> settingsSectionButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.profile_settings_about_how_it_works() }

    _ = self.howKsrWorksLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_about_how_it_works() }

    _ = self.logoutButton |> settingsLogoutButtonStyle

    _ = self.newslettersLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Newsletters() }

    _ = self.notificationsLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_navbar_title_notifications() }

    _ = self.privacyLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Privacy() }

    _ = self.privacyTitleLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Privacy() }

    _ = self.privacyPolicyButton
      |> settingsSectionButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.profile_settings_about_privacy() }

    _ = self.privacyPolicyLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_about_privacy() }

    _ = self.privateProfileLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Private_profile() }

    _ = self.privateProfileMoreInfoButton
      |> UIButton.lens.image(for: .normal)
      .~ image(named: "icon--info", tintColor: .ksr_grey_500, inBundle: Bundle.framework)
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.Private_profile_more_info() }

    _ = self.rateUsButton
      |> settingsSectionButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.profile_settings_rating_rate_us() }

    _ = self.rateUsLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Rate_us_in_the_App_Store() }

    _ = self.recommendationsInfoButton
      |> UIButton.lens.image(for: .normal)
        .~ image(named: "icon--info", tintColor: .ksr_grey_500, inBundle: Bundle.framework)
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.Recommendations_More_Info() }

    _ = self.recommendationsLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Recommendations() }

    _ = self.separatorViews
      ||> separatorStyle

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
  }
  // swiftlint:enable function_body_length

    internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.goToAppStoreRating
      .observeForControllerAction()
      .observeValues { [weak self] link in self?.goToAppStore(link: link) }

    self.viewModel.outputs.goToDeleteAccountBrowser
      .observeForControllerAction()
      .observeValues { [weak self] url in self?.goToDeleteAccount(url: url) }

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

    self.viewModel.outputs.showPrivacyFollowingPrompt
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.showPrivacyFollowingPrompt()
      }

    self.viewModel.outputs.unableToSaveError
      .observeForControllerAction()
      .observeValues { [weak self] message in
        self?.present(UIAlertController.genericError(message), animated: true, completion: nil)
    }

    self.viewModel.outputs.updateCurrentUser
      .observeForUI()
      .observeValues { user in AppEnvironment.updateCurrentUser(user) }

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

    self.followingPrivacySwitch.rac.on = self.viewModel.outputs.followingPrivacyOn
    self.recommendationsSwitch.rac.on = self.viewModel.outputs.recommendationsOn
    self.exportDataExpirationText.rac.text = self.viewModel.outputs.exportDataExpirationDate
    self.exportDataLabel.rac.text = self.viewModel.outputs.exportDataText
    self.versionLabel.rac.text = self.viewModel.outputs.versionText
    self.exportDataActivityIndicator.rac.animating = self.viewModel.outputs.exportDataLoadingIndicator
    self.exportDataButton.rac.enabled = self.viewModel.outputs.exportDataButtonEnabled
    self.exportDataExpirationText.rac.hidden = self.viewModel.outputs.showDataExpirationAndChevron
    self.exportChevron.rac.hidden = self.viewModel.outputs.showDataExpirationAndChevron
    self.privateProfileSwitch.rac.on = self.viewModel.outputs.privateProfileEnabled
    self.versionLabel.rac.text = self.viewModel.outputs.versionText
  }
  // swiftlint:enable function_body_length

  fileprivate func goToAppStore(link: String) {
    guard let url = URL(string: link) else { return }
    UIApplication.shared.openURL(url)
  }

  fileprivate func goToDeleteAccount(url: URL) {
    let controller = SFSafariViewController(url: url)
    controller.modalPresentationStyle = .overFullScreen
    self.present(controller, animated: true, completion: nil)
  }

  fileprivate func goToEmailFrequency(user: User) {

  }

  fileprivate func goToHelpType(_ helpType: HelpType) {
    let vc = HelpWebViewController.configuredWith(helpType: helpType)
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

  @IBAction fileprivate func artsAndCultureNewsletterTapped(_ newsletterSwitch: UISwitch) {
    self.viewModel.inputs.artsAndCultureNewsletterTapped(on: newsletterSwitch.isOn)
  }

  @objc fileprivate func contactTapped() {
    self.helpViewModel.inputs.helpTypeButtonTapped(.contact)
  }

  @objc fileprivate func cookiePolicyTapped() {
    self.helpViewModel.inputs.helpTypeButtonTapped(.cookie)
  }

  @objc fileprivate func exportDataTapped() {
    let exportDataSheet = UIAlertController(
      title: Strings.Download_your_personal_data(),
      message: Strings.It_may_take_up_to_24_hours_to_collect_your_data(),
      preferredStyle: .actionSheet)

    let startTheRequest = UIAlertAction(title: Strings.Start_the_request(),
                                        style: .default,
                                        handler: { [weak self] _ in
                                          self?.viewModel.inputs.exportDataTapped()
    })

    let dismiss = UIAlertAction(title: Strings.Cancel(), style: .cancel, handler: nil)

    exportDataSheet.addAction(startTheRequest)
    exportDataSheet.addAction(dismiss)

    self.present(exportDataSheet, animated: true, completion: nil)
  }

  @objc fileprivate func followingPrivacyInfoTapped() {
    let privacyInfoAlert = UIAlertController.followingPrivacyInfo()
    self.present(privacyInfoAlert, animated: true, completion: nil)
  }

  fileprivate func showPrivacyFollowingPrompt() {
    let followingAlert = UIAlertController.turnOffPrivacyFollowing(
       turnOnHandler: { [weak self] _ in
        self?.viewModel.inputs.followingSwitchTapped(on: true, didShowPrompt: true)
      },
       turnOffHandler: { [weak self] _ in
        self?.viewModel.inputs.followingSwitchTapped(on: false, didShowPrompt: true)
      }
    )
     self.present(followingAlert, animated: true, completion: nil)
  }

  @IBAction func followingPrivacySwitchTapped(_ followingPrivacySwitch: UISwitch) {
    self.viewModel.inputs.followingSwitchTapped(on: followingPrivacySwitch.isOn, didShowPrompt: false)
  }

  @IBAction func goToNotifications(_ sender: UIButton) {
    let vc = SettingsNotificationsViewController.instantiate()
    self.navigationController?.pushViewController(vc, animated: true)
  }

  @IBAction func goToNewsletters(_ sender: Any) {
    let vc = SettingsNewslettersViewController.instantiate()
    self.navigationController?.pushViewController(vc, animated: true)
  }

  @IBAction fileprivate func gamesNewsletterTapped(_ newsletterSwitch: UISwitch) {
    self.viewModel.inputs.gamesNewsletterTapped(on: newsletterSwitch.isOn)
  }

  @IBAction fileprivate func happeningNewsletterTapped(_ newsletterSwitch: UISwitch) {
    self.viewModel.inputs.happeningNewsletterTapped(on: newsletterSwitch.isOn)
  }

  @objc fileprivate func helpCenterTapped() {
    self.helpViewModel.inputs.helpTypeButtonTapped(.helpCenter)
  }

  @IBAction fileprivate func inventNewsletterTapped(_ newsletterSwitch: UISwitch) {
    self.viewModel.inputs.inventNewsletterTapped(on: newsletterSwitch.isOn)
  }

  @objc fileprivate func howKickstarterWorksTapped() {
    self.helpViewModel.inputs.helpTypeButtonTapped(.howItWorks)
  }

  @objc fileprivate func recommendationsInfoTapped() {
    let alertController = UIAlertController(

      title: Strings.Recommendations(),
      message: Strings.We_use_your_activity_internally_to_make_recommendations_for_you(),
      preferredStyle: .alert)
    alertController.addAction(
      UIAlertAction(
        title: Strings.Got_it(),
        style: .cancel,
        handler: nil
      )
    )
    self.present(alertController, animated: true, completion: nil)
  }

  @objc fileprivate func privacyPolicyTapped() {
    self.helpViewModel.inputs.helpTypeButtonTapped(.privacy)
  }

  @IBAction fileprivate func privateProfileSwitchDidChange(_ sender: UISwitch) {
    self.viewModel.inputs.privateProfileSwitchDidChange(isOn: sender.isOn)
  }
  @IBAction fileprivate func privateProfileMoreInfoButtonTapped(_ sender: UIButton) {
    let alertController = UIAlertController(
      title: Strings.Private_profile(),
      message: Strings.Private_profile_more_info_content(),
      preferredStyle: .alert)

    alertController.addAction(
      UIAlertAction(
        title: Strings.Got_it(),
        style: .cancel,
        handler: nil
      )
    )

    self.present(alertController, animated: true, completion: nil)
  }

  @IBAction fileprivate func promoNewsletterTapped(_ newsletterSwitch: UISwitch) {
    self.viewModel.inputs.promoNewsletterTapped(on: newsletterSwitch.isOn)
  }

  @IBAction fileprivate func recommendationsTapped(_ recommendationSwitch: UISwitch) {
    self.viewModel.inputs.recommendationsTapped(on: recommendationSwitch.isOn)
  }

  @objc fileprivate func rateUsTapped() {
    self.viewModel.inputs.rateUsTapped()
  }

  @objc fileprivate func deleteAccountTapped() {
    self.viewModel.inputs.deleteAccountTapped()
  }

  @objc fileprivate func termsOfUseTapped() {
    self.helpViewModel.inputs.helpTypeButtonTapped(.terms)
  }

  @objc fileprivate func privacyTapped() {
    self.viewModel.inputs.privacyTapped()
  }

  @IBAction fileprivate func weeklyNewsletterTapped(_ newsletterSwitch: UISwitch) {
    self.viewModel.inputs.weeklyNewsletterTapped(on: newsletterSwitch.isOn)
  }

  @objc fileprivate func closeButtonPressed() {
    self.dismiss(animated: true, completion: nil)
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
