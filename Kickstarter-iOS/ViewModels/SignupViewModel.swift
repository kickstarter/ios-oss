import Foundation
import Library
import KsApi
import Models
import Prelude
import ReactiveCocoa
import Result

internal protocol SignupViewModelInputs {
  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the user enters a new name.
  func nameChanged(name: String)

  /// Call when the user enters a new email address.
  func emailChanged(email: String)

  /// Call when the user enters a new password.
  func passwordChanged(password: String)

  /// Call when the user toggles weekly newsletter.
  func weeklyNewsletterChanged(weeklyNewsletter: Bool)

  /// Call when the user taps signup.
  func signupButtonPressed()

  /// Call when the environment has been logged into
  func environmentLoggedIn()
}

internal protocol SignupViewModelOutputs {
  /// Emits the value for the weekly newsletter.
  var setWeeklyNewsletterState: Signal<Bool, NoError> { get }

  /// Emits true when the signup button should be enabled, false otherwise.
  var isSignupButtonEnabled: Signal<Bool, NoError> { get }

  /// Emits when a notification should be posted.
  var postNotification: Signal<NSNotification, NoError> { get }

  /// Emits an access token envelope that can be used to update the environment.
  var logIntoEnvironment: Signal<AccessTokenEnvelope, NoError> { get }
}

internal protocol SignupViewModelErrors {
  /// Emits when a signup error has occurred and a message should be displayed.
  var showError: Signal<String, NoError> { get }
}

internal protocol SignupViewModelType {
  var inputs: SignupViewModelInputs { get }
  var outputs: SignupViewModelOutputs { get }
  var errors: SignupViewModelErrors { get }
}

internal final class SignupViewModel: SignupViewModelType, SignupViewModelInputs, SignupViewModelOutputs,
SignupViewModelErrors {
  internal init() {
    self.setWeeklyNewsletterState = viewDidLoadProperty.signal.map {
      AppEnvironment.current.countryCode == "US"
    }

    self.isSignupButtonEnabled = combineLatest(
      nameChangedProperty.signal,
      emailChangedProperty.signal,
      passwordChangedProperty.signal
      )
      .map { name, email, password in
        !name.characters.isEmpty &&
        isValidEmail(email) &&
        !password.characters.isEmpty
      }
      .mergeWith(viewDidLoadProperty.signal.mapConst(false))

    // MILK: password confirmation
    // MILK: newsletter
    // MILK: Validate input again?
    let signupEvent = combineLatest(
        nameChangedProperty.signal,
        emailChangedProperty.signal,
        passwordChangedProperty.signal
      )
      .takeWhen(signupButtonPressedProperty.signal)
      .switchMap { name, email, password in
        AppEnvironment.current.apiService.signup(
          name: name,
          email: email,
          password: password,
          passwordConfirmation: password,
          sendNewsletters: true
          )
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .materialize()
      }

    self.logIntoEnvironment = signupEvent.values()

    self.postNotification = self.environmentLoggedInProperty.signal
      .mapConst(NSNotification(name: CurrentUserNotifications.sessionStarted, object: nil))
  }

  // INPUTS
  private let viewDidLoadProperty = MutableProperty()
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let nameChangedProperty = MutableProperty<String>("")
  internal func nameChanged(name: String) {
    self.nameChangedProperty.value = name
  }

  private let emailChangedProperty = MutableProperty<String>("")
  internal func emailChanged(email: String) {
    self.emailChangedProperty.value = email
  }

  private let passwordChangedProperty = MutableProperty<String>("")
  internal func passwordChanged(password: String) {
    self.passwordChangedProperty.value = password
  }

  private let weeklyNewsletterChangedProperty = MutableProperty<Bool?>(nil)
  internal func weeklyNewsletterChanged(weeklyNewsletter: Bool) {
    self.weeklyNewsletterChangedProperty.value = weeklyNewsletter
  }

  private let signupButtonPressedProperty = MutableProperty()
  internal func signupButtonPressed() {
    self.signupButtonPressedProperty.value = ()
  }

  private let environmentLoggedInProperty = MutableProperty(())
  internal func environmentLoggedIn() {
    self.environmentLoggedInProperty.value = ()
  }

  // OUTPUTS
  internal let setWeeklyNewsletterState: Signal<Bool, NoError>
  internal let isSignupButtonEnabled: Signal<Bool, NoError>
  internal let postNotification: Signal<NSNotification, NoError>
  internal let logIntoEnvironment: Signal<AccessTokenEnvelope, NoError>


  // ERRORS
  internal let showError: Signal<String, NoError> = .empty

  var inputs: SignupViewModelInputs { return self }
  var outputs: SignupViewModelOutputs { return self }
  var errors: SignupViewModelErrors { return self }
}
