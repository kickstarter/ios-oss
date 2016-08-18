import Library
import Prelude
import Prelude_UIKit
import ReactiveCocoa
import ReactiveExtensions
import UIKit

internal final class ResetPasswordViewController: UIViewController {
  @IBOutlet weak var emailTextFieldBackgroundView: UIView!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var resetPasswordButton: BorderButton!

  private let viewModel: ResetPasswordViewModelType = ResetPasswordViewModel()

  internal static func configuredWith(email email: String?) -> ResetPasswordViewController {
    let vc = Storyboard.Login.instantiate(ResetPasswordViewController)
    if let email = email {
      vc.viewModel.inputs.emailChanged(email)
    }
    return vc
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()
  }

  override func bindStyles() {
    self |> resetPasswordControllerStyle
    self.emailTextField |> emailFieldStyle
    self.emailTextFieldBackgroundView |> cardStyle()
    self.resetPasswordButton |> resetPasswordButtonStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.setEmailInitial
      .observeForUI()
      .observeNext { [weak self] email in
        self?.emailTextField.text = email
      }

    self.resetPasswordButton.rac.enabled = self.viewModel.outputs.formIsValid

    self.viewModel.outputs.showResetSuccess
      .observeForUI()
      .observeNext { [weak self] message in
        self?.presentViewController(UIAlertController.alert(
          message: message,
          handler: { alert in
            self?.viewModel.inputs.confirmResetButtonPressed()
          }), animated: true, completion: nil)
      }

    self.viewModel.outputs.returnToLogin
      .observeForUI()
      .observeNext { [weak self] _ in
        self?.navigationController?.popViewControllerAnimated(true)
      }

    self.viewModel.errors.showError
      .observeForUI()
      .observeNext { [weak self] message in
        self?.presentViewController(UIAlertController.genericError(message), animated: true, completion: nil)
      }
  }

  @IBAction
  internal func emailTextFieldEditingChanged(textfield: UITextField) {
    self.viewModel.inputs.emailChanged(textfield.text)
  }

  @IBAction
  internal func resetPasswordPressed(sender: UIButton) {
    self.emailTextField.resignFirstResponder()
    self.viewModel.inputs.resetButtonPressed()
  }
}
