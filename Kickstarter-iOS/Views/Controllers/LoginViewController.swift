import func Foundation.NSLocalizedString
import class ReactiveExtensions.UITextField
import class UIKit.UIButton
import class UIKit.UIAlertAction
import class UIKit.UIAlertController
import class ReactiveCocoa.MutableProperty
import func ReactiveCocoa.<~
import class Library.MVVMViewController
import class Library.BorderButton

internal final class LoginViewController: MVVMViewController {

  @IBOutlet private weak var emailTextField: UITextField!
  @IBOutlet private weak var passwordTextField: UITextField!
  @IBOutlet private weak var loginButton: BorderButton!

  let viewModel: LoginViewModelType = LoginViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func bindViewModel() {
    self.viewModel.inputs.email <~ emailTextField.rac_text
    self.viewModel.inputs.password <~ passwordTextField.rac_text
    self.loginButton.rac_enabled <~ viewModel.outputs.isValid

    self.viewModel.errors.invalidLogin
      .observeNext { [weak self] message in
        self?.presentError(message)
    }

    viewModel.errors.genericError
      .map { NSLocalizedString("Unable to login.", comment: "") }
      .observeNext { [weak self] message in
        self?.presentError(message)
    }
  }

  private func presentError(message: String) {
    let alertController = UIAlertController(
      title: NSLocalizedString("Oops, something went wrong!", comment: ""),
      message: message,
      preferredStyle: .Alert
    )
    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Cancel, handler: nil))
    self.presentViewController(alertController, animated: true, completion: nil)
  }

  @IBAction
  internal func loginButtonPressed(sender: UIButton) {
    self.viewModel.inputs.loginButtonPressed()
  }
}
