import ReactiveCocoa
import ReactiveExtensions
import Result
import KsApi
import Library

internal protocol ResetPasswordViewModelInputs {
  /// Call when the view will appear
  func viewWillAppear()
  /// Call when email textfield input is entered
  func emailChanged(email: String?)
  /// Call when reset button is pressed
  func resetButtonPressed()
  /// Call when OK button is pressed on reset confirmation popup
  func confirmResetButtonPressed()
}

internal protocol ResetPasswordViewModelOutputs {
  /// Emits Bool representing form validity
  var formIsValid: Signal<Bool, NoError> { get }
  /// Emits email String when reset is successful
  var showResetSuccess: Signal<String, NoError> { get }
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

  private let emailProperty = MutableProperty<String?>(nil)
  func emailChanged(email: String?) {
    emailProperty.value = email
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
  internal let showResetSuccess: Signal<String, NoError>
  internal var returnToLogin: Signal<(), NoError>

  // MARK: ResetPasswordViewModelErrors

  internal let resetFail: Signal<String, NoError>

  // MARK: Constructor
  internal init() {

    let (resetFailSignal, resetFailObserver) = Signal<ErrorEnvelope, NoError>.pipe()
    resetFail = resetFailSignal.map { envelope in envelope.errorMessages.first ??
      localizedString(key: "forgot_password.error",
        defaultValue: "Sorry, we don’t know that email address. Try again?")
    }

    formIsValid = emailProperty.signal.ignoreNil()
      .map { email in email.characters.count > 3 }
      .mergeWith(viewWillAppearSignal.mapConst(false))
      .skipRepeats()

    showResetSuccess = emailProperty.signal.ignoreNil()
      .takeWhen(resetButtonPressedSignal)
      .switchMap { email in
        AppEnvironment.current.apiService.resetPassword(email: email)
          .demoteErrors(pipeErrorsTo: resetFailObserver)
          .mapConst(localizedString(
            key: "forgot_password.we_sent_an_email_to_email_address_with_instructions_to_reset_your_password",
            defaultValue: "We've sent an email to %{email} with instructions to reset your password.",
            count: nil,
            substitutions: ["email": email], env: AppEnvironment.current))
    }

    returnToLogin = confirmResetButtonPressedSignal

    viewWillAppearSignal.observeNext { AppEnvironment.current.koala.trackResetPassword() }
    showResetSuccess.observeNext { _ in AppEnvironment.current.koala.trackResetPasswordSuccess() }
  }
  
}
