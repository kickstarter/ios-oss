import ReactiveCocoa
import ReactiveExtensions
import Result
import KsApi
import Library

internal protocol ResetPasswordViewModelInputs {
  /// Call when the view loads
  func viewDidLoad()
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
  /// Emits email address to set email textfield
  var setEmailInitial: Signal<String, NoError> { get }
  /// Emits Bool representing form validity
  var formIsValid: Signal<Bool, NoError> { get }
  /// Emits email String when reset is successful
  var showResetSuccess: Signal<String, NoError> { get }
  /// Emits after user closes popup confirmation
  var returnToLogin: Signal<(), NoError> { get }
}

internal protocol ResetPasswordViewModelErrors {
  /// Emits error message String on reset fail
  var showError: Signal<String, NoError> { get }
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

  private let viewDidLoadProperty = MutableProperty()
  func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let viewWillAppearProperty = MutableProperty()
  func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  private let emailProperty = MutableProperty<String?>("")
  func emailChanged(email: String?) {
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
  internal let showResetSuccess: Signal<String, NoError>
  internal var returnToLogin: Signal<(), NoError>
  internal var setEmailInitial: Signal<String, NoError>

  // MARK: ResetPasswordViewModelErrors

  internal let showError: Signal<String, NoError>

  // MARK: Constructor
  internal init() {
    let resetErrors = MutableProperty<ErrorEnvelope?>(nil)

    self.showError = resetErrors.signal.ignoreNil()
      .map { envelope in
        if (envelope.httpCode == 404) {
          return localizedString(key: "forgot_password.error",
            defaultValue: "Sorry, we don't know that email address. Try again?")
        } else {
          return localizedString(key: "general.error.something_wrong",
            defaultValue: "Something went wrong.")
        }
    }

    self.setEmailInitial = self.emailProperty.signal.ignoreNil()
      .takeWhen(viewDidLoadProperty.signal)
      .take(1)

    self.formIsValid = self.viewDidLoadProperty.signal
      .take(1)
      .mapConst(self.emailProperty.producer)
      .flatten(.Merge)
      .map { $0 ?? "" }
      .map(isValidEmail)
      .skipRepeats()

    self.showResetSuccess = self.emailProperty.signal.ignoreNil()
      .takeWhen(resetButtonPressedProperty.signal)
      .switchMap { email in
        AppEnvironment.current.apiService.resetPassword(email: email)
          .demoteErrors(pipeErrorsTo: resetErrors)
          .map { _ in localizedString(
            key: "forgot_password.we_sent_an_email_to_email_address_with_instructions_to_reset_your_password",
            defaultValue: "We've sent an email to %{email} with instructions to reset your password.",
            count: nil,
            substitutions: ["email": email], env: AppEnvironment.current)
      }
    }

    self.returnToLogin = self.confirmResetButtonPressedProperty.signal

    self.viewWillAppearProperty.signal.observeNext { AppEnvironment.current.koala.trackResetPassword() }
    self.showResetSuccess.observeNext { _ in AppEnvironment.current.koala.trackResetPasswordSuccess() }
  }
}
