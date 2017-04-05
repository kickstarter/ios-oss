import FBSDKLoginKit
import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol LoginToutViewModelInputs {
  /// Call when the environment has been logged into
  func environmentLoggedIn()

  /// Call when Faceboook login button is pressed
  func facebookLoginButtonPressed()

  /// Call when Facebook login completed with error
  func facebookLoginFail(error: Error?)

  /// Call when Facebook login completed successfully with a result
  func facebookLoginSuccess(result: FBSDKLoginManagerLoginResult)

  /// Call to set the reason the user is attempting to log in
  func loginIntent(_ intent: LoginIntent)

  /// Call when login button is pressed
  func loginButtonPressed()

  /// Call when sign up button is pressed
  func signupButtonPressed()

  /// Call when a user session starts.
  func userSessionStarted()

  /// Call when the view appears with a boolean telling us whether or not this controller was presented,
  /// i.e. it's presentingViewController is non-`nil`.
  func view(isPresented: Bool)

  /// Call when the view controller's viewWillAppear() method is called
  func viewWillAppear()
}

public protocol LoginToutViewModelOutputs {
  /// Emits when Facebook login should start
  var attemptFacebookLogin: Signal<(), NoError> { get }

  /// Emits when the controller should be dismissed.
  var dismissViewController: Signal<(), NoError> { get }

  /// Emits if label should be hidden.
  var headlineLabelHidden: Signal<Bool, NoError> { get }

  /// Emits whether a request is loading or not
  var isLoading: Signal<Bool, NoError> { get }

  /// Emits the login context to be displayed.
  var logInContextText: Signal<String, NoError> { get }

  /// Emits an access token envelope that can be used to update the environment.
  var logIntoEnvironment: Signal<AccessTokenEnvelope, NoError> { get }

  /// Emits when a login success notification should be posted.
  var postNotification: Signal<Notification, NoError> { get }

  /// Emits when should show Facebook error alert with AlertError
  var showFacebookErrorAlert: Signal<AlertError, NoError> { get }

  /// Emits when Login view should be shown
  var startLogin: Signal<(), NoError> { get }

  /// Emits when Signup view should be shown
  var startSignup: Signal<(), NoError> { get }

  /// Emits a Facebook user and access token when Facebook login has occurred
  var startFacebookConfirmation: Signal<(ErrorEnvelope.FacebookUser?, String), NoError> { get }

  /// Emits an access token to show 2fa view when Facebook login fails with tfaRequired error
  var startTwoFactorChallenge: Signal<String, NoError> { get }
}

public protocol LoginToutViewModelType {
  var inputs: LoginToutViewModelInputs { get }
  var outputs: LoginToutViewModelOutputs { get }
}

