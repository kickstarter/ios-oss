import Library
import MessageUI
import Prelude
import Prelude_UIKit
import UIKit

internal final class SignupViewController: UIViewController, MFMailComposeViewControllerDelegate {
  fileprivate let viewModel: SignupViewModelType = SignupViewModel()
  fileprivate let helpViewModel = HelpViewModel()

  @IBOutlet fileprivate weak var bottomConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate weak var disclaimerButton: UIButton!
  @IBOutlet fileprivate weak var emailTextField: UITextField!
  @IBOutlet fileprivate weak var formBackgroundView: UIView!
  @IBOutlet fileprivate weak var nameTextField: UITextField!
  @IBOutlet fileprivate weak var newsletterLabel: UILabel!
  @IBOutlet fileprivate weak var newsletterSwitch: UISwitch!
  @IBOutlet fileprivate weak var passwordTextField: UITextField!
  @IBOutlet fileprivate weak var rootStackView: UIStackView!
  @IBOutlet fileprivate weak var signupButton: UIButton!

  internal static func instantiate() -> SignupViewController {
    let vc = Storyboard.Login.instantiate(SignupViewController.self)
    vc.helpViewModel.inputs.configureWith(helpContext: .signup)
    vc.helpViewModel.inputs.canSendEmail(MFMailComposeViewController.canSendMail())
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.disclaimerButton.addTarget(self, action: #selector(disclaimerButtonPressed),
                                    for: .touchUpInside)

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> signupControllerStyle

    _ = self.disclaimerButton
      |> disclaimerButtonStyle

    _ = self.emailTextField
      |> emailFieldStyle

    _ = self.formBackgroundView
      |> cardStyle()

    _ = self.nameTextField
      |> UITextField.lens.placeholder %~ { _ in Strings.signup_input_fields_full_name() }

    _ = self.newsletterLabel
      |> newsletterLabelStyle

    _ = self.passwordTextField
      |> passwordFieldStyle

    _ = self.rootStackView
      |> loginRootStackViewStyle

    _ = self.signupButton
      |> signupButtonStyle
  }

  internal override func bindViewModel() {
    self.emailTextField.rac.becomeFirstResponder = self.viewModel.outputs.emailTextFieldBecomeFirstResponder
    self.nameTextField.rac.becomeFirstResponder = self.viewModel.outputs.nameTextFieldBecomeFirstResponder
    self.newsletterSwitch.rac.on = self.viewModel.outputs.setWeeklyNewsletterState
    self.passwordTextField.rac.becomeFirstResponder =
      self.viewModel.outputs.passwordTextFieldBecomeFirstResponder
    self.signupButton.rac.enabled = self.viewModel.outputs.isSignupButtonEnabled

    self.viewModel.outputs.logIntoEnvironment
      .observeValues { [weak self] in
        AppEnvironment.login($0)
        self?.viewModel.inputs.environmentLoggedIn()
      }

    self.viewModel.outputs.postNotification
      .observeForUI()
      .observeValues(NotificationCenter.default.post)

    self.viewModel.outputs.showError
      .observeForControllerAction()
      .observeValues { [weak self] message in
        self?.present(
          UIAlertController.alert(Strings.signup_error_title(), message: message),
          animated: true, completion: nil
        )
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

    Keyboard.change.observeForUI()
      .observeValues { [weak self] in self?.animateTextViewConstraint($0) }
  }

  @IBAction internal func emailChanged(_ textField: UITextField) {
    self.viewModel.inputs.emailChanged(textField.text ?? "")
  }

  @IBAction internal func nameChanged(_ textField: UITextField) {
    self.viewModel.inputs.nameChanged(textField.text ?? "")
  }

  @IBAction internal func passwordChanged(_ textField: UITextField) {
    self.viewModel.inputs.passwordChanged(textField.text ?? "")
  }

  @IBAction internal func weeklyNewsletterChanged(_ newsletterSwitch: UISwitch) {
    self.viewModel.inputs.weeklyNewsletterChanged(newsletterSwitch.isOn)
  }

  @IBAction internal func signupButtonPressed() {
    self.viewModel.inputs.signupButtonPressed()
  }

  @objc fileprivate func disclaimerButtonPressed() {
    self.helpViewModel.inputs.showHelpSheetButtonTapped()
  }

  @objc internal func mailComposeController(_ controller: MFMailComposeViewController,
                                            didFinishWith result: MFMailComposeResult,
                                                                error: Error?) {
    self.helpViewModel.inputs.mailComposeCompletion(result: result)
    self.dismiss(animated: true, completion: nil)
  }

  fileprivate func animateTextViewConstraint(_ change: Keyboard.Change) {
    UIView.animate(withDuration: change.duration, delay: 0.0, options: change.options, animations: {
      self.bottomConstraint.constant = self.view.frame.height - change.frame.minY
      }, completion: nil)
  }

  fileprivate func goToHelpType(_ helpType: HelpType) {
    let vc = HelpWebViewController.configuredWith(helpType: helpType)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  fileprivate func showHelpSheet(helpTypes: [HelpType]) {
    let helpSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

    helpTypes.forEach { helpType in
      helpSheet.addAction(UIAlertAction(title: helpType.title, style: .default, handler: {
        [weak helpVM = self.helpViewModel] _ in
        helpVM?.inputs.helpTypeButtonTapped(helpType)
        }))
    }

    helpSheet.addAction(UIAlertAction(title: Strings.login_tout_help_sheet_cancel(),
      style: .cancel,
      handler: { [weak helpVM = self.helpViewModel] _ in
        helpVM?.inputs.cancelHelpSheetButtonTapped()
      }))

    //iPad provision
    helpSheet.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem

    self.present(helpSheet, animated: true, completion: nil)
  }
}

extension SignupViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    switch textField {
    case emailTextField:
      self.viewModel.inputs.emailTextFieldReturn()
    case nameTextField:
      self.viewModel.inputs.nameTextFieldReturn()
    case passwordTextField:
      self.viewModel.inputs.passwordTextFieldReturn()
    default:
      fatalError("\(textField) unrecognized")
    }

    return true
  }
}
