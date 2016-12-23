import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol TwoFactorViewModelInputs {
  /// Call when code textfield is updated
  func codeChanged(_ code: String?)

  /// Call to set email and password
  func email(_ email: String, password: String)

  /// Call when the environment has been logged into
  func environmentLoggedIn()

  /// Call to set facebook token
  func facebookToken(_ token: String)

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
  var postNotification: Signal<Notification, NoError> { get }

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
  fileprivate struct TfaData {
    fileprivate let email: String?
    fileprivate let password: String?
    fileprivate let facebookToken: String?
    fileprivate let code: String?

    // swiftlint:disable type_name
    fileprivate enum lens {
      fileprivate static let code = Lens<TfaData, String?>(
        view: { $0.code },
        set: { TfaData(email: $1.email, password: $1.password, facebookToken: $1.facebookToken, code: $0) }
      )
    }
    // swiftlint:enable type_name
  }

  // swiftlint:disable function_body_length
  public init() {
    let isLoading = MutableProperty(false)

    let loginData = SignalProducer.combineLatest(
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
      .mapConst(Notification(name: Notification.Name(rawValue: CurrentUserNotifications.sessionStarted), object: nil))

    self.viewWillAppearProperty.signal
      .observeValues { AppEnvironment.current.koala.trackTfa() }

    self.facebookTokenProperty.signal.ignoreValues()
      .takeWhen(self.logIntoEnvironment)
      .observeValues { AppEnvironment.current.koala.trackLoginSuccess(authType: Koala.AuthType.facebook) }

    self.passwordProperty.signal.ignoreValues()
      .takeWhen(self.logIntoEnvironment)
      .observeValues { AppEnvironment.current.koala.trackLoginSuccess(authType: Koala.AuthType.email) }

    self.resendPressedProperty.signal
      .observeValues { AppEnvironment.current.koala.trackTfaResendCode() }

    self.facebookTokenProperty.signal
      .takeWhen(self.showError)
      .observeValues { _ in AppEnvironment.current.koala.trackLoginError(authType: Koala.AuthType.facebook) }

    self.emailProperty.signal
      .takeWhen(self.showError)
      .observeValues { _ in AppEnvironment.current.koala.trackLoginError(authType: Koala.AuthType.email) }
  }
  // swiftlint:enable function_body_length

  fileprivate let codeProperty = MutableProperty<String?>(nil)
  public func codeChanged(_ code: String?) {
    self.codeProperty.value = code
  }

  fileprivate let emailProperty = MutableProperty<String?>(nil)
  fileprivate let passwordProperty = MutableProperty<String?>(nil)
  public func email(_ email: String, password: String) {
    self.emailProperty.value = email
    self.passwordProperty.value = password
  }

  fileprivate let environmentLoggedInProperty = MutableProperty(())
  public func environmentLoggedIn() {
    self.environmentLoggedInProperty.value = ()
  }

  fileprivate let facebookTokenProperty = MutableProperty<String?>(nil)
  public func facebookToken(_ token: String) {
    self.facebookTokenProperty.value = token
  }

  fileprivate let resendPressedProperty = MutableProperty(())
  public func resendPressed() {
    self.resendPressedProperty.value = ()
  }

  fileprivate let submitPressedProperty = MutableProperty(())
  public func submitPressed() {
    self.submitPressedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let viewWillAppearProperty = MutableProperty()
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  public let codeTextFieldBecomeFirstResponder: Signal<(), NoError>
  public let isFormValid: Signal<Bool, NoError>
  public let isLoading: Signal<Bool, NoError>
  public let logIntoEnvironment: Signal<AccessTokenEnvelope, NoError>
  public let postNotification: Signal<Notification, NoError>
  public let resendSuccess: Signal<(), NoError>
  public let showError: Signal<String, NoError>

  public var inputs: TwoFactorViewModelInputs { return self }
  public var outputs: TwoFactorViewModelOutputs { return self }
}

private func login(_ tfaData: TwoFactorViewModel.TfaData,
                   apiService: ServiceType,
                   isLoading: MutableProperty<Bool>) -> SignalProducer<AccessTokenEnvelope, ErrorEnvelope> {

  let login: SignalProducer<AccessTokenEnvelope, ErrorEnvelope>

  if let email = tfaData.email, let password = tfaData.password {
    login = apiService.login(email: email, password: password, code: tfaData.code)
  } else if let facebookToken = tfaData.facebookToken {
    login = apiService.login(facebookAccessToken: facebookToken, code: tfaData.code)
  } else {
    login = .empty
  }

  return login
    .on(starting: { isLoading.value = true },
      terminated: { isLoading.value = false })
}
