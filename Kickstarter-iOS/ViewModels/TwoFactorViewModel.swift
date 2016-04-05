import ReactiveCocoa
import ReactiveExtensions
import Result
import KsApi
import Library

internal protocol TwoFactorViewModelInputs {
  func viewWillAppear()
  func email(email: String, password: String)
  func facebookToken(token: String)
  func codeChanged(code: String?)
  func resendPressed()
  func submitPressed()

  /// Call when the environment has been logged into
  func environmentLoggedIn()
}

internal protocol TwoFactorViewModelOutputs {
  var isFormValid: Signal<Bool, NoError> { get }
  var isLoading: Signal<Bool, NoError> { get }
  var resendSuccess: Signal<(), NoError> { get }

  /// Emits when a login success notification should be posted.
  var postNotification: Signal<NSNotification, NoError> { get }

  /// Emits an access token envelope that can be used to update the environment.
  var logIntoEnvironment: Signal<AccessTokenEnvelope, NoError> { get }
}

internal protocol TwoFactorViewModelErrors {
  var codeMismatch: Signal<String, NoError> { get }
  var genericFail: Signal<String, NoError> { get }
}

internal protocol TwoFactorViewModelType {
  var inputs: TwoFactorViewModelInputs { get }
  var outputs: TwoFactorViewModelOutputs { get }
  var errors: TwoFactorViewModelErrors { get }
}

