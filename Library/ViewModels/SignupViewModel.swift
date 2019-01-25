import Foundation
import KsApi
import Prelude
import ReactiveSwift
import Result

public final class SignupViewModel {
  public struct Inputs {
    /// Call when the user enters a new email address.
    public let emailTextChanged = MutableProperty<String?>(nil)
    /// Call when the user returns from email text field.
    public let emailTextFieldDidReturn = MutableProperty(())
    /// Call when the environment has been logged into
    public let environmentLoggedIn = MutableProperty(())
    /// Call when the user enters a new name.
    public let nameTextChanged = MutableProperty<String?>(nil)
    /// Call when the user returns from the name text field.
    public let nameTextFieldDidReturn = MutableProperty(())
    /// Call when the user enters a new password.
    public let passwordTextChanged = MutableProperty<String?>(nil)
    /// Call when the user returns from the password text field.
    public let passwordTextFieldDidReturn = MutableProperty(())
    /// Call when the user taps signup.
    public let signupButtonPressed = MutableProperty(())
    /// Call when the view did load.
    public let viewDidLoad = MutableProperty(())
    /// Call when the user toggles weekly newsletter.
    public let weeklyNewsletterChanged = MutableProperty(false)
  }

  public let inputs = Inputs()

  public init() {}

  public func outputs(from inputs: Inputs) -> (
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
    ) {
      let initialText = inputs.viewDidLoad.signal.mapConst("")

      let name = Signal.merge(
        inputs.nameTextChanged.signal.skipNil(),
        initialText
      )

      let email = Signal.merge(
        inputs.emailTextChanged.signal.skipNil(),
        initialText
      )
      let password = Signal.merge(
        inputs.passwordTextChanged.signal.skipNil(),
        initialText
      )

      let newsletter = Signal.merge(
        inputs.viewDidLoad.signal.mapConst(false),
        inputs.weeklyNewsletterChanged.signal
      )

      let nameIsPresent = name.map { !$0.isEmpty }
      let emailIsPresent = email.map { !$0.isEmpty }
      let passwordIsPresent = password.map { !$0.isEmpty }

      let nameTextFieldBecomeFirstResponder = inputs.viewDidLoad.signal
      let emailTextFieldBecomeFirstResponder = inputs.nameTextFieldDidReturn.signal
      let passwordTextFieldBecomeFirstResponder = inputs.emailTextFieldDidReturn.signal

      let isSignupButtonEnabled = Signal.combineLatest(nameIsPresent, emailIsPresent, passwordIsPresent)
        .map { $0 && $1 && $2 }
        .skipRepeats()

      let setWeeklyNewsletterState = newsletter.take(first: 1)

      let attemptSignup = Signal.merge(
        inputs.passwordTextFieldDidReturn.signal,
        inputs.signupButtonPressed.signal
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

      let postNotification = inputs.environmentLoggedIn.signal
        .mapConst(Notification(name: .ksr_sessionStarted))

      inputs.environmentLoggedIn.signal
        .observeValues { AppEnvironment.current.koala.trackLoginSuccess(authType: Koala.AuthType.email) }

      showError
        .observeValues { _ in AppEnvironment.current.koala.trackSignupError(authType: Koala.AuthType.email) }

      inputs.weeklyNewsletterChanged.signal
        .observeValues {
          AppEnvironment.current.koala.trackChangeNewsletter(
            newsletterType: .weekly, sendNewsletter: $0, project: nil, context: .signup
          )
      }

      signupEvent.values()
        .observeValues {
          _ in AppEnvironment.current.koala.trackSignupSuccess(authType: Koala.AuthType.email)
      }

      inputs.viewDidLoad.signal
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
