import ReactiveSwift
import Foundation
import UIKit
import MessageUI
import Library
import KsApi
import Prelude
import FBSDKLoginKit

internal final class LoginToutViewController: UIViewController, MFMailComposeViewControllerDelegate {
  @IBOutlet fileprivate weak var contextLabel: UILabel!
  @IBOutlet fileprivate weak var bringCreativeProjectsToLifeLabel: UILabel!
  @IBOutlet fileprivate weak var fbLoginButton: UIButton!
  @IBOutlet fileprivate weak var disclaimerButton: UIButton!
  @IBOutlet fileprivate weak var loginButton: UIButton!
  @IBOutlet fileprivate weak var signupButton: UIButton!
  @IBOutlet fileprivate weak var loginContextStackView: UIStackView!
  @IBOutlet fileprivate weak var rootStackView: UIStackView!
  @IBOutlet fileprivate weak var facebookDisclaimerLabel: UILabel!

  fileprivate let helpViewModel = HelpViewModel()
  private var sessionStartedObserver: Any?
  fileprivate let viewModel: LoginToutViewModelType = LoginToutViewModel()

  fileprivate lazy var fbLoginManager: FBSDKLoginManager = {
    let manager = FBSDKLoginManager()
    manager.loginBehavior = .systemAccount
    manager.defaultAudience = .friends
    return manager
  }()

  internal static func configuredWith(loginIntent intent: LoginIntent) -> LoginToutViewController {
    let vc = Storyboard.Login.instantiate(LoginToutViewController.self)
    vc.viewModel.inputs.loginIntent(intent)
    vc.helpViewModel.inputs.configureWith(helpContext: .loginTout)
    vc.helpViewModel.inputs.canSendEmail(MFMailComposeViewController.canSendMail())
    return vc
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.fbLoginManager.logOut()

    self.sessionStartedObserver = NotificationCenter.default
      .addObserver(forName: .ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }

    if self.presentingViewController != nil {
      self.navigationItem.leftBarButtonItem = .close(self, selector: #selector(closeButtonPressed))
    }
    self.navigationItem.rightBarButtonItem = .help(self, selector: #selector(helpButtonPressed))

    self.disclaimerButton.addTarget(self, action: #selector(helpButtonPressed), for: .touchUpInside)
  }

  deinit {
    self.sessionStartedObserver.doIfSome(NotificationCenter.default.removeObserver)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.view(isPresented: self.presentingViewController != nil)
    self.viewModel.inputs.viewWillAppear()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self |> baseControllerStyle()
    _ = self.fbLoginButton |> fbLoginButtonStyle
    _ = self.disclaimerButton
      |> disclaimerButtonStyle
    _ = self.loginButton |> loginWithEmailButtonStyle
    _ = self.rootStackView
      |> loginRootStackViewStyle
      |> UIStackView.lens.spacing .~ Styles.grid(5)
    _ = self.signupButton |> signupWithEmailButtonStyle

    _ = self.facebookDisclaimerLabel |> fbDisclaimerTextStyle

    _ = self.bringCreativeProjectsToLifeLabel
      |> UILabel.lens.font %~~ { _, l in
        l.traitCollection.isRegularRegular
          ? .ksr_headline(size: 20)
          : .ksr_headline(size: 14)
      }
      |> UILabel.lens.text %~ { _ in Strings.Bring_creative_projects_to_life() }

    _ = self.contextLabel
      |> UILabel.lens.font %~~ { _, l in
        l.traitCollection.isRegularRegular
          ? .ksr_subhead(size: 20)
          : .ksr_subhead(size: 14)  }

    _ = self.loginContextStackView
      |> UIStackView.lens.spacing .~ Styles.gridHalf(1)
      |> UIStackView.lens.layoutMargins %~~ { _, stack in
        stack.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(10), leftRight: 0)
          : .init(top: Styles.grid(10), left: 0, bottom: Styles.grid(5), right: 0)
      }
      |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true
    }

    override func bindViewModel() {
    self.viewModel.outputs.startLogin
      .observeForControllerAction()
      .observeValues { [weak self] _ in
        self?.pushLoginViewController()
    }

    self.viewModel.outputs.startSignup
      .observeForControllerAction()
      .observeValues { [weak self] _ in
        self?.pushSignupViewController()
    }

    self.viewModel.outputs.logIntoEnvironment
      .observeValues { [weak self] accessTokenEnv in
        AppEnvironment.login(accessTokenEnv)
        self?.viewModel.inputs.environmentLoggedIn()
    }

    self.viewModel.outputs.postNotification
      .observeForUI()
      .observeValues {
        NotificationCenter.default.post($0.0)
        NotificationCenter.default.post($0.1)
      }

    self.viewModel.outputs.startFacebookConfirmation
      .observeForControllerAction()
      .observeValues { [weak self] (user, token) in
        self?.pushFacebookConfirmationController(facebookUser: user, facebookToken: token)
    }

    self.viewModel.outputs.startTwoFactorChallenge
      .observeForControllerAction()
      .observeValues { [weak self] token in
        self?.pushTwoFactorViewController(facebookAccessToken: token)
    }

    self.viewModel.outputs.attemptFacebookLogin
      .observeValues { [weak self] _ in self?.attemptFacebookLogin()
    }

    self.viewModel.outputs.showFacebookErrorAlert
      .observeForControllerAction()
      .observeValues { [weak self] error in
        self?.present(
          UIAlertController.alertController(forError: error),
          animated: true,
          completion: nil
        )
    }

    self.viewModel.outputs.dismissViewController
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.dismiss(animated: true, completion: nil)
    }

    self.helpViewModel.outputs.showHelpSheet
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.showHelpSheet(helpTypes: $0)
    }

    self.helpViewModel.outputs.showMailCompose
      .observeForControllerAction()
      .observeValues { [weak self] in
        guard let _self = self else { return }
        let controller = MFMailComposeViewController.support()
        controller.mailComposeDelegate = _self
        _self.present(controller, animated: true, completion: nil)
    }

    self.helpViewModel.outputs.showNoEmailError
      .observeForControllerAction()
      .observeValues { [weak self] alert in
        self?.present(alert, animated: true, completion: nil)
    }

    self.helpViewModel.outputs.showWebHelp
      .observeForControllerAction()
      .observeValues { [weak self] helpType in
        self?.goToHelpType(helpType)
    }

    self.contextLabel.rac.text = self.viewModel.outputs.logInContextText
    self.bringCreativeProjectsToLifeLabel.rac.hidden = self.viewModel.outputs.headlineLabelHidden
  }

