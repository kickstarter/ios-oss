import Foundation
import UIKit
import ReactiveExtensions
import ReactiveCocoa
import Library
import Prelude

internal final class TwoFactorViewController: MVVMViewController {

  @IBOutlet weak var codeTextField: UITextField!
  @IBOutlet weak var resendButton: BorderButton!
  @IBOutlet weak var submitButton: BorderButton!

  private let viewModel: TwoFactorViewModelType = TwoFactorViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.title = localizedString(key: "two_factor.title", defaultValue: "Verify")
    self.view.backgroundColor = Color.OffWhite.toUIColor()

    codeTextField.borderStyle = .None
    codeTextField.layer.borderColor = Color.Gray.toUIColor().CGColor
    codeTextField.layer.borderWidth = 1.0
    codeTextField.leftView = UIView(frame: CGRectMake(0, 0, 10, 0))
    codeTextField.leftViewMode = UITextFieldViewMode.Always;
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
        self?.submitButton.alpha = isValid ? 1.0 : 0.5
        self?.submitButton.enabled = isValid
    }

    self.viewModel.outputs.logIntoEnvironment
      .observeNext { [weak self] env in
        AppEnvironment.login(env)
        self?.viewModel.inputs.environmentLoggedIn()
    }

    self.viewModel.outputs.postNotification
      .observeNext(NSNotificationCenter.defaultCenter().postNotification)

    self.viewModel.errors.showError
      .observeForUI()
      .observeNext { [weak self] message in
        self?.showError(message)
      }
  }

  internal func email(email: String, password: String) {
    self.viewModel.inputs.email(email, password: password)
  }

  internal func facebookToken(facebookToken: String) {
    self.viewModel.inputs.facebookToken(facebookToken)
  }

  private func showError(message: String) {
    self.presentViewController(UIAlertController.genericError(message), animated: true, completion: nil)
  }

  @IBAction
  internal func codeEditingChanged(textField: UITextField) {
    self.viewModel.inputs.codeChanged(textField.text)
  }

  @IBAction
  internal func resendButtonPressed(sender: AnyObject) {
    self.viewModel.inputs.resendPressed()
  }

  @IBAction
  internal func submitButtonPressed(sender: AnyObject) {
    self.viewModel.inputs.submitPressed()
  }
}
