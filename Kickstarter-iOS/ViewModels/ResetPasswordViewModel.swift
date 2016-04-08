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

  private let viewWillAppearProperty = MutableProperty()
  func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  private let emailProperty = MutableProperty("")
  func email(email: String) {
    self.emailProperty.value = email
  }

  private let resetButtonPressedProperty = MutableProperty()
  func resetButtonPressed() {
    self.resetButtonPressedProperty.value = ()
  }

  private let confirmResetButtonPressedProperty = MutableProperty()
  func confirmResetButtonPressed() {
    self.confirmResetButtonPressedProperty.value = ()
  }

  // MARK: ResetPasswordViewModelOutputs

  internal let formIsValid: Signal<Bool, NoError>
  internal let resetSuccess: Signal<String, NoError>
  internal var returnToLogin: Signal<(), NoError>

  // MARK: ResetPasswordViewModelErrors

  internal let resetFail: Signal<String, NoError>

  // MARK: Constructor
  internal init() {
    let resetErrors = MutableProperty<ErrorEnvelope?>(nil)

    resetFail = resetErrors.signal.ignoreNil()
      .map { envelope in envelope.errorMessages.first ??
        localizedString(key: "forgot_password.error",
          defaultValue: "Sorry, we don’t know that email address. Try again?")
    }

    formIsValid = self.emailProperty.signal
      .map { email in email.characters.count > 3 }
      .mergeWith(self.viewWillAppearProperty.signal.mapConst(false))
      .skipRepeats()

    resetSuccess = self.emailProperty.signal
      .takeWhen(self.resetButtonPressedProperty.signal)
      .switchMap { email in
        AppEnvironment.current.apiService.resetPassword(email: email)
          .demoteErrors(pipeErrorsTo: resetErrors)
          .mapConst(email)
    }

    returnToLogin = self.confirmResetButtonPressedProperty.signal

    self.viewWillAppearProperty.signal.observeNext { AppEnvironment.current.koala.trackResetPassword() }
    self.resetSuccess.observeNext { _ in AppEnvironment.current.koala.trackResetPasswordSuccess() }
  }
}
