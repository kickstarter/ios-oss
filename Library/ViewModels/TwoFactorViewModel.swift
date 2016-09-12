import KsApi
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol TwoFactorViewModelInputs {
  /// Call when code textfield is updated
  func codeChanged(code: String?)

  /// Call to set email and password
  func email(email: String, password: String)

  /// Call when the environment has been logged into
  func environmentLoggedIn()

  /// Call to set facebook token
  func facebookToken(token: String)

  /// Call when resend button pressed
  func resendPressed()

  /// Call when submit button pressed
  func submitPressed()

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when view will appear
  func viewWillAppear()
}

public protocol TwoFactorViewModelOutputs {
  /// Emits when the code text field is the first responder.
  var codeTextFieldBecomeFirstResponder: Signal<(), NoError> { get }

  /// Emits whether the form is valid or not
  var isFormValid: Signal<Bool, NoError> { get }

  /// Emits whether a request is loading or not
  var isLoading: Signal<Bool, NoError> { get }

  /// Emits an access token envelope that can be used to update the environment.
  var logIntoEnvironment: Signal<AccessTokenEnvelope, NoError> { get }

  /// Emits when a login success notification should be posted.
  var postNotification: Signal<NSNotification, NoError> { get }

  /// Emits when code was resent successfully
  var resendSuccess: Signal<(), NoError> { get }

  /// Emits a message when the code submitted is not correct or login fails
  var showError: Signal<String, NoError> { get }
}

public protocol TwoFactorViewModelType {
  var inputs: TwoFactorViewModelInputs { get }
  var outputs: TwoFactorViewModelOutputs { get }
}

public final class TwoFactorViewModel: TwoFactorViewModelType, TwoFactorViewModelInputs,
  TwoFactorViewModelOutputs {

  // A simple type to hold all the data needed to login.
  private struct TfaData {
    private let email: String?
    private let password: String?
    private let facebookToken: String?
    private let code: String?

    // swiftlint:disable type_name
    private enum lens {
      private static let code = Lens<TfaData, String?>(
        view: { $0.code },
        set: { TfaData(email: $1.email, password: $1.password, facebookToken: $1.facebookToken, code: $0) }
      )
    }
    // swiftlint:enable type_name
  }

  // swiftlint:disable function_body_length
  public init() {
    let isLoading = MutableProperty(false)

    let loginData = combineLatest(
      self.emailProperty.producer,
      self.passwordProperty.producer,
      self.facebookTokenProperty.producer,
      self.codeProperty.producer
      )
      .map(TfaData.init)

    let resendData = loginData.map(TfaData.lens.code .~ nil)

    let loginEvent = loginData
      .takeWhen(self.submitPressedProperty.signal)
      .switchMap { data in
        login(data, apiService: AppEnvironment.current.apiService, isLoading: isLoading)
          .materialize()
    }

    self.codeTextFieldBecomeFirstResponder = self.viewDidLoadProperty.signal

    self.logIntoEnvironment = loginEvent.values()

    self.resendSuccess = resendData
      .takeWhen(self.resendPressedProperty.signal)
      .switchMap { data in
        login(data, apiService: AppEnvironment.current.apiService, isLoading: isLoading)
          .materialize()
          .errors()
          .filter { error in error.ksrCode == .TfaRequired }
          .ignoreValues()
      }

    self.isLoading = isLoading.signal

    self.isFormValid = Signal.merge([
      codeProperty.signal.map { code in code?.characters.count == 6 },
      viewWillAppearProperty.signal.mapConst(false)
      ])
      .skipRepeats()

    let codeMismatch = loginEvent.errors()
      .filter { $0.ksrCode == .TfaFailed }
      .map { $0.errorMessages.first ?? Strings.two_factor_error_message() }

    let genericFail = loginEvent.errors()
      .filter { $0.ksrCode != .TfaFailed }
      .map { $0.errorMessages.first ?? Strings.login_errors_unable_to_log_in() }

    self.showError = Signal.merge([codeMismatch, genericFail])

    self.postNotification = self.environmentLoggedInProperty.signal
      .mapConst(NSNotification(name: CurrentUserNotifications.sessionStarted, object: nil))

    self.viewWillAppearProperty.signal
      .observeNext { AppEnvironment.current.koala.trackTfa() }

    self.facebookTokenProperty.signal.ignoreValues()
      .takeWhen(self.logIntoEnvironment)
      .observeNext { AppEnvironment.current.koala.trackFacebookLoginSuccess() }

    self.passwordProperty.signal.ignoreValues()
      .takeWhen(self.logIntoEnvironment)
      .observeNext { AppEnvironment.current.koala.trackLoginSuccess() }

    self.resendPressedProperty.signal
      .observeNext { AppEnvironment.current.koala.trackTfaResendCode() }

    loginEvent.errors()
      .observeNext { _ in AppEnvironment.current.koala.trackLoginError() }
  }
  // swiftlint:enable function_body_length

  private let codeProperty = MutableProperty<String?>(nil)
  public func codeChanged(code: String?) {
    self.codeProperty.value = code
  }

  private let emailProperty = MutableProperty<String?>(nil)
  private let passwordProperty = MutableProperty<String?>(nil)
  public func email(email: String, password: String) {
    self.emailProperty.value = email
    self.passwordProperty.value = password
  }

  private let environmentLoggedInProperty = MutableProperty(())
  public func environmentLoggedIn() {
    self.environmentLoggedInProperty.value = ()
  }

  private let facebookTokenProperty = MutableProperty<String?>(nil)
  public func facebookToken(token: String) {
    self.facebookTokenProperty.value = token
  }

  private let resendPressedProperty = MutableProperty(())
  public func resendPressed() {
    self.resendPressedProperty.value = ()
  }

  private let submitPressedProperty = MutableProperty(())
  public func submitPressed() {
    self.submitPressedProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let viewWillAppearProperty = MutableProperty()
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  public let codeTextFieldBecomeFirstResponder: Signal<(), NoError>
  public let isFormValid: Signal<Bool, NoError>
  public let isLoading: Signal<Bool, NoError>
  public let logIntoEnvironment: Signal<AccessTokenEnvelope, NoError>
  public let postNotification: Signal<NSNotification, NoError>
  public let resendSuccess: Signal<(), NoError>
  public let showError: Signal<String, NoError>

  public var inputs: TwoFactorViewModelInputs { return self }
  public var outputs: TwoFactorViewModelOutputs { return self }
}

private func login(tfaData: TwoFactorViewModel.TfaData,
                   apiService: ServiceType,
                   isLoading: MutableProperty<Bool>) -> SignalProducer<AccessTokenEnvelope, ErrorEnvelope> {

  let login: SignalProducer<AccessTokenEnvelope, ErrorEnvelope>

  if let email = tfaData.email, password = tfaData.password {
    login = apiService.login(email: email, password: password, code: tfaData.code)
  } else if let facebookToken = tfaData.facebookToken {
    login = apiService.login(facebookAccessToken: facebookToken, code: tfaData.code)
  } else {
    login = .empty
  }

  return login
    .on(started: { isLoading.value = true },
      terminated: { isLoading.value = false })
}
