import KsApi
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol LoginViewModelInputs {

  /// String value of email textfield text
  func emailChanged(email: String?)

  /// Call when email textfield keyboard returns
  func emailTextFieldDoneEditing()

  /// Call when the environment has been logged into
  func environmentLoggedIn()

  /// Call when login button is pressed
  func loginButtonPressed()

  /// Call with onepassword's available ability.
  func onePassword(isAvailable available: Bool)

  /// Call when the onepassword button is tapped.
  func onePasswordButtonTapped()

  /// Call when onepassword finds a login.
  func onePasswordFoundLogin(email email: String?, password: String?)

  /// String value of password textfield text
  func passwordChanged(password: String?)

  /// Call when password textfield keyboard returns
  func passwordTextFieldDoneEditing()

  /// Call when reset password button is pressed
  func resetPasswordButtonPressed()

  /// Call when the view will appear.
  func viewWillAppear()
}

public protocol LoginViewModelOutputs {

  /// Emits when to dismiss a textfield keyboard
  var dismissKeyboard: Signal<(), NoError> { get }

  /// Emits text that should be put into the email field.
  var emailText: Signal<String, NoError> { get }

  /// Bool value whether form is valid
  var isFormValid: Signal<Bool, NoError> { get }

  /// Emits an access token envelope that can be used to update the environment.
  var logIntoEnvironment: Signal<AccessTokenEnvelope, NoError> { get }

  /// Emits a boolean that determines if the onepassword button should be hidden or not.
  var onePasswordButtonHidden: Signal<Bool, NoError> { get }

  /// Emits when we should request from the onepassword extension a login.
  var onePasswordFindLoginForURLString: Signal<String, NoError> { get }

  /// Emits text that should be put into the password field.
  var passwordText: Signal<String, NoError> { get }

  /// Emits when the password textfield should become the first responder
  var passwordTextFieldBecomeFirstResponder: Signal<(), NoError> { get }

  /// Emits when a login success notification should be posted.
  var postNotification: Signal<NSNotification, NoError> { get }

  /// Emits when a login error has occurred and a message should be displayed.
  var showError: Signal<String, NoError> { get }

  /// Emits when the reset password screen should be shown
  var showResetPassword: Signal<(), NoError> { get }

  /// Emits when TFA is required for login.
  var tfaChallenge: Signal<(email: String, password: String), NoError> { get }
}

public protocol LoginViewModelType {
  var inputs: LoginViewModelInputs { get }
  var outputs: LoginViewModelOutputs { get }
}

public final class LoginViewModel: LoginViewModelType, LoginViewModelInputs, LoginViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {
    let emailAndPassword = combineLatest(
      .merge(self.emailChangedProperty.signal.ignoreNil(), self.prefillEmailProperty.signal.ignoreNil()),
      .merge(self.passwordChangedProperty.signal.ignoreNil(), self.prefillPasswordProperty.signal.ignoreNil())
    )

    self.isFormValid = self.viewWillAppearProperty.signal.mapConst(false).take(1)
      .mergeWith(emailAndPassword.map(isValid))

    let tryLogin = Signal.merge(
      self.loginButtonPressedProperty.signal,
      combineLatest(self.prefillEmailProperty.signal, self.prefillPasswordProperty.signal).ignoreValues()
    )

    let loginEvent = emailAndPassword
      .takeWhen(tryLogin)
      .switchMap { email, password in
        AppEnvironment.current.apiService.login(email: email, password: password, code: nil)
          .materialize()
    }

    self.logIntoEnvironment = loginEvent.values()

    let tfaError = loginEvent.errors()
      .filter { $0.ksrCode == .TfaRequired }
      .ignoreValues()

    self.tfaChallenge = emailAndPassword
      .takeWhen(tfaError)

    self.postNotification = self.environmentLoggedInProperty.signal
      .mapConst(NSNotification(name: CurrentUserNotifications.sessionStarted, object: nil))
    self.dismissKeyboard = self.passwordTextFieldDoneEditingProperty.signal
    self.passwordTextFieldBecomeFirstResponder = self.emailTextFieldDoneEditingProperty.signal

