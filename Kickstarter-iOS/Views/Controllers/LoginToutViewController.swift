import ReactiveCocoa
import Foundation
import UIKit
import MessageUI
import Library
import SafariServices
import KsApi
import Prelude
import FBSDKLoginKit

internal final class LoginToutViewController: UIViewController, MFMailComposeViewControllerDelegate {
  @IBOutlet internal weak var fbLoginButton: UIButton!
  @IBOutlet internal weak var fbDisclaimer: UILabel!
  @IBOutlet internal weak var helpButton: UIButton!
  @IBOutlet internal weak var loginButton: UIButton!
  @IBOutlet internal weak var signupButton: UIButton!

  internal let viewModel: LoginToutViewModelType = LoginToutViewModel()

  internal lazy var fbLoginManager: FBSDKLoginManager = {
    let manager = FBSDKLoginManager()
    manager.loginBehavior = .SystemAccount
    manager.defaultAudience = .Friends
    return manager
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    if let _ = self.presentingViewController {
      self.navigationItem.leftBarButtonItem = .close(self, selector: #selector(closeButtonPressed))
    }
    self.navigationItem.rightBarButtonItem = .help(self, selector: #selector(helpButtonPressed))
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }

  override func bindStyles() {
    self |> baseControllerStyle()
    self.fbLoginButton |> facebookButtonStyle
    self.fbDisclaimer |> disclaimerLabelStyle
    self.helpButton |> disclaimerButtonStyle
    self.loginButton |> loginWithEmailButtonStyle
    self.signupButton |> signupWithEmailButtonStyle
  }

// swiftlint:disable function_body_length
  override func bindViewModel() {
    self.viewModel.outputs.startLogin
      .observeForUI()
      .observeNext { [weak self] _ in
        self?.pushLoginViewController()
    }
    self.viewModel.outputs.startSignup
      .observeForUI()
      .observeNext { [weak self] _ in
        self?.pushSignupViewController()
    }

    self.viewModel.outputs.logIntoEnvironment
      .observeNext { [weak self] accessTokenEnv in
        AppEnvironment.login(accessTokenEnv)
        self?.viewModel.inputs.environmentLoggedIn()
    }

    self.viewModel.outputs.postNotification
      .observeNext { note in
        NSNotificationCenter.defaultCenter().postNotification(note)
    }

    self.viewModel.outputs.startFacebookConfirmation
      .observeForUI()
      .observeNext { [weak self] (user, token) in
        self?.pushFacebookConfirmationController(facebookUser: user, facebookToken: token)
    }

    self.viewModel.outputs.startTwoFactorChallenge
      .observeForUI()
      .observeNext { [weak self] token in
        self?.pushTwoFactorViewController(facebookAccessToken: token)
    }

    self.viewModel.outputs.showHelpActionSheet
      .observeForUI()
      .observeNext { [weak self] actions in
        self?.showHelp(actions)
    }

    self.viewModel.outputs.showHelp
      .observeForUI()
      .observeNext { [weak self] helpType in
        self?.showHelpType(helpType)
    }

    self.viewModel.outputs.attemptFacebookLogin
      .observeNext { [weak self] _ in self?.attemptFacebookLogin()
    }

    self.viewModel.outputs.showFacebookErrorAlert
      .observeForUI()
      .observeNext { [weak self] error in
        self?.presentViewController(
          UIAlertController.alertController(forError: error),
          animated: true,
          completion: nil
        )
    }
  }
  // swiftlint:enable function_body_length

  internal func configureWith(loginIntent intent: LoginIntent) {
    self.viewModel.inputs.loginIntent(intent)
  }

  @IBAction
  internal func loginButtonPressed(sender: UIButton) {
    self.viewModel.inputs.loginButtonPressed()
  }

  @IBAction func helpButtonPressed() {
    self.viewModel.inputs.helpButtonPressed()
  }

  @IBAction func facebookLoginButtonPressed(sender: UIButton) {
    self.viewModel.inputs.facebookLoginButtonPressed()
  }

  @IBAction private func signupButtonPressed() {
    self.viewModel.inputs.signupButtonPressed()
  }

  internal func closeButtonPressed() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  internal func showHelp(helpTypes: [HelpType]) {
    let helpAlert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

    helpTypes.forEach { helpType in
      helpAlert.addAction(UIAlertAction(title: helpType.title, style: .Default, handler: { [weak self] _ in
        self?.viewModel.inputs.helpTypeButtonPressed(helpType)
        }))
    }
    helpAlert.addAction(UIAlertAction(title: Strings.login_tout_help_sheet_cancel(),
      style: .Cancel,
      handler: nil))

    // iPad provision
    helpAlert.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem

    self.presentViewController(helpAlert, animated: true, completion: nil)
  }

  @objc internal func mailComposeController(controller: MFMailComposeViewController,
                                            didFinishWithResult result: MFMailComposeResult,
                                                                error: NSError?) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  private func pushLoginViewController() {
    guard let loginVC = self.storyboard?
      .instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController else {
        fatalError("Couldn’t instantiate LoginViewController.")
    }

    self.navigationController?.pushViewController(loginVC, animated: true)
  }

  private func pushTwoFactorViewController(facebookAccessToken token: String) {
    guard let tfaVC = self.storyboard?.instantiateViewControllerWithIdentifier("TwoFactorViewController")
      as? TwoFactorViewController else {
        fatalError("Failed to instantiate TwoFactorViewController")
    }
    tfaVC.configureWith(facebookAccessToken: token)
    self.navigationController?.pushViewController(tfaVC, animated: true)
  }

  private func pushFacebookConfirmationController(facebookUser user: ErrorEnvelope.FacebookUser?,
                                                               facebookToken token: String) {
    guard let fbVC = self.storyboard?
      .instantiateViewControllerWithIdentifier("FacebookConfirmationViewController")
      as? FacebookConfirmationViewController else {
        fatalError("Failed to instantiate FacebookConfirmationViewController")
    }
    fbVC.configureWith(facebookUserEmail: user?.email ?? "", facebookAccessToken: token)
    self.navigationController?.pushViewController(fbVC, animated: true)
  }

  private func pushSignupViewController() {
    guard let signupVC = self.storyboard?
      .instantiateViewControllerWithIdentifier("SignupViewController") as? SignupViewController else {
        fatalError("Couldn’t instantiate SignupViewController.")
    }

    self.navigationController?.pushViewController(signupVC, animated: true)
  }

  private func showHelpType(helpType: HelpType) {
    switch helpType {
    case .Contact:
      let mcvc = MFMailComposeViewController.support()
      mcvc.mailComposeDelegate = self
      self.presentViewController(mcvc, animated: true, completion: nil)
    default:
      let svc = SFSafariViewController.help(helpType, baseURL: ServerConfig.production.webBaseUrl)
      self.presentViewController(svc, animated: true, completion: nil)
    }
  }

  // MARK: Facebook Login
  private func attemptFacebookLogin() {
    self.fbLoginManager.logInWithReadPermissions(
      ["public_profile", "email", "user_friends"],
      fromViewController: self) {
        (result: FBSDKLoginManagerLoginResult!, error: NSError!) in
        if error != nil {
          self.viewModel.inputs.facebookLoginFail(error: error)
        } else if !result.isCancelled {
          self.viewModel.inputs.facebookLoginSuccess(result: result)
        }
    }
  }
}
