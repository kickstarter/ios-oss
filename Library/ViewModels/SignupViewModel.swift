import Foundation
import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol SignupViewModelInputs {

  /// Call when the user enters a new email address.
  func emailChanged(email: String)

  /// Call when the user returns from email text field.
  func emailTextFieldReturn()

  /// Call when the environment has been logged into
  func environmentLoggedIn()

  /// Call when the user enters a new name.
  func nameChanged(name: String)

  /// Call when the user returns from the name text field.
  func nameTextFieldReturn()

  /// Call when the user enters a new password.
  func passwordChanged(password: String)

  /// Call when the user returns from the password text field.
  func passwordTextFieldReturn()

  /// Call when the user taps signup.
  func signupButtonPressed()

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the user toggles weekly newsletter.
  func weeklyNewsletterChanged(weeklyNewsletter: Bool)
}

public protocol SignupViewModelOutputs {
  /// Sets whether the email text field is the first responder.
  var emailTextFieldBecomeFirstResponder: Signal<(), NoError> { get }

  /// Emits true when the signup button should be enabled, false otherwise.
  var isSignupButtonEnabled: Signal<Bool, NoError> { get }

  /// Emits an access token envelope that can be used to update the environment.
  var logIntoEnvironment: Signal<AccessTokenEnvelope, NoError> { get }

  /// Sets whether the password text field is the first responder.
  var passwordTextFieldBecomeFirstResponder: Signal<(), NoError> { get }

  /// Emits when a notification should be posted.
  var postNotification: Signal<NSNotification, NoError> { get }

  /// Sets whether the name text field is the first responder.
  var nameTextFieldBecomeFirstResponder: Signal<(), NoError> { get }

  /// Emits the value for the weekly newsletter.
  var setWeeklyNewsletterState: Signal<Bool, NoError> { get }

  /// Emits when a signup error has occurred and a message should be displayed.
  var showError: Signal<String, NoError> { get }
}

public protocol SignupViewModelType {
  var inputs: SignupViewModelInputs { get }
  var outputs: SignupViewModelOutputs { get }
}

public final class SignupViewModel: SignupViewModelType, SignupViewModelInputs, SignupViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {
    let initialText = self.viewDidLoadProperty.signal.mapConst("")
    let name = Signal.merge(
      self.nameChangedProperty.signal,
      initialText
    )
    let email = Signal.merge(
      self.emailChangedProperty.signal,
      initialText
    )
    let password = Signal.merge(
      self.passwordChangedProperty.signal,
      initialText
    )
    let newsletter = Signal.merge(
      self.viewDidLoadProperty.signal.map { AppEnvironment.current.config?.countryCode == "US" },
      self.weeklyNewsletterChangedProperty.signal.ignoreNil()
    )

    let nameIsPresent = name.map { !$0.isEmpty }
    let emailIsPresent = email.map { !$0.isEmpty }
    let passwordIsPresent = password.map { !$0.isEmpty }

    self.nameTextFieldBecomeFirstResponder = self.viewDidLoadProperty.signal.ignoreValues()
    self.emailTextFieldBecomeFirstResponder = self.nameTextFieldReturnProperty.signal
    self.passwordTextFieldBecomeFirstResponder = self.emailTextFieldReturnProperty.signal

    self.isSignupButtonEnabled = combineLatest(nameIsPresent, emailIsPresent, passwordIsPresent)
      .map { $0 && $1 && $2 }
      .skipRepeats()

    self.setWeeklyNewsletterState = newsletter.take(1)

    let attemptSignup = Signal.merge(
      self.passwordTextFieldReturnProperty.signal,
      self.signupButtonPressedProperty.signal
    )

    let signupEvent = combineLatest(name, email, password, newsletter)
      .takeWhen(attemptSignup)
      .switchMap { name, email, password, newsletter in
        AppEnvironment.current.apiService.signup(
          name: name,
          email: email,
          password: password,
          passwordConfirmation: password,
          sendNewsletters: newsletter)
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .materialize()
      }

    let signupError = signupEvent.errors()
      .map {
        $0.errorMessages.first ?? Strings.signup_error_something_wrong()
    }

    self.showError = signupError

    self.logIntoEnvironment = signupEvent.values()

    self.postNotification = self.environmentLoggedInProperty.signal
      .mapConst(NSNotification(name: CurrentUserNotifications.sessionStarted, object: nil))

    self.environmentLoggedInProperty.signal
      .observeNext { AppEnvironment.current.koala.trackLoginSuccess() }

    self.showError
      .observeNext { _ in AppEnvironment.current.koala.trackSignupError() }

    self.weeklyNewsletterChangedProperty.signal
      .ignoreNil()
      .observeNext { AppEnvironment.current.koala.trackSignupNewsletterToggle($0) }

    signupEvent.values()
      .observeNext { _ in AppEnvironment.current.koala.trackSignupSuccess() }

    self.viewDidLoadProperty.signal
      .observeNext { AppEnvironment.current.koala.trackSignupView() }
  }

  // INPUTS
  private let emailChangedProperty = MutableProperty("")
  public func emailChanged(email: String) {
    self.emailChangedProperty.value = email
  }

  private let emailTextFieldReturnProperty = MutableProperty()
  public func emailTextFieldReturn() {
    self.emailTextFieldReturnProperty.value = ()
  }

  private let environmentLoggedInProperty = MutableProperty()
  public func environmentLoggedIn() {
    self.environmentLoggedInProperty.value = ()
  }

  private let nameChangedProperty = MutableProperty("")
  public func nameChanged(name: String) {
    self.nameChangedProperty.value = name
  }

  private let nameTextFieldReturnProperty = MutableProperty()
  public func nameTextFieldReturn() {
    self.nameTextFieldReturnProperty.value = ()
  }

  private let passwordChangedProperty = MutableProperty("")
  public func passwordChanged(password: String) {
    self.passwordChangedProperty.value = password
  }

  private let passwordTextFieldReturnProperty = MutableProperty()
  public func passwordTextFieldReturn() {
    self.passwordTextFieldReturnProperty.value = ()
  }

  private let signupButtonPressedProperty = MutableProperty()
  public func signupButtonPressed() {
    self.signupButtonPressedProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let weeklyNewsletterChangedProperty = MutableProperty<Bool?>(nil)
  public func weeklyNewsletterChanged(weeklyNewsletter: Bool) {
    self.weeklyNewsletterChangedProperty.value = weeklyNewsletter
  }

  // OUTPUTS
  public let emailTextFieldBecomeFirstResponder: Signal<(), NoError>
  public let isSignupButtonEnabled: Signal<Bool, NoError>
  public let logIntoEnvironment: Signal<AccessTokenEnvelope, NoError>
  public let nameTextFieldBecomeFirstResponder: Signal<(), NoError>
  public let passwordTextFieldBecomeFirstResponder: Signal<(), NoError>
  public let postNotification: Signal<NSNotification, NoError>
  public let setWeeklyNewsletterState: Signal<Bool, NoError>
  public let showError: Signal<String, NoError>

  public var inputs: SignupViewModelInputs { return self }
  public var outputs: SignupViewModelOutputs { return self }
}
