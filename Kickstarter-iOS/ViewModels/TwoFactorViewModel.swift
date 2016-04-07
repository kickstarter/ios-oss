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
  /// Emits a message when the code submitted is not correct or login fails
  var showError: Signal<String, NoError> { get }
}

internal protocol TwoFactorViewModelType {
  var inputs: TwoFactorViewModelInputs { get }
  var outputs: TwoFactorViewModelOutputs { get }
  var errors: TwoFactorViewModelErrors { get }
}

internal final class TwoFactorViewModel: TwoFactorViewModelType, TwoFactorViewModelInputs,
  TwoFactorViewModelOutputs, TwoFactorViewModelErrors {

  // A simple type to hold all the data needed to login.
  private struct TfaData {
    private let email: String?
    private let password: String?
    private let facebookToken: String?
    private let code: String?
  }

  // MARK: TwoFactorViewModelType

  internal var inputs: TwoFactorViewModelInputs { return self }
  internal var outputs: TwoFactorViewModelOutputs { return self }
  internal var errors: TwoFactorViewModelErrors { return self }

  // MARK: TwoFactorViewModelInputs

  private let viewWillAppearProperty = MutableProperty(())
  internal func viewWillAppear() {
    viewWillAppearProperty.value = ()
  }

  private let emailProperty = MutableProperty<String?>(nil)
  private let passwordProperty = MutableProperty<String?>(nil)
  internal func email(email: String, password: String) {
    self.emailProperty.value = email
    self.passwordProperty.value = password
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

  internal let showError: Signal<String, NoError>

  internal init() {
    let (isLoadingSignal, isLoadingObserver) = Signal<Bool, NoError>.pipe()
    let (showErrorSignal, showErrorObserver) = Signal<ErrorEnvelope, NoError>.pipe()

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

    self.logIntoEnvironment = loginData
      .takeWhen(self.submitPressedProperty.signal)
      .switchMap { data in
        login(data, apiService: AppEnvironment.current.apiService, isLoading: isLoadingObserver)
          .demoteErrors(pipeErrorsTo: showErrorObserver)
      }

    self.resendSuccess = resendData
      .takeWhen(self.resendPressedProperty.signal)
      .switchMap { data in
        login(data, apiService: AppEnvironment.current.apiService, isLoading: isLoadingObserver)
          .materialize()
          .map { event in event.error }
          .ignoreNil()
          .filter { error in error.ksrCode == .TfaRequired }
          .ignoreValues()
    }

    self.isLoading = isLoadingSignal

    self.isFormValid = Signal.merge([
      codeProperty.signal.map { code in code?.characters.count == 6 },
      viewWillAppearProperty.signal.mapConst(false)
      ])
      .skipRepeats()

    let codeMismatch = showErrorSignal
      .filter { $0.ksrCode == .TfaFailed }
      .map { $0.errorMessages.first ??
        localizedString(key: "two_factor.error.message", defaultValue: "The code provided does not match.")
    }

    let genericFail = showErrorSignal
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

    showErrorSignal
      .observeNext { _ in AppEnvironment.current.koala.trackLoginError() }
  }
}

private func login(tfaData: TwoFactorViewModel.TfaData,
                   apiService: ServiceType,
                   isLoading: Observer<Bool, NoError>) -> SignalProducer<AccessTokenEnvelope, ErrorEnvelope> {

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
      started: { isLoading.sendNext(true) },
      terminated: { isLoading.sendNext(false) }
  )
}
