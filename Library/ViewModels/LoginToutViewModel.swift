import FBSDKLoginKit
import KsApi
import Prelude
import ReactiveSwift

public protocol LoginToutViewModelInputs {
  /// Call when the environment has been logged into
  func environmentLoggedIn()

  /// Call when Faceboook login button is pressed
  func facebookLoginButtonPressed()

  /// Call when Facebook login completed with error
  func facebookLoginFail(error: Error?)

  /// Call when Facebook login completed successfully with a result
  func facebookLoginSuccess(result: LoginManagerLoginResult)

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
  var attemptFacebookLogin: Signal<(), Never> { get }

  /// Emits when the controller should be dismissed.
  var dismissViewController: Signal<(), Never> { get }

  /// Emits string for facebook button title text.
  var facebookButtonTitleText: Signal<String, Never> { get }

  /// Emits if label should be hidden.
  var headlineLabelHidden: Signal<Bool, Never> { get }

  /// Emits whether a request is loading or not
  var isLoading: Signal<Bool, Never> { get }

  /// Emits the login context to be displayed.
  var logInContextText: Signal<String, Never> { get }

  /// Emits an access token envelope that can be used to update the environment.
  var logIntoEnvironment: Signal<AccessTokenEnvelope, Never> { get }

  /// Emits when a login success notification should be posted.
  var postNotification: Signal<(Notification, Notification), Never> { get }

  /// Emits when should show Facebook error alert with AlertError
  var showFacebookErrorAlert: Signal<AlertError, Never> { get }

  /// Emits when Login view should be shown
  var startLogin: Signal<(), Never> { get }

  /// Emits when Signup view should be shown
  var startSignup: Signal<(), Never> { get }

  /// Emits a Facebook user and access token when Facebook login has occurred
  var startFacebookConfirmation: Signal<(ErrorEnvelope.FacebookUser?, String), Never> { get }

  /// Emits an access token to show 2fa view when Facebook login fails with tfaRequired error
  var startTwoFactorChallenge: Signal<String, Never> { get }
}

public protocol LoginToutViewModelType {
  var inputs: LoginToutViewModelInputs { get }
  var outputs: LoginToutViewModelOutputs { get }
}

