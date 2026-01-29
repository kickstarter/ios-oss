import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol LoginViewModelInputs {
  /// String value of email textfield text
  func emailChanged(_ email: String?)

  /// Call when email textfield keyboard returns.
  func emailTextFieldDoneEditing()

  /// Call when the environment has been logged into.
  func environmentLoggedIn()

  /// Call when login button is pressed.
  func loginButtonPressed()

  /// String value of password textfield text
  func passwordChanged(_ password: String?)

  /// Call when password textfield keyboard returns.
  func passwordTextFieldDoneEditing()

  /// Call when reset password button is pressed.
  func resetPasswordButtonPressed()

  /// Call when the show/hide password button is pressed.
  func showHidePasswordButtonTapped()

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear.
  func viewWillAppear()

  /// Call when the trait collection did change.
  func traitCollectionDidChange()
}

public protocol LoginViewModelOutputs {
  /// Emits when to dismiss a textfield keyboard
  var dismissKeyboard: Signal<(), Never> { get }

  /// Sets whether the email text field is the first responder.
  var emailTextFieldBecomeFirstResponder: Signal<(), Never> { get }

  /// Bool value whether form is valid
  var isFormValid: Signal<Bool, Never> { get }

  /// Emits an access token envelope that can be used to update the environment.
  var logIntoEnvironment: Signal<AccessTokenEnvelope, Never> { get }

  /// Emits when the password textfield should become the first responder
  var passwordTextFieldBecomeFirstResponder: Signal<(), Never> { get }

  /// Emits when a login success notification should be posted.
  var postNotification: Signal<(Notification, Notification), Never> { get }

  /// Emits when a login error has occurred and a message should be displayed.
  var showError: Signal<String, Never> { get }

  /// Emits when the reset password screen should be shown
  var showResetPassword: Signal<(), Never> { get }

  /// Emits when the show/hide password button is toggled
  var showHidePasswordButtonToggled: Signal<Bool, Never> { get }

  /// Emits when TFA is required for login.
  var tfaChallenge: Signal<(email: String, password: String), Never> { get }
}

public protocol LoginViewModelType {
  var inputs: LoginViewModelInputs { get }
  var outputs: LoginViewModelOutputs { get }
}

public final class LoginViewModel: LoginViewModelType, LoginViewModelInputs, LoginViewModelOutputs {
  public init() {
    let emailAndPassword = Signal.combineLatest(
      self.emailChangedProperty.signal.skipNil(),
      self.passwordChangedProperty.signal.skipNil()
    )

    self.emailTextFieldBecomeFirstResponder = self.viewDidLoadProperty.signal

    self.isFormValid = self.viewWillAppearProperty.signal.mapConst(false).take(first: 1)
      .mergeWith(emailAndPassword.map(isValid))

    let tryLogin = Signal.merge(
      self.loginButtonPressedProperty.signal,
      self.passwordTextFieldDoneEditingProperty.signal
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
      .mapConst(
        (
          Notification(name: .ksr_sessionStarted),
          Notification(
            name: .ksr_showNotificationsDialog,
            userInfo: [UserInfoKeys.context: PushNotificationDialog.Context.login]
          )
        )
      )

    self.dismissKeyboard = self.passwordTextFieldDoneEditingProperty.signal
    self.passwordTextFieldBecomeFirstResponder = self.emailTextFieldDoneEditingProperty.signal

    self.showError = loginEvent.errors()
      .filter { $0.ksrCode != .TfaRequired }
      .map { env in
        env.errorMessages.first ?? Strings.login_errors_unable_to_log_in()
      }

    self.showResetPassword = self.resetPasswordPressedProperty.signal

    self.showHidePasswordButtonToggled = Signal.merge(
      self.shouldShowPasswordProperty.signal,
      self.shouldShowPasswordProperty.signal.takeWhen(self.traitCollectionDidChangeProperty.signal)
    )

    // Tracking

    self.viewDidLoadProperty.signal
      .observeValues { AppEnvironment.current.ksrAnalytics.trackLoginPageViewed() }

    tryLogin
      .observeValues { AppEnvironment.current.ksrAnalytics.trackLoginSubmitButtonClicked() }
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

  fileprivate let shouldShowPasswordProperty = MutableProperty(false)
  public func showHidePasswordButtonTapped() {
    self.shouldShowPasswordProperty.value = self.shouldShowPasswordProperty.negate().value
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let traitCollectionDidChangeProperty = MutableProperty(())
  public func traitCollectionDidChange() {
    self.traitCollectionDidChangeProperty.value = ()
  }

  public let dismissKeyboard: Signal<(), Never>
  public let emailTextFieldBecomeFirstResponder: Signal<(), Never>
  public let isFormValid: Signal<Bool, Never>
  public let logIntoEnvironment: Signal<AccessTokenEnvelope, Never>
  public let passwordTextFieldBecomeFirstResponder: Signal<(), Never>
  public let postNotification: Signal<(Notification, Notification), Never>
  public let showError: Signal<String, Never>
  public let showResetPassword: Signal<(), Never>
  public let showHidePasswordButtonToggled: Signal<Bool, Never>
  public let tfaChallenge: Signal<(email: String, password: String), Never>
}

private func isValid(email: String, password: String) -> Bool {
  return isValidEmail(email) && !password.isEmpty
}
