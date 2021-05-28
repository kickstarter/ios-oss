import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol SignupViewModelInputs {
  /// Call when the user enters a new email address.
  func emailChanged(_ email: String)

  /// Call when the user returns from email text field.
  func emailTextFieldReturn()

  /// Call when the environment has been logged into
  func environmentLoggedIn()

  /// Call when the user enters a new name.
  func nameChanged(_ name: String)

  /// Call when the user returns from the name text field.
  func nameTextFieldReturn()

  /// Call when the user enters a new password.
  func passwordChanged(_ password: String)

  /// Call when the user returns from the password text field.
  func passwordTextFieldReturn()

  /// Call when the user taps signup.
  func signupButtonPressed()

  /// Call when link tapped on disclaimer textView
  func tapped(_ url: URL)

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the user toggles weekly newsletter.
  func weeklyNewsletterChanged(_ weeklyNewsletter: Bool)
}

public protocol SignupViewModelOutputs {
  /// Sets whether the email text field is the first responder.
  var emailTextFieldBecomeFirstResponder: Signal<(), Never> { get }

  /// Emits true when the signup button should be enabled, false otherwise.
  var isSignupButtonEnabled: Signal<Bool, Never> { get }

  /// Emits an access token envelope that can be used to update the environment.
  var logIntoEnvironment: Signal<AccessTokenEnvelope, Never> { get }

  /// Sets whether the name text field is the first responder.
  var nameTextFieldBecomeFirstResponder: Signal<(), Never> { get }

  /// Emits when a help link from a disclaimer should be opened.
  var notifyDelegateOpenHelpType: Signal<HelpType, Never> { get }

  /// Sets whether the password text field is the first responder.
  var passwordTextFieldBecomeFirstResponder: Signal<(), Never> { get }

  /// Emits when a notification should be posted.
  var postNotification: Signal<Notification, Never> { get }

  /// Emits the value for the weekly newsletter.
  var setWeeklyNewsletterState: Signal<Bool, Never> { get }

  /// Emits when a signup error has occurred and a message should be displayed.
  var showError: Signal<String, Never> { get }
}

public protocol SignupViewModelType {
  var inputs: SignupViewModelInputs { get }
  var outputs: SignupViewModelOutputs { get }
}

public final class SignupViewModel: SignupViewModelType, SignupViewModelInputs, SignupViewModelOutputs {
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

    let isSubscribed = Signal.merge(
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

    self.setWeeklyNewsletterState = isSubscribed.take(first: 1)

    let attemptSignup = Signal.merge(
      self.passwordTextFieldReturnProperty.signal,
      self.signupButtonPressedProperty.signal
    )

    let signupEvent = Signal.combineLatest(name, email, password, isSubscribed)
      .takeWhen(attemptSignup)
      .switchMap { name, email, password, newsletter in
        AppEnvironment.current.apiService.signup(
          name: name,
          email: email,
          password: password,
          passwordConfirmation: password,
          sendNewsletters: newsletter
        )
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

    self.notifyDelegateOpenHelpType = self.tappedUrlProperty.signal.skipNil().map { url -> HelpType? in
      HelpType.allCases.first(where: {
        url.absoluteString == $0.url(
          withBaseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl
        )?.absoluteString
      })
    }
    .skipNil()

    // Tracking

    isSubscribed.takeWhen(attemptSignup)
      .observeValues { isSubscribed in
        AppEnvironment.current.ksrAnalytics.trackSignupSubmitButtonClicked(isSubscribed: isSubscribed)
      }

    self.viewDidLoadProperty.signal
      .observeValues { AppEnvironment.current.ksrAnalytics.trackSignupPageViewed() }
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

  private let tappedUrlProperty = MutableProperty<(URL)?>(nil)
  public func tapped(_ url: URL) {
    self.tappedUrlProperty.value = url
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let weeklyNewsletterChangedProperty = MutableProperty<Bool?>(nil)
  public func weeklyNewsletterChanged(_ weeklyNewsletter: Bool) {
    self.weeklyNewsletterChangedProperty.value = weeklyNewsletter
  }

  public let emailTextFieldBecomeFirstResponder: Signal<(), Never>
  public let isSignupButtonEnabled: Signal<Bool, Never>
  public let logIntoEnvironment: Signal<AccessTokenEnvelope, Never>
  public let nameTextFieldBecomeFirstResponder: Signal<(), Never>
  public let notifyDelegateOpenHelpType: Signal<HelpType, Never>
  public let passwordTextFieldBecomeFirstResponder: Signal<(), Never>
  public let postNotification: Signal<Notification, Never>
  public let setWeeklyNewsletterState: Signal<Bool, Never>
  public let showError: Signal<String, Never>

  public var inputs: SignupViewModelInputs { return self }
  public var outputs: SignupViewModelOutputs { return self }
}
