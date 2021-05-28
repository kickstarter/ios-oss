import Library
import MessageUI
import Prelude
import Prelude_UIKit
import UIKit

internal final class SignupViewController: UIViewController, MFMailComposeViewControllerDelegate {
  fileprivate let viewModel: SignupViewModelType = SignupViewModel()
  fileprivate let helpViewModel = HelpViewModel()

  @IBOutlet fileprivate var scrollView: UIScrollView!
  @IBOutlet fileprivate var disclaimerTextView: UITextView!
  @IBOutlet fileprivate var emailTextField: UITextField!
  @IBOutlet fileprivate var formBackgroundView: UIView!
  @IBOutlet fileprivate var nameTextField: UITextField!
  @IBOutlet fileprivate var newsletterLabel: UILabel!
  @IBOutlet fileprivate var newsletterSwitch: UISwitch!
  @IBOutlet fileprivate var passwordTextField: UITextField!
  @IBOutlet fileprivate var rootStackView: UIStackView!
  @IBOutlet fileprivate var signupButton: UIButton!

  internal static func instantiate() -> SignupViewController {
    let vc = Storyboard.Login.instantiate(SignupViewController.self)
    vc.helpViewModel.inputs.configureWith(helpContext: .signup)
    vc.helpViewModel.inputs.canSendEmail(MFMailComposeViewController.canSendMail())
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.nameTextField.addTarget(
      self,
      action: #selector(self.nameTextFieldReturn),
      for: .editingDidEndOnExit
    )

    self.nameTextField.addTarget(
      self,
      action: #selector(self.nameTextFieldChanged(_:)),
      for: [.editingDidEndOnExit, .editingChanged]
    )

    self.emailTextField.addTarget(
      self,
      action: #selector(self.emailTextFieldReturn),
      for: .editingDidEndOnExit
    )

    self.emailTextField.addTarget(
      self,
      action: #selector(self.emailTextFieldChanged(_:)),
      for: [.editingDidEndOnExit, .editingChanged]
    )

    self.passwordTextField.addTarget(
      self,
      action: #selector(self.passwordTextFieldReturn),
      for: .editingDidEndOnExit
    )

    self.passwordTextField.addTarget(
      self,
      action: #selector(self.passwordTextFieldChanged(_:)),
      for: [.editingChanged]
    )

    let newsletterLabelTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(self.newsletterLabelTapped)
    )
    self.newsletterLabel.addGestureRecognizer(newsletterLabelTapGesture)

    self.disclaimerTextView.delegate = self

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> signupControllerStyle

    _ = self.disclaimerTextView
      |> disclaimerTextViewStyle

    _ = self.nameTextField
      |> UITextField.lens.returnKeyType .~ .next
      |> UITextField.lens.placeholder %~ { _ in Strings.Name() }

    _ = self.emailTextField
      |> emailFieldAutoFillStyle
      |> UITextField.lens.returnKeyType .~ .next

    _ = self.formBackgroundView
      |> cardStyle()

    _ = self.newsletterLabel
      |> newsletterLabelStyle

    _ = self.passwordTextField
      |> newPasswordFieldAutoFillStyle
      |> UITextField.lens.returnKeyType .~ .go

    _ = self.rootStackView
      |> loginRootStackViewStyle

    _ = self.signupButton
      |> signupButtonStyle
  }

  internal override func bindViewModel() {
    self.emailTextField.rac.becomeFirstResponder = self.viewModel.outputs.emailTextFieldBecomeFirstResponder
    self.newsletterSwitch.rac.on = self.viewModel.outputs.setWeeklyNewsletterState
    self.passwordTextField.rac.becomeFirstResponder =
      self.viewModel.outputs.passwordTextFieldBecomeFirstResponder
    self.signupButton.rac.enabled = self.viewModel.outputs.isSignupButtonEnabled

    self.viewModel.outputs.logIntoEnvironment
      .observeValues { [weak self] env in
        AppEnvironment.login(env)
        self?.viewModel.inputs.environmentLoggedIn()
      }

    self.viewModel.outputs.postNotification
      .observeForUI()
      .observeValues(NotificationCenter.default.post)

    self.viewModel.outputs.showError
      .observeForControllerAction()
      .observeValues { [weak self] message in
        self?.present(
          UIAlertController.alert(nil, message: message),
          animated: true, completion: nil
        )
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
    self.viewModel.outputs.notifyDelegateOpenHelpType
      .observeForUI()
      .observeValues { [weak self] helpType in
        self?.goToHelpType(helpType)
      }

    self.helpViewModel.outputs.showWebHelp
      .observeForControllerAction()
      .observeValues { [weak self] helpType in
        self?.goToHelpType(helpType)
      }

    Keyboard.change.observeForUI()
      .observeValues { [weak self] in self?.animateTextViewConstraint($0) }
  }

  @objc internal func emailTextFieldChanged(_ textField: UITextField) {
    self.viewModel.inputs.emailChanged(textField.text ?? "")
  }

  @objc internal func emailTextFieldReturn(_: UITextField) {
    self.viewModel.inputs.emailTextFieldReturn()
  }

  @objc internal func nameTextFieldChanged(_ textField: UITextField) {
    self.viewModel.inputs.nameChanged(textField.text ?? "")
  }

  @objc internal func nameTextFieldReturn(_: UITextField) {
    self.viewModel.inputs.nameTextFieldReturn()
  }

  @objc internal func passwordTextFieldChanged(_ textField: UITextField) {
    self.viewModel.inputs.passwordChanged(textField.text ?? "")
  }

  @objc internal func passwordTextFieldReturn(_: UITextField) {
    self.viewModel.inputs.passwordTextFieldReturn()
  }

  @IBAction internal func weeklyNewsletterChanged(_ newsletterSwitch: UISwitch) {
    self.viewModel.inputs.weeklyNewsletterChanged(newsletterSwitch.isOn)
  }

  @IBAction internal func signupButtonPressed() {
    self.viewModel.inputs.signupButtonPressed()
  }

  @objc fileprivate func newsletterLabelTapped() {
    self.helpViewModel.inputs.showHelpSheetButtonTapped()
  }

  @objc internal func mailComposeController(
    _: MFMailComposeViewController,
    didFinishWith result: MFMailComposeResult,
    error _: Error?
  ) {
    self.helpViewModel.inputs.mailComposeCompletion(result: result)
    self.dismiss(animated: true, completion: nil)
  }

  fileprivate func animateTextViewConstraint(_ change: Keyboard.Change) {
    UIView.animate(withDuration: change.duration, delay: 0.0, options: change.options, animations: {
      self.scrollView.contentInset.bottom = change.frame.height
    }, completion: nil)
  }

  fileprivate func goToHelpType(_ helpType: HelpType) {
    let vc = HelpWebViewController.configuredWith(helpType: helpType)
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension SignupViewController: UITextViewDelegate {
  func textView(
    _: UITextView,
    shouldInteractWith _: NSTextAttachment,
    in _: NSRange,
    interaction _: UITextItemInteraction
  ) -> Bool {
    return false
  }

  func textView(
    _: UITextView, shouldInteractWith url: URL,
    in _: NSRange,
    interaction _: UITextItemInteraction
  ) -> Bool {
    self.viewModel.inputs.tapped(url)
    return false
  }
}
