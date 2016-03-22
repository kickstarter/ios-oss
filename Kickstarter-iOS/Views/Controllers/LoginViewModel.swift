import KsApi
import ReactiveCocoa
import ReactiveExtensions
import struct Library.Environment
import struct Library.AppEnvironment
import func Library.localizedString
import enum Result.NoError

internal protocol LoginViewModelInputs {
  /// String value of email textfield text
  var email: MutableProperty<String?> { get }
  /// String value of password textfield text
  var password: MutableProperty<String?> { get }
  /// Call when login button is pressed
  func loginButtonPressed()
  /// Call when email textfield keyboard returns
  func emailTextFieldDoneEditing()
  /// Call when password textfield keyboard returns
  func passwordTextFieldDoneEditing()
}

internal protocol LoginViewModelOutputs {
  /// Bool value whether form is valid
  var isFormValid: MutableProperty<Bool> { get }
  /// Emits when a login request is successful
  var logInSuccess: Signal<(), NoError> { get }
  /// Emits when to dismiss a textfield keyboard
  var dismissKeyboard: Signal<(), NoError> { get }
  /// Emits when the password textfield should become the first responder
  var passwordTextFieldBecomeFirstResponder: Signal<(), NoError> { get }
}

internal protocol LoginViewModelErrors {
  /// Emits an error String when a login request has failed
  var invalidLogin: Signal<String, NoError> { get }
  /// Emits when a generic login error has occurred
  var genericError: Signal<(), NoError> { get }
  /// Emits when a tfa request has failed
  var tfaChallenge: Signal<(), NoError> { get }
}

internal protocol LoginViewModelType {
  var inputs: LoginViewModelInputs { get }
  var outputs: LoginViewModelOutputs { get }
  var errors: LoginViewModelErrors { get }
}







































































































































































internal final class LoginViewModel: LoginViewModelType, LoginViewModelInputs, LoginViewModelOutputs, LoginViewModelErrors {

  // MARK: LoginViewModelType
  internal var inputs: LoginViewModelInputs { return self }
  internal var outputs: LoginViewModelOutputs { return self }
  internal var errors: LoginViewModelErrors { return self }

  // MARK: Inputs
  internal let email = MutableProperty<String?>(nil)
  internal let password = MutableProperty<String?>(nil)
  private var (loginButtonPressedSignal, loginButtonPressedObserver) = Signal<(), NoError>.pipe()
  internal func loginButtonPressed() {
    loginButtonPressedObserver.sendNext(())
  }
  private let (emailTextFieldDoneEditingSignal, emailTextFieldDoneEditingObserver) = Signal<(), NoError>.pipe()
  internal func emailTextFieldDoneEditing() {
    emailTextFieldDoneEditingObserver.sendNext(())
  }
  private let (passwordTextFieldDoneEditingSignal, passwordTextFieldDoneEditingObserver) = Signal<(), NoError>.pipe()
  internal func passwordTextFieldDoneEditing() {
    passwordTextFieldDoneEditingObserver.sendNext(())
  }

  // MARK: Outputs
  internal let isFormValid = MutableProperty(false)
  internal let logInSuccess: Signal<(), NoError>
  internal let dismissKeyboard: Signal<(), NoError>
  internal let passwordTextFieldBecomeFirstResponder: Signal<(), NoError>

  // MARK: Errors
  internal let invalidLogin: Signal<String, NoError>
  internal let genericError: Signal<(), NoError>
  internal let tfaChallenge: Signal<(), NoError>

  internal init(env: Environment = AppEnvironment.current) {
    let apiService = env.apiService
    let currentUser = env.currentUser
    let koala = env.koala

    let (loginErrors, loginErrorsObserver) = Signal<ErrorEnvelope, NoError>.pipe()

    invalidLogin = loginErrors
      .filter { $0.ksrCode == .InvalidXauthLogin }
      .map { $0.errorMessages.first }
      .ignoreNil()

    tfaChallenge = loginErrors
      .filter { $0.ksrCode == .TfaRequired }
      .map { _ in localizedString(key: "two_factor.error.message", defaultValue: "The code provided does not match.") }

    genericError = loginErrors
      .filter { $0.ksrCode != .InvalidXauthLogin && $0.ksrCode != .TfaRequired }
      .map { _ in localizedString(key: "login.errors.unable_to_log_in", defaultValue: "Unable to log in.") }

    let emailAndPassword = email.signal.ignoreNil()
      .combineLatestWith(password.signal.ignoreNil())
      .map { ep in (email: ep.0, password: ep.1) }

    isFormValid <~ emailAndPassword.map(LoginViewModel.isValid)

    let login = emailAndPassword.takeWhen(loginButtonPressedSignal)
      .switchMap { ep in apiService.login(email: ep.0, password: ep.1).demoteErrors(loginErrorsObserver) }

    self.logInSuccess = login.ignoreValues()

    login.observeNext { envelope in
      currentUser.login(envelope.user, accessToken: envelope.accessToken)
      koala.trackLoginSuccess()
    }

    loginErrors.observeNext { _ in koala.trackLoginError() }

    self.dismissKeyboard = passwordTextFieldDoneEditingSignal
    self.passwordTextFieldBecomeFirstResponder = emailTextFieldDoneEditingSignal
  }

  private static func isValid(email: String, password: String) -> Bool {
    return email.characters.count > 0 && password.characters.count > 0
  }
}
