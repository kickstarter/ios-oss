import Foundation
import KsApi
import Prelude
import ReactiveSwift
import Result

public final class SignupViewModel {
  public struct Inputs {
    public let environmentLoggedIn = MutableProperty(())
    public let emailTextChanged = MutableProperty<String?>(nil)
    public let emailTextFieldDidReturn = MutableProperty(())
    public let nameTextChanged = MutableProperty<String?>(nil)
    public let nameTextFieldDidReturn = MutableProperty(())
    public let passwordTextChanged = MutableProperty<String?>(nil)
    public let passwordTextFieldDidReturn = MutableProperty(())
    public let signupButtonPressed = MutableProperty(())
    public let viewDidLoad = MutableProperty(())
    public let weeklyNewsletterChanged = MutableProperty(false)
  }

  public let inputs = Inputs()

  public init() {}

  public func outputs(from inputs: Inputs) -> (
    emailTextFieldBecomeFirstResponder: Signal<(), NoError>,
    isSignupButtonEnabled: Signal<Bool, NoError>,
    logIntoEnvironment: Signal<AccessTokenEnvelope, NoError>,
    passwordTextFieldBecomeFirstResponder: Signal<(), NoError>,
    postNotification: Signal<Notification, NoError>,
    nameTextFieldBecomeFirstResponder: Signal<(), NoError>,
    setWeeklyNewsletterState: Signal<Bool, NoError>,
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
