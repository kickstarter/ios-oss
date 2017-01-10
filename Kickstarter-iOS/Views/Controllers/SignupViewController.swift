import Library
import MessageUI
import Prelude
import Prelude_UIKit
import UIKit

internal final class SignupViewController: UIViewController, MFMailComposeViewControllerDelegate {
  private let viewModel: SignupViewModelType = SignupViewModel()
  private let helpViewModel = HelpViewModel()

  @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
  @IBOutlet private weak var disclaimerButton: UIButton!
  @IBOutlet private weak var emailTextField: UITextField!
  @IBOutlet private weak var formBackgroundView: UIView!
  @IBOutlet private weak var nameTextField: UITextField!
  @IBOutlet private weak var newsletterLabel: UILabel!
  @IBOutlet private weak var newsletterSwitch: UISwitch!
  @IBOutlet private weak var passwordTextField: UITextField!
  @IBOutlet private weak var rootStackView: UIStackView!
  @IBOutlet private weak var signupButton: UIButton!

  internal static func instantiate() -> SignupViewController {
    let vc = Storyboard.Login.instantiate(SignupViewController)
    vc.helpViewModel.inputs.configureWith(helpContext: .signup)
    vc.helpViewModel.inputs.canSendEmail(MFMailComposeViewController.canSendMail())
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.disclaimerButton.addTarget(self, action: #selector(disclaimerButtonPressed),
                                    forControlEvents: .TouchUpInside)

    self.nameTextField.addTarget(self,
                                 action: #selector(nameTextFieldReturn),
                                 forControlEvents: .EditingDidEndOnExit)
    self.nameTextField.addTarget(self,
                                 action: #selector(nameTextFieldChanged(_:)),
                                 forControlEvents: [.EditingDidEndOnExit, .EditingChanged])
    self.emailTextField.addTarget(self,
                                  action: #selector(emailTextFieldReturn),
                                  forControlEvents: .EditingDidEndOnExit)
    self.emailTextField.addTarget(self,
                                  action: #selector(emailTextFieldChanged(_:)),
                                  forControlEvents: [.EditingDidEndOnExit, .EditingChanged])
    self.passwordTextField.addTarget(self,
                                     action: #selector(passwordTextFieldReturn),
                                     forControlEvents: .EditingDidEndOnExit)
    self.passwordTextField.addTarget(self,
                                     action: #selector(passwordTextFieldChanged(_:)),
                                     forControlEvents: [.EditingChanged])

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> signupControllerStyle

    self.disclaimerButton
      |> disclaimerButtonStyle

    self.nameTextField
      |> UITextField.lens.returnKeyType .~ .Next

    self.emailTextField |> emailFieldStyle
      <> UITextField.lens.returnKeyType .~ .Next

    self.formBackgroundView
      |> cardStyle()

    self.nameTextField
      |> UITextField.lens.placeholder %~ { _ in Strings.signup_input_fields_full_name() }

    self.newsletterLabel
      |> newsletterLabelStyle

    self.passwordTextField |> passwordFieldStyle
      <> UITextField.lens.returnKeyType .~ .Go

    self.rootStackView
      |> loginRootStackViewStyle

    self.signupButton
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
      .observeNext { [weak self] in
        AppEnvironment.login($0)
        self?.viewModel.inputs.environmentLoggedIn()
      }

    self.viewModel.outputs.postNotification
      .observeForUI()
      .observeNext(NSNotificationCenter.defaultCenter().postNotification)

    self.viewModel.outputs.showError
      .observeForControllerAction()
      .observeNext { [weak self] message in
        self?.presentViewController(
          UIAlertController.alert(Strings.signup_error_title(), message: message),
          animated: true, completion: nil
        )
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

    Keyboard.change.observeForUI()
      .observeNext { [weak self] in self?.animateTextViewConstraint($0) }
  }

  @objc internal func emailTextFieldChanged(textField: UITextField) { //this
    self.viewModel.inputs.emailChanged(textField.text ?? "")
  }

  @objc internal func emailTextFieldReturn(textField: UITextField) {
    self.viewModel.inputs.emailTextFieldReturn()
  }

  @objc internal func nameTextFieldChanged(textField: UITextField) { //this
    self.viewModel.inputs.nameChanged(textField.text ?? "")
  }

  @objc internal func nameTextFieldReturn(textField: UITextField) {
    self.viewModel.inputs.nameTextFieldReturn()
  }

  @objc internal func passwordTextFieldChanged(textField: UITextField) { //this
    self.viewModel.inputs.passwordChanged(textField.text ?? "")
  }

  @objc internal func passwordTextFieldReturn(textField: UITextField) {
    self.viewModel.inputs.passwordTextFieldReturn()
  }

  @IBAction internal func weeklyNewsletterChanged(newsletterSwitch: UISwitch) {
    self.viewModel.inputs.weeklyNewsletterChanged(newsletterSwitch.on)
  }

  @IBAction internal func signupButtonPressed() {
    self.viewModel.inputs.signupButtonPressed()
  }

  @objc private func disclaimerButtonPressed() {
    self.helpViewModel.inputs.showHelpSheetButtonTapped()
  }

  @objc internal func mailComposeController(controller: MFMailComposeViewController,
                                            didFinishWithResult result: MFMailComposeResult,
                                                                error: NSError?) {
    self.helpViewModel.inputs.mailComposeCompletion(result: result)
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  private func animateTextViewConstraint(change: Keyboard.Change) {
    UIView.animateWithDuration(change.duration, delay: 0.0, options: change.options, animations: {
      self.bottomConstraint.constant = self.view.frame.height - change.frame.minY
      }, completion: nil)
  }

  private func goToHelpType(helpType: HelpType) {
    let vc = HelpWebViewController.configuredWith(helpType: helpType)
    self.navigationController?.pushViewController(vc, animated: true)
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

    helpSheet.addAction(UIAlertAction(title: Strings.login_tout_help_sheet_cancel(),
      style: .Cancel,
      handler: { [weak helpVM = self.helpViewModel] _ in
        helpVM?.inputs.cancelHelpSheetButtonTapped()
      }))

    //iPad provision
    helpSheet.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem

    self.presentViewController(helpSheet, animated: true, completion: nil)
  }
}
