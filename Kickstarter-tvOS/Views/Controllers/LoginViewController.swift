import UIKit
import ReactiveCocoa
import ReactiveExtensions
import Library

final class LoginViewController: UIViewController {

  @IBOutlet private weak var emailTextField: UITextField!
  @IBOutlet private weak var passwordTextField: UITextField!
  @IBOutlet private weak var loginButton: UIButton!

  let viewModel: LoginViewModel

  init(viewModel: LoginViewModel = LoginViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: LoginViewController.defaultNib, bundle: nil)
  }

  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func bindViewModel() {
    super.bindViewModel()

    viewModel.inputs.email <~ emailTextField.rac_text
    viewModel.inputs.password <~ passwordTextField.rac_text
    loginButton.rac_enabled <~ viewModel.outputs.isValid

    viewModel.errors.invalidLogin
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
    alertController.addAction(
      UIAlertAction(
        title: NSLocalizedString("OK", comment: ""),
        style: .Cancel,
        handler: nil
      )
    )
    self.presentViewController(alertController, animated: true, completion: nil)
  }

  @IBAction private func loginButtonPressed(sender: UIButton) {
    viewModel.inputs.loginPressed()
  }
}
