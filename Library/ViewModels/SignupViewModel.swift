import Foundation
import KsApi
import Models
import Prelude
import ReactiveCocoa
import Result

public protocol SignupViewModelInputs {

  /// Call when the user enters a new email address.
  func emailChanged(email: String)

  /// Call when the user is done editing the email text field.
  func emailTextFieldDoneEditing()

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
    let nameIsValid = Signal.merge(
      viewDidLoadProperty.signal.mapConst(false),
      nameChangedProperty.signal.map { !$0.isEmpty }
    )

    let emailIsValid = Signal.merge(
      viewDidLoadProperty.signal.mapConst(false),
      emailChangedProperty.signal.map { isValidEmail($0) }
    )

    let passwordIsValid = Signal.merge(
      viewDidLoadProperty.signal.mapConst(false),
      passwordChangedProperty.signal.map { !$0.isEmpty }
    )

    self.nameTextFieldBecomeFirstResponder = viewDidLoadProperty.signal.ignoreValues()

    self.emailTextFieldBecomeFirstResponder = self.nameTextFieldReturnProperty.signal

    self.passwordTextFieldBecomeFirstResponder = self.emailTextFieldReturnProperty.signal

    let formValid = combineLatest(nameIsValid, emailIsValid, passwordIsValid)
      .map { name, email, password in
        name && email && password
      }
      .skipRepeats()

    self.setWeeklyNewsletterState = self.viewDidLoadProperty.signal.map {
      // Change to: AppEnvironment.current.config?.countryCode == "US"
      AppEnvironment.current.countryCode == "US"
    }

    self.isSignupButtonEnabled = formValid.skipRepeats()

    let weeklyNewsletter = Signal.merge(
      self.setWeeklyNewsletterState,
      self.weeklyNewsletterChangedProperty.signal
        .ignoreNil()
    )

    let signupEvent = combineLatest(
      Signal.merge(
        self.nameChangedProperty.signal,
        self.viewDidLoadProperty.signal.mapConst("")
      ),
      Signal.merge(
        self.emailChangedProperty.signal,
        self.viewDidLoadProperty.signal.mapConst("")
      ),
      Signal.merge(
        self.passwordChangedProperty.signal,
        self.viewDidLoadProperty.signal.mapConst("")
      ),
      weeklyNewsletter
      )
      .takeWhen(
        Signal.merge(
          passwordTextFieldReturnProperty.signal,
          signupButtonPressedProperty.signal
        )
      )
      .switchMap { name, email, password, newsletter in
        AppEnvironment.current.apiService.signup(
          name: name,
          email: email,
          password: password,
          passwordConfirmation: password,
          sendNewsletters: newsletter
          )
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .materialize()
      }

    let emailError = emailIsValid
      .takeWhen(
        Signal.merge(
          emailTextFieldReturnProperty.signal,
          emailTextFieldDoneEditingProperty.signal
        )
      )
      .filter(isFalse)
      .map { _ in
        localizedString(key: "signup.error.email_invalid", defaultValue: "Oof! The email you entered isn't valid.")
      }

    let signupError = signupEvent.errors()
      .map {
        $0.errorMessages.first ??
          localizedString(key: "signup.error.something_wrong", defaultValue: "Something went wrong.")
      }

    self.showError = Signal.merge(emailError, signupError)

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
  private let emailChangedProperty = MutableProperty<String>("")
  public func emailChanged(email: String) {
    self.emailChangedProperty.value = email
  }

  private let emailTextFieldDoneEditingProperty = MutableProperty(())
  public func emailTextFieldDoneEditing() {
    self.emailTextFieldDoneEditingProperty.value = ()
  }

  private let emailTextFieldReturnProperty = MutableProperty(())
  public func emailTextFieldReturn() {
    self.emailTextFieldReturnProperty.value = ()
  }

  private let environmentLoggedInProperty = MutableProperty(())
  public func environmentLoggedIn() {
    self.environmentLoggedInProperty.value = ()
  }

  private let nameChangedProperty = MutableProperty<String>("")
  public func nameChanged(name: String) {
    self.nameChangedProperty.value = name
  }

  private let nameTextFieldReturnProperty = MutableProperty(())
  public func nameTextFieldReturn() {
    self.nameTextFieldReturnProperty.value = ()
  }

  private let passwordChangedProperty = MutableProperty<String>("")
  public func passwordChanged(password: String) {
    self.passwordChangedProperty.value = password
  }

  private let passwordTextFieldReturnProperty = MutableProperty(())
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
  public let passwordTextFieldBecomeFirstResponder: Signal<(), NoError>
  public let nameTextFieldBecomeFirstResponder: Signal<(), NoError>
  public let postNotification: Signal<NSNotification, NoError>
  public let setWeeklyNewsletterState: Signal<Bool, NoError>
  public let showError: Signal<String, NoError>

  public var inputs: SignupViewModelInputs { return self }
  public var outputs: SignupViewModelOutputs { return self }
}