internal final class TwoFactorViewModel: TwoFactorViewModelType, TwoFactorViewModelInputs,
  TwoFactorViewModelOutputs, TwoFactorViewModelErrors {

  // MARK: TwoFactorViewModelType

  internal var inputs: TwoFactorViewModelInputs { return self }
  internal var outputs: TwoFactorViewModelOutputs { return self }
  internal var errors: TwoFactorViewModelErrors { return self }

  // MARK: TwoFactorViewModelInputs

  private let (viewWillAppearSignal, viewWillAppearObserver) = Signal<(), NoError>.pipe()
  internal func viewWillAppear() {
    viewWillAppearObserver.sendNext()
  }

  private let (emailAndPasswordSignal, emailAndPasswordObserver) = Signal<(email: String, password: String), NoError>.pipe()
  internal func email(email: String, password: String) {
    emailAndPasswordObserver.sendNext((email, password))
  }

  private let (facebookTokenSignal, facebookTokenObserver) = Signal<String, NoError>.pipe()
  internal func facebookToken(token: String) {
    facebookTokenObserver.sendNext(token)
  }

  private let code = MutableProperty<String?>(nil)
  internal func codeChanged(code: String?) {
    self.code.value = code
  }

  private let (resendPressedSignal, resendPressedObserver) = Signal<(), NoError>.pipe()
  internal func resendPressed() {
    resendPressedObserver.sendNext()
  }

  private let (submitPressedSignal, submitPressedObserver) = Signal<(), NoError>.pipe()
  internal func submitPressed() {
    submitPressedObserver.sendNext()
  }

  private let environmentLoggedInProperty = MutableProperty(())
  internal func environmentLoggedIn() {
    self.environmentLoggedInProperty.value = ()
  }

  // MARK: TwoFactorViewModelOutputs

  internal let isFormValid: Signal<Bool, NoError>
  internal let isLoading: Signal<Bool, NoError>
  internal let resendSuccess: Signal<(), NoError>
  internal let postNotification: Signal<NSNotification, NoError>
  internal let logIntoEnvironment: Signal<AccessTokenEnvelope, NoError>

  // MARK: TwoFactorViewModelErrors

  internal let codeMismatch: Signal<String, NoError>
  internal let genericFail: Signal<String, NoError>

  internal init() {

    let hasInput = emailAndPasswordSignal.ignoreValues()
      .mergeWith(facebookTokenSignal.ignoreValues())

    let (isLoadingSignal, isLoadingObserver) = Signal<Bool, NoError>.pipe()

    let (tfaErrorSignal, tfaErrorObserver) = Signal<ErrorEnvelope, NoError>.pipe()

    let emailPasswordLogin = emailAndPasswordSignal
      .combineLatestWith(code.signal)
      .filter { _, code in code != nil }
      .takeWhen(submitPressedSignal)
      .switchMap { ep, code in
        login(email: ep.email,
          password: ep.password,
          code: code,
          apiService: AppEnvironment.current.apiService,
          loading: isLoadingObserver)
          .demoteErrors(pipeErrorsTo: tfaErrorObserver)
      }

    let facebookLogin = facebookTokenSignal
      .combineLatestWith(code.signal)
      .filter { _, code in code != nil }
      .takeWhen(submitPressedSignal)
      .switchMap { token, code in
        login(facebookAccessToken: token,
          code: code,
          apiService: AppEnvironment.current.apiService,
          loading: isLoadingObserver)
          .demoteErrors(pipeErrorsTo: tfaErrorObserver)
      }

    let emailPasswordResend = emailAndPasswordSignal
      .takeWhen(resendPressedSignal)
      .switchMap { email, password in
        login(email: email,
          password: password,
          apiService: AppEnvironment.current.apiService,
          loading: isLoadingObserver)
          .materialize()
          .filter { $0.error != nil }
    }

    let facebookResend = facebookTokenSignal
      .takeWhen(resendPressedSignal)
      .switchMap { token in
        login(facebookAccessToken: token,
          apiService: AppEnvironment.current.apiService,
          loading: isLoadingObserver)
          .materialize()
          .filter { $0.error != nil }
    }

    self.resendSuccess = Signal.merge([emailPasswordResend, facebookResend]).ignoreValues()

    self.isLoading = isLoadingSignal

    self.isFormValid = combineLatest(hasInput.take(1), code.signal.ignoreNil())
      .map { _, code in code.characters.count == 6 }
      .mergeWith(viewWillAppearSignal.mapConst(false))
      .skipRepeats()

    self.codeMismatch = tfaErrorSignal
      .filter { $0.ksrCode == .TfaFailed }
      .map { $0.errorMessages.first ??
        localizedString(key: "two_factor.error.message", defaultValue: "The code provided does not match.")
      }

    self.genericFail = tfaErrorSignal
      .filter { $0.ksrCode != .TfaFailed }
      .map { $0.errorMessages.first ??
        localizedString(key: "login.errors.unable_to_log_in", defaultValue: "Unable to log in.")
    }

    self.logIntoEnvironment = Signal.merge([emailPasswordLogin, facebookLogin])

    self.postNotification = self.environmentLoggedInProperty.signal
      .mapConst(NSNotification(name: CurrentUserNotifications.sessionStarted, object: nil))

    self.viewWillAppearSignal
      .observeNext { AppEnvironment.current.koala.trackTfa() }

    self.logIntoEnvironment
      .observeNext { _ in AppEnvironment.current.koala.trackLoginSuccess() }

    self.resendPressedSignal
      .observeNext { AppEnvironment.current.koala.trackTfaResendCode() }
  }
}

private func login(email email: String? = nil,
                         password: String? = nil,
                         facebookAccessToken: String? = nil,
                         code: String? = nil,
                         apiService: ServiceType,
                         loading: Observer<Bool, NoError>) -> SignalProducer<AccessTokenEnvelope, ErrorEnvelope> {


  let emailPasswordLogin: SignalProducer<AccessTokenEnvelope, ErrorEnvelope>
  let facebookLogin: SignalProducer<AccessTokenEnvelope, ErrorEnvelope>

  if let email = email, password = password {
    emailPasswordLogin = apiService.login(email: email, password: password, code: code)
    facebookLogin = .empty
  } else if let facebookAccessToken = facebookAccessToken {
    emailPasswordLogin = .empty
    facebookLogin = apiService.login(facebookAccessToken: facebookAccessToken, code: code)
  } else {
    emailPasswordLogin = .empty
    facebookLogin = .empty
  }

  return emailPasswordLogin.mergeWith(facebookLogin)
    .on(
      started: { loading.sendNext(true) },
      terminated: { loading.sendNext(false) }
  )
}
