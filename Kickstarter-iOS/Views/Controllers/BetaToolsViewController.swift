import KsApi
import Library
import MessageUI
import Prelude
import SafariServices
import UIKit

internal final class BetaToolsViewController: UIViewController {
  fileprivate let viewModel: BetaToolsViewModelType = BetaToolsViewModel()
  fileprivate let helpViewModel: HelpViewModelType = HelpViewModel()

  @IBOutlet fileprivate weak var doneButton: UIBarButtonItem!
  @IBOutlet fileprivate weak var betaDebugPushNotificationsButton: UIButton!
  @IBOutlet fileprivate weak var betaFeedbackButton: UIButton!
  @IBOutlet fileprivate weak var betaTitleLabel: UILabel!
  @IBOutlet fileprivate weak var languageSwitcher: UIButton!
  @IBOutlet fileprivate weak var environmentSwitcher: UIButton!

  internal static func instantiate() -> BetaToolsViewController {
    return Storyboard.BetaTools.instantiate(BetaToolsViewController.self)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.navigationItem.setRightBarButton(doneButton, animated: false)
  }

  override func bindStyles() {
    _ = self.betaDebugPushNotificationsButton
      |> UIButton.lens.titleColor(for: .normal) .~ .ksr_text_dark_grey_500
      |> UIButton.lens.titleLabel.font .~ .ksr_body()
      |> UIButton.lens.contentHorizontalAlignment .~ .left
      |> UIButton.lens.title(for: .normal) .~ "Debug push notifications"

    _ = self.betaFeedbackButton
      |> greenButtonStyle
      |> UIButton.lens.title(for: .normal) .~ "Submit feedback for beta"

    _ = self.betaTitleLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text .~ "Beta tools"

    _ = self.languageSwitcher
      |> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 15)
      |> UIButton.lens.titleColor(for: .normal) .~ .ksr_text_dark_grey_500
      |> UIButton.lens.title(for: .normal) .~ AppEnvironment.current.language.displayString

        _ = self.environmentSwitcher
      |> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 15)
      |> UIButton.lens.contentHorizontalAlignment .~ .left
      |> UIButton.lens.titleColor(for: .normal) .~ .ksr_text_dark_grey_500
      |> UIButton.lens.title(for: .normal) .~
      AppEnvironment.current.apiService.serverConfig.environment.rawValue
  }

  override func bindViewModel() {
    self.environmentSwitcher.rac.title = self.viewModel.outputs.environmentSwitcherButtonTitle

    self.languageSwitcher.rac.title = self.viewModel.outputs.currentLanguage
      .map { $0.displayString }

    self.viewModel.outputs.currentLanguage
      .observeForUI()
      .observeValues { [weak self] language in self?.languageDidChange(language: language) }

    self.viewModel.outputs.goToBetaFeedback
      .observeForControllerAction()
      .observeValues { [weak self] in self?.goToBetaFeedback() }

    self.viewModel.outputs.betaFeedbackMailDisabled
      .observeForControllerAction()
      .observeValues { [weak self] in self?.showMailDisabledAlert() }

    self.viewModel.outputs.logoutWithParams
      .observeForControllerAction()
      .observeValues { [weak self] in self?.logoutAndDismiss(params: $0) }
  }

  @IBAction fileprivate func betaFeedbackButtonTapped(_ sender: Any) {
    self.viewModel.inputs.betaFeedbackButtonTapped(canSendMail: MFMailComposeViewController.canSendMail())
  }

  @IBAction fileprivate func betaDebugPushNotificationsButtonTapped(_ sender: Any) {
    self.navigationController?.pushViewController(
      Storyboard.DebugPushNotifications.instantiate(DebugPushNotificationsViewController.self),
      animated: true
    )
  }

  @IBAction func languageSwitcherTapped(_ sender: Any) {
    self.showLanguageActionSheet()
  }

  @IBAction func environmentSwitcherTapped(_ sender: Any) {
    self.showEnvironmentActionSheet()
  }

  @IBAction func doneTapped(_ sender: Any) {
    self.navigationController?.dismiss(animated: true, completion: nil)
  }

  // MARK: Private Helper Functions

  private func showLanguageActionSheet() {
    let alert = UIAlertController(title: "Change Language",
                                  message: nil,
                                  preferredStyle: .actionSheet)

    Language.allLanguages.forEach { language in
      alert.addAction(
        UIAlertAction(title: language.displayString, style: .default) { [weak self] _ in
          self?.viewModel.inputs.setCurrentLanguage(language)
        }
      )
    }

    alert.addAction(
      UIAlertAction.init(title: "Cancel", style: .cancel)
    )

    self.present(alert, animated: true, completion: nil)
  }

  private func showEnvironmentActionSheet() {
    let alert = UIAlertController(title: "Change Environment",
                                  message: nil,
                                  preferredStyle: .actionSheet)

    EnvironmentType.allCases.forEach { environment in
      alert.addAction(UIAlertAction(title: environment.rawValue, style: .default) { [weak self] _ in
        self?.viewModel.inputs.environmentSwitcherButtonTapped(environment: environment)
      })
    }

    alert.addAction(
      UIAlertAction.init(title: "Cancel", style: .cancel)
    )

    self.present(alert, animated: true, completion: nil)
  }

  private func languageDidChange(language: Language) {
    self.navigationController?.dismiss(animated: true, completion: {
      AppEnvironment.updateLanguage(language)

      NotificationCenter.default.post(name: Notification.Name.ksr_languageChanged, object: nil, userInfo: nil)
    })
  }

  private func goToBetaFeedback() {
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

  private func showMailDisabledAlert() {
    let alert = UIAlertController(title: "Cannot send mail",
                                  message: "Mail is disabled. Please set up mail and try again.",
                                  preferredStyle: .alert)

    alert.addAction(
      UIAlertAction.init(title: "Ok", style: .cancel)
    )

    self.present(alert, animated: true, completion: nil)
  }

  private func logoutAndDismiss(params: DiscoveryParams) {
    AppEnvironment.logout()

    NotificationCenter.default.post(.init(name: .ksr_sessionEnded))
    // Refresh the discovery screens
    NotificationCenter.default.post(.init(name: .ksr_environmentChanged))

    self.navigationController?.dismiss(animated: true, completion: nil)
  }
}

extension BetaToolsViewController: MFMailComposeViewControllerDelegate {
  internal func mailComposeController(_ controller: MFMailComposeViewController,
                                      didFinishWith result: MFMailComposeResult,
                                      error: Error?) {
    self.helpViewModel.inputs.mailComposeCompletion(result: result)
    controller.dismiss(animated: true, completion: nil)
  }
}
