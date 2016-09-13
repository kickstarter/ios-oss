import Library
import Prelude
import Prelude_UIKit
import ReactiveCocoa
import UIKit

internal final class LoginViewController: UIViewController {
  @IBOutlet private weak var emailTextField: UITextField!
  @IBOutlet private weak var forgotPasswordButton: UIButton!
  @IBOutlet private weak var formBackgroundView: UIView!
  @IBOutlet private weak var formDividerView: UIView!
  @IBOutlet private weak var loginButton: UIButton!
  @IBOutlet private weak var onePasswordButton: UIButton!
  @IBOutlet private weak var passwordTextField: UITextField!

  internal let viewModel: LoginViewModelType = LoginViewModel()

  internal static func instantiate() -> LoginViewController {
    return Storyboard.Login.instantiate(LoginViewController)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    self.view.addGestureRecognizer(tap)

    self.onePasswordButton.addTarget(self,
                                     action: #selector(onePasswordButtonTapped),
                                     forControlEvents: .TouchUpInside)

    self.emailTextField.addTarget(self,
                                  action: #selector(emailTextFieldDoneEditing),
                                  forControlEvents: .EditingDidEndOnExit)
    self.emailTextField.addTarget(self,
                                  action: #selector(emailTextFieldChanged(_:)),
                                  forControlEvents: .EditingChanged)
    self.passwordTextField.addTarget(self,
                                     action: #selector(passwordTextFieldDoneEditing),
                                     forControlEvents: .EditingDidEndOnExit)
    self.passwordTextField.addTarget(self,
                                     action: #selector(passwordTextFieldChanged(_:)),
                                     forControlEvents: .EditingChanged)

    self.viewModel.inputs.onePassword(
      isAvailable: OnePasswordExtension.sharedExtension().isAppExtensionAvailable()
    )

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }

  override func bindStyles() {
    self |> loginControllerStyle

    self.loginButton |> loginButtonStyle

    self.forgotPasswordButton |> forgotPasswordButtonStyle

    self.emailTextField |> emailFieldStyle
      <> UITextField.lens.returnKeyType .~ .Next

    self.passwordTextField |> passwordFieldStyle
      <> UITextField.lens.returnKeyType .~ .Go

    self.formDividerView |> separatorStyle

    self.formBackgroundView |> cardStyle()

    self.onePasswordButton |> onePasswordButtonStyle
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
      .observeNext { [weak self] visible in
        self?.dismissKeyboard()
    }

    self.viewModel.outputs.postNotification
      .observeNext(NSNotificationCenter.defaultCenter().postNotification)

    self.viewModel.outputs.logIntoEnvironment
      .observeNext { [weak self] env in
        AppEnvironment.login(env)
        self?.viewModel.inputs.environmentLoggedIn()
    }

    self.viewModel.outputs.showResetPassword
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.startResetPasswordViewController()
      }

    self.viewModel.outputs.showError
      .observeForControllerAction()
      .observeNext { [weak self] message in
        self?.presentViewController(UIAlertController.genericError(message), animated: true, completion: nil)
    }

    self.viewModel.outputs.tfaChallenge
      .observeForControllerAction()
      .observeNext { [weak self] (email, password) in
        self?.startTwoFactorViewController(email, password: password)
    }

    self.viewModel.outputs.onePasswordFindLoginForURLString
      .observeForControllerAction()
      .observeNext { [weak self] in self?.onePasswordFindLogin(forURLString: $0) }
  }

  private func onePasswordFindLogin(forURLString string: String) {

    OnePasswordExtension.sharedExtension()
      .findLoginForURLString(string, forViewController: self, sender: self.onePasswordButton) { result, _ in
        guard let result = result else { return }

        self.viewModel.inputs.onePasswordFoundLogin(
          email: result[AppExtensionUsernameKey] as? String,
          password: result[AppExtensionPasswordKey] as? String
        )
    }
  }

  private func startTwoFactorViewController(email: String, password: String) {
    let vc = TwoFactorViewController.configuredWith(email: email, password: password)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func startResetPasswordViewController() {
    let vc = ResetPasswordViewController.configuredWith(email: emailTextField.text)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  @IBAction
  internal func loginButtonPressed(sender: UIButton) {
    self.viewModel.inputs.loginButtonPressed()
  }

  @objc internal func emailTextFieldChanged(textField: UITextField) {
    self.viewModel.inputs.emailChanged(textField.text)
  }

  @objc internal func emailTextFieldDoneEditing() {
    self.viewModel.inputs.emailTextFieldDoneEditing()
  }

  @objc internal func passwordTextFieldChanged(textField: UITextField) {
    self.viewModel.inputs.passwordChanged(textField.text)
  }

  @objc internal func passwordTextFieldDoneEditing() {
    self.viewModel.inputs.passwordTextFieldDoneEditing()
  }

  @IBAction
  internal func resetPasswordButtonPressed(sender: UIButton) {
    self.viewModel.inputs.resetPasswordButtonPressed()
  }

  @objc @IBAction private func onePasswordButtonTapped() {
    self.viewModel.inputs.onePasswordButtonTapped()
  }

  internal func dismissKeyboard() {
    self.view.endEditing(true)
  }
}
