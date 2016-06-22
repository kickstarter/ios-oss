import ReactiveCocoa
import KsApi
import Result
import FBSDKLoginKit

public protocol LoginToutViewModelInputs {
  /// Call when the environment has been logged into
  func environmentLoggedIn()

  /// Call when Faceboook login button is pressed
  func facebookLoginButtonPressed()

  /// Call when Facebook login completed with error
  func facebookLoginFail(error error: NSError?)

  /// Call when Facebook login completed successfully with a result
  func facebookLoginSuccess(result result: FBSDKLoginManagerLoginResult)

  /// Call when the help button is pressed
  func helpButtonPressed()

  /// Call when a help sheet button is pressed
  func helpTypeButtonPressed(helpType: HelpType)

  /// Call to set the reason the user is attempting to log in
  func loginIntent(intent: LoginIntent)

  /// Call when login button is pressed
  func loginButtonPressed()

  /// Call when sign up button is pressed
  func signupButtonPressed()

  /// Call when the view controller's viewWillAppear() method is called
  func viewWillAppear()
}

public protocol LoginToutViewModelOutputs {
  /// Emits when Facebook login should start
  var attemptFacebookLogin: Signal<(), NoError> { get }

  /// Emits whether a request is loading or not
  var isLoading: Signal<Bool, NoError> { get }

  /// Emits an access token envelope that can be used to update the environment.
  var logIntoEnvironment: Signal<AccessTokenEnvelope, NoError> { get }

  /// Emits when a login success notification should be posted.
  var postNotification: Signal<NSNotification, NoError> { get }

  /// Emits when should show Facebook error alert with AlertError
  var showFacebookErrorAlert: Signal<AlertError, NoError> { get }

  /// Emits when the help actionsheet should be shown with an array of HelpType values
  var showHelpActionSheet: Signal<[HelpType], NoError> { get }

  /// Emits a HelpType value when a button on the help actionsheet is pressed
  var showHelp: Signal<HelpType, NoError> { get }

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
    let isLoading = MutableProperty(false)

    self.isLoading = isLoading.signal
    self.startLogin = self.loginButtonPressedProperty.signal
    self.startSignup = self.signupButtonPressedProperty.signal
    self.showHelpActionSheet = self.helpButtonPressedProperty.signal.mapConst(
      [.HowItWorks, .Contact, .Terms, .Privacy, .Cookie])
    self.showHelp = self.helpTypeButtonPressedProperty.signal.ignoreNil()
    self.attemptFacebookLogin = self.facebookLoginButtonPressedProperty.signal

    let tokenString = self.facebookLoginSuccessProperty.signal.ignoreNil()
      .map { $0.token.tokenString ?? "" }

    let facebookLogin = tokenString
      .switchMap { token in
        AppEnvironment.current.apiService.login(facebookAccessToken: token, code: nil)
          .on(
            started: {
              isLoading.value = true
            },
            terminated: {
              isLoading.value = false
          })
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
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

    let facebookLoginAttemptFailAlert = self.facebookLoginFailProperty.signal.ignoreNil()
      .map { AlertError.facebookLoginAttemptFail(error: $0) }

    self.startTwoFactorChallenge = tokenString.takeWhen(tfaRequiredError)

    self.startFacebookConfirmation = tokenString
      .takePairWhen(facebookSignupError)
      .map { token, error in (error.facebookUser ?? nil, token) }

    self.postNotification = self.environmentLoggedInProperty.signal
      .mapConst(NSNotification(name: CurrentUserNotifications.sessionStarted, object: nil))

    self.logIntoEnvironment
      .observeNext { _ in AppEnvironment.current.koala.trackFacebookLoginSuccess() }

    self.showFacebookErrorAlert = Signal.merge(
      facebookTokenFailAlert,
      facebookLoginAttemptFailAlert,
      genericFacebookErrorAlert
    )

    self.showFacebookErrorAlert.observeNext { _ in AppEnvironment.current.koala.trackFacebookLoginError() }

    self.loginIntentProperty.producer.ignoreNil()
      .takeWhen(viewWillAppearProperty.signal.take(1))
      .observeNext { AppEnvironment.current.koala.trackLoginTout(intent: $0) }
  }
  // swiftlint:enable function_body_length

  // MARK: LoginToutViewModelType
  public var inputs: LoginToutViewModelInputs { return self }
  public var outputs: LoginToutViewModelOutputs { return self }

  // MARK: Inputs
  private var viewWillAppearProperty = MutableProperty()
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  private let loginIntentProperty = MutableProperty<LoginIntent?>(LoginIntent.LoginTab)
  public func loginIntent(intent: LoginIntent) {
    self.loginIntentProperty.value = intent
  }

  private let loginButtonPressedProperty = MutableProperty()
  public func loginButtonPressed() {
    self.loginButtonPressedProperty.value = ()
  }

  private let signupButtonPressedProperty = MutableProperty()
  public func signupButtonPressed() {
    self.signupButtonPressedProperty.value = ()
  }

  private let facebookLoginButtonPressedProperty = MutableProperty()
  public func facebookLoginButtonPressed() {
    self.facebookLoginButtonPressedProperty.value = ()
  }

  private let facebookLoginSuccessProperty = MutableProperty<FBSDKLoginManagerLoginResult?>(nil)
  public func facebookLoginSuccess(result result: FBSDKLoginManagerLoginResult) {
    self.facebookLoginSuccessProperty.value = result
  }

  private let facebookLoginFailProperty = MutableProperty<NSError?>(nil)
  public func facebookLoginFail(error error: NSError?) {
    self.facebookLoginFailProperty.value = error
  }

  private let environmentLoggedInProperty = MutableProperty()
  public func environmentLoggedIn() {
    self.environmentLoggedInProperty.value = ()
  }

  private let helpButtonPressedProperty = MutableProperty()
  public func helpButtonPressed() {
    self.helpButtonPressedProperty.value = ()
  }

  private let helpTypeButtonPressedProperty = MutableProperty<HelpType?>(nil)
  public func helpTypeButtonPressed(helpType: HelpType) {
    self.helpTypeButtonPressedProperty.value = helpType
  }

  // MARK: Outputs
  public let startLogin: Signal<(), NoError>
  public let startSignup: Signal<(), NoError>
  public let startFacebookConfirmation: Signal<(ErrorEnvelope.FacebookUser?, String), NoError>
  public let startTwoFactorChallenge: Signal<String, NoError>
  public let logIntoEnvironment: Signal<AccessTokenEnvelope, NoError>
  public let postNotification: Signal<NSNotification, NoError>
  public let showHelpActionSheet: Signal<[HelpType], NoError>
  public let showHelp: Signal<HelpType, NoError>
  public let isLoading: Signal<Bool, NoError>
  public let attemptFacebookLogin: Signal<(), NoError>
  public let showFacebookErrorAlert: Signal<AlertError, NoError>
}