  @objc internal func mailComposeController(_ controller: MFMailComposeViewController,
                                            didFinishWith result: MFMailComposeResult,
                                            error: Error?) {
    self.helpViewModel.inputs.mailComposeCompletion(result: result)
    self.dismiss(animated: true, completion: nil)
  }

  fileprivate func goToHelpType(_ helpType: HelpType) {
    let vc = HelpWebViewController.configuredWith(helpType: helpType)
    self.navigationController?.pushViewController(vc, animated: true)
    self.navigationItem.backBarButtonItem = UIBarButtonItem.back(nil, selector: nil)
  }

  fileprivate func pushLoginViewController() {
    self.navigationController?.pushViewController(LoginViewController.instantiate(), animated: true)
    self.navigationItem.backBarButtonItem = UIBarButtonItem.back(nil, selector: nil)
  }

  fileprivate func pushTwoFactorViewController(facebookAccessToken token: String) {
    let vc = TwoFactorViewController.configuredWith(facebookAccessToken: token)
    self.navigationController?.pushViewController(vc, animated: true)
    self.navigationItem.backBarButtonItem = UIBarButtonItem.back(nil, selector: nil)
  }

  fileprivate func pushFacebookConfirmationController(facebookUser user: ErrorEnvelope.FacebookUser?,
                                                      facebookToken token: String) {
    let vc = FacebookConfirmationViewController
      .configuredWith(facebookUserEmail: user?.email ?? "", facebookAccessToken: token)
    self.navigationController?.pushViewController(vc, animated: true)
    self.navigationItem.backBarButtonItem = UIBarButtonItem.back(nil, selector: nil)
  }

  fileprivate func pushSignupViewController() {
    self.navigationController?.pushViewController(SignupViewController.instantiate(), animated: true)
    self.navigationItem.backBarButtonItem = UIBarButtonItem.back(nil, selector: nil)
  }

  fileprivate func showHelpSheet(helpTypes: [HelpType]) {
    let helpSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

    helpTypes.forEach { helpType in
      helpSheet.addAction(
        UIAlertAction(title: helpType.title, style: .default) { [weak helpVM = self.helpViewModel] _ in
          helpVM?.inputs.helpTypeButtonTapped(helpType)
        }
      )
    }

    helpSheet.addAction(
      UIAlertAction(
        title: Strings.login_tout_help_sheet_cancel(),
        style: .cancel
      ) { [weak helpVM = self.helpViewModel] _ in
        helpVM?.inputs.cancelHelpSheetButtonTapped()
      }
    )

    //iPad provision
    helpSheet.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem

    self.present(helpSheet, animated: true, completion: nil)
  }

  // MARK: Facebook Login

  fileprivate func attemptFacebookLogin() {
    self.fbLoginManager
      .logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: nil) { result, error in
        if let error = error {
          self.viewModel.inputs.facebookLoginFail(error: error)
        } else if let result = result, !result.isCancelled {
          self.viewModel.inputs.facebookLoginSuccess(result: result)
        }
    }
  }

  @objc fileprivate func closeButtonPressed() {
    self.dismiss(animated: true, completion: nil)
  }

  @IBAction fileprivate func helpButtonPressed() {
    self.helpViewModel.inputs.showHelpSheetButtonTapped()
  }

  @IBAction fileprivate func loginButtonPressed(_ sender: UIButton) {
    self.viewModel.inputs.loginButtonPressed()
  }

  @IBAction fileprivate func facebookLoginButtonPressed(_ sender: UIButton) {
    self.viewModel.inputs.facebookLoginButtonPressed()
  }

  @IBAction fileprivate func signupButtonPressed() {
    self.viewModel.inputs.signupButtonPressed()
  }
}

extension LoginToutViewController: TabBarControllerScrollable {
  func scrollToTop() {
    if let scrollView = self.view.subviews.first as? UIScrollView {
      scrollView.scrollToTop()
    }
  }
}
