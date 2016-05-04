import Library
import ReactiveCocoa
import KsApi
import Result
import FBSDKLoginKit

internal protocol LoginToutViewModelInputs {
  /// Call when the view controller's viewWillAppear() method is called
  func viewWillAppear()
  /// Call to set the reason the user is attempting to log in
  func loginIntent(intent: LoginIntent)
  /// Call when login button is pressed
  func loginButtonPressed()
  /// Call when sign up button is pressed
  func signupButtonPressed()
  /// Call when Faceboook login button is pressed
  func facebookLoginButtonPressed()
  /// Call when Facebook login completed successfully with a result
  func facebookLoginSuccess(result result: FBSDKLoginManagerLoginResult)
  /// Call when Facebook login completed with error
  func facebookLoginFail(error error: NSError?)
  /// Call when the help button is pressed
  func helpButtonPressed()
  /// Call when a help sheet button is pressed
  func helpTypeButtonPressed(helpType: HelpType)
  /// Call when the environment has been logged into
  func environmentLoggedIn()
}

internal protocol LoginToutViewModelOutputs {
  /// Emits when Login view should be shown
  var startLogin: Signal<(), NoError> { get }
  /// Emits when Signup view should be shown
  var startSignup: Signal<(), NoError> { get }
  /// Emits a Facebook user and access token when Facebook login has occurred
  var startFacebookConfirmation: Signal<(ErrorEnvelope.FacebookUser?, String), NoError> { get }
  /// Emits an access token to show 2fa view when Facebook login fails with tfaRequired error
  var startTwoFactorChallenge: Signal<String, NoError> { get }
  /// Emits an access token envelope that can be used to update the environment.
  var logIntoEnvironment: Signal<AccessTokenEnvelope, NoError> { get }
  /// Emits when a login success notification should be posted.
  var postNotification: Signal<NSNotification, NoError> { get }
  /// Emits when the help actionsheet should be shown with an array of HelpType values
  var showHelpActionSheet: Signal<[HelpType], NoError> { get }
  /// Emits a HelpType value when a button on the help actionsheet is pressed
  var showHelp: Signal<HelpType, NoError> { get }
  /// Emits whether a request is loading or not
  var isLoading: Signal<Bool, NoError> { get }
  /// Emits when Facebook login should start
  var attemptFacebookLogin: Signal<(), NoError> { get }
}

internal protocol LoginToutViewModelErrors {
  /// Emits an error message to display when Facebook login fails
  var showFacebookError: Signal<(title: String, message: String), NoError> { get }
}

internal protocol LoginToutViewModelType {
  var inputs: LoginToutViewModelInputs { get }
  var outputs: LoginToutViewModelOutputs { get }
  var errors: LoginToutViewModelErrors { get }
}

