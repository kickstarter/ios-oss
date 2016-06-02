import ReactiveCocoa
import ReactiveExtensions
import Result
import KsApi

public protocol TwoFactorViewModelInputs {
  /// Call when view will appear
  func viewWillAppear()

  /// Call to set email and password
  func email(email: String, password: String)

  /// Call to set facebook token
  func facebookToken(token: String)

  /// Call when code textfield is updated
  func codeChanged(code: String?)

  /// Call when resend button pressed
  func resendPressed()

  /// Call when submit button pressed
  func submitPressed()

  /// Call when the environment has been logged into
  func environmentLoggedIn()
}

public protocol TwoFactorViewModelOutputs {
  /// Emits whether the form is valid or not
  var isFormValid: Signal<Bool, NoError> { get }

  /// Emits whether a request is loading or not
  var isLoading: Signal<Bool, NoError> { get }

  /// Emits when code was resent successfully
  var resendSuccess: Signal<(), NoError> { get }

  /// Emits when a login success notification should be posted.
  var postNotification: Signal<NSNotification, NoError> { get }

  /// Emits an access token envelope that can be used to update the environment.
  var logIntoEnvironment: Signal<AccessTokenEnvelope, NoError> { get }
}

public protocol TwoFactorViewModelErrors {
  /// Emits a message when the code submitted is not correct or login fails
  var showError: Signal<String, NoError> { get }
}

public protocol TwoFactorViewModelType {
  var inputs: TwoFactorViewModelInputs { get }
  var outputs: TwoFactorViewModelOutputs { get }
  var errors: TwoFactorViewModelErrors { get }
}

public final class TwoFactorViewModel: TwoFactorViewModelType, TwoFactorViewModelInputs,
  TwoFactorViewModelOutputs, TwoFactorViewModelErrors {

  // A simple type to hold all the data needed to login.
  private struct TfaData {
    private let email: String?
    private let password: String?
    private let facebookToken: String?
    private let code: String?
  }

  // MARK: TwoFactorViewModelType

  public var inputs: TwoFactorViewModelInputs { return self }
  public var outputs: TwoFactorViewModelOutputs { return self }
  public var errors: TwoFactorViewModelErrors { return self }

  // MARK: TwoFactorViewModelInputs

  private let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    viewWillAppearProperty.value = ()
  }

  private let emailProperty = MutableProperty<String?>(nil)
  private let passwordProperty = MutableProperty<String?>(nil)
  public func email(email: String, password: String) {
    self.emailProperty.value = email
    self.passwordProperty.value = password
  }

  private let facebookTokenProperty = MutableProperty<String?>(nil)
  public func facebookToken(token: String) {
    self.facebookTokenProperty.value = token
  }

  private let codeProperty = MutableProperty<String?>(nil)
  public func codeChanged(code: String?) {
    self.codeProperty.value = code
  }

  private let resendPressedProperty = MutableProperty(())
  public func resendPressed() {
    self.resendPressedProperty.value = ()
  }

  private let submitPressedProperty = MutableProperty(())
  public func submitPressed() {
    self.submitPressedProperty.value = ()
  }

  private let environmentLoggedInProperty = MutableProperty(())
  public func environmentLoggedIn() {
    self.environmentLoggedInProperty.value = ()
  }

  // MARK: TwoFactorViewModelOutputs

  public let isFormValid: Signal<Bool, NoError>
  public let isLoading: Signal<Bool, NoError>
  public let resendSuccess: Signal<(), NoError>
  public let postNotification: Signal<NSNotification, NoError>
  public let logIntoEnvironment: Signal<AccessTokenEnvelope, NoError>

  // MARK: TwoFactorViewModelErrors

  public let showError: Signal<String, NoError>

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

    let resendData = combineLatest(
      self.emailProperty.producer,
      self.passwordProperty.producer,
      self.facebookTokenProperty.producer,
      SignalProducer(value: nil)
      )
      .map(TfaData.init)

    let loginEvent = loginData
      .takeWhen(self.submitPressedProperty.signal)
      .switchMap { data in
        login(data, apiService: AppEnvironment.current.apiService, isLoading: isLoading)
          .materialize()
    }

    self.logIntoEnvironment = loginEvent.values()

    self.resendSuccess = resendData
      .takeWhen(self.resendPressedProperty.signal)
      .switchMap { data in
        login(data, apiService: AppEnvironment.current.apiService, isLoading: isLoading)
          .materialize()
          .map { event in event.error }
          .ignoreNil()
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
      .map { $0.errorMessages.first ??
        localizedString(key: "two_factor.error.message", defaultValue: "The code provided does not match.")
    }

    let genericFail = loginEvent.errors()
      .filter { $0.ksrCode != .TfaFailed }
      .map { $0.errorMessages.first ??
        localizedString(key: "login.errors.unable_to_log_in", defaultValue: "Unable to log in.")
    }

    self.showError = Signal.merge([codeMismatch, genericFail])

    self.postNotification = self.environmentLoggedInProperty.signal
      .mapConst(NSNotification(name: CurrentUserNotifications.sessionStarted, object: nil))

    self.viewWillAppearProperty.signal
      .observeNext { AppEnvironment.current.koala.trackTfa() }

    self.logIntoEnvironment
      .observeNext { _ in AppEnvironment.current.koala.trackLoginSuccess() }

    self.resendPressedProperty.signal
      .observeNext { AppEnvironment.current.koala.trackTfaResendCode() }

    loginEvent.errors()
      .observeNext { _ in AppEnvironment.current.koala.trackLoginError() }
  }
  // swiftlint:enable function_body_length
}

private func login(tfaData: TwoFactorViewModel.TfaData,
                   apiService: ServiceType,
                   isLoading: MutableProperty<Bool>) -> SignalProducer<AccessTokenEnvelope, ErrorEnvelope> {

  let emailLogin: SignalProducer<AccessTokenEnvelope, ErrorEnvelope>
  let facebookLogin: SignalProducer<AccessTokenEnvelope, ErrorEnvelope>

  if let email = tfaData.email, password = tfaData.password {
    emailLogin = apiService.login(email: email, password: password, code: tfaData.code)
    facebookLogin = .empty
  } else if let facebookToken = tfaData.facebookToken {
    emailLogin = .empty
    facebookLogin = apiService.login(facebookAccessToken: facebookToken, code: tfaData.code)
  } else {
    emailLogin = .empty
    facebookLogin = .empty
  }

  return emailLogin.mergeWith(facebookLogin)
    .on(
      started: {
        isLoading.value = true
      },
      terminated: {
        isLoading.value = false
    })
}