public final class LoginToutViewModel: LoginToutViewModelType, LoginToutViewModelInputs,
  LoginToutViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {

    let intent = self.loginIntentProperty.signal.skipNil()
      .takeWhen(self.viewWillAppearProperty.signal)

    self.logInContextText = intent.map { intent in statusString(intent) }

    self.headlineLabelHidden = intent.map { $0 != .generic && $0 != .discoveryOnboarding }

    let isLoading = MutableProperty(false)

    self.isLoading = isLoading.signal
    self.startLogin = self.loginButtonPressedProperty.signal
    self.startSignup = self.signupButtonPressedProperty.signal
    self.attemptFacebookLogin = self.facebookLoginButtonPressedProperty.signal

    let tokenString = self.facebookLoginSuccessProperty.signal.skipNil()
      .map { $0.token.tokenString ?? "" }

    let facebookLogin = tokenString
      .switchMap { token in
        AppEnvironment.current.apiService.login(facebookAccessToken: token, code: nil)
          .on(
            starting: {
              isLoading.value = true
            },
            terminated: {
              isLoading.value = false
          })
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
    }

    self.logIntoEnvironment = facebookLogin.values()

    let tfaRequiredError = facebookLogin.errors()
      .filter { $0.ksrCode == .TfaRequired }

    let facebookSignupError = facebookLogin.errors()
      .filter { $0.ksrCode == .ConfirmFacebookSignup }

    let genericFacebookErrorAlert = facebookLogin.errors()
      .filter { env in (
        env.ksrCode != .TfaRequired &&
          env.ksrCode != .ConfirmFacebookSignup &&
          env.ksrCode != .FacebookInvalidAccessToken
      )}
      .map { AlertError.genericFacebookError(envelope: $0) }

    let facebookTokenFailAlert = facebookLogin.errors()
      .filter { $0.ksrCode == .FacebookInvalidAccessToken }
      .ignoreValues()
      .mapConst(AlertError.facebookTokenFail)

    let facebookLoginAttemptFailAlert = self.facebookLoginFailProperty.signal
      .map { $0 as NSError? }
      .skipNil()
      .map(AlertError.facebookLoginAttemptFail)

    self.startTwoFactorChallenge = tokenString.takeWhen(tfaRequiredError)

    self.startFacebookConfirmation = tokenString
      .takePairWhen(facebookSignupError)
      .map { token, error in (error.facebookUser ?? nil, token) }

    self.postNotification = self.environmentLoggedInProperty.signal
      .mapConst(Notification(name: .ksr_sessionStarted))

    self.dismissViewController = self.viewIsPresentedProperty.signal
      .filter(isTrue)
      .takeWhen(self.userSessionStartedProperty.signal)
      .ignoreValues()

    self.logIntoEnvironment
      .observeValues { _ in AppEnvironment.current.koala.trackLoginSuccess(authType: .facebook) }

    self.showFacebookErrorAlert = Signal.merge(
      facebookTokenFailAlert,
      facebookLoginAttemptFailAlert,
      genericFacebookErrorAlert
    )

    self.showFacebookErrorAlert
      .observeValues { _ in AppEnvironment.current.koala.trackLoginError(authType: .facebook) }

    self.loginIntentProperty.producer.skipNil()
      .takeWhen(viewWillAppearProperty.signal.take(first: 1))
      .observeValues { AppEnvironment.current.koala.trackLoginTout(intent: $0) }
  }
  // swiftlint:enable function_body_length

  public var inputs: LoginToutViewModelInputs { return self }
  public var outputs: LoginToutViewModelOutputs { return self }

  fileprivate var viewWillAppearProperty = MutableProperty()
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }
  fileprivate let loginIntentProperty = MutableProperty<LoginIntent?>(.loginTab)
  public func loginIntent(_ intent: LoginIntent) {
    self.loginIntentProperty.value = intent
  }
  fileprivate let loginButtonPressedProperty = MutableProperty()
  public func loginButtonPressed() {
    self.loginButtonPressedProperty.value = ()
  }
  fileprivate let signupButtonPressedProperty = MutableProperty()
  public func signupButtonPressed() {
    self.signupButtonPressedProperty.value = ()
  }
  fileprivate let facebookLoginButtonPressedProperty = MutableProperty()
  public func facebookLoginButtonPressed() {
    self.facebookLoginButtonPressedProperty.value = ()
  }
  fileprivate let facebookLoginSuccessProperty = MutableProperty<FBSDKLoginManagerLoginResult?>(nil)
  public func facebookLoginSuccess(result: FBSDKLoginManagerLoginResult) {
    self.facebookLoginSuccessProperty.value = result
  }
  fileprivate let facebookLoginFailProperty = MutableProperty<Error?>(nil)
  public func facebookLoginFail(error: Error?) {
    self.facebookLoginFailProperty.value = error
  }
  fileprivate let environmentLoggedInProperty = MutableProperty()
  public func environmentLoggedIn() {
    self.environmentLoggedInProperty.value = ()
  }

  fileprivate let userSessionStartedProperty = MutableProperty()
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }
  fileprivate let viewIsPresentedProperty = MutableProperty<Bool>(false)
  public func view(isPresented: Bool) {
    self.viewIsPresentedProperty.value = isPresented
  }

  public let dismissViewController: Signal<(), NoError>
  public let headlineLabelHidden: Signal<Bool, NoError>
  public let startLogin: Signal<(), NoError>
  public let startSignup: Signal<(), NoError>
  public let startFacebookConfirmation: Signal<(ErrorEnvelope.FacebookUser?, String), NoError>
  public let startTwoFactorChallenge: Signal<String, NoError>
  public let logIntoEnvironment: Signal<AccessTokenEnvelope, NoError>
  public let postNotification: Signal<Notification, NoError>
  public let logInContextText: Signal<String, NoError>
  public let isLoading: Signal<Bool, NoError>
  public let attemptFacebookLogin: Signal<(), NoError>
  public let showFacebookErrorAlert: Signal<AlertError, NoError>
}

private func statusString(_ forStatus: LoginIntent) -> String {
  switch forStatus {
  case .starProject:
    return Strings.Log_in_or_sign_up_to_save_this_project_and_we_ll_remind_you()
  case .backProject:
    return Strings.Please_log_in_or_sign_up_to_back_this_project()
  case .liveStreamSubscribe:
    return Strings.Please_log_in_or_sign_up_to_subscribe_to_this_live_stream()
  case .messageCreator:
    return Strings.Please_log_in_or_sign_up_to_message_this_creator()
  case .discoveryOnboarding, .generic:
    return Strings.Pledge_to_projects_and_view_all_your_saved_and_backed_projects_in_one_place()
  default:
    return " "
  }
}