internal final class LoginToutViewModel: LoginToutViewModelType, LoginToutViewModelInputs,
  LoginToutViewModelOutputs, LoginToutViewModelErrors {

  // MARK: LoginToutViewModelType
  internal var inputs: LoginToutViewModelInputs { return self }
  internal var outputs: LoginToutViewModelOutputs { return self }
  internal var errors: LoginToutViewModelErrors { return self }

  // MARK: Inputs
  private var viewWillAppearProperty = MutableProperty()
  func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  private let loginIntentProperty = MutableProperty<LoginIntent?>(LoginIntent.LoginTab)
  internal func loginIntent(intent: LoginIntent) {
    self.loginIntentProperty.value = intent
  }

  private let loginButtonPressedProperty = MutableProperty()
  internal func loginButtonPressed() {
    self.loginButtonPressedProperty.value = ()
  }

  private let signupButtonPressedProperty = MutableProperty()
  internal func signupButtonPressed() {
    self.signupButtonPressedProperty.value = ()
  }

  private let facebookLoginButtonPressedProperty = MutableProperty()
  internal func facebookLoginButtonPressed() {
    self.facebookLoginButtonPressedProperty.value = ()
  }

  private let facebookLoginSuccessProperty = MutableProperty<FBSDKLoginManagerLoginResult?>(nil)
  func facebookLoginSuccess(result result: FBSDKLoginManagerLoginResult) {
    self.facebookLoginSuccessProperty.value = result
  }

  private let facebookLoginFailProperty = MutableProperty<NSError?>(nil)
  func facebookLoginFail(error error: NSError?) {
    self.facebookLoginFailProperty.value = error
  }

  private let environmentLoggedInProperty = MutableProperty()
  func environmentLoggedIn() {
    self.environmentLoggedInProperty.value = ()
  }

  private let helpButtonPressedProperty = MutableProperty()
  internal func helpButtonPressed() {
    self.helpButtonPressedProperty.value = ()
  }

  private let helpTypeButtonPressedProperty = MutableProperty<HelpType?>(nil)
  internal func helpTypeButtonPressed(helpType: HelpType) {
    self.helpTypeButtonPressedProperty.value = helpType
  }

  // MARK: Outputs
  internal let startLogin: Signal<(), NoError>
  internal let startSignup: Signal<(), NoError>
  internal let startFacebookConfirmation: Signal<(ErrorEnvelope.FacebookUser?, String), NoError>
  internal let startTwoFactorChallenge: Signal<String, NoError>
  internal let logIntoEnvironment: Signal<AccessTokenEnvelope, NoError>
  internal let postNotification: Signal<NSNotification, NoError>
  internal let showHelpActionSheet: Signal<[HelpType], NoError>
  internal let showHelp: Signal<HelpType, NoError>
  internal let isLoading: Signal<Bool, NoError>
  internal let attemptFacebookLogin: Signal<(), NoError>

  // MARK: Errors
  internal let showFacebookError: Signal<(title: String, message: String), NoError>

  // swiftlint:disable function_body_length
  internal init() {
    let isLoading = MutableProperty(false)

    self.isLoading = isLoading.signal
    self.startLogin = self.loginButtonPressedProperty.signal
    self.startSignup = self.signupButtonPressedProperty.signal
    self.showHelpActionSheet = self.helpButtonPressedProperty.signal.mapConst(HelpType.allValues)
    self.showHelp = self.helpTypeButtonPressedProperty.signal.ignoreNil()
    self.attemptFacebookLogin = self.facebookLoginButtonPressedProperty.signal

    let tokenString = self.facebookLoginSuccessProperty.signal.ignoreNil()
      .map { result in result.token.tokenString ?? "" }

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
      .filter { env in env.ksrCode == .TfaRequired }

    let facebookSignupError = facebookLogin.errors()
      .filter { env in env.ksrCode == .ConfirmFacebookSignup }

    let genericFacebookError: Signal<(title: String, message: String), NoError> = facebookLogin.errors()
      .filter { env in (
        env.ksrCode != .TfaRequired &&
          env.ksrCode != .ConfirmFacebookSignup &&
          env.ksrCode != .FacebookInvalidAccessToken
        )}
      .map(genericFacebookErrorAlert)

    let facebookTokenFail: Signal<(title: String, message: String), NoError> = facebookLogin.errors()
      .filter { env in env.ksrCode == .FacebookInvalidAccessToken }
      .mapConst(facebookTokenFailAlert())

    let facebookLoginAttemptFail: Signal<(title: String, message: String), NoError> =
      self.facebookLoginFailProperty.signal.ignoreNil()
      .map(facebookLoginAttemptFailAlert)

    self.startTwoFactorChallenge = tokenString.takeWhen(tfaRequiredError)

    self.startFacebookConfirmation = tokenString
      .takePairWhen(facebookSignupError)
      .map { token, error in (error.facebookUser ?? nil, token) }

    self.showFacebookError = Signal.merge([
      genericFacebookError,
      facebookTokenFail,
      facebookLoginAttemptFail
    ])

    self.postNotification = self.environmentLoggedInProperty.signal
      .mapConst(NSNotification(name: CurrentUserNotifications.sessionStarted, object: nil))

    self.logIntoEnvironment
      .observeNext { _ in AppEnvironment.current.koala.trackFacebookLoginSuccess() }

    self.showFacebookError.observeNext { _, _ in AppEnvironment.current.koala.trackFacebookLoginError() }

    self.loginIntentProperty.producer.ignoreNil()
      .takeWhen(viewWillAppearProperty.signal.take(1))
      .map { $0.trackingString }
      .observeNext { AppEnvironment.current.koala.trackLoginTout($0) }
  }
  // swiftlint:enable function_body_length
}

private func genericFacebookErrorAlert(envelope: ErrorEnvelope) -> (title: String, message: String) {
  let title = localizedString(key: "login_tout.errors.facebook.generic_error.title",
                              defaultValue: "Facebook login")

  let message = envelope.errorMessages.first ??
    localizedString(key: "login_tout.errors.facebook.generic_error.message",
                    defaultValue: "Couldn't log into Facebook.")

  return (title: title, message: message)
}

private func facebookTokenFailAlert() -> (title: String, message: String) {
  let title = localizedString(key: "login_tout.errors.facebook.invalid_token.title",
    defaultValue: "Facebook login")

  let message = localizedString(key: "login_tout.errors.facebook.invalid_token.message",
                defaultValue: "There was a problem logging you in with Facebook.\n\nThis is commonly fixed " +
                "by going to iOS Settings > Facebook and toggling access for Kickstarter.")
  return (title: title, message: message)
}

private func facebookLoginAttemptFailAlert(error: NSError) -> (title: String, message: String) {
  let title = error.userInfo[FBSDKErrorLocalizedTitleKey] as? String ??
    localizedString(key: "login_tout.errors.facebook.settings_disabled.title",
                    defaultValue: "Permission denied")

  let message = error.userInfo[FBSDKErrorLocalizedDescriptionKey] as? String ??
                localizedString(key: "login_tout.errors.facebook.settings_disabled.message",
                  defaultValue: "It seems that you have denied Kickstarter access to your Facebook account. "
                    + "Please go to Settings > Facebook to enable access.")

  return (title: title, message: message)
}
