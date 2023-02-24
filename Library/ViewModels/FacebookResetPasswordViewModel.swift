import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol FacebookResetPasswordViewModelInputs {
  func viewDidLoad()
  func viewWillAppear()
  func emailTextFieldFieldDidChange(_ text: String)
  func emailTextFieldFieldDidReturn()
  func setPasswordButtonPressed()
}

public protocol FacebookResetPasswordViewModelOutputs {
  var shouldShowActivityIndicator: Signal<Bool, Never> { get }
  var setPasswordButtonIsEnabled: Signal<Bool, Never> { get }
  var contextLabelText: Signal<String, Never> { get }
  var emailLabel: Signal<String, Never> { get }
  var setPasswordFailure: Signal<String, Never> { get }
  var setPasswordSuccess: Signal<String, Never> { get }
  var textFieldAndSetPasswordButtonAreEnabled: Signal<Bool, Never> { get }
}

public protocol FacebookResetPasswordViewModelType {
  var inputs: FacebookResetPasswordViewModelInputs { get }
  var outputs: FacebookResetPasswordViewModelOutputs { get }
}

public final class FacebookResetPasswordViewModel: FacebookResetPasswordViewModelType,
  FacebookResetPasswordViewModelInputs,
  FacebookResetPasswordViewModelOutputs {
  public init() {
    self.contextLabelText = self.viewWillAppearProperty.signal
      .map { Strings.We_re_simplifying_our_login_process_To_log_in() }
    self.emailLabel = self.viewWillAppearProperty.signal
      .map { Strings.forgot_password_placeholder_email() }

    let formIsValid = Signal.combineLatest(
      self.viewDidLoadProperty.signal,
      self.emailTextFieldProperty.signal.skipNil()
    )
    .map(second)
    .map(isValidEmail)
    .skipRepeats()

    self.setPasswordButtonIsEnabled = formIsValid

    let submitFormEvent = Signal.merge(
      self.emailTextFieldReturnProperty.signal,
      self.setPasswordButtonPressedProperty.signal
    )

    let submitAction = formIsValid
      .takeWhen(submitFormEvent)
      .filter(isTrue)
      .ignoreValues()

    let setPasswordEvent = self.emailTextFieldProperty.signal.skipNil()
      .takeWhen(submitAction)
      .switchMap { email in
        AppEnvironment.current.apiService.resetPassword(email: email)
          .mapConst(email)
          .materialize()
      }

    self.setPasswordFailure = setPasswordEvent.errors()
      .map { envelope in
        envelope.errorMessages.last ?? Strings.general_error_something_wrong()
      }

    self.setPasswordSuccess = setPasswordEvent.values().map { email in
      Strings.forgot_password_we_sent_an_email_to_email_address_with_instructions_to_reset_your_password(
        email: email
      )
    }

    self.shouldShowActivityIndicator = Signal.merge(
      submitAction.signal.ignoreValues().mapConst(true),
      setPasswordEvent.filter { $0.isTerminating }.mapConst(false)
    )

    self.textFieldAndSetPasswordButtonAreEnabled = self.shouldShowActivityIndicator.map { $0 }.negate()
  }

  public var inputs: FacebookResetPasswordViewModelInputs { return self }
  public var outputs: FacebookResetPasswordViewModelOutputs { return self }

  // MARK: - Input Methods

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  private let emailTextFieldProperty = MutableProperty<String?>(nil)
  public func emailTextFieldFieldDidChange(_ text: String) {
    self.emailTextFieldProperty.value = text
  }

  private let emailTextFieldReturnProperty = MutableProperty(())
  public func emailTextFieldFieldDidReturn() {
    self.emailTextFieldReturnProperty.value = ()
  }

  private let setPasswordButtonPressedProperty = MutableProperty(())
  public func setPasswordButtonPressed() {
    self.setPasswordButtonPressedProperty.value = ()
  }

  // MARK: - Output Properties

  public var shouldShowActivityIndicator: Signal<Bool, Never>
  public var setPasswordButtonIsEnabled: Signal<Bool, Never>
  public var contextLabelText: Signal<String, Never>
  public var emailLabel: Signal<String, Never>
  public var setPasswordFailure: Signal<String, Never>
  public var setPasswordSuccess: Signal<String, Never>
  public var textFieldAndSetPasswordButtonAreEnabled: Signal<Bool, Never>
}
