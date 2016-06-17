import KsApi
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol LoginViewModelInputs {
  /// Call when the view will appear.
  func viewWillAppear()

  /// String value of email textfield text
  func emailChanged(email: String?)

  /// String value of password textfield text
  func passwordChanged(password: String?)

  /// Call when login button is pressed
  func loginButtonPressed()

  /// Call when email textfield keyboard returns
  func emailTextFieldDoneEditing()

  /// Call when password textfield keyboard returns
  func passwordTextFieldDoneEditing()

  /// Call when the environment has been logged into
  func environmentLoggedIn()

  /// Call when reset password button is pressed
  func resetPasswordButtonPressed()
}

public protocol LoginViewModelOutputs {
  /// Bool value whether form is valid
  var isFormValid: Signal<Bool, NoError> { get }

  /// Emits when a login success notification should be posted.
  var postNotification: Signal<NSNotification, NoError> { get }

  /// Emits an access token envelope that can be used to update the environment.
  var logIntoEnvironment: Signal<AccessTokenEnvelope, NoError> { get }

  /// Emits when to dismiss a textfield keyboard
  var dismissKeyboard: Signal<(), NoError> { get }

  /// Emits when the password textfield should become the first responder
  var passwordTextFieldBecomeFirstResponder: Signal<(), NoError> { get }

  /// Emits when the reset password screen should be shown
  var showResetPassword: Signal<(), NoError> { get }
}

public protocol LoginViewModelErrors {
  /// Emits when a login error has occurred and a message should be displayed.
  var showError: Signal<String, NoError> { get }

  /// Emits when TFA is required for login.
  var tfaChallenge: Signal<(email: String, password: String), NoError> { get }
}

public protocol LoginViewModelType {
  var inputs: LoginViewModelInputs { get }
  var outputs: LoginViewModelOutputs { get }
  var errors: LoginViewModelErrors { get }
}

public final class LoginViewModel: LoginViewModelType, LoginViewModelInputs, LoginViewModelOutputs,
LoginViewModelErrors {

  // MARK: LoginViewModelType
  public var inputs: LoginViewModelInputs { return self }
  public var outputs: LoginViewModelOutputs { return self }
  public var errors: LoginViewModelErrors { return self }

  // MARK: Inputs
  private let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }
  private let email = MutableProperty<String?>(nil)
  public func emailChanged(email: String?) {
    self.email.value = email
  }
  private let password = MutableProperty<String?>(nil)
  public func passwordChanged(password: String?) {
    self.password.value = password
  }
  private let loginButtonPressedProperty = MutableProperty(())
  public func loginButtonPressed() {
    self.loginButtonPressedProperty.value = ()
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

  // MARK: Outputs
  public let isFormValid: Signal<Bool, NoError>
  public let postNotification: Signal<NSNotification, NoError>
  public let dismissKeyboard: Signal<(), NoError>
  public let passwordTextFieldBecomeFirstResponder: Signal<(), NoError>
  public let logIntoEnvironment: Signal<AccessTokenEnvelope, NoError>
  public let showResetPassword: Signal<(), NoError>

  // MARK: Errors
  public let showError: Signal<String, NoError>
  public let tfaChallenge: Signal<(email: String, password: String), NoError>

  public init() {
    let emailAndPassword = self.email.signal.ignoreNil()
      .combineLatestWith(self.password.signal.ignoreNil())

    self.isFormValid = self.viewWillAppearProperty.signal.mapConst(false).take(1)
      .mergeWith(emailAndPassword.map(isValid))

    let loginEvent = emailAndPassword
      .takeWhen(self.loginButtonPressedProperty.signal)
      .switchMap { ep in
        AppEnvironment.current.apiService.login(email: ep.0, password: ep.1, code: nil)
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

    self.logIntoEnvironment
      .observeNext { _ in AppEnvironment.current.koala.trackLoginSuccess() }

    self.showError
      .observeNext { _ in AppEnvironment.current.koala.trackLoginError() }
  }
}

private func isValid(email email: String, password: String) -> Bool {
  return isValidEmail(email) && !password.characters.isEmpty
}
