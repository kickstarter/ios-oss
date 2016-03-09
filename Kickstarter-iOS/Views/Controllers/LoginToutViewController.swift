import UIKit.UIButton
import class Library.MVVMViewController

internal final class LoginToutViewController: MVVMViewController {
  @IBOutlet private weak var facebookButton: UIButton!
  @IBOutlet private weak var signupButton: UIButton!
  @IBOutlet private weak var loginButton: UIButton!

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
