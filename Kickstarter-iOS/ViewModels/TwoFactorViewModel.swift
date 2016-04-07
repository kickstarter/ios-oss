import ReactiveCocoa
import ReactiveExtensions
import Result
import KsApi
import Library

internal protocol TwoFactorViewModelInputs {
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

internal protocol TwoFactorViewModelOutputs {
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

internal protocol TwoFactorViewModelErrors {
  /// Emits a message when the code is not correct
  var codeMismatch: Signal<String, NoError> { get }

  /// Emits a message when a request fails
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

  private let viewWillAppearProperty = MutableProperty(())
  internal func viewWillAppear() {
    viewWillAppearProperty.value = ()
  }

  private let (emailAndPasswordSignal, emailAndPasswordObserver) = Signal<(email: String, password: String), NoError>.pipe()
  internal func email(email: String, password: String) {
    emailAndPasswordObserver.sendNext((email, password))
  }

  private let facebookTokenProperty = MutableProperty<String?>(nil)
  internal func facebookToken(token: String) {
    self.facebookTokenProperty.value = token
  }

  private let codeProperty = MutableProperty<String?>(nil)
  internal func codeChanged(code: String?) {
    self.codeProperty.value = code
  }

  private let resendPressedProperty = MutableProperty(())
  internal func resendPressed() {
    self.resendPressedProperty.value = ()
  }

  private let submitPressedProperty = MutableProperty(())
  internal func submitPressed() {
    self.submitPressedProperty.value = ()
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
      .mergeWith(facebookTokenProperty.signal.ignoreValues())

    let (isLoadingSignal, isLoadingObserver) = Signal<Bool, NoError>.pipe()

    let (tfaErrorSignal, tfaErrorObserver) = Signal<ErrorEnvelope, NoError>.pipe()

    let emailPasswordLogin = emailAndPasswordSignal
      .combineLatestWith(codeProperty.signal)
      .filter { _, code in code != nil }
      .takeWhen(submitPressedProperty.signal)
      .switchMap { ep, code in
        login(email: ep.email,
          password: ep.password,
          code: code,
          apiService: AppEnvironment.current.apiService,
          loading: isLoadingObserver)
          .demoteErrors(pipeErrorsTo: tfaErrorObserver)
      }

    let facebookLogin = facebookTokenProperty.signal
      .combineLatestWith(codeProperty.signal)
      .filter { _, code in code != nil
      }
      .takeWhen(submitPressedProperty.signal)
      .switchMap { token, code in
        login(facebookAccessToken: token,
          code: code,
          apiService: AppEnvironment.current.apiService,
          loading: isLoadingObserver)
          .demoteErrors(pipeErrorsTo: tfaErrorObserver)
      }

    let emailPasswordResend = emailAndPasswordSignal
      .takeWhen(resendPressedProperty.signal)
      .switchMap { email, password in
        login(email: email,
          password: password,
          apiService: AppEnvironment.current.apiService,
          loading: isLoadingObserver)
          .materialize()
          .filter { isResendSuccessful($0.error) }
    }

    let facebookResend = facebookTokenProperty.signal
      .takeWhen(resendPressedProperty.signal)
      .switchMap { token in
        login(facebookAccessToken: token,
          apiService: AppEnvironment.current.apiService,
          loading: isLoadingObserver)
          .materialize()
          .filter { isResendSuccessful($0.error) }
    }

    self.resendSuccess = Signal.merge([emailPasswordResend, facebookResend]).ignoreValues()

    self.isLoading = isLoadingSignal

    self.isFormValid = combineLatest(hasInput.take(1), codeProperty.signal.ignoreNil())
      .map { _, code in code.characters.count == 6 }
      .mergeWith(viewWillAppearProperty.signal.mapConst(false))
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

    self.viewWillAppearProperty.signal
      .observeNext { AppEnvironment.current.koala.trackTfa()
    }

    self.logIntoEnvironment
      .observeNext { _ in AppEnvironment.current.koala.trackLoginSuccess()
    }

    self.resendPressedProperty.signal
      .observeNext { AppEnvironment.current.koala.trackTfaResendCode()
    }

    self.genericFail.observeNext { _ in AppEnvironment.current.koala.trackLoginError()
    }
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

private func isResendSuccessful(error:ErrorEnvelope?) -> Bool {
  guard let error = error else { return false }
  return error.ksrCode == .TfaRequired
}
