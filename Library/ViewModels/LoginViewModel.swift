import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol LoginViewModelInputs {

  /// String value of email textfield text
  func emailChanged(_ email: String?)

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
  func onePasswordFoundLogin(email: String?, password: String?)

  /// String value of password textfield text
  func passwordChanged(_ password: String?)

  /// Call when password textfield keyboard returns
  func passwordTextFieldDoneEditing()

  /// Call when reset password button is pressed
  func resetPasswordButtonPressed()

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear.
  func viewWillAppear()
}

public protocol LoginViewModelOutputs {
  /// Emits when to dismiss a textfield keyboard
  var dismissKeyboard: Signal<(), NoError> { get }

  /// Emits text that should be put into the email field.
  var emailText: Signal<String, NoError> { get }

  /// Sets whether the email text field is the first responder.
  var emailTextFieldBecomeFirstResponder: Signal<(), NoError> { get }

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
  var postNotification: Signal<Notification, NoError> { get }

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
    let emailAndPassword = Signal.combineLatest(
      .merge(self.emailChangedProperty.signal.skipNil(), self.prefillEmailProperty.signal.skipNil()),
      .merge(self.passwordChangedProperty.signal.skipNil(), self.prefillPasswordProperty.signal.skipNil())
    )

    self.emailTextFieldBecomeFirstResponder = self.viewDidLoadProperty.signal

    self.isFormValid = self.viewWillAppearProperty.signal.mapConst(false).take(first: 1)
      .mergeWith(emailAndPassword.map(isValid))

    let tryLogin = Signal.merge(
      self.loginButtonPressedProperty.signal,
      self.passwordTextFieldDoneEditingProperty.signal,
      Signal.combineLatest(
        self.prefillEmailProperty.signal,
        self.prefillPasswordProperty.signal
        ).ignoreValues()
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
      .map { (email: $0, password: $1) }

    self.postNotification = self.environmentLoggedInProperty.signal
      .mapConst(Notification(name: .ksr_sessionStarted))
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

    self.emailText = self.prefillEmailProperty.signal.skipNil()
    self.passwordText = self.prefillPasswordProperty.signal.skipNil()

    Signal.combineLatest(self.emailText, self.passwordText)
      .observeValues { _ in AppEnvironment.current.koala.trackAttemptingOnePasswordLogin() }

    self.onePasswordIsAvailable.signal
      .observeValues { AppEnvironment.current.koala.trackLoginFormView(onePasswordIsAvailable: $0) }

    self.logIntoEnvironment
      .observeValues { _ in AppEnvironment.current.koala.trackLoginSuccess(authType: Koala.AuthType.email) }

    self.showError
      .observeValues { _ in AppEnvironment.current.koala.trackLoginError(authType: Koala.AuthType.email) }
  }

  public var inputs: LoginViewModelInputs { return self }
  public var outputs: LoginViewModelOutputs { return self }

  fileprivate let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }
  fileprivate let emailChangedProperty = MutableProperty<String?>(nil)
  public func emailChanged(_ email: String?) {
    self.emailChangedProperty.value = email
  }
  fileprivate let passwordChangedProperty = MutableProperty<String?>(nil)
  public func passwordChanged(_ password: String?) {
    self.passwordChangedProperty.value = password
  }
  fileprivate let loginButtonPressedProperty = MutableProperty(())
  public func loginButtonPressed() {
    self.loginButtonPressedProperty.value = ()
  }
  fileprivate let onePasswordButtonTappedProperty = MutableProperty()
  public func onePasswordButtonTapped() {
    self.onePasswordButtonTappedProperty.value = ()
  }
  fileprivate let prefillEmailProperty = MutableProperty<String?>(nil)
  fileprivate let prefillPasswordProperty = MutableProperty<String?>(nil)
  public func onePasswordFoundLogin(email: String?, password: String?) {
    self.prefillEmailProperty.value = email
    self.prefillPasswordProperty.value = password
  }
  fileprivate let onePasswordIsAvailable = MutableProperty(false)
  public func onePassword(isAvailable available: Bool) {
    self.onePasswordIsAvailable.value = available
  }
  fileprivate let emailTextFieldDoneEditingProperty = MutableProperty(())
  public func emailTextFieldDoneEditing() {
    self.emailTextFieldDoneEditingProperty.value = ()
  }
  fileprivate let passwordTextFieldDoneEditingProperty = MutableProperty(())
  public func passwordTextFieldDoneEditing() {
    self.passwordTextFieldDoneEditingProperty.value = ()
  }
  fileprivate let environmentLoggedInProperty = MutableProperty(())
  public func environmentLoggedIn() {
    self.environmentLoggedInProperty.value = ()
  }
  fileprivate let resetPasswordPressedProperty = MutableProperty(())
  public func resetPasswordButtonPressed() {
    self.resetPasswordPressedProperty.value = ()
  }
  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let dismissKeyboard: Signal<(), NoError>
  public let emailText: Signal<String, NoError>
  public let emailTextFieldBecomeFirstResponder: Signal<(), NoError>
  public let isFormValid: Signal<Bool, NoError>
  public let logIntoEnvironment: Signal<AccessTokenEnvelope, NoError>
  public var onePasswordButtonHidden: Signal<Bool, NoError>
  public let onePasswordFindLoginForURLString: Signal<String, NoError>
  public let passwordText: Signal<String, NoError>
  public let passwordTextFieldBecomeFirstResponder: Signal<(), NoError>
  public let postNotification: Signal<Notification, NoError>
  public let showError: Signal<String, NoError>
  public let showResetPassword: Signal<(), NoError>
  public let tfaChallenge: Signal<(email: String, password: String), NoError>
}

private func isValid(email: String, password: String) -> Bool {
  return isValidEmail(email) && !password.characters.isEmpty
}
