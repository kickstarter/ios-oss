import Foundation
import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol SignupViewModelInputs {
  func emailChanged(_ email: String)
  func emailTextFieldReturn()
  func environmentLoggedIn()
  func nameChanged(_ name: String)
  func nameTextFieldReturn()
  func passwordChanged(_ password: String)
  func passwordTextFieldReturn()
  func signupButtonPressed()
  func viewDidLoad()
  func weeklyNewsletterChanged(_ weeklyNewsletter: Bool)
}

public protocol SignupViewModelOutputs {
  var emailTextFieldBecomeFirstResponder: Signal<(), NoError> { get }
  var isSignupButtonEnabled: Signal<Bool, NoError> { get }
  var logIntoEnvironment: Signal<AccessTokenEnvelope, NoError> { get }
  var passwordTextFieldBecomeFirstResponder: Signal<(), NoError> { get }
  var postNotification: Signal<Notification, NoError> { get }
  var nameTextFieldBecomeFirstResponder: Signal<(), NoError> { get }
  var setWeeklyNewsletterState: Signal<Bool, NoError> { get }
  var showError: Signal<String, NoError> { get }
}

public protocol SignupViewModelType {
  var inputs: SignupViewModelInputs { get }
  var outputs: SignupViewModelOutputs { get }
}

public final class SignupViewModel: SignupViewModelType, SignupViewModelInputs, SignupViewModelOutputs {

  public var inputs: SignupViewModelInputs { return self }
  public var outputs: SignupViewModelOutputs { return self }

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
      self.viewDidLoadProperty.signal.mapConst(false),
      self.weeklyNewsletterChangedProperty.signal.skipNil()
    )

    let nameIsPresent = name.map { !$0.isEmpty }
    let emailIsPresent = email.map { !$0.isEmpty }
    let passwordIsPresent = password.map { !$0.isEmpty }

    self.nameTextFieldBecomeFirstResponder = self.viewDidLoadProperty.signal
    self.emailTextFieldBecomeFirstResponder = self.nameTextFieldReturnProperty.signal
    self.passwordTextFieldBecomeFirstResponder = self.emailTextFieldReturnProperty.signal

    self.isSignupButtonEnabled = Signal.combineLatest(nameIsPresent, emailIsPresent, passwordIsPresent)
      .map { $0 && $1 && $2 }
      .skipRepeats()

    self.setWeeklyNewsletterState = newsletter.take(first: 1)

    let attemptSignup = Signal.merge(
      self.passwordTextFieldReturnProperty.signal,
      self.signupButtonPressedProperty.signal
    )

    let signupEvent = Signal.combineLatest(name, email, password, newsletter)
      .takeWhen(attemptSignup)
      .switchMap { name, email, password, newsletter in
        AppEnvironment.current.apiService.signup(
          name: name,
          email: email,
          password: password,
          passwordConfirmation: password,
          sendNewsletters: newsletter)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    let signupError = signupEvent.errors()
      .map {
        $0.errorMessages.first ?? Strings.signup_error_something_wrong()
    }

    self.showError = signupError

    self.logIntoEnvironment = signupEvent.values()

    self.postNotification = self.environmentLoggedInProperty.signal
      .mapConst(Notification(name: .ksr_sessionStarted))

    self.environmentLoggedInProperty.signal
      .observeValues { AppEnvironment.current.koala.trackLoginSuccess(authType: Koala.AuthType.email) }

    self.showError
      .observeValues { _ in AppEnvironment.current.koala.trackSignupError(authType: Koala.AuthType.email) }

    self.weeklyNewsletterChangedProperty.signal
      .skipNil()
      .observeValues {
        AppEnvironment.current.koala.trackChangeNewsletter(
          newsletterType: .weekly, sendNewsletter: $0, project: nil, context: .signup
        )
    }

    signupEvent.values()
      .observeValues { _ in AppEnvironment.current.koala.trackSignupSuccess(authType: Koala.AuthType.email) }

    self.viewDidLoadProperty.signal
      .observeValues { AppEnvironment.current.koala.trackSignupView() }
  }

  fileprivate let emailChangedProperty = MutableProperty("")
  public func emailChanged(_ email: String) {
    self.emailChangedProperty.value = email
  }

  fileprivate let emailTextFieldReturnProperty = MutableProperty(())
  public func emailTextFieldReturn() {
    self.emailTextFieldReturnProperty.value = ()
  }

  fileprivate let environmentLoggedInProperty = MutableProperty(())
  public func environmentLoggedIn() {
    self.environmentLoggedInProperty.value = ()
  }

  fileprivate let nameChangedProperty = MutableProperty("")
  public func nameChanged(_ name: String) {
    self.nameChangedProperty.value = name
  }

  fileprivate let nameTextFieldReturnProperty = MutableProperty(())
  public func nameTextFieldReturn() {
    self.nameTextFieldReturnProperty.value = ()
  }

  fileprivate let passwordChangedProperty = MutableProperty("")
  public func passwordChanged(_ password: String) {
    self.passwordChangedProperty.value = password
  }

  fileprivate let passwordTextFieldReturnProperty = MutableProperty(())
  public func passwordTextFieldReturn() {
    self.passwordTextFieldReturnProperty.value = ()
  }

  fileprivate let signupButtonPressedProperty = MutableProperty(())
  public func signupButtonPressed() {
    self.signupButtonPressedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let weeklyNewsletterChangedProperty = MutableProperty<Bool?>(nil)
  public func weeklyNewsletterChanged(_ weeklyNewsletter: Bool) {
    self.weeklyNewsletterChangedProperty.value = weeklyNewsletter
  }

  public let emailTextFieldBecomeFirstResponder: Signal<(), NoError>
  public let isSignupButtonEnabled: Signal<Bool, NoError>
  public let logIntoEnvironment: Signal<AccessTokenEnvelope, NoError>
  public let nameTextFieldBecomeFirstResponder: Signal<(), NoError>
  public let passwordTextFieldBecomeFirstResponder: Signal<(), NoError>
  public let postNotification: Signal<Notification, NoError>
  public let setWeeklyNewsletterState: Signal<Bool, NoError>
  public let showError: Signal<String, NoError>
}
