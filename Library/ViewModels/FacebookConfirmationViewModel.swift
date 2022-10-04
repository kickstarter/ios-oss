import Foundation
import KsApi
import ReactiveExtensions
import ReactiveSwift

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
  /// Call when link tapped on disclaimer textView
  func tapped(_ url: URL)
}

public protocol FacebookConfirmationViewModelOutputs {
  /// Emits an email address to display
  var displayEmail: Signal<String, Never> { get }
  /// Emits whether to send newsletters with login
  var sendNewsletters: Signal<Bool, Never> { get }
  /// Emits when a login success notification should be posted.
  var postNotification: Signal<Notification, Never> { get }
  /// Emits an access token envelope that can be used to update the environment.
  var logIntoEnvironment: Signal<AccessTokenEnvelope, Never> { get }
  /// Emits to show the Login with Email flow
  var showLogin: Signal<(), Never> { get }
  /// Emits whether a request is loading or not
  var isLoading: Signal<Bool, Never> { get }
  /// Emits when a help link from a disclaimer should be opened.
  var notifyDelegateOpenHelpType: Signal<HelpType, Never> { get }
}

public protocol FacebookConfirmationViewModelErrors {
  var showSignupError: Signal<String, Never> { get }
}

public protocol FacebookConfirmationViewModelType {
  var inputs: FacebookConfirmationViewModelInputs { get }
  var outputs: FacebookConfirmationViewModelOutputs { get }
  var errors: FacebookConfirmationViewModelErrors { get }
}

public final class FacebookConfirmationViewModel: FacebookConfirmationViewModelType,
  FacebookConfirmationViewModelInputs, FacebookConfirmationViewModelOutputs,
  FacebookConfirmationViewModelErrors {
  // MARK: - FacebookConfirmationViewModelType

  public var inputs: FacebookConfirmationViewModelInputs { return self }
  public var outputs: FacebookConfirmationViewModelOutputs { return self }
  public var errors: FacebookConfirmationViewModelErrors { return self }

  // MARK: - FacebookConfirmationViewModelInputs

  fileprivate let viewDidLoadProperty = MutableProperty(())
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

  fileprivate let createAccountButtonProperty = MutableProperty(())
  public func createAccountButtonPressed() {
    self.createAccountButtonProperty.value = ()
  }

  fileprivate let loginButtonPressedProperty = MutableProperty(())
  public func loginButtonPressed() {
    self.loginButtonPressedProperty.value = ()
  }

  fileprivate let environmentLoggedInProperty = MutableProperty(())
  public func environmentLoggedIn() {
    self.environmentLoggedInProperty.value = ()
  }

  private let tappedUrlProperty = MutableProperty<(URL)?>(nil)
  public func tapped(_ url: URL) {
    self.tappedUrlProperty.value = url
  }

  // MARK: - FacebookConfirmationViewModelOutputs

  public let displayEmail: Signal<String, Never>
  public let sendNewsletters: Signal<Bool, Never>
  public let logIntoEnvironment: Signal<AccessTokenEnvelope, Never>
  public let postNotification: Signal<Notification, Never>
  public let showLogin: Signal<(), Never>
  public let isLoading: Signal<Bool, Never>
  public let notifyDelegateOpenHelpType: Signal<HelpType, Never>

  // MARK: - FacebookConfirmationViewModelErrors

  public let showSignupError: Signal<String, Never>

  public init() {
    let isLoading = MutableProperty(false)

    self.isLoading = isLoading.signal

    self.displayEmail = self.emailProperty.signal.takeWhen(self.viewDidLoadProperty.signal)

    self.sendNewsletters = Signal.merge([
      self.sendNewslettersToggledProperty.signal,
      self.viewDidLoadProperty.signal.mapConst(false)
    ])

    let signupEvent = Signal.combineLatest(self.facebookTokenProperty.signal, self.sendNewsletters)
      .takeWhen(self.createAccountButtonProperty.signal)
      .switchMap { token, newsletter in
        AppEnvironment.current.apiService.signup(facebookAccessToken: token, sendNewsletters: newsletter)
          .on(
            starting: {
              isLoading.value = true
            },
            terminated: {
              isLoading.value = false
            }
          )
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    self.logIntoEnvironment = signupEvent.values()

    self.postNotification = self.environmentLoggedInProperty.signal
      .mapConst(Notification(name: .ksr_sessionStarted))

    self.showSignupError = signupEvent.errors()
      .map { error in
        error.errorMessages.first ??
          Strings.facebook_confirmation_could_not_log_in()
      }

    self.showLogin = self.loginButtonPressedProperty.signal

    self.notifyDelegateOpenHelpType = self.tappedUrlProperty.signal.skipNil().map { url -> HelpType? in
      HelpType.allCases.first(where: {
        url.absoluteString == $0.url(
          withBaseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl
        )?.absoluteString
      })
    }
    .skipNil()
  }
}
