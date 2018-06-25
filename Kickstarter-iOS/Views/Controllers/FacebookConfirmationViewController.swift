import FBSDKCoreKit
import Foundation
import Library
import MessageUI
import Prelude
import ReactiveSwift
import ReactiveExtensions
import UIKit

internal final class FacebookConfirmationViewController: UIViewController,
  MFMailComposeViewControllerDelegate {

  @IBOutlet private weak var confirmationLabel: UILabel!
  @IBOutlet private weak var createAccountButton: UIButton!
  @IBOutlet private weak var emailLabel: UILabel!
  @IBOutlet private weak var loginButton: UIButton!
  @IBOutlet private weak var loginLabel: UILabel!
  @IBOutlet private weak var newsletterLabel: UILabel!
  @IBOutlet private weak var newsletterSwitch: UISwitch!
  @IBOutlet private weak var rootStackView: UIStackView!

  private let helpViewModel = HelpViewModel()
  fileprivate let viewModel: FacebookConfirmationViewModelType = FacebookConfirmationViewModel()

  internal static func configuredWith(facebookUserEmail email: String, facebookAccessToken token: String)
    -> FacebookConfirmationViewController {

      let vc = Storyboard.Login.instantiate(FacebookConfirmationViewController.self)
      vc.viewModel.inputs.email(email)
      vc.viewModel.inputs.facebookToken(token)
      vc.helpViewModel.inputs.configureWith(helpContext: .facebookConfirmation)
      vc.helpViewModel.inputs.canSendEmail(MFMailComposeViewController.canSendMail())
      return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.createAccountButton.addTarget(self, action: #selector(createAccountButtonPressed),
                                       for: .touchUpInside)

    self.loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)

    self.newsletterSwitch.addTarget(self, action: #selector(newsletterSwitchChanged),
                                    for: .valueChanged)

    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(newsletterLabelTapped))
    self.newsletterLabel.addGestureRecognizer(tapGestureRecognizer)

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()

    _ = self.confirmationLabel |> fbConfirmationMessageLabelStyle
    _ = self.createAccountButton |> createNewAccountButtonStyle
    _ = self.emailLabel |> fbConfirmEmailLabelStyle
    _ = self.loginButton |> loginWithEmailButtonStyle
    _ = self.loginLabel |> fbWrongAccountLabelStyle
    _ = self.navigationItem.title = Strings.signup_navbar_title()
    _ = self.newsletterLabel
      |> newsletterLabelStyle
    _ = self.newsletterSwitch |> newsletterSwitchStyle
    _ = self.rootStackView |> loginRootStackViewStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.displayEmail
      .observeForUI()
      .observeValues { [weak self] email in
        self?.emailLabel.text = email
    }

    self.viewModel.outputs.sendNewsletters
      .observeForUI()
      .observeValues { [weak self] send in self?.newsletterSwitch.setOn(send, animated: false)
    }

    self.viewModel.outputs.showLogin
      .observeForControllerAction()
      .observeValues { [weak self] _ in self?.goToLoginViewController()
    }

    self.viewModel.outputs.logIntoEnvironment
      .observeValues { [weak self] env in
        AppEnvironment.login(env)
        self?.viewModel.inputs.environmentLoggedIn()
    }

    self.viewModel.outputs.postNotification
      .observeForUI()
      .observeValues(NotificationCenter.default.post)

    self.viewModel.errors.showSignupError
      .observeForControllerAction()
      .observeValues { [weak self] message in
        self?.present(UIAlertController.genericError(message), animated: true, completion: nil)
    }

    self.helpViewModel.outputs.showHelpSheet
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.showHelpSheet(helpTypes: $0)
    }

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
  }

  fileprivate func goToHelpType(_ helpType: HelpType) {
    let vc = HelpWebViewController.configuredWith(helpType: helpType)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  fileprivate func goToLoginViewController() {
    self.navigationController?.pushViewController(LoginViewController.instantiate(), animated: true)
  }

  fileprivate func showHelpSheet(helpTypes: [HelpType]) {
    let helpSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

    helpTypes.forEach { helpType in
      helpSheet.addAction(
        UIAlertAction(title: helpType.title, style: .default) { [weak helpVM = self.helpViewModel] _ in
          helpVM?.inputs.helpTypeButtonTapped(helpType)
        }
      )
    }

    helpSheet.addAction(
      UIAlertAction(
        title: Strings.login_tout_help_sheet_cancel(),
        style: .cancel
      ) { [weak helpVM = self.helpViewModel] _ in
        helpVM?.inputs.cancelHelpSheetButtonTapped()
      }
    )

    //iPad provision
    helpSheet.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem

    self.present(helpSheet, animated: true, completion: nil)
  }

  @objc private func newsletterSwitchChanged(_ sender: UISwitch) {
    self.viewModel.inputs.sendNewslettersToggled(sender.isOn)
  }

  @objc private func createAccountButtonPressed() {
    self.viewModel.inputs.createAccountButtonPressed()
  }

  @objc private func loginButtonPressed() {
    self.viewModel.inputs.loginButtonPressed()
  }

  @objc fileprivate func newsletterLabelTapped() {
    self.helpViewModel.inputs.showHelpSheetButtonTapped()
  }

  @objc internal func mailComposeController(_ controller: MFMailComposeViewController,
                                            didFinishWith result: MFMailComposeResult,
                                            error: Error?) {
    self.helpViewModel.inputs.mailComposeCompletion(result: result)
    self.dismiss(animated: true, completion: nil)
  }
}
