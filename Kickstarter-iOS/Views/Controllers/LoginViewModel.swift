import ReactiveExtensions
import KsApi
import class ReactiveCocoa.Signal
import class ReactiveCocoa.MutableProperty
import func ReactiveCocoa.<~
import struct Library.Environment
import struct Library.AppEnvironment
import enum Result.NoError

internal protocol LoginViewModelInputs {
  var email: MutableProperty<String?> { get }
  var password: MutableProperty<String?> { get }
  func loginButtonPressed()
}

internal protocol LoginViewModelOutputs {
  var isFormValid: MutableProperty<Bool> { get }
  var logInSuccess: Signal<(), NoError> { get }
}

internal protocol LoginViewModelErrors {
  var invalidLogin: Signal<String, NoError> { get }
  var genericError: Signal<(), NoError> { get }
  var tfaChallenge: Signal<(), NoError> { get }
}

internal protocol LoginViewModelType {
  var inputs: LoginViewModelInputs { get }
  var outputs: LoginViewModelOutputs { get }
  var errors: LoginViewModelErrors { get }
}

internal final class LoginViewModel: LoginViewModelType, LoginViewModelInputs, LoginViewModelOutputs, LoginViewModelErrors {

  // MARK: LoginViewModelType
  internal var inputs: LoginViewModelInputs { return self }
  internal var outputs: LoginViewModelOutputs { return self }
  internal var errors: LoginViewModelErrors { return self }

  // MARK: Inputs
  internal let email = MutableProperty<String?>(nil)
  internal let password = MutableProperty<String?>(nil)
  private var (loginButtonPressedSignal, loginButtonPressedObserver) = Signal<(), NoError>.pipe()
  internal func loginButtonPressed() {
    loginButtonPressedObserver.sendNext(())
  }

  // MARK: Outputs
  internal let isFormValid = MutableProperty(false)
  internal let logInSuccess: Signal<(), NoError>

  // MARK: Errors
  internal let invalidLogin: Signal<String, NoError>
  internal let genericError: Signal<(), NoError>
  internal let tfaChallenge: Signal<(), NoError>

  internal init(env: Environment = AppEnvironment.current) {
    let apiService = env.apiService
    let currentUser = env.currentUser
    let koala = env.koala

    let (loggedInSignal, loggedInObserver) = Signal<(), NoError>.pipe()
    logInSuccess = loggedInSignal

    let (loginErrors, loginErrorsObserver) = Signal<ErrorEnvelope, NoError>.pipe()

    invalidLogin = loginErrors
      .filter { $0.ksrCode == .InvalidXauthLogin }
      .map { $0.errorMessages.first }
      .ignoreNil()

    tfaChallenge = loginErrors
      .filter { $0.ksrCode == .TfaRequired }
      .ignoreValues()

    genericError = loginErrors
      .filter { $0.ksrCode != .InvalidXauthLogin && $0.ksrCode != .TfaRequired }
      .ignoreValues()

    let emailAndPassword = email.producer.ignoreNil()
      .combineLatestWith(password.producer.ignoreNil())
      .map { ep in (email: ep.0, password: ep.1) }

    isFormValid <~ emailAndPassword.map(isValid)

    emailAndPassword.takeWhen(loginButtonPressedSignal)
      .flatMap { ep in apiService.login(ep).demoteErrors(loginErrorsObserver) }
      .start { event in
        switch event {
        case let .Next(envelope):
          currentUser.login(envelope.user, accessToken: envelope.accessToken)
          koala.trackLoginSuccess()
          loggedInObserver.sendNext(())
        default:
          print("")
        }
    }

    loginErrors.observeNext { _ in koala.trackLoginError() }
  }

  private func isValid(email: String, password: String) -> Bool {
    return email.characters.count > 5 && password.characters.count >= 6
  }
}
