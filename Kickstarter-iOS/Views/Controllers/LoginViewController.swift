import func Foundation.NSLocalizedString
import ReactiveExtensions
import class UIKit.UITextField
import class UIKit.UIButton
import class UIKit.UIAlertAction
import class UIKit.UIAlertController
import class ReactiveCocoa.MutableProperty
import func ReactiveCocoa.<~
import class Library.MVVMViewController

internal final class LoginViewController: MVVMViewController {

  @IBOutlet private weak var emailTextField: UITextField!
  @IBOutlet private weak var passwordTextField: UITextField!
  @IBOutlet private weak var loginButton: UIButton!

  let viewModel: LoginViewModelType = LoginViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = NSLocalizedString("Log in", comment: "")
  }

  override func bindViewModel() {
    self.viewModel.inputs.email <~ emailTextField.rac_text
    self.viewModel.inputs.password <~ passwordTextField.rac_text
    self.loginButton.rac_enabled <~ self.viewModel.outputs.isFormValid

    self.viewModel.outputs.isFormValid.producer
      .observeForUI()
      .startWithNext { [weak self] isValid in
        self?.loginButton.alpha = isValid ? 1.0 : 0.5
    }

    self.viewModel.outputs.logInSuccess
      .observeForUI()
      .observeNext { [weak self] _ in
        self?.onLoginSuccess()
    }

    self.viewModel.errors.invalidLogin
      .observeForUI()
      .observeNext { [weak self] message in
        self?.presentError(message)
    }

    self.viewModel.errors.genericError
      .observeForUI()
      .map { NSLocalizedString("Unable to login.", comment: "") }
      .observeNext { [weak self] message in
        self?.presentError(message)
    }
  }

  private func onLoginSuccess() {
    self.dismissViewControllerAnimated(false, completion: nil)
    self.navigationController?.tabBarController?.selectedIndex = 0
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
