import Foundation
import KsApi
import Prelude
import ReactiveSwift
import Result

public func signupViewModel(
  emailChanged: Signal<(String), NoError>,
  emailTextFieldReturn: Signal<(), NoError>,
  environmentLoggedIn: Signal<(), NoError>,
  nameChanged: Signal<(String), NoError>,
  nameTextFieldReturn: Signal<(), NoError>,
  passwordChanged: Signal<(String), NoError>,
  passwordTextFieldReturn: Signal<(), NoError>,
  signupButtonPressed: Signal<(), NoError>,
  viewDidLoad: Signal<(), NoError>,
  weeklyNewsletterChanged: Signal<(Bool), NoError>
) -> (
  emailTextFieldBecomeFirstResponder: Signal<(), NoError>,
  isSignupButtonEnabled: Signal<Bool, NoError>,
  logIntoEnvironment: Signal<AccessTokenEnvelope, NoError>,
  passwordTextFieldBecomeFirstResponder: Signal<(), NoError>,
  postNotification: Signal<Notification, NoError>,
  nameTextFieldBecomeFirstResponder: Signal<(), NoError>,
  setWeeklyNewsletterState: Signal<Bool, NoError>,
  showError: Signal<String, NoError>
) {
  let initialText = viewDidLoad.mapConst("")
  let name = Signal.merge(
    nameChanged,
    initialText
  )
  let email = Signal.merge(
    emailChanged,
    initialText
  )
  let password = Signal.merge(
    passwordChanged,
    initialText
  )

  let newsletter = Signal.merge(
    viewDidLoad.mapConst(false),
    weeklyNewsletterChanged
  )

  let nameIsPresent = name.map { !$0.isEmpty }
  let emailIsPresent = email.map { !$0.isEmpty }
  let passwordIsPresent = password.map { !$0.isEmpty }

  let nameTextFieldBecomeFirstResponder = viewDidLoad
  let emailTextFieldBecomeFirstResponder = nameTextFieldReturn
  let passwordTextFieldBecomeFirstResponder = emailTextFieldReturn

  let isSignupButtonEnabled = Signal.combineLatest(nameIsPresent, emailIsPresent, passwordIsPresent)
    .map { $0 && $1 && $2 }
    .skipRepeats()

  let setWeeklyNewsletterState = newsletter.take(first: 1)

  let attemptSignup = Signal.merge(
    passwordTextFieldReturn,
    signupButtonPressed
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

  let postNotification = environmentLoggedIn
    .mapConst(Notification(name: .ksr_sessionStarted))

  environmentLoggedIn
    .observeValues { AppEnvironment.current.koala.trackLoginSuccess(authType: Koala.AuthType.email) }

  showError
    .observeValues { _ in AppEnvironment.current.koala.trackSignupError(authType: Koala.AuthType.email) }

  weeklyNewsletterChanged
    .observeValues {
      AppEnvironment.current.koala.trackChangeNewsletter(
        newsletterType: .weekly, sendNewsletter: $0, project: nil, context: .signup
      )
  }

  signupEvent.values()
    .observeValues { _ in AppEnvironment.current.koala.trackSignupSuccess(authType: Koala.AuthType.email) }

  viewDidLoad
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