    self.showError = loginEvent.errors()
      .filter { $0.ksrCode != .TfaRequired }
      .map { env in
        env.errorMessages.first ?? Strings.login_errors_unable_to_log_in()
    }

    self.showResetPassword = self.resetPasswordPressedProperty.signal

    self.onePasswordButtonHidden = self.onePasswordIsAvailable.signal.map(negate)

    self.onePasswordFindLoginForURLString = self.onePasswordButtonTappedProperty.signal
      .map { AppEnvironment.current.apiService.serverConfig.webBaseUrl.absoluteString }

    self.emailText = self.prefillEmailProperty.signal.ignoreNil()
    self.passwordText = self.prefillPasswordProperty.signal.ignoreNil()

    combineLatest(self.emailText, self.passwordText)
      .observeNext { _ in AppEnvironment.current.koala.trackAttemptingOnePasswordLogin() }

    self.onePasswordIsAvailable.signal
      .observeNext { AppEnvironment.current.koala.trackLoginFormView(onePasswordIsAvailable: $0) }

    self.logIntoEnvironment
      .observeNext { _ in AppEnvironment.current.koala.trackLoginSuccess() }

    self.showError
      .observeNext { _ in AppEnvironment.current.koala.trackLoginError() }
  }

  public var inputs: LoginViewModelInputs { return self }
  public var outputs: LoginViewModelOutputs { return self }

  private let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }
  private let emailChangedProperty = MutableProperty<String?>(nil)
  public func emailChanged(email: String?) {
    self.emailChangedProperty.value = email
  }
  private let passwordChangedProperty = MutableProperty<String?>(nil)
  public func passwordChanged(password: String?) {
    self.passwordChangedProperty.value = password
  }
  private let loginButtonPressedProperty = MutableProperty(())
  public func loginButtonPressed() {
    self.loginButtonPressedProperty.value = ()
  }
  private let onePasswordButtonTappedProperty = MutableProperty()
  public func onePasswordButtonTapped() {
    self.onePasswordButtonTappedProperty.value = ()
  }
  private let prefillEmailProperty = MutableProperty<String?>(nil)
  private let prefillPasswordProperty = MutableProperty<String?>(nil)
  public func onePasswordFoundLogin(email email: String?, password: String?) {
    self.prefillEmailProperty.value = email
    self.prefillPasswordProperty.value = password
  }
  private let onePasswordIsAvailable = MutableProperty(false)
  public func onePassword(isAvailable available: Bool) {
    self.onePasswordIsAvailable.value = available
  }
  private let emailTextFieldDoneEditingProperty = MutableProperty(())
  public func emailTextFieldDoneEditing() {
    self.emailTextFieldDoneEditingProperty.value = ()
  }
  private let passwordTextFieldDoneEditingProperty = MutableProperty(())
  public func passwordTextFieldDoneEditing() {
    self.passwordTextFieldDoneEditingProperty.value = ()
  }
  private let environmentLoggedInProperty = MutableProperty(())
  public func environmentLoggedIn() {
    self.environmentLoggedInProperty.value = ()
  }
  private let resetPasswordPressedProperty = MutableProperty(())
  public func resetPasswordButtonPressed() {
    self.resetPasswordPressedProperty.value = ()
  }

  public let dismissKeyboard: Signal<(), NoError>
  public let emailText: Signal<String, NoError>
  public let isFormValid: Signal<Bool, NoError>
  public let logIntoEnvironment: Signal<AccessTokenEnvelope, NoError>
  public var onePasswordButtonHidden: Signal<Bool, NoError>
  public let onePasswordFindLoginForURLString: Signal<String, NoError>
  public let passwordText: Signal<String, NoError>
  public let passwordTextFieldBecomeFirstResponder: Signal<(), NoError>
  public let postNotification: Signal<NSNotification, NoError>
  public let showError: Signal<String, NoError>
  public let showResetPassword: Signal<(), NoError>
  public let tfaChallenge: Signal<(email: String, password: String), NoError>
}

private func isValid(email email: String, password: String) -> Bool {
  return isValidEmail(email) && !password.characters.isEmpty
}
