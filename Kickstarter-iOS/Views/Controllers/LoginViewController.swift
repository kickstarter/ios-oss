import Library
import Prelude
import Prelude_UIKit
import ReactiveSwift
import UIKit

internal final class LoginViewController: UIViewController {
  @IBOutlet fileprivate weak var emailTextField: UITextField!
  @IBOutlet fileprivate weak var forgotPasswordButton: UIButton!
  @IBOutlet fileprivate weak var formBackgroundView: UIView!
  @IBOutlet fileprivate weak var formDividerView: UIView!
  @IBOutlet fileprivate weak var loginButton: UIButton!
  @IBOutlet fileprivate weak var onePasswordButton: UIButton!
  @IBOutlet fileprivate weak var passwordTextField: UITextField!
  @IBOutlet fileprivate weak var rootStackView: UIStackView!

  internal let viewModel: LoginViewModelType = LoginViewModel()

  internal static func instantiate() -> LoginViewController {
    return Storyboard.Login.instantiate(LoginViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    self.view.addGestureRecognizer(tap)

    self.onePasswordButton.addTarget(self,
                                     action: #selector(onePasswordButtonTapped),
                                     for: .touchUpInside)

    self.emailTextField.addTarget(self,
                                  action: #selector(emailTextFieldDoneEditing),
                                  for: .editingDidEndOnExit)

    self.emailTextField.addTarget(self,
                                  action: #selector(emailTextFieldChanged(_:)),
                                  for: [.editingDidEndOnExit, .editingChanged])

    self.passwordTextField.addTarget(self,
                                     action: #selector(passwordTextFieldDoneEditing),
                                     for: .editingDidEndOnExit)

    self.passwordTextField.addTarget(self,
                                     action: #selector(passwordTextFieldChanged(_:)),
                                     for: .editingChanged)

    self.viewModel.inputs.onePassword(
      isAvailable: OnePasswordExtension.shared().isAppExtensionAvailable()
    )

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }

  override func bindStyles() {
    _ = self |> loginControllerStyle

    _ = self.loginButton |> loginButtonStyle

    _ = self.forgotPasswordButton |> forgotPasswordButtonStyle

    _ = self.emailTextField |> emailFieldStyle
      |> UITextField.lens.returnKeyType .~ .next

    _ = self.passwordTextField |> passwordFieldStyle
      |> UITextField.lens.returnKeyType .~ .go

    _ = self.formDividerView |> separatorStyle

    _ = self.formBackgroundView |> cardStyle()

    _ = self.onePasswordButton |> onePasswordButtonStyle

    _ = self.rootStackView |> loginRootStackViewStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.emailTextField.rac.becomeFirstResponder = self.viewModel.outputs.emailTextFieldBecomeFirstResponder
    self.emailTextField.rac.text = self.viewModel.outputs.emailText
    self.loginButton.rac.enabled = self.viewModel.outputs.isFormValid
    self.passwordTextField.rac.becomeFirstResponder =
      self.viewModel.outputs.passwordTextFieldBecomeFirstResponder
    self.passwordTextField.rac.text = self.viewModel.outputs.passwordText
    self.onePasswordButton.rac.hidden = self.viewModel.outputs.onePasswordButtonHidden

    self.viewModel.outputs.dismissKeyboard
      .observeForControllerAction()
      .observeValues { [weak self] _ in
        self?.dismissKeyboard()
    }

    self.viewModel.outputs.postNotification
      .observeForUI()
      .observeValues(NotificationCenter.default.post)

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
      .observeValues { [weak self] (email, password) in
        self?.startTwoFactorViewController(email, password: password)
    }

    self.viewModel.outputs.onePasswordFindLoginForURLString
      .observeForControllerAction()
      .observeValues { [weak self] in self?.onePasswordFindLogin(forURLString: $0) }
  }

  fileprivate func onePasswordFindLogin(forURLString string: String) {

    OnePasswordExtension.shared()
      .findLogin(forURLString: string, for: self, sender: self.onePasswordButton) { result, _ in
        guard let result = result else { return }

        self.viewModel.inputs.onePasswordFoundLogin(
          email: result[AppExtensionUsernameKey] as? String,
          password: result[AppExtensionPasswordKey] as? String
        )
    }
  }

  fileprivate func startTwoFactorViewController(_ email: String, password: String) {
    let vc = TwoFactorViewController.configuredWith(email: email, password: password)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  fileprivate func startResetPasswordViewController() {
    let vc = ResetPasswordViewController.configuredWith(email: emailTextField.text)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  @IBAction
  internal func loginButtonPressed(_ sender: UIButton) {
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
  internal func resetPasswordButtonPressed(_ sender: UIButton) {
    self.viewModel.inputs.resetPasswordButtonPressed()
  }

  @objc fileprivate func onePasswordButtonTapped() {
    self.viewModel.inputs.onePasswordButtonTapped()
  }

  internal func dismissKeyboard() {
    self.view.endEditing(true)
  }
}