public final class LoginToutViewModel: LoginToutViewModelType, LoginToutViewModelInputs,
  LoginToutViewModelOutputs {
  public init() {
    let intent: Signal<LoginIntent, Never> = self.loginIntentProperty.signal.skipNil()
      .takeWhen(self.viewWillAppearProperty.signal)

    self.logInContextText = intent.map { (intent: LoginIntent) -> String in statusString(intent) }

    self.headlineLabelHidden = intent.map { (intent: LoginIntent) -> Bool in
      intent != LoginIntent.generic && intent != LoginIntent.discoveryOnboarding
    }

    self.facebookButtonTitleText = intent.map { (intent: LoginIntent) -> String in
      intent == .backProject ? Strings.Continue_with_Facebook()
        : Strings.login_tout_back_intent_traditional_login_button()
    }

    let isLoading: MutableProperty<Bool> = MutableProperty(false)

    self.isLoading = isLoading.signal
    self.startLogin = self.loginButtonPressedProperty.signal
    self.startSignup = self.signupButtonPressedProperty.signal
    self.attemptFacebookLogin = self.facebookLoginButtonPressedProperty.signal

    let tokenString: Signal<String, Never> = self.facebookLoginSuccessProperty.signal.skipNil()
      .map { $0.token?.tokenString ?? "" }

    let facebookLogin = tokenString
      .switchMap { token in
        AppEnvironment.current.apiService.login(facebookAccessToken: token, code: nil)
          .on(
            starting: {
              isLoading.value = true
            },
            terminated: {
              isLoading.value = false
            }
          )
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    self.logIntoEnvironment = facebookLogin.values()

    let tfaRequiredError = facebookLogin.errors()
      .filter { $0.ksrCode == .TfaRequired }

    let facebookSignupError = facebookLogin.errors()
      .filter { $0.ksrCode == .ConfirmFacebookSignup }

    let genericFacebookErrorAlert = facebookLogin.errors()
      .filter { env in
        env.ksrCode != .TfaRequired &&
          env.ksrCode != .ConfirmFacebookSignup &&
          env.ksrCode != .FacebookInvalidAccessToken
      }
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
      .mapConst((
        Notification(name: .ksr_sessionStarted),
        Notification(
          name: .ksr_showNotificationsDialog,
          userInfo: [UserInfoKeys.context: PushNotificationDialog.Context.login]
        )
      ))

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
      .takeWhen(self.viewWillAppearProperty.signal.take(first: 1))
      .observeValues { AppEnvironment.current.koala.trackLoginTout(intent: $0) }
  }

  public var inputs: LoginToutViewModelInputs { return self }
  public var outputs: LoginToutViewModelOutputs { return self }

  fileprivate var viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  fileprivate let loginIntentProperty = MutableProperty<LoginIntent?>(.loginTab)
  public func loginIntent(_ intent: LoginIntent) {
    self.loginIntentProperty.value = intent
  }

  fileprivate let loginButtonPressedProperty = MutableProperty(())
  public func loginButtonPressed() {
    self.loginButtonPressedProperty.value = ()
  }

  fileprivate let signupButtonPressedProperty = MutableProperty(())
  public func signupButtonPressed() {
    self.signupButtonPressedProperty.value = ()
  }

  fileprivate let facebookLoginButtonPressedProperty = MutableProperty(())
  public func facebookLoginButtonPressed() {
    self.facebookLoginButtonPressedProperty.value = ()
  }

  fileprivate let facebookLoginSuccessProperty = MutableProperty<LoginManagerLoginResult?>(nil)
  public func facebookLoginSuccess(result: LoginManagerLoginResult) {
    self.facebookLoginSuccessProperty.value = result
  }

  fileprivate let facebookLoginFailProperty = MutableProperty<Error?>(nil)
  public func facebookLoginFail(error: Error?) {
    self.facebookLoginFailProperty.value = error
  }

  fileprivate let environmentLoggedInProperty = MutableProperty(())
  public func environmentLoggedIn() {
    self.environmentLoggedInProperty.value = ()
  }

  fileprivate let userSessionStartedProperty = MutableProperty(())
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  fileprivate let viewIsPresentedProperty = MutableProperty<Bool>(false)
  public func view(isPresented: Bool) {
    self.viewIsPresentedProperty.value = isPresented
  }

  public let dismissViewController: Signal<(), Never>
  public let facebookButtonTitleText: Signal<String, Never>
  public let headlineLabelHidden: Signal<Bool, Never>
  public let startLogin: Signal<(), Never>
  public let startSignup: Signal<(), Never>
  public let startFacebookConfirmation: Signal<(ErrorEnvelope.FacebookUser?, String), Never>
  public let startTwoFactorChallenge: Signal<String, Never>
  public let logIntoEnvironment: Signal<AccessTokenEnvelope, Never>
  public let postNotification: Signal<(Notification, Notification), Never>
  public let logInContextText: Signal<String, Never>
  public let isLoading: Signal<Bool, Never>
  public let attemptFacebookLogin: Signal<(), Never>
  public let showFacebookErrorAlert: Signal<AlertError, Never>
}

private func statusString(_ forStatus: LoginIntent) -> String {
  switch forStatus {
  case .starProject:
    return Strings.Log_in_or_sign_up_to_save_this_project_and_we_ll_remind_you()
  case .backProject:
    return Strings.Please_log_in_or_sign_up_to_back_this_project()
  case .messageCreator:
    return Strings.Please_log_in_or_sign_up_to_message_this_creator()
  case .discoveryOnboarding, .generic, .activity, .loginTab:
    return Strings.Pledge_to_projects_and_view_all_your_saved_and_backed_projects_in_one_place()
  }
}
