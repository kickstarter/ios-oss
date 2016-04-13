import ReactiveExtensions
import ReactiveCocoa
import Foundation
import UIKit
import Library
import Prelude

internal final class LoginViewController: MVVMViewController {
  @IBOutlet internal weak var emailTextField: UITextField!
  @IBOutlet internal weak var passwordTextField: UITextField!
  @IBOutlet internal weak var loginButton: BorderButton!
  @IBOutlet internal weak var forgotPasswordButton: BorderButton!

  internal let viewModel: LoginViewModelType = LoginViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = localizedString(key: "login.navbar.title", defaultValue: "Log in")
    self.view.backgroundColor = Color.OffWhite.toUIColor()

    emailTextField.borderStyle = .None
    passwordTextField.borderStyle = .None
    emailTextField.layer.borderColor = Color.Gray.toUIColor().CGColor
    passwordTextField.layer.borderColor = Color.Gray.toUIColor().CGColor
    emailTextField.layer.borderWidth = 1.0
    passwordTextField.layer.borderWidth = 1.0

    emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
    emailTextField.leftViewMode = UITextFieldViewMode.Always

    passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
    passwordTextField.leftViewMode = UITextFieldViewMode.Always

    let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
    self.view.addGestureRecognizer(tap)
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.isFormValid
      .observeForUI()
      .observeNext { [weak self] isValid in
        self?.loginButton.alpha = isValid ? 1.0 : 0.5
        self?.loginButton.enabled = isValid
    }

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

    self.viewModel.errors.showError
      .observeForUI()
      .observeNext { [weak self] message in
        self?.presentViewController(UIAlertController.genericError(message), animated: true, completion: nil)
    }

    self.viewModel.errors.tfaChallenge
      .observeForUI()
      .observeNext { [weak self] (email, password) in
        self?.startTwoFactorViewController(email, password: password)
      }
  }

  private func startTwoFactorViewController(email: String, password: String) {
    guard let tfaVC = self.storyboard?
      .instantiateViewControllerWithIdentifier("TwoFactorViewController") as? TwoFactorViewController else {
        fatalError("Couldn’t instantiate TwoFactorViewController.")
    }

    tfaVC.initialize(email: email, password: password)
    self.navigationController?.pushViewController(tfaVC, animated: true)
  }

  private func startResetPasswordViewController() {
    guard let resetPasswordVC = self.storyboard?
      .instantiateViewControllerWithIdentifier("ResetPasswordViewController") as? ResetPasswordViewController
      else {
        fatalError("Couldn’t instantiate ResetPasswordViewController.")
    }

    resetPasswordVC.initialize(email: emailTextField.text)
    self.navigationController?.pushViewController(resetPasswordVC, animated: true)
  }

  @IBAction
  internal func loginButtonPressed(sender: UIButton) {
    self.viewModel.inputs.loginButtonPressed()
  }

  @IBAction
  internal func emailTextFieldChanged(textField: UITextField) {
    self.viewModel.inputs.emailChanged(textField.text)
  }

  @IBAction
  internal func emailTextFieldDoneEditing(textField: UITextField) {
    self.viewModel.inputs.emailTextFieldDoneEditing()
  }

  @IBAction
  internal func passwordTextFieldChanged(textField: UITextField) {
    self.viewModel.inputs.passwordChanged(textField.text)
  }

  @IBAction
  internal func passwordTextFieldDoneEditing(textField: UITextField) {
    self.viewModel.inputs.passwordTextFieldDoneEditing()
  }

  @IBAction
  internal func resetPasswordButtonPressed(sender: UIButton) {
    self.viewModel.inputs.resetPasswordButtonPressed()
  }

  internal func dismissKeyboard() {
    self.view.endEditing(true)
  }
}
