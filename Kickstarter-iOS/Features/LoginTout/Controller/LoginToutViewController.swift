import AuthenticationServices
import FBSDKLoginKit
import Foundation
import KsApi
import Library
import MessageUI
import Prelude
import ReactiveSwift
import UIKit

public final class LoginToutViewController: UIViewController, MFMailComposeViewControllerDelegate,
  ProcessingViewPresenting {
  // MARK: - Properties

  private lazy var appleLoginButton: ASAuthorizationAppleIDButton = {
    ASAuthorizationAppleIDButton(type: .continue, style: .black)
  }()

  private lazy var backgroundImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var bringCreativeProjectsToLifeLabel = { UILabel(frame: .zero) }()
  private lazy var contextLabel = { UILabel(frame: .zero) }()
  private lazy var emailLoginStackView = { UIStackView(frame: .zero) }()
  private lazy var fbLoginButton = { UIButton(type: .custom)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var fbLoginManager: LoginManager = {
    let manager = LoginManager()
    manager.defaultAudience = .friends
    return manager
  }()

  private lazy var fbLoginStackView = { UIStackView(frame: .zero) }()
  private lazy var getNotifiedLabel = { UILabel(frame: .zero) }()
  private let helpViewModel = HelpViewModel()
  private lazy var loginButton = { UIButton(type: .custom)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var loginContextStackView = { UIStackView() }()
  private lazy var logoImageView = { UIImageView(frame: .zero) }()
  internal var processingView: ProcessingView? = ProcessingView(frame: .zero)
  private lazy var rootStackView = { UIStackView() }()
  private lazy var scrollView = {
    UIScrollView(frame: .zero)
      |> \.alwaysBounceVertical .~ true

  }()

  private lazy var separatorView: UIView = { UIView(frame: .zero) }()
  private var sessionStartedObserver: Any?
  private lazy var signupButton = { UIButton(type: .custom)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let viewModel: LoginToutViewModelType = LoginToutViewModel()

  // MARK: - Configuration

  public static func configuredWith(
    loginIntent intent: LoginIntent,
    project: Project? = nil,
    reward: Reward? = nil
  ) -> LoginToutViewController {
    let vc = LoginToutViewController.instantiate()
    vc.viewModel.inputs.configureWith(intent, project: project, reward: reward)
    vc.helpViewModel.inputs.configureWith(helpContext: .loginTout)
    vc.helpViewModel.inputs.canSendEmail(MFMailComposeViewController.canSendMail())
    return vc
  }

  // MARK: - Lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.configureViews()
    self.setupConstraints()
    self.configureTargets()

    self.fbLoginManager.logOut()

    self.sessionStartedObserver = NotificationCenter.default
      .addObserver(forName: .ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
      }

    if self.presentingViewController != nil {
      self.navigationItem.leftBarButtonItem = .close(self, selector: #selector(self.closeButtonPressed))
    }

    _ = self.navigationItem
      |> \.rightBarButtonItem .~ .help(self, selector: #selector(self.helpButtonPressed))
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.view(isPresented: self.presentingViewController != nil)
    self.viewModel.inputs.viewWillAppear()
  }

  deinit {
    self.sessionStartedObserver.doIfSome(NotificationCenter.default.removeObserver)
  }

  // MARK: - Styles

  public override func bindStyles() {
    super.bindStyles()

    let isPad = self.traitCollection.userInterfaceIdiom == .pad

    _ = self.backgroundImageView
      |> backgroundImageViewStyle

    _ = self.appleLoginButton
      |> roundedStyle(cornerRadius: Styles.grid(2))

    _ = self.bringCreativeProjectsToLifeLabel
      |> baseLabelStyle
      |> UILabel.lens.font .~ .ksr_title2()
      |> UILabel.lens.text %~ { _ in Strings.Bring_creative_projects_to_life() }

    _ = self.contextLabel
      |> baseLabelStyle
      |> UILabel.lens.font %~ { _ in
        self.bringCreativeProjectsToLifeLabel.isHidden ? UIFont.ksr_title2() : UIFont.ksr_subhead()
      }

    _ = self.fbLoginButton
      |> facebookButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Continue_with_Facebook() }

    _ = self.getNotifiedLabel
      |> baseLabelStyle
      |> UILabel.lens.font %~~ { _, _ in
        isPad ? UIFont.ksr_subhead() : UIFont.ksr_caption2()
      }
      |> UILabel.lens.text %~ { _ in Strings.Get_notified_when_your_friends_back_and_launch_projects() }

    if self.viewModel.outputs.loginWithOAuthEnabled {
      // TODO: Add and translate a new version of this string for this page.
      _ = self.loginButton |> greenButtonStyle
      self.loginButton.setTitle(Strings.discovery_onboarding_buttons_signup_or_login(), for: .normal)
    } else {
      _ = self.loginButton |> greyButtonStyle
      self.loginButton.setTitle(Strings.login_tout_back_intent_traditional_login_button(), for: .normal)
    }

    _ = self.loginContextStackView
      |> UIStackView.lens.spacing .~ Styles.gridHalf(1)
      |> UIStackView.lens.layoutMargins %~~ { _, _ in
        isPad
          ? .init(topBottom: Styles.grid(2), leftRight: 0)
          : .init(top: Styles.grid(10), left: 0, bottom: Styles.grid(5), right: 0)
      }
      |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true

    _ = self.logoImageView
      |> logoImageViewStyle

    _ = self.rootStackView
      |> baseStackViewStyle
      |> UIStackView.lens.spacing .~ Styles.grid(5)
    applyLoginRootStackViewStyle(self.rootStackView, useLargerMargins: isPad)

    _ = self.separatorView
      |> separatorViewStyle

    _ = self.signupButton
      |> signupWithEmailButtonStyle

    _ = [self.loginContextStackView, self.fbLoginStackView, self.emailLoginStackView]
      ||> baseStackViewStyle
  }

  // MARK: - View Model

  public override func bindViewModel() {
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

    self.viewModel.outputs.logIntoEnvironmentWithApple
      .observeValues { [weak self] accessTokenEnv in
        AppEnvironment.login(accessTokenEnv)
        self?.viewModel.inputs.environmentLoggedIn()
      }

    self.viewModel.outputs.logIntoEnvironmentWithFacebook
      .observeValues { [weak self] accessTokenEnv in
        guard let strongSelf = self else { return }

        AppEnvironment.login(accessTokenEnv)

        if featureFacebookLoginInterstitialEnabled(), accessTokenEnv.user.needsPassword == true {
          strongSelf.pushSetYourPasswordViewController()
          return
        }

        strongSelf.viewModel.inputs.environmentLoggedIn()
      }

    self.viewModel.outputs.postNotification
      .observeForUI()
      .observeValues {
        NotificationCenter.default.post($0.0)
        NotificationCenter.default.post($0.1)
      }

    self.viewModel.outputs.startFacebookConfirmation
      .observeForControllerAction()
      .observeValues { [weak self] user, token in
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
        guard let strongSelf = self else { return }

        if featureFacebookLoginInterstitialEnabled() {
          strongSelf.present(
            UIAlertController.facebookDeprecationNewPasswordOptionAlert(
              loginHandler: { [weak self] _ in
                self?.pushLoginViewController()
              },
              setNewPasswordHandler: { [weak self] _ in
                self?.pushFacebookResetPasswordViewController()
              }
            ),
            animated: true,
            completion: nil
          )

          return
        }

        strongSelf.present(
          UIAlertController.alertController(forError: error),
          animated: true,
          completion: nil
        )
      }

    self.viewModel.outputs.dismissViewController
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.dismiss(animated: true)
      }

    self.helpViewModel.outputs.showHelpSheet
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.showHelpSheet(helpTypes: $0)
      }

    self.helpViewModel.outputs.showMailCompose
      .observeForControllerAction()
      .observeValues { [weak self] in
        guard let strongSelf = self else { return }
        let controller = MFMailComposeViewController.support()
        controller.mailComposeDelegate = strongSelf
        strongSelf.present(controller, animated: true, completion: nil)
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

    self.viewModel.outputs.headlineLabelHidden
      .observeForUI()
      .observeValues { [weak self] isHidden in
        _ = self?.contextLabel
          ?|> UILabel.lens.font .~ (isHidden ? UIFont.ksr_title2() : UIFont.ksr_subhead())
      }

    self.viewModel.outputs.attemptAppleLogin
      .observeForUI()
      .observeValues { [weak self] in
        self?.attemptAppleLogin()
      }

    self.viewModel.outputs.showAppleErrorAlert
      .observeForControllerAction()
      .observeValues { [weak self] message in
        self?.present(UIAlertController.genericError(message), animated: true)
      }

    self.viewModel.outputs.isLoading
      .observeForUI()
      .observeValues { [weak self] isLoading in
        if isLoading {
          self?.showProcessingView()
        } else {
          self?.hideProcessingView()
        }
      }
  }

  // MARK: - Functions

  private func configureViews() {
    _ = (self.backgroundImageView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.scrollView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.rootStackView, self.scrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([
      self.loginContextStackView, self.fbLoginStackView, self.separatorView, self.emailLoginStackView
    ], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    let spacer = UIView()
    _ = ([
      self.logoImageView, spacer, self.bringCreativeProjectsToLifeLabel, self.contextLabel
    ], self.loginContextStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.appleLoginButton, self.fbLoginButton, self.getNotifiedLabel], self.fbLoginStackView)
      |> ksr_addArrangedSubviewsToStackView()

    if self.viewModel.outputs.loginWithOAuthEnabled {
      self.emailLoginStackView.addArrangedSubview(self.loginButton)
    } else {
      self.emailLoginStackView.addArrangedSubview(self.signupButton)
      self.emailLoginStackView.addArrangedSubview(self.loginButton)
    }
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.separatorView.heightAnchor.constraint(equalToConstant: 1),
      self.rootStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
      self.fbLoginButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height),
      self.loginButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height),
      self.signupButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height)
    ])

    NSLayoutConstraint.activate([
      self.appleLoginButton.heightAnchor
        .constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height)
    ])
  }

  private func configureTargets() {
    self.appleLoginButton.addTarget(
      self, action: #selector(self.appleLoginButtonPressed(_:)),
      for: .touchUpInside
    )
    self.fbLoginButton.addTarget(
      self, action: #selector(self.facebookLoginButtonPressed(_:)),
      for: .touchUpInside
    )
    self.loginButton.addTarget(self, action: #selector(self.loginButtonPressed(_:)), for: .touchUpInside)
    self.signupButton.addTarget(self, action: #selector(self.signupButtonPressed), for: .touchUpInside)
  }

  private func attemptAppleLogin() {
    let appleIDRequest = ASAuthorizationAppleIDProvider().createRequest()
      |> \.requestedScopes .~ [.fullName, .email]

    let authorizationController = ASAuthorizationController(authorizationRequests: [appleIDRequest])
      |> \.delegate .~ self
      ?|> \.presentationContextProvider .~ self
    authorizationController?.performRequests()
  }

  fileprivate func goToHelpType(_ helpType: HelpType) {
    let vc = HelpWebViewController.configuredWith(helpType: helpType)
    self.navigationController?.pushViewController(vc, animated: true)
    self.navigationItem.backBarButtonItem = UIBarButtonItem.back(nil, selector: nil)
  }

  fileprivate func pushLoginViewController() {
    if self.viewModel.outputs.loginWithOAuthEnabled, let session = createAuthorizationSession() {
      session.presentationContextProvider = self
      session.start()
    } else {
      self.navigationController?.pushViewController(LoginViewController.instantiate(), animated: true)
      self.navigationItem.backBarButtonItem = UIBarButtonItem.back(nil, selector: nil)
    }
  }

  fileprivate func createAuthorizationSession() -> ASWebAuthenticationSession? {
    return OAuth.createAuthorizationSession { [weak self] result in
      switch result {
      case .loggedIn:
        self?.viewModel.inputs.environmentLoggedIn()
      case let .failure(errorMessage):
        let alert = UIAlertController(
          title: Strings.login_errors_title(),
          message: errorMessage,
          preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Strings.login_errors_button_ok(), style: .cancel))
        self?.present(alert, animated: true)
      case .cancelled:
        // Do nothing
        break
      }
    }
  }

  fileprivate func pushTwoFactorViewController(facebookAccessToken token: String) {
    let vc = TwoFactorViewController.configuredWith(facebookAccessToken: token)
    self.navigationController?.pushViewController(vc, animated: true)
    self.navigationItem.backBarButtonItem = UIBarButtonItem.back(nil, selector: nil)
  }

  fileprivate func pushFacebookConfirmationController(
    facebookUser user: ErrorEnvelope.FacebookUser?,
    facebookToken token: String
  ) {
    let vc = FacebookConfirmationViewController
      .configuredWith(facebookUserEmail: user?.email ?? "", facebookAccessToken: token)
    self.navigationController?.pushViewController(vc, animated: true)
    self.navigationItem.backBarButtonItem = UIBarButtonItem.back(nil, selector: nil)
  }

  fileprivate func pushSignupViewController() {
    self.navigationController?.pushViewController(SignupViewController.instantiate(), animated: true)
    self.navigationItem.backBarButtonItem = UIBarButtonItem.back(nil, selector: nil)
  }

  private func pushFacebookResetPasswordViewController() {
    let vc = FacebookResetPasswordViewController.instantiate()
    self.navigationController?.pushViewController(vc, animated: true)
    self.navigationItem
      .backBarButtonItem = UIBarButtonItem(title: "Log in", style: .plain, target: nil, action: nil)
  }

  private func pushSetYourPasswordViewController() {
    let vc = SetYourPasswordViewController.instantiate()
    vc.delegate = self
    self.navigationController?.pushViewController(vc, animated: true)
    self.navigationItem
      .backBarButtonItem = UIBarButtonItem(title: "Log in", style: .plain, target: nil, action: nil)
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
        style: .cancel,
        handler: nil
      )
    )

    // iPad provision
    helpSheet.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem

    self.present(helpSheet, animated: true, completion: nil)
  }

  // MARK: - Facebook Login

  fileprivate func attemptFacebookLogin() {
    self.fbLoginManager.logIn(
      permissions: ["public_profile", "email", "user_friends"], from: nil
    ) { result, error in
      if let error = error {
        self.viewModel.inputs.facebookLoginFail(error: error)
      } else if let result = result, !result.isCancelled {
        self.viewModel.inputs.facebookLoginSuccess(result: result)
      }
    }
  }

  // MARK: - Accessors

  @objc public func mailComposeController(
    _: MFMailComposeViewController,
    didFinishWith result: MFMailComposeResult,
    error _: Error?
  ) {
    self.helpViewModel.inputs.mailComposeCompletion(result: result)
    self.dismiss(animated: true, completion: nil)
  }

  @objc private func appleLoginButtonPressed(_: UIButton) {
    self.viewModel.inputs.appleLoginButtonPressed()
  }

  @objc private func closeButtonPressed() {
    self.dismiss(animated: true, completion: nil)
  }

  @objc private func helpButtonPressed() {
    self.helpViewModel.inputs.showHelpSheetButtonTapped()
  }

  @objc private func loginButtonPressed(_: UIButton) {
    self.viewModel.inputs.loginButtonPressed()
  }

  @objc private func facebookLoginButtonPressed(_: UIButton) {
    self.viewModel.inputs.facebookLoginButtonPressed()
  }

  @objc private func signupButtonPressed() {
    self.viewModel.inputs.signupButtonPressed()
  }
}

