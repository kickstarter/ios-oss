import KsApi
import ReactiveExtensions
import ReactiveSwift

public protocol ResetPasswordViewModelInputs {
  /// Call when the view loads
  func viewDidLoad()
  /// Call when email textfield input is entered
  func emailChanged(_ email: String?)
  /// Call when reset button is pressed
  func resetButtonPressed()
  /// Call when OK button is pressed on reset confirmation popup
  func confirmResetButtonPressed()
}

public protocol ResetPasswordViewModelOutputs {
  /// Sets whether the email text field is the first responder.
  var emailTextFieldBecomeFirstResponder: Signal<(), Never> { get }
  /// Emits email address to set email textfield
  var setEmailInitial: Signal<String, Never> { get }
  /// Emits Bool representing form validity
  var formIsValid: Signal<Bool, Never> { get }
  /// Emits email String when reset is successful
  var showResetSuccess: Signal<String, Never> { get }
  /// Emits after user closes popup confirmation
  var returnToLogin: Signal<(), Never> { get }
  /// Emits error message String on reset fail
  var showError: Signal<String, Never> { get }
}

public protocol ResetPasswordViewModelType {
  var inputs: ResetPasswordViewModelInputs { get }
  var outputs: ResetPasswordViewModelOutputs { get }
}

public final class ResetPasswordViewModel: ResetPasswordViewModelType, ResetPasswordViewModelInputs,
  ResetPasswordViewModelOutputs {
  public init() {
    self.emailTextFieldBecomeFirstResponder = self.viewDidLoadProperty.signal

    self.setEmailInitial = self.emailProperty.signal.skipNil()
      .takeWhen(self.viewDidLoadProperty.signal)
      .take(first: 1)

    self.formIsValid = self.viewDidLoadProperty.signal
      .flatMap { [email = emailProperty.producer] _ in email }
      .map { $0 ?? "" }
      .map(isValidEmail)
      .skipRepeats()

    let resetEvent = self.emailProperty.signal.skipNil()
      .takeWhen(self.resetButtonPressedProperty.signal)
      .switchMap { email in
        AppEnvironment.current.apiService.resetPassword(email: email)
          .mapConst(email)
          .materialize()
      }

    self.showResetSuccess = resetEvent.values().map { email in
      Strings.forgot_password_we_sent_an_email_to_email_address_with_instructions_to_reset_your_password(
        email: email
      )
    }

    self.showError = resetEvent.errors()
      .map { envelope in
        if envelope.httpCode == 404 {
          return Strings.forgot_password_error()
        } else {
          return Strings.general_error_something_wrong()
        }
      }

    self.returnToLogin = self.confirmResetButtonPressedProperty.signal
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let emailProperty = MutableProperty<String?>(nil)
  public func emailChanged(_ email: String?) {
    self.emailProperty.value = email
  }

  fileprivate let resetButtonPressedProperty = MutableProperty(())
  public func resetButtonPressed() {
    self.resetButtonPressedProperty.value = ()
  }

  fileprivate let confirmResetButtonPressedProperty = MutableProperty(())
  public func confirmResetButtonPressed() {
    self.confirmResetButtonPressedProperty.value = ()
  }

  public let emailTextFieldBecomeFirstResponder: Signal<(), Never>
  public let formIsValid: Signal<Bool, Never>
  public let showResetSuccess: Signal<String, Never>
  public var returnToLogin: Signal<(), Never>
  public var setEmailInitial: Signal<String, Never>
  public let showError: Signal<String, Never>

  public var inputs: ResetPasswordViewModelInputs { return self }
  public var outputs: ResetPasswordViewModelOutputs { return self }
}
