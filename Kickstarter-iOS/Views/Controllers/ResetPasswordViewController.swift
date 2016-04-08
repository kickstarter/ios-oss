import Foundation
import UIKit
import ReactiveExtensions
import ReactiveCocoa
import Library
import Prelude

internal final class ResetPasswordViewController: MVVMViewController {

  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var resetPasswordButton: BorderButton!

  private let viewModel: ResetPasswordViewModelType = ResetPasswordViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.title = localizedString(key: "forgot_password.title", defaultValue: "Forgot your password?")
    self.view.backgroundColor = Color.OffWhite.toUIColor()

    self.emailTextField.borderStyle = .None
    self.emailTextField.layer.borderColor = Color.Gray.toUIColor().CGColor
    self.emailTextField.layer.borderWidth = 1.0
    self.emailTextField.leftView = UIView(frame: CGRectMake(0, 0, 10, 0))
    self.emailTextField.leftViewMode = UITextFieldViewMode.Always;
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.formIsValid
      .observeForUI()
      .observeNext { [weak self] isValid in
        self?.resetPasswordButton.enabled = isValid
        self?.resetPasswordButton.alpha = isValid ? 1.0 : 0.5
      }

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
