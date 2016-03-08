import UIKit
import class Library.MVVMViewController
import class Library.FacebookButton
import class Library.BorderButton

internal final class LoginToutViewController: MVVMViewController {
  @IBOutlet private weak var facebookButton: FacebookButton!
  @IBOutlet private weak var signupButton: BorderButton!
  @IBOutlet private weak var loginButton: BorderButton!

  let viewModel: LoginToutViewModelType = LoginToutViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func bindViewModel() {
    self.viewModel.outputs.startLogin
      .observeForUI()
      .observeNext { [weak self] _ in
        self?.startLoginViewController()
    }
    self.viewModel.outputs.startSignup
      .observeForUI()
      .observeNext { [weak self] _ in
        self?.startSignupViewController()
    }
  }

  func startLoginViewController() {
    let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
    self.navigationController?.pushViewController(loginVC, animated: true)

  }

  func startSignupViewController() {

  }

  @IBAction
  internal func loginButtonPressed(sender: UIButton) {
    self.viewModel.inputs.loginButtonPressed()
  }
}
