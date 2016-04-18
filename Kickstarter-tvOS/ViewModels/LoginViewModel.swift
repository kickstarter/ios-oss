import ReactiveCocoa
import Result
import KsApi
import Models
import Library

protocol LoginViewModelInputs {
  var email: MutableProperty<String?> { get }
  var password: MutableProperty<String?> { get }
  func loginPressed()
}

protocol LoginViewModelOutputs {
  var isValid: MutableProperty<Bool> { get }
  var loggedIn: Signal<(), NoError> { get }
}

protocol LoginViewModelErrors {
  var invalidLogin: Signal<String, NoError> { get }
  var genericError: Signal<(), NoError> { get }
  var tfaChallenge: Signal<(), NoError> { get }
}

final class LoginViewModel: LoginViewModelInputs, LoginViewModelOutputs, LoginViewModelErrors {
  // MARK: Inputs
  let email = MutableProperty<String?>(nil)
  let password = MutableProperty<String?>(nil)
  private var (loginPress, loginPressObserver) = Signal<(), NoError>.pipe()
  func loginPressed() { loginPressObserver.sendNext(()) }
  var inputs: LoginViewModelInputs { return self }

  // MARK: Outputs
  let isValid = MutableProperty(false)
  let loggedIn: Signal<(), NoError>
  var outputs: LoginViewModelOutputs { return self }

  // MARK: Errors
  let invalidLogin: Signal<String, NoError>
  let genericError: Signal<(), NoError>
  let tfaChallenge: Signal<(), NoError>
  var errors: LoginViewModelErrors { return self }

  init(env: Environment = AppEnvironment.current) {
    let _ = env.apiService
    let _ = env.currentUser

    let (loggedInSignal, _) = Signal<(), NoError>.pipe()
    loggedIn = loggedInSignal

    let errors = MutableProperty<ErrorEnvelope?>(nil)

    invalidLogin = errors.signal.ignoreNil()
      .filter { $0.ksrCode == .InvalidXauthLogin }
      .map { $0.errorMessages.first }
      .ignoreNil()

    tfaChallenge = errors.signal.ignoreNil()
      .filter { $0.ksrCode == .TfaRequired }
      .ignoreValues()

    genericError = errors.signal.ignoreNil()
      .filter { $0.ksrCode != .InvalidXauthLogin && $0.ksrCode != .TfaRequired }
      .ignoreValues()

    let emailAndPassword = email.producer.ignoreNil()
      .combineLatestWith(password.producer.ignoreNil())
      .map { ep in (email: ep.0, password: ep.1) }

    isValid <~ emailAndPassword.map(isValid)
  }

  private func isValid(email: String, password: String) -> Bool {
    return email.characters.count > 5 && !password.characters.isEmpty
  }
}
