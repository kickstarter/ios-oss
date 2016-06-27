import Library
import Prelude
import Prelude_UIKit
import ReactiveCocoa
import UIKit

internal final class LoginViewController: UIViewController {
  @IBOutlet internal weak var emailTextField: UITextField!
  @IBOutlet internal weak var forgotPasswordButton: UIButton!
  @IBOutlet internal weak var formBackgroundView: UIView!
  @IBOutlet internal weak var formDividerView: UIView!
  @IBOutlet internal weak var loginButton: UIButton!
  @IBOutlet internal weak var onePasswordButton: UIButton!
  @IBOutlet internal weak var passwordTextField: UITextField!

  internal let viewModel: LoginViewModelType = LoginViewModel()

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

    self.formDividerView |> UIView.lens.backgroundColor .~ .ksr_gray

    self.formBackgroundView |> cardStyle()

    self.onePasswordButton |> onePasswordButtonStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.emailTextField.rac.text = self.viewModel.outputs.emailText
    self.loginButton.rac.enabled = self.viewModel.outputs.isFormValid
    self.passwordTextField.rac.text = self.viewModel.outputs.passwordText
    self.onePasswordButton.rac.hidden = self.viewModel.outputs.onePasswordButtonHidden

    self.viewModel.outputs.passwordTextFieldBecomeFirstResponder
      .observeForUI()
      .observeNext { [weak self] _ in
        self?.passwordTextField.becomeFirstResponder()
    }

    self.viewModel.outputs.dismissKeyboard
      .observeForUI()
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
      .observeForUI()
      .observeNext { [weak self] in
        self?.startResetPasswordViewController()
      }

    self.viewModel.outputs.showError
      .observeForUI()
      .observeNext { [weak self] message in
        self?.presentViewController(UIAlertController.genericError(message), animated: true, completion: nil)
    }

    self.viewModel.outputs.tfaChallenge
      .observeForUI()
      .observeNext { [weak self] (email, password) in
        self?.startTwoFactorViewController(email, password: password)
    }

    self.viewModel.outputs.onePasswordFindLoginForURLString
      .observeForUI()
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
    guard let tfaVC = self.storyboard?
      .instantiateViewControllerWithIdentifier("TwoFactorViewController") as? TwoFactorViewController else {
        fatalError("Couldn’t instantiate TwoFactorViewController.")
    }

    tfaVC.configureWith(email: email, password: password)
    self.navigationController?.pushViewController(tfaVC, animated: true)
  }

  private func startResetPasswordViewController() {
    guard let resetPasswordVC = self.storyboard?
      .instantiateViewControllerWithIdentifier("ResetPasswordViewController") as? ResetPasswordViewController
      else {
        fatalError("Couldn’t instantiate ResetPasswordViewController.")
    }

    resetPasswordVC.configureWith(email: emailTextField.text)
    self.navigationController?.pushViewController(resetPasswordVC, animated: true)
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
