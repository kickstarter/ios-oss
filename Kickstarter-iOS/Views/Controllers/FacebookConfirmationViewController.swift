import Foundation
import UIKit
import ReactiveExtensions
import ReactiveCocoa
import Library
import Prelude
import FBSDKCoreKit
import MessageUI

internal final class FacebookConfirmationViewController: UIViewController,
  MFMailComposeViewControllerDelegate {
  @IBOutlet private weak var confirmationLabel: UILabel!
  @IBOutlet private weak var createAccountButton: UIButton!
  @IBOutlet private weak var emailLabel: UILabel!
  @IBOutlet private weak var helpButton: UIButton!
  @IBOutlet private weak var loginButton: UIButton!
  @IBOutlet private weak var loginLabel: UILabel!
  @IBOutlet private weak var newsletterLabel: UILabel!
  @IBOutlet private weak var newsletterSwitch: UISwitch!
  @IBOutlet private weak var rootStackView: UIStackView!

  private let viewModel: FacebookConfirmationViewModelType = FacebookConfirmationViewModel()
  private let helpViewModel = HelpViewModel()

  internal static func configuredWith(facebookUserEmail email: String, facebookAccessToken token: String)
    -> FacebookConfirmationViewController {

      let vc = Storyboard.Login.instantiate(FacebookConfirmationViewController)
      vc.viewModel.inputs.email(email)
      vc.viewModel.inputs.facebookToken(token)
      vc.helpViewModel.inputs.configureWith(helpContext: .facebookConfirmation)
      vc.helpViewModel.inputs.canSendEmail(MFMailComposeViewController.canSendMail())
      return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.helpButton.addTarget(self, action: #selector(helpButtonPressed), forControlEvents: .TouchUpInside)

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    self |> baseControllerStyle()
    self.confirmationLabel |> fbConfirmationMessageLabelStyle
    self.createAccountButton |> createNewAccountButtonStyle
    self.emailLabel |> fbConfirmEmailLabelStyle
    self.helpButton |> disclaimerButtonStyle
    self.loginButton |> loginWithEmailButtonStyle
    self.loginLabel |> fbWrongAccountLabelStyle
    self.navigationItem.title = Strings.signup_navbar_title()
    self.newsletterLabel |> newsletterLabelStyle
    self.rootStackView |> loginRootStackViewStyle
  }

  // swiftlint:disable function_body_length
  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.displayEmail
      .observeForControllerAction()
      .observeNext { [weak self] email in
        self?.emailLabel.text = email
    }

    self.viewModel.outputs.sendNewsletters
      .observeForControllerAction()
      .observeNext { [weak self] send in self?.newsletterSwitch.setOn(send, animated: false)
    }

    self.viewModel.outputs.showLogin
      .observeForControllerAction()
      .observeNext { [weak self] _ in self?.goToLoginViewController()
    }

    self.viewModel.outputs.logIntoEnvironment
      .observeNext { [weak self] env in
        AppEnvironment.login(env)
        self?.viewModel.inputs.environmentLoggedIn()
    }

    self.viewModel.outputs.postNotification
      .observeForUI()
      .observeNext(NSNotificationCenter.defaultCenter().postNotification)

    self.viewModel.errors.showSignupError
      .observeForControllerAction()
      .observeNext { [weak self] message in
        self?.presentViewController(UIAlertController.genericError(message), animated: true, completion: nil)
    }

    self.helpViewModel.outputs.showHelpSheet
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.showHelpSheet(helpTypes: $0)
    }

    self.helpViewModel.outputs.showMailCompose
      .observeForControllerAction()
      .observeNext { [weak self] in
        guard let _self = self else { return }
        let controller = MFMailComposeViewController.support()
        controller.mailComposeDelegate = _self
        _self.presentViewController(controller, animated: true, completion: nil)
    }

    self.helpViewModel.outputs.showNoEmailError
      .observeForControllerAction()
      .observeNext { [weak self] alert in
        self?.presentViewController(alert, animated: true, completion: nil)
    }

    self.helpViewModel.outputs.showWebHelp
      .observeForControllerAction()
      .observeNext { [weak self] helpType in
        self?.goToHelpType(helpType)
    }
  }
  // swiftlint:enable function_body_length

  private func goToHelpType(helpType: HelpType) {
    let vc = HelpWebViewController.configuredWith(helpType: helpType)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func goToLoginViewController() {
    self.navigationController?.pushViewController(LoginViewController.instantiate(), animated: true)
  }

  private func showHelpSheet(helpTypes helpTypes: [HelpType]) {
    let helpSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

    helpTypes.forEach { helpType in
      helpSheet.addAction(
        UIAlertAction(title: helpType.title, style: .Default) { [weak helpVM = self.helpViewModel] _ in
          helpVM?.inputs.helpTypeButtonTapped(helpType)
        }
      )
    }

    helpSheet.addAction(
      UIAlertAction(
        title: Strings.login_tout_help_sheet_cancel(),
        style: .Cancel
      ) { [weak helpVM = self.helpViewModel] _ in
        helpVM?.inputs.cancelHelpSheetButtonTapped()
      }
    )

    //iPad provision
    helpSheet.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem

    self.presentViewController(helpSheet, animated: true, completion: nil)
  }

  @IBAction private func newsletterSwitchChanged(sender: UISwitch) {
    self.viewModel.inputs.sendNewslettersToggled(sender.on)
  }

  @IBAction private func createAccountButtonPressed(sender: AnyObject) {
    self.viewModel.inputs.createAccountButtonPressed()
  }

  @IBAction private func loginButtonPressed(sender: BorderButton) {
    self.viewModel.inputs.loginButtonPressed()
  }

  @objc private func helpButtonPressed(sender: AnyObject) {
    self.helpViewModel.inputs.showHelpSheetButtonTapped()
  }

  @objc internal func mailComposeController(controller: MFMailComposeViewController,
                                            didFinishWithResult result: MFMailComposeResult,
                                                                error: NSError?) {
    self.helpViewModel.inputs.mailComposeCompletion(result: result)
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}
