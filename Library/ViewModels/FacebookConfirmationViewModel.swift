import KsApi
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol FacebookConfirmationViewModelInputs {
  /// Call when view controller's viewDidLoad() is called
  func viewDidLoad()
  /// Call to set an email address for the user
  func email(_ email: String)
  /// Call to set a facebook token for the user
  func facebookToken(_ token: String)
  /// Call when newsletter switch is toggled
  func sendNewslettersToggled(_ newsletters: Bool)
  /// Call when create new account button is pressed
  func createAccountButtonPressed()
  /// Call when Login with email button is pressed
  func loginButtonPressed()
  /// Call when the environment has been logged into
  func environmentLoggedIn()
}

public protocol FacebookConfirmationViewModelOutputs {
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

public protocol FacebookConfirmationViewModelErrors {
  var showSignupError: Signal<String, NoError> { get }
}

public protocol FacebookConfirmationViewModelType {
  var inputs: FacebookConfirmationViewModelInputs { get }
  var outputs: FacebookConfirmationViewModelOutputs { get }
  var errors: FacebookConfirmationViewModelErrors { get }
}

public final class FacebookConfirmationViewModel: FacebookConfirmationViewModelType,
FacebookConfirmationViewModelInputs, FacebookConfirmationViewModelOutputs,
FacebookConfirmationViewModelErrors {

  // MARK: FacebookConfirmationViewModelType
  public var inputs: FacebookConfirmationViewModelInputs { return self }
  public var outputs: FacebookConfirmationViewModelOutputs { return self }
  public var errors: FacebookConfirmationViewModelErrors { return self }

  // MARK: FacebookConfirmationViewModelInputs
  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let sendNewslettersToggledProperty = MutableProperty(false)
  public func sendNewslettersToggled(_ newsletters: Bool) {
    self.sendNewslettersToggledProperty.value = newsletters
  }

  fileprivate let emailProperty = MutableProperty("")
  public func email(_ email: String) {
    self.emailProperty.value = email
  }

  fileprivate let facebookTokenProperty = MutableProperty("")
  public func facebookToken(_ token: String) {
    self.facebookTokenProperty.value = token
  }

  fileprivate let createAccountButtonProperty = MutableProperty()
  public func createAccountButtonPressed() {
    self.createAccountButtonProperty.value = ()
  }

  fileprivate let loginButtonPressedProperty = MutableProperty()
  public func loginButtonPressed() {
    self.loginButtonPressedProperty.value = ()
  }

  fileprivate let environmentLoggedInProperty = MutableProperty()
  public func environmentLoggedIn() {
    self.environmentLoggedInProperty.value = ()
  }

  // MARK: FacebookConfirmationViewModelOutputs
  public let displayEmail: Signal<String, NoError>
  public let sendNewsletters: Signal<Bool, NoError>
  public let logIntoEnvironment: Signal<AccessTokenEnvelope, NoError>
  public let postNotification: Signal<NSNotification, NoError>
  public let showLogin: Signal<(), NoError>
  public let isLoading: Signal<Bool, NoError>

  // MARK: FacebookConfirmationViewModelErrors
  public let showSignupError: Signal<String, NoError>

  public init() {
    let isLoading = MutableProperty(false)

    self.isLoading = isLoading.signal

    self.displayEmail = self.emailProperty.signal.takeWhen(self.viewDidLoadProperty.signal)

    self.sendNewsletters = Signal.merge([
      self.sendNewslettersToggledProperty.signal,
      self.viewDidLoadProperty.signal.map { AppEnvironment.current.countryCode == "US" }
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
            Strings.facebook_confirmation_could_not_log_in()
    }

    self.showLogin = self.loginButtonPressedProperty.signal

    self.viewDidLoadProperty.signal.observeNext { AppEnvironment.current.koala.trackFacebookConfirmation() }

    self.environmentLoggedInProperty.signal
      .observeNext { _ in AppEnvironment.current.koala.trackLoginSuccess(authType: Koala.AuthType.facebook) }

    self.showSignupError
      .observeNext { _ in AppEnvironment.current.koala.trackSignupError(authType: Koala.AuthType.facebook) }

    signupEvent.values()
      .observeNext { _ in AppEnvironment.current.koala.trackSignupSuccess(authType: Koala.AuthType.facebook) }

    self.sendNewslettersToggledProperty.signal
      .observeNext {
        AppEnvironment.current.koala.trackChangeNewsletter(
          newsletterType: .weekly, sendNewsletter: $0, project: nil, context: .facebookSignup
        )
    }
  }
}
