import KsApi
import ReactiveCocoa
import ReactiveExtensions
import Library
import Result

internal protocol LoginViewModelInputs {
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
}

internal protocol LoginViewModelOutputs {
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
}

internal protocol LoginViewModelErrors {
  /// Emits when a login error has occurred and a message should be displayed.
  var showError: Signal<String, NoError> { get }

  /// Emits when TFA is required for login.
  var tfaChallenge: Signal<(email: String, password: String), NoError> { get }
}

internal protocol LoginViewModelType {
  var inputs: LoginViewModelInputs { get }
  var outputs: LoginViewModelOutputs { get }
  var errors: LoginViewModelErrors { get }
}

internal final class LoginViewModel: LoginViewModelType, LoginViewModelInputs, LoginViewModelOutputs,
LoginViewModelErrors {

  // MARK: LoginViewModelType
  internal var inputs: LoginViewModelInputs { return self }
  internal var outputs: LoginViewModelOutputs { return self }
  internal var errors: LoginViewModelErrors { return self }

  // MARK: Inputs
  private let viewWillAppearProperty = MutableProperty(())
  internal func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }
  private let email = MutableProperty<String?>(nil)
  internal func emailChanged(email: String?) {
    self.email.value = email
  }
  private let password = MutableProperty<String?>(nil)
  internal func passwordChanged(password: String?) {
    self.password.value = password
  }
  private let loginButtonPressedProperty = MutableProperty(())
  internal func loginButtonPressed() {
    self.loginButtonPressedProperty.value = ()
  }
  private let emailTextFieldDoneEditingProperty = MutableProperty(())
  internal func emailTextFieldDoneEditing() {
    self.emailTextFieldDoneEditingProperty.value = ()
  }
  private let passwordTextFieldDoneEditingProperty = MutableProperty(())
  internal func passwordTextFieldDoneEditing() {
    self.passwordTextFieldDoneEditingProperty.value = ()
  }
  private let environmentLoggedInProperty = MutableProperty(())
  internal func environmentLoggedIn() {
    self.environmentLoggedInProperty.value = ()
  }

  // MARK: Outputs
  internal let isFormValid: Signal<Bool, NoError>
  internal let postNotification: Signal<NSNotification, NoError>
  internal let dismissKeyboard: Signal<(), NoError>
  internal let passwordTextFieldBecomeFirstResponder: Signal<(), NoError>
  internal let logIntoEnvironment: Signal<AccessTokenEnvelope, NoError>

  // MARK: Errors
  internal let showError: Signal<String, NoError>
  internal let tfaChallenge: Signal<(email: String, password: String), NoError>

  init() {
    let loginErrors = MutableProperty<ErrorEnvelope?>(nil)

    let emailAndPassword = self.email.signal.ignoreNil()
      .combineLatestWith(self.password.signal.ignoreNil())

    let tfaError = loginErrors.signal.ignoreNil()
      .filter { $0.ksrCode == .TfaRequired }
      .ignoreValues()

    self.tfaChallenge = emailAndPassword
      .takeWhen(tfaError)

    self.isFormValid = self.viewWillAppearProperty.signal.mapConst(false).take(1)
      .mergeWith(emailAndPassword.map(isValid))

    self.logIntoEnvironment = emailAndPassword
      .takeWhen(self.loginButtonPressedProperty.signal)
      .switchMap { ep in
        AppEnvironment.current.apiService.login(email: ep.0, password: ep.1, code: nil)
          .demoteErrors(pipeErrorsTo: loginErrors)
      }

    self.postNotification = self.environmentLoggedInProperty.signal
      .mapConst(NSNotification(name: CurrentUserNotifications.sessionStarted, object: nil))
    self.dismissKeyboard = self.passwordTextFieldDoneEditingProperty.signal
    self.passwordTextFieldBecomeFirstResponder = self.emailTextFieldDoneEditingProperty.signal

    self.showError = loginErrors.signal.ignoreNil()
      .filter { $0.ksrCode != .TfaRequired }
      .map { env in
        env.errorMessages.first ??
          localizedString(key: "login.errors.unable_to_log_in", defaultValue: "Unable to log in.")
      }

    self.logIntoEnvironment
      .observeNext { _ in AppEnvironment.current.koala.trackLoginSuccess() }

    self.showError
      .observeNext { _ in AppEnvironment.current.koala.trackLoginError() }
  }
}

private func isValid(email email: String, password: String) -> Bool {
  return email.characters.count > 0 && password.characters.count > 0
}
