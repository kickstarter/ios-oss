import Foundation
import UIKit
import ReactiveExtensions
import ReactiveCocoa
import Library
import Prelude
import FBSDKCoreKit

internal final class FacebookConfirmationViewController: UIViewController {
  @IBOutlet weak var confirmationLabel: UILabel!
  @IBOutlet weak var createAccountButton: UIButton!
  @IBOutlet weak var emailLabel: UILabel!
  @IBOutlet weak var helpButton: UIButton!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var loginLabel: UILabel!
  @IBOutlet weak var newsletterLabel: UILabel!
  @IBOutlet weak var newsletterSwitch: UISwitch!

  let viewModel: FacebookConfirmationViewModelType = FacebookConfirmationViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()
  }

  override func bindStyles() {
    self |> baseControllerStyle()

    self.confirmationLabel
      |> UILabel.lens.textColor .~ .ksr_textDefault
      |> UILabel.lens.font .~ .ksr_body()

    self.createAccountButton |> createNewAccountButtonStyle

    self.emailLabel
      |> UILabel.lens.textColor .~ .ksr_textDefault
      |> UILabel.lens.font .~ .ksr_headline()
      |> UILabel.lens.textAlignment .~ .Center

    self.helpButton |> disclaimerButtonStyle

    self.loginButton |> loginWithEmailButtonStyle

    self.loginLabel |> UILabel.lens.font .~ .ksr_caption1()

    self.newsletterLabel |> newsletterLabelStyle
  }

  override func bindViewModel() {
    self.viewModel.outputs.displayEmail
      .observeForUI()
      .observeNext { [weak self] email in
        self?.emailLabel.text = email
    }

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
