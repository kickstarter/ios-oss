import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol ResetYourFacebookPasswordViewModelInputs {
  func viewDidLoad()
  func viewWillAppear()
  func emailTextFieldFieldDidChange(_ text: String)
  func emailTextFieldDidReturn(email: String)
  func setPasswordButtonPressed()
}

public protocol ResetYourFacebookPasswordViewModelOutputs {
  var shouldShowActivityIndicator: Signal<Bool, Never> { get }
  var setPasswordButtonIsEnabled: Signal<Bool, Never> { get }
  var contextLabelText: Signal<String, Never> { get }
  var emailLabel: Signal<String, Never> { get }
  var setPasswordFailure: Signal<String, Never> { get }
  var setPasswordSuccess: Signal<String, Never> { get }
  var textFieldAndSetPasswordButtonAreEnabled: Signal<Bool, Never> { get }
}

public protocol ResetYourFacebookPasswordViewModelType {
  var inputs: ResetYourFacebookPasswordViewModelInputs { get }
  var outputs: ResetYourFacebookPasswordViewModelOutputs { get }
}

public final class ResetYourFacebookPasswordViewModel: ResetYourFacebookPasswordViewModelType,
  ResetYourFacebookPasswordViewModelInputs,
  ResetYourFacebookPasswordViewModelOutputs {
  public init() {
    // TODO: Remove hardcoded string
    self.contextLabelText = self.viewWillAppearProperty.signal
      .map {
        "We’re simplifying our login process.  To access your Kickstarter account, enter the email associated to your Facebook account and we’ll send you a link to set a password."
      }
    self.emailLabel = self.viewWillAppearProperty.signal
      .map { Strings.forgot_password_placeholder_email() }

    let formIsValid = self.viewDidLoadProperty.signal
      .flatMap { [email = emailTextFieldProperty.producer] _ in email }
      .map { $0 ?? "" }
      .map(isValidEmail)
      .skipRepeats()

    self.setPasswordButtonIsEnabled = formIsValid

    let submitFormEvent = self.setPasswordButtonPressedProperty.signal

    let saveAction = formIsValid
      .takeWhen(submitFormEvent)
      .filter(isTrue)
      .ignoreValues()

    let setPasswordEvent = self.emailTextFieldProperty.signal.skipNil()
      .takeWhen(self.setPasswordButtonPressedProperty.signal)
      .switchMap { email in
        AppEnvironment.current.apiService.resetPassword(email: email)
          .mapConst(email)
          .materialize()
      }

    self.setPasswordFailure = setPasswordEvent.errors()
      .map { envelope in
        if envelope.httpCode == 404 {
          return Strings.forgot_password_error()
        } else {
          return Strings.general_error_something_wrong()
        }
      }

    self.setPasswordSuccess = setPasswordEvent.values().map { email in
      Strings.forgot_password_we_sent_an_email_to_email_address_with_instructions_to_reset_your_password(
        email: email
      )
    }

    self.shouldShowActivityIndicator = Signal.merge(
      saveAction.signal.ignoreValues().mapConst(true),
      setPasswordEvent.filter { $0.isTerminating }.mapConst(false)
    )

    self.textFieldAndSetPasswordButtonAreEnabled = self.shouldShowActivityIndicator.map { $0 }.negate()
  }

  public var inputs: ResetYourFacebookPasswordViewModelInputs { return self }
  public var outputs: ResetYourFacebookPasswordViewModelOutputs { return self }

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

  private var emailTextFieldDoneEditingProperty = MutableProperty(())
  public func emailTextFieldDidReturn(email _: String) {
    self.emailTextFieldDoneEditingProperty.value = ()
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
