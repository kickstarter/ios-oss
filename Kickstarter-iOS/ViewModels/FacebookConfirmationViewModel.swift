import KsApi
import ReactiveCocoa
import ReactiveExtensions
import Result
import Library
import FBSDKCoreKit

internal protocol FacebookConfirmationViewModelInputs {
  /// Call when view controller's viewDidLoad() is called
  func viewDidLoad()
  /// Call to set an email address for the user
  func email(email: String)
  /// Call to set a facebook token for the user
  func facebookToken(token: String)
  /// Call when newsletter switch is toggled
  func sendNewslettersToggled(newsletters: Bool)
  /// Call when create new account button is pressed
  func createAccountButtonPressed()
  /// Call when Login with email button is pressed
  func loginButtonPressed()
  /// Call when the environment has been logged into
  func environmentLoggedIn()
}

internal protocol FacebookConfirmationViewModelOutputs {
  /// Emits an email address to display
  var displayEmail: Signal<String, NoError> { get }
  /// Emits whether to send newsletters with login
  var sendNewsletters: Signal<Bool, NoError> { get }
  /// Emits when a login success notification should be posted.
  var postNotification: Signal<NSNotification, NoError> { get }
  /// Emits an access token envelope that can be used to update the environment.
  var logIntoEnvironment: Signal<AccessTokenEnvelope, NoError> { get }
  /// Emits to show the Login with Email flow
  var showLogin: Signal<(), NoError> { get }
  /// Emits whether a request is loading or not
  var isLoading: Signal<Bool, NoError> { get }
}

internal protocol FacebookConfirmationViewModelErrors {
  var showSignupError: Signal<String, NoError> { get }
}

internal protocol FacebookConfirmationViewModelType {
  var inputs: FacebookConfirmationViewModelInputs { get }
  var outputs: FacebookConfirmationViewModelOutputs { get }
  var errors: FacebookConfirmationViewModelErrors { get }
}

internal final class FacebookConfirmationViewModel: FacebookConfirmationViewModelType,
FacebookConfirmationViewModelInputs, FacebookConfirmationViewModelOutputs,
FacebookConfirmationViewModelErrors {

  // MARK: FacebookConfirmationViewModelType
  internal var inputs: FacebookConfirmationViewModelInputs { return self }
  internal var outputs: FacebookConfirmationViewModelOutputs { return self }
  internal var errors: FacebookConfirmationViewModelErrors { return self }

  // MARK: FacebookConfirmationViewModelInputs
  private let viewDidLoadProperty = MutableProperty()
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let sendNewslettersToggledProperty = MutableProperty(false)
  func sendNewslettersToggled(newsletters: Bool) {
    self.sendNewslettersToggledProperty.value = newsletters
  }

  private let emailProperty = MutableProperty("")
  func email(email: String) {
    self.emailProperty.value = email
  }

  private let facebookTokenProperty = MutableProperty("")
  func facebookToken(token: String) {
    self.facebookTokenProperty.value = token
  }

  private let createAccountButtonProperty = MutableProperty()
  internal func createAccountButtonPressed() {
    self.createAccountButtonProperty.value = ()
  }

  private let loginButtonPressedProperty = MutableProperty()
  internal func loginButtonPressed() {
    self.loginButtonPressedProperty.value = ()
  }

  private let environmentLoggedInProperty = MutableProperty()
  internal func environmentLoggedIn() {
    self.environmentLoggedInProperty.value = ()
  }

  // MARK: FacebookConfirmationViewModelOutputs
  internal let displayEmail: Signal<String, NoError>
  internal let sendNewsletters: Signal<Bool, NoError>
  internal let logIntoEnvironment: Signal<AccessTokenEnvelope, NoError>
  internal let postNotification: Signal<NSNotification, NoError>
  internal let showLogin: Signal<(), NoError>
  internal let isLoading: Signal<Bool, NoError>

  // MARK: FacebookConfirmationViewModelErrors
  internal let showSignupError: Signal<String, NoError>

  internal init() {
    let isLoading = MutableProperty(false)

    self.isLoading = isLoading.signal

    self.displayEmail = self.emailProperty.signal.takeWhen(self.viewDidLoadProperty.signal)

    self.sendNewsletters = Signal.merge([
      self.sendNewslettersToggledProperty.signal,
      self.viewDidLoadProperty.signal.map { AppEnvironment.current.countryCode != "DE" }
    ])

    let signupEvent = combineLatest(self.facebookTokenProperty.signal, self.sendNewsletters)
      .takeWhen(self.createAccountButtonProperty.signal)
      .switchMap { token, newsletter in
        AppEnvironment.current.apiService.signup(facebookAccessToken: token, sendNewsletters: newsletter)
          .on(
            started: {
              isLoading.value = true
            },
            terminated: {
              isLoading.value = false
          })
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .materialize()
    }

    self.logIntoEnvironment = signupEvent.values()

    self.postNotification = self.environmentLoggedInProperty.signal
      .mapConst(NSNotification(name: CurrentUserNotifications.sessionStarted, object: nil))

    self.showSignupError = signupEvent.errors()
      .map { error in
        error.errorMessages.first ??
        localizedString(key: "facebook_confirmation.could_not_log_in",
          defaultValue: "Couldn't log in with Facebook.")
    }

    self.showLogin = self.loginButtonPressedProperty.signal

    self.viewDidLoadProperty.signal.observeNext { AppEnvironment.current.koala.trackFacebookConfirmation() }

    self.logIntoEnvironment.observeNext { _ in AppEnvironment.current.koala.trackFacebookLoginSuccess() }

    self.showSignupError.observeNext { _ in AppEnvironment.current.koala.trackFacebookLoginError() }

    self.sendNewslettersToggledProperty.signal
      .observeNext { AppEnvironment.current.koala.trackSignupNewsletterToggle($0) }
  }
}
