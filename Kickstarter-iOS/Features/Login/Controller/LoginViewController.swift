import Library
import Prelude
import Prelude_UIKit
import ReactiveSwift
import UIKit

internal final class LoginViewController: UIViewController {
  @IBOutlet fileprivate var emailTextField: UITextField!
  @IBOutlet fileprivate var forgotPasswordButton: UIButton!
  @IBOutlet fileprivate var formBackgroundView: UIView!
  @IBOutlet fileprivate var formDividerView: UIView!
  @IBOutlet fileprivate var loginButton: UIButton!
  @IBOutlet fileprivate var passwordTextField: UITextField!
  @IBOutlet fileprivate var rootStackView: UIStackView!
  @IBOutlet fileprivate var showHidePasswordButton: UIButton!

  internal let viewModel: LoginViewModelType = LoginViewModel()

  internal static func instantiate() -> LoginViewController {
    return Storyboard.Login.instantiate(LoginViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
    self.view.addGestureRecognizer(tap)

    self.emailTextField.addTarget(
      self,
      action: #selector(self.emailTextFieldDoneEditing),
      for: .editingDidEndOnExit
    )

    self.emailTextField.addTarget(
      self,
      action: #selector(self.emailTextFieldChanged(_:)),
      for: [.editingDidEndOnExit, .editingChanged]
    )

    self.passwordTextField.addTarget(
      self,
      action: #selector(self.passwordTextFieldDoneEditing),
      for: .editingDidEndOnExit
    )

    self.passwordTextField.addTarget(
      self,
      action: #selector(self.passwordTextFieldChanged(_:)),
      for: .editingChanged
    )

    self.showHidePasswordButton.addTarget(
      self,
      action: #selector(self.showHidePasswordButtonTapped),
      for: .touchUpInside
    )

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    self.viewModel.inputs.traitCollectionDidChange()
  }

  override func bindStyles() {
    _ = self |> loginControllerStyle

    _ = self.loginButton
      |> greenButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in
        Strings.login_tout_back_intent_traditional_login_button()
      }

    _ = self.forgotPasswordButton |> forgotPasswordButtonStyle

    _ = self.emailTextField |> emailFieldAutoFillStyle
      |> UITextField.lens.returnKeyType .~ .next

    _ = self.showHidePasswordButton |> showHidePasswordButtonStyle
      |> \.frame .~ CGRect(x: 0, y: 0, width: 45, height: 30)
      |> UIButton.lens.image(for: .normal) .~ image(
        named: "icon--eye",
        inBundle: Bundle.framework,
        compatibleWithTraitCollection: nil
      )
      |> UIButton.lens.accessibilityValue %~ { _ in
        Strings.Show_password()
      }

    _ = self.passwordTextField |> passwordFieldAutoFillStyle
      |> UITextField.lens.returnKeyType .~ .go

    _ = self.formDividerView |> separatorStyle

    _ = self.formBackgroundView |> cardStyle()

    _ = self.rootStackView |> loginRootStackViewStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.emailTextField.rac.becomeFirstResponder = self.viewModel.outputs.emailTextFieldBecomeFirstResponder
    self.loginButton.rac.enabled = self.viewModel.outputs.isFormValid
    self.passwordTextField.rac.becomeFirstResponder =
      self.viewModel.outputs.passwordTextFieldBecomeFirstResponder

    self.viewModel.outputs.showHidePasswordButtonToggled
      .observeForUI()
      .observeValues { [weak self] shouldShow in
        self?.updateShowHidePassword(shouldShow)
      }

    self.viewModel.outputs.dismissKeyboard
      .observeForControllerAction()
      .observeValues { [weak self] _ in
        self?.dismissKeyboard()
      }

    self.viewModel.outputs.postNotification
      .observeForUI()
      .observeValues {
        NotificationCenter.default.post($0.0)
        NotificationCenter.default.post($0.1)
      }

    self.viewModel.outputs.logIntoEnvironment
      .observeValues { [weak self] env in
        AppEnvironment.login(env)
        self?.viewModel.inputs.environmentLoggedIn()
      }

    self.viewModel.outputs.showResetPassword
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.startResetPasswordViewController()
      }

    self.viewModel.outputs.showError
      .observeForControllerAction()
      .observeValues { [weak self] message in
        self?.present(UIAlertController.genericError(message), animated: true, completion: nil)
      }

    self.viewModel.outputs.tfaChallenge
      .observeForControllerAction()
      .observeValues { [weak self] email, password in
        self?.startTwoFactorViewController(email, password: password)
      }
  }

  fileprivate func startTwoFactorViewController(_ email: String, password: String) {
    let vc = TwoFactorViewController.configuredWith(email: email, password: password)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  fileprivate func startResetPasswordViewController() {
    let vc = ResetPasswordViewController.configuredWith(email: self.emailTextField.text)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  fileprivate func updateShowHidePassword(_ shouldShow: Bool) {
    let tintColor: UIColor = shouldShow ? .ksr_create_700 : .ksr_support_300
    let accessibilityValue = shouldShow ? Strings.Hide_password() : Strings.Show_password()

    _ = self.showHidePasswordButton
      |> UIButton.lens.tintColor .~ tintColor
      |> UIButton.lens.accessibilityValue .~ accessibilityValue

    let currentText = self.passwordTextField ^* UITextField.lens.text

    // Note: workaround for cursor whitespace render bug
    _ = self.passwordTextField
      |> UITextField.lens.secureTextEntry .~ !shouldShow
      |> UITextField.lens.text .~ " "
      |> UITextField.lens.text .~ currentText
  }

  @IBAction
  internal func loginButtonPressed(_: UIButton) {
    self.viewModel.inputs.loginButtonPressed()
  }

  @objc internal func emailTextFieldChanged(_ textField: UITextField) {
    self.viewModel.inputs.emailChanged(textField.text)
  }

  @objc internal func emailTextFieldDoneEditing() {
    self.viewModel.inputs.emailTextFieldDoneEditing()
  }

  @objc internal func passwordTextFieldChanged(_ textField: UITextField) {
    self.viewModel.inputs.passwordChanged(textField.text)
  }

  @objc internal func passwordTextFieldDoneEditing() {
    self.viewModel.inputs.passwordTextFieldDoneEditing()
  }

  @IBAction
  internal func resetPasswordButtonPressed(_: UIButton) {
    self.viewModel.inputs.resetPasswordButtonPressed()
  }

  @objc internal func dismissKeyboard() {
    self.view.endEditing(true)
  }

  @objc func showHidePasswordButtonTapped() {
    self.viewModel.inputs.showHidePasswordButtonTapped()
  }
}
