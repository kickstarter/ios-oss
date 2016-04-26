import Foundation
import UIKit
import ReactiveExtensions
import ReactiveCocoa
import Library
import Prelude
import FBSDKCoreKit

internal final class FacebookConfirmationViewController: UIViewController {

  @IBOutlet weak var emailLabel: StyledLabel!
  @IBOutlet weak var newsletterSwitch: UISwitch!
  @IBOutlet weak var createAccountButton: BorderButton!
  @IBOutlet weak var helpButton: BorderButton!
  @IBOutlet weak var loginButton: BorderButton!

  let viewModel: FacebookConfirmationViewModelType = FacebookConfirmationViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.viewModel.inputs.viewDidLoad()
  }

  override func bindViewModel() {

    self.emailLabel.rac.text = self.viewModel.outputs.displayEmail

    self.viewModel.outputs.sendNewsletters
      .observeForUI()
      .observeNext { [weak self] send in self?.newsletterSwitch.setOn(send, animated: false)
    }

    self.viewModel.outputs.showLogin
      .observeForUI()
      .observeNext { [weak self] _ in self?.pushLoginViewController()
    }

    self.viewModel.outputs.logIntoEnvironment
      .observeNext { [weak self] env in
        AppEnvironment.login(env)
        self?.viewModel.inputs.environmentLoggedIn()
    }

    self.viewModel.outputs.postNotification
      .observeNext { note in
        NSNotificationCenter.defaultCenter().postNotification(note)
    }

    self.viewModel.errors.showSignupError
      .observeForUI()
      .observeNext { [weak self] message in
        self?.presentViewController(UIAlertController.genericError(message), animated: true, completion: nil)
    }
  }

  internal func configureWith(facebookUserEmail email: String, facebookAccessToken token: String) {
    self.viewModel.inputs.email(email)
    self.viewModel.inputs.facebookToken(token)
  }

  internal func pushLoginViewController() {
    guard let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController")
      as? LoginViewController else {
        fatalError("Couldn’t instantiate LoginViewController")
    }
    self.navigationController?.pushViewController(loginVC, animated: true)
  }

  @IBAction func newsletterSwitchChanged(sender: UISwitch) {
    self.viewModel.inputs.sendNewslettersToggled(sender.on)
  }
  @IBAction func createAccountButtonPressed(sender: AnyObject) {
    self.viewModel.inputs.createAccountButtonPressed()
  }
  @IBAction func loginButtonPressed(sender: BorderButton) {
    self.viewModel.inputs.loginButtonPressed()
  }
  @IBAction func helpButtonPressed(sender: AnyObject) {
  }
}