extension LoginToutViewController: TabBarControllerScrollable {
  func scrollToTop() {
    guard let scrollView = self.view.subviews
      .first(where: { view in view is UIScrollView })
      .flatMap({ view in view as? UIScrollView })
    else { return }

    scrollView.scrollToTop()
  }
}

// MARK: - Styles

private let backgroundImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.contentMode .~ .scaleToFill
    |> \.image .~ image(named: "signup-background")
}

private let baseStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.distribution .~ .fill
    |> \.alignment .~ .fill
    |> \.axis .~ .vertical
    |> \.spacing .~ Styles.grid(2)
}

private let baseLabelStyle: LabelStyle = { label in
  label
    |> \.textAlignment .~ NSTextAlignment.center
    |> \.lineBreakMode .~ NSLineBreakMode.byWordWrapping
    |> \.numberOfLines .~ 0
}

private let logoImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.image .~ image(named: "kickstarter-logo")?.withRenderingMode(.alwaysTemplate)
    |> \.tintColor .~ .ksr_create_500
    |> \.contentMode .~ .scaleAspectFit
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
    |> \.accessibilityLabel %~ { _ in Strings.general_accessibility_kickstarter() }
}

private let separatorViewStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ .ksr_support_300
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
}

// MARK: - ASAuthorizationControllerDelegate

