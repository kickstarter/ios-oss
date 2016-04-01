import ReactiveCocoa
import ReactiveExtensions
import Result
import KsApi
import Library

internal protocol ResetPasswordViewModelInputs {
  /// Call when the view will appear
  func viewWillAppear()
  /// Call when email textfield input is entered
  func email(email: String)
  /// Call when reset button is pressed
  func resetButtonPressed()
  /// Call when OK button is pressed on reset confirmation popup
  func confirmResetButtonPressed()
}

internal protocol ResetPasswordViewModelOutputs {
  /// Emits Bool representing form validity
  var formIsValid: Signal<Bool, NoError> { get }
  /// Emits email String when reset is successful
  var resetSuccess: Signal<String, NoError> { get }
  /// Emits after user closes popup confirmation
  var returnToLogin: Signal<(), NoError> { get }
}

internal protocol ResetPasswordViewModelErrors {
  /// Emits error message String on generic error
  var resetFail: Signal<String, NoError> { get }
}

internal protocol ResetPasswordViewModelType {
  var inputs: ResetPasswordViewModelInputs { get }
  var outputs: ResetPasswordViewModelOutputs { get }
  var errors: ResetPasswordViewModelErrors { get }
}

internal final class ResetPasswordViewModel: ResetPasswordViewModelType, ResetPasswordViewModelInputs,
  ResetPasswordViewModelOutputs, ResetPasswordViewModelErrors {

  // MARK: ResetPasswordViewModelType

  internal var inputs: ResetPasswordViewModelInputs { return self }
  internal var outputs: ResetPasswordViewModelOutputs { return self }
  internal var errors: ResetPasswordViewModelErrors { return self }


  // MARK: ResetPasswordViewModelInputs

  private let (viewWillAppearSignal, viewWillAppearObserver) = Signal<(), NoError>.pipe()
  func viewWillAppear() {
    viewWillAppearObserver.sendNext()
  }

  private let (emailSignal, emailObserver) = Signal<String, NoError>.pipe()
  func email(email: String) {
    emailObserver.sendNext(email)
  }

  private let (resetButtonPressedSignal, resetButtonPressedObserver) = Signal<(), NoError>.pipe()
  func resetButtonPressed() {
    resetButtonPressedObserver.sendNext()
  }

  private let (confirmResetButtonPressedSignal, confirmResetButtonPressedObserver) = Signal<(), NoError>.pipe()
  func confirmResetButtonPressed() {
    confirmResetButtonPressedObserver.sendNext()
  }

  // MARK: ResetPasswordViewModelOutputs

  internal let formIsValid: Signal<Bool, NoError>
  internal let resetSuccess: Signal<String, NoError>
  internal var returnToLogin: Signal<(), NoError>

  // MARK: ResetPasswordViewModelErrors

  internal let resetFail: Signal<String, NoError>

  // MARK: Constructor
  internal init(env: Environment = AppEnvironment.current) {
    let apiService = env.apiService
    let koala = env.koala

    let (resetFailSignal, resetFailObserver) = Signal<ErrorEnvelope, NoError>.pipe()
    resetFail = resetFailSignal.map { envelope in envelope.errorMessages.first ??
      localizedString(key: "forgot_password.error",
        defaultValue: "Sorry, we don’t know that email address. Try again?")
    }

    formIsValid = emailSignal
      .map { email in email.characters.count > 3 }
      .mergeWith(viewWillAppearSignal.mapConst(false))
      .skipRepeats()

    resetSuccess = emailSignal
      .takeWhen(resetButtonPressedSignal)
      .switchMap { email in apiService.resetPassword(email: email)
        .demoteErrors(pipeErrorsTo: resetFailObserver)
        .mapConst(email) }

    returnToLogin = confirmResetButtonPressedSignal

    viewWillAppearSignal.observeNext { _ in koala.trackResetPassword() }
    resetSuccess.observeNext { _ in koala.trackResetPasswordSuccess() }
  }
  
}
