import Foundation
import KsApi
import Prelude
import ReactiveSwift
import Result

public final class SignupViewModel {
  public struct Inputs {
    /// Call when the user enters a new email address.
    public let (emailTextChangedSignal, emailTextChangedObserver) = Signal<String?, NoError>.pipe()
    /// Call when the user returns from email text field.
    public let (emailTextFieldDidReturnSignal, emailTextFieldDidReturnObserver) = Signal<(), NoError>.pipe()
    /// Call when the environment has been logged into
    public let (environmentLoggedInSignal, environmentLoggedInObserver) = Signal<(), NoError>.pipe()
    /// Call when the user enters a new name.
    public let (nameTextChangedSignal, nameTextChangedObserver) = Signal<String?, NoError>.pipe()
    /// Call when the user returns from the name text field.
    public let (nameTextFieldDidReturnSignal, nameTextFieldDidReturnObserver) = Signal<(), NoError>.pipe()
    /// Call when the user enters a new password.
    public let (passwordTextChangedSignal, passwordTextChangedObserver) = Signal<String?, NoError>.pipe()
    /// Call when the user returns from the password text field.
    public let (passwordTextFieldDidReturnSignal, passwordTextFieldDidReturnObserver) =
      Signal<(), NoError>.pipe()
    /// Call when the user taps signup.
    public let (signupButtonPressedSignal, signupButtonPressedObserver) = Signal<(), NoError>.pipe()
    /// Call when the view did load.
    public let (viewDidLoadSignal, viewDidLoadObserver) = Signal<(), NoError>.pipe()
    /// Call when the user toggles weekly newsletter.
    public let (weeklyNewsletterChangedSignal, weeklyNewsletterChangedObserver) = Signal<Bool, NoError>.pipe()

    init() {}
  }

  public typealias Outputs = (
    // Call when the emailTextField should become the first responder
    emailTextFieldBecomeFirstResponder: Signal<(), NoError>,
    // Call when the sign up button should be enabled
    isSignupButtonEnabled: Signal<Bool, NoError>,
    /// Emits an access token envelope that can be used to update the environment.
    logIntoEnvironment: Signal<AccessTokenEnvelope, NoError>,
    /// Sets whether the password text field is the first responder.
    passwordTextFieldBecomeFirstResponder: Signal<(), NoError>,
    /// Emits when a notification should be posted.
    postNotification: Signal<Notification, NoError>,
    /// Sets whether the name text field is the first responder.
    nameTextFieldBecomeFirstResponder: Signal<(), NoError>,
    /// Emits the value for the weekly newsletter.
    setWeeklyNewsletterState: Signal<Bool, NoError>,
    /// Emits when a signup error has occurred and a message should be displayed.
    showError: Signal<String, NoError>
  )

  public let inputs = Inputs()

  public init() {}

  public func outputs(from inputs: Inputs) -> Outputs {
    let name = inputs.nameTextChangedSignal.skipNil()
    let email = inputs.emailTextChangedSignal.skipNil()
    let password = inputs.passwordTextChangedSignal.skipNil()

    let newsletter = Signal.merge(
      inputs.viewDidLoadSignal.mapConst(false),
      inputs.weeklyNewsletterChangedSignal
    )

    let nameIsPresent = name.map { !$0.isEmpty }
    let emailIsPresent = email.map { !$0.isEmpty }
    let passwordIsPresent = password.map { !$0.isEmpty }

    let nameTextFieldBecomeFirstResponder = inputs.viewDidLoadSignal
    let emailTextFieldBecomeFirstResponder = inputs.nameTextFieldDidReturnSignal
    let passwordTextFieldBecomeFirstResponder = inputs.emailTextFieldDidReturnSignal

    let formIsValid = Signal.combineLatest(nameIsPresent, emailIsPresent, passwordIsPresent)
      .map { $0 && $1 && $2 }
      .skipRepeats()

    let isSignupButtonEnabled = Signal.merge(formIsValid, inputs.viewDidLoadSignal.mapConst(false))

    let setWeeklyNewsletterState = newsletter.take(first: 1)

    let attemptSignup = Signal.merge(
      inputs.passwordTextFieldDidReturnSignal,
      inputs.signupButtonPressedSignal
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

    let showError = signupError
    let logIntoEnvironment = signupEvent.values()

    let postNotification = inputs.environmentLoggedInSignal
      .mapConst(Notification(name: .ksr_sessionStarted))

    inputs.environmentLoggedInSignal
      .observeValues { AppEnvironment.current.koala.trackLoginSuccess(authType: Koala.AuthType.email) }

    showError
      .observeValues { _ in AppEnvironment.current.koala.trackSignupError(authType: Koala.AuthType.email) }

    inputs.weeklyNewsletterChangedSignal
      .observeValues {
        AppEnvironment.current.koala.trackChangeNewsletter(
          newsletterType: .weekly, sendNewsletter: $0, project: nil, context: .signup
        )
    }

    signupEvent.values()
      .observeValues {
        _ in AppEnvironment.current.koala.trackSignupSuccess(authType: Koala.AuthType.email)
    }

    inputs.viewDidLoadSignal
      .observeValues { AppEnvironment.current.koala.trackSignupView() }

    return (
      emailTextFieldBecomeFirstResponder: emailTextFieldBecomeFirstResponder,
      isSignupButtonEnabled: isSignupButtonEnabled,
      logIntoEnvironment: logIntoEnvironment,
      passwordTextFieldBecomeFirstResponder: passwordTextFieldBecomeFirstResponder,
      postNotification: postNotification,
      nameTextFieldBecomeFirstResponder: nameTextFieldBecomeFirstResponder,
      setWeeklyNewsletterState: setWeeklyNewsletterState,
      showError: showError
    )
  }
}