extension LoginToutViewController: ASAuthorizationControllerDelegate {
  public func authorizationController(
    controller _: ASAuthorizationController,
    didCompleteWithAuthorization authorization: ASAuthorization
  ) {
    guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
      let authToken = credential.authorizationCode else {
      return
    }

    let fullName = credential.fullName
    let token = String(data: authToken, encoding: .utf8)

    let data = (
      appId: AppEnvironment.current.apiService.appId,
      firstName: fullName?.givenName,
      lastName: fullName?.familyName,
      token: token
    ) as? SignInWithAppleData
    self.viewModel.inputs.appleAuthorizationDidSucceed(with: data)
  }

  public func authorizationController(
    controller _: ASAuthorizationController,
    didCompleteWithError error: Error
  ) {
    if let error = error as? ASAuthorizationError {
      let authError: AuthServicesError
      switch error.errorCode {
      case ASAuthorizationError.canceled.rawValue:
        authError = .canceled
      default:
        authError = .other(error)
      }
      self.viewModel.inputs.appleAuthorizationDidFail(with: authError)
    }
  }
}

// MARK: SetYourPasswordViewControllerDelegate

extension LoginToutViewController: SetYourPasswordViewControllerDelegate {
  func setPasswordCompleteAndLogUserIn() {
    self.viewModel.inputs.environmentLoggedIn()
  }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension LoginToutViewController: ASAuthorizationControllerPresentationContextProviding {
  public func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
    guard let window = self.view.window else {
      return ASPresentationAnchor()
    }
    return window
  }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension LoginToutViewController: ASWebAuthenticationPresentationContextProviding {
  public func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
    guard let window = self.view.window else {
      return ASPresentationAnchor()
    }

    return window
  }
}
