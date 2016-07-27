import ReactiveCocoa
import Foundation
import UIKit
import MessageUI
import Library
import KsApi
import Prelude
import FBSDKLoginKit

internal final class LoginToutViewController: UIViewController, MFMailComposeViewControllerDelegate {
  @IBOutlet private weak var fbDisclaimer: UILabel!
  @IBOutlet private weak var fbLoginButton: UIButton!
  @IBOutlet private weak var fbLoginStackView: UIStackView!
  @IBOutlet private weak var helpButton: UIButton!
  @IBOutlet private weak var loginButton: UIButton!
  @IBOutlet private weak var loginSignupButtonsStackView: UIStackView!
  @IBOutlet private weak var signupButton: UIButton!
  @IBOutlet private weak var rootStackView: UIStackView!

  private let viewModel: LoginToutViewModelType = LoginToutViewModel()
  private let helpViewModel = HelpViewModel()

  private lazy var fbLoginManager: FBSDKLoginManager = {
    let manager = FBSDKLoginManager()
    manager.loginBehavior = .SystemAccount
    manager.defaultAudience = .Friends
    return manager
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    NSNotificationCenter.defaultCenter()
      .addObserverForName(CurrentUserNotifications.sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }

    if let _ = self.presentingViewController {
      self.navigationItem.leftBarButtonItem = .close(self, selector: #selector(closeButtonPressed))
    }
    self.navigationItem.rightBarButtonItem = .help(self, selector: #selector(helpButtonPressed))
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.view(isPresented: self.presentingViewController != nil)
    self.viewModel.inputs.viewWillAppear()
  }

  override func bindStyles() {
    self |> baseControllerStyle()

    self.fbDisclaimer |> disclaimerLabelStyle
    self.fbLoginButton |> facebookButtonStyle
    self.fbLoginStackView |> fbLoginStackViewStyle
    self.helpButton |> disclaimerButtonStyle
    self.loginButton |> loginWithEmailButtonStyle
    self.loginSignupButtonsStackView |> loginSignupButtonsStackViewStyle
    self.rootStackView |> loginRootStackViewStyle
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

    self.viewModel.outputs.dismissViewController
      .observeForUI()
      .observeNext { [weak self] in
        self?.dismissViewControllerAnimated(true, completion: nil)
    }

    self.helpViewModel.outputs.showHelpSheet
      .observeForUI()
      .observeNext { [weak self] in
        self?.showHelpSheet(helpTypes: $0)
    }

    self.helpViewModel.outputs.showMailCompose
      .observeForUI()
      .observeNext { [weak self] in
        guard let _self = self else { return }
        let controller = MFMailComposeViewController.support()
        controller.mailComposeDelegate = _self
        _self.presentViewController(controller, animated: true, completion: nil)
    }

    self.helpViewModel.outputs.showNoEmailError
      .observeForUI()
      .observeNext { [weak self] alert in
        self?.presentViewController(alert, animated: true, completion: nil)
    }

    self.helpViewModel.outputs.showWebHelp
      .observeForUI()
      .observeNext { [weak self] helpType in
        self?.goToHelpType(helpType)
    }
  }
  // swiftlint:enable function_body_length

  internal func configureWith(loginIntent intent: LoginIntent) {
    self.viewModel.inputs.loginIntent(intent)
    self.helpViewModel.inputs.configureWith(helpContext: .loginTout)
    self.helpViewModel.inputs.canSendEmail(MFMailComposeViewController.canSendMail())
  }

  @objc internal func mailComposeController(controller: MFMailComposeViewController,
                                            didFinishWithResult result: MFMailComposeResult,
                                                                error: NSError?) {
    self.helpViewModel.inputs.mailComposeCompletion(result: result)
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  private func goToHelpType(helpType: HelpType) {
    guard let helpVC = UIStoryboard(name: "Help", bundle: .framework)
      .instantiateViewControllerWithIdentifier("HelpWebViewController") as? HelpWebViewController else {
        fatalError("Could not instantiate HelpWebViewController")
    }

    helpVC.configureWith(helpType: helpType)
    self.navigationController?.pushViewController(helpVC, animated: true)
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

  private func showHelpSheet(helpTypes helpTypes: [HelpType]) {
    let helpSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

    helpTypes.forEach { helpType in
      helpSheet.addAction(UIAlertAction(title: helpType.title, style: .Default, handler: {
        [weak helpVM = self.helpViewModel] _ in
        helpVM?.inputs.helpTypeButtonTapped(helpType)
      }))
    }

    helpSheet.addAction(UIAlertAction(title: Strings.login_tout_help_sheet_cancel(),
      style: .Cancel,
      handler: { [weak helpVM = self.helpViewModel] _ in
        helpVM?.inputs.cancelHelpSheetButtonTapped()
      }))

    //iPad provision
    helpSheet.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem

    self.presentViewController(helpSheet, animated: true, completion: nil)
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

  @objc private func closeButtonPressed() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  @objc private func helpButtonPressed() {
    self.helpViewModel.inputs.showHelpSheetButtonTapped()
  }

  @IBAction private func loginButtonPressed(sender: UIButton) {
    self.viewModel.inputs.loginButtonPressed()
  }

  @IBAction private func facebookLoginButtonPressed(sender: UIButton) {
    self.viewModel.inputs.facebookLoginButtonPressed()
  }

  @IBAction private func signupButtonPressed() {
    self.viewModel.inputs.signupButtonPressed()
  }
}
