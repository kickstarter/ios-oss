import ReactiveCocoa
import ReactiveExtensions
import Result
import KsApi
import Library

internal protocol TwoFactorViewModelInputs {
  func viewWillAppear()
  func email(email: String, andPassword password: String)
  func facebookToken(token: String)
  func code(code: String)
  func resendPressed()
  func submitPressed()
}

internal protocol TwoFactorViewModelOutputs {
  var isFormValid: Signal<Bool, NoError> { get }
  var isLoading: Signal<Bool, NoError> { get }
  var loginSuccess: Signal<(), NoError> { get }
}

internal protocol TwoFactorViewModelErrors {
  var codeMismatch: Signal<(), NoError> { get }
  var generic: Signal<(), NoError> { get }
}

internal protocol TwoFactorViewModelType {
  var inputs: TwoFactorViewModelInputs { get }
  var outputs: TwoFactorViewModelOutputs { get }
  var errors: TwoFactorViewModelErrors { get }
}

internal final class TwoFactorViewModel: TwoFactorViewModelType, TwoFactorViewModelInputs,
  TwoFactorViewModelOutputs, TwoFactorViewModelErrors {

  private let (viewWillAppearSignal, viewWillAppearObserver) = Signal<(), NoError>.pipe()
  func viewWillAppear() {
    viewWillAppearObserver.sendNext()
  }

  private let (emailAndPasswordSignal, emailAndPasswordObserver) = Signal<(email: String, password: String), NoError>.pipe()
  func email(email: String, andPassword password: String) {
    emailAndPasswordObserver.sendNext((email, password))
  }

  private let (facebookTokenSignal, facebookTokenObserver) = Signal<String, NoError>.pipe()
  func facebookToken(token: String) {
    facebookTokenObserver.sendNext(token)
  }

  private let (codeSignal, codeObserver) = Signal<String, NoError>.pipe()
  func code(code: String) {
    codeObserver.sendNext(code)
  }

  private let (resendPressedSignal, resendPressedObserver) = Signal<(), NoError>.pipe()
  func resendPressed() {
    resendPressedObserver.sendNext()
  }

  private let (submitPressedSignal, submitPressedObserver) = Signal<(), NoError>.pipe()
  func submitPressed() {
    submitPressedObserver.sendNext()
  }

  let isFormValid: Signal<Bool, NoError>
  let isLoading: Signal<Bool, NoError>
  let loginSuccess: Signal<(), NoError>

  var codeMismatch: Signal<(), NoError>
  var generic: Signal<(), NoError>

  var inputs: TwoFactorViewModelInputs { return self }
  var outputs: TwoFactorViewModelOutputs { return self }
  var errors: TwoFactorViewModelErrors { return self }

  internal init(env: Environment = AppEnvironment.current) {
    let apiService = env.apiService
    let koala = env.koala

    let hasInput = emailAndPasswordSignal.ignoreValues()
      .mergeWith(facebookTokenSignal.ignoreValues())

    let (loginSuccessSignal, loginSuccessObserver) = Signal<(), NoError>.pipe()
    loginSuccess = loginSuccessSignal

    let (isLoadingSignal, isLoadingObserver) = Signal<Bool, NoError>.pipe()
    isLoading = isLoadingSignal

    codeMismatch = .empty
    generic = .empty

    resendPressedSignal
      .mergeWith(submitPressedSignal)
      .observeNext { isLoadingObserver.sendNext(true) }

    isFormValid = combineLatest(hasInput, codeSignal)
      .map { _, code in code.characters.count == 6 }
      .mergeWith(viewWillAppearSignal.mapConst(false))
      .skipRepeats()

    emailAndPasswordSignal
      .combineLatestWith(codeSignal)
      .takeWhen(submitPressedSignal)
      .switchMap { ep, code in apiService.login(email: ep.email,
        password: ep.password, code: code).demoteErrors() }
      .ignoreValues()
      .observeNext { _ in
        loginSuccessObserver.sendNext()
        isLoadingObserver.sendNext(false)
    }

    facebookTokenSignal
      .combineLatestWith(codeSignal)
      .takeWhen(submitPressedSignal)
      .switchMap { token, code in apiService.login(facebookAccessToken: token, code: code).demoteErrors() }
      .ignoreValues()
      .observeNext { _ in
        loginSuccessObserver.sendNext()
        isLoadingObserver.sendNext(false)
    }

    emailAndPasswordSignal
      .takeWhen(resendPressedSignal)
      .observeNext { email, password in
        apiService.login(email: email, password: password, code: nil)
        isLoadingObserver.sendNext(false)
        koala.trackTwoFactorResendCode()
    }

    facebookTokenSignal
      .takeWhen(resendPressedSignal)
      .observeNext { token in
        apiService.login(facebookAccessToken: token, code: nil)
        isLoadingObserver.sendNext(false)
        koala.trackTwoFactorResendCode()
    }

    viewWillAppearSignal.observeNext { _ in koala.trackTfa() }
    loginSuccess.observeNext { _ in koala.trackLoginSuccess() }
  }
}
