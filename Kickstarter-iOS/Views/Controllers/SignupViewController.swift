import Library
import Prelude
import Prelude_UIKit
import UIKit

internal final class SignupViewController: UIViewController {
  @IBOutlet private weak var emailTextField: UITextField!
  @IBOutlet private weak var formBackgroundView: UIView!
  @IBOutlet private weak var nameTextField: UITextField!
  @IBOutlet private weak var newsletterSwitch: UISwitch!
  @IBOutlet private weak var passwordTextField: UITextField!
  @IBOutlet private weak var signupButton: UIButton!

  private let viewModel: SignupViewModelType = SignupViewModel()

  internal static func instantiate() -> SignupViewController {
    return Storyboard.Login.instantiate(SignupViewController)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()
  }

  override func bindStyles() {
    self |> signupControllerStyle

    self.signupButton |> signupButtonStyle

    self.formBackgroundView |> cardStyle()
  }

  override func bindViewModel() {
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
      .observeNext(NSNotificationCenter.defaultCenter().postNotification)

    self.viewModel.outputs.showError
      .observeForControllerAction()
      .observeNext { [weak self] message in
        self?.presentViewController(
          UIAlertController
            .alert(
              Strings.signup_error_title(),
              message: message),
          animated: true, completion: nil)
      }
  }

  @IBAction internal func emailChanged(textField: UITextField) {
    self.viewModel.inputs.emailChanged(textField.text ?? "")
  }

  @IBAction internal func nameChanged(textField: UITextField) {
    self.viewModel.inputs.nameChanged(textField.text ?? "")
  }

  @IBAction internal func passwordChanged(textField: UITextField) {
    self.viewModel.inputs.passwordChanged(textField.text ?? "")
  }

  @IBAction internal func weeklyNewsletterChanged(newsletterSwitch: UISwitch) {
    self.viewModel.inputs.weeklyNewsletterChanged(newsletterSwitch.on)
  }

  @IBAction internal func signupButtonPressed() {
    self.viewModel.inputs.signupButtonPressed()
  }
}

extension SignupViewController: UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
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
