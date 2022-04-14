import KsApi
import Prelude
import ReactiveSwift
import UIKit

public protocol ChangeEmailViewModelInputs {
  func emailFieldTextDidChange(text: String?)
  func passwordFieldTextDidChange(text: String?)
  func resendVerificationEmailButtonTapped()
  func saveButtonTapped()
  func saveButtonIsEnabled(_ enabled: Bool)
  func textFieldShouldReturn(with returnKeyType: UIReturnKeyType)
  func viewDidLoad()
}

public protocol ChangeEmailViewModelOutputs {
  var activityIndicatorShouldShow: Signal<Bool, Never> { get }
  var didChangeEmail: Signal<Void, Never> { get }
  var didFailToChangeEmail: Signal<String, Never> { get }
  var didFailToSendVerificationEmail: Signal<String, Never> { get }
  var didSendVerificationEmail: Signal<Void, Never> { get }
  var dismissKeyboard: Signal<Void, Never> { get }
  var emailText: Signal<String, Never> { get }
  var messageLabelViewHidden: Signal<Bool, Never> { get }
  var passwordFieldBecomeFirstResponder: Signal<Void, Never> { get }
  var resendVerificationEmailViewIsHidden: Signal<Bool, Never> { get }
  var resetFields: Signal<String, Never> { get }
  var saveButtonIsEnabled: Signal<Bool, Never> { get }
  var textFieldsAreEnabled: Signal<Bool, Never> { get }
  var unverifiedEmailLabelHidden: Signal<Bool, Never> { get }
  var warningMessageLabelHidden: Signal<Bool, Never> { get }
  var verificationEmailButtonTitle: Signal<String, Never> { get }
}

public protocol ChangeEmailViewModelType {
  var inputs: ChangeEmailViewModelInputs { get }
  var outputs: ChangeEmailViewModelOutputs { get }
}

public final class ChangeEmailViewModel: ChangeEmailViewModelType, ChangeEmailViewModelInputs,
  ChangeEmailViewModelOutputs {
  public init() {
    self.dismissKeyboard = Signal.merge(
      self.textFieldShouldReturnProperty.signal.skipNil()
        .filter { $0 == .done }
        .ignoreValues(),
      self.saveButtonTappedProperty.signal
    )

    let triggerSaveAction = self.saveButtonEnabledProperty.signal
      .takeWhen(self.dismissKeyboard)
      .filter(isTrue)
      .ignoreValues()

    let changeEmailEvent = Signal.combineLatest(
      self.newEmailProperty.signal.skipNil(),
      self.passwordProperty.signal.skipNil()
    )
    .takeWhen(triggerSaveAction)
    .map(ChangeEmailInput.init(email:currentPassword:))
    .switchMap { input in
      AppEnvironment.current.apiService.changeEmail(input: input)
        .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
        .map { _ in input.email }
        .materialize()
    }

    let clearValues = changeEmailEvent.values().map { _ -> String? in nil }
    self.newEmailProperty <~ clearValues
    self.passwordProperty <~ clearValues

    let userEmailEvent = self.viewDidLoadProperty.signal
      .switchMap { _ in
        AppEnvironment.current
          .apiService
          .fetchGraphUser(withStoredCards: false)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    let resendEmailVerificationEvent = self.resendVerificationEmailButtonProperty.signal
      .switchMap { _ in
        AppEnvironment.current.apiService.sendVerificationEmail(input: EmptyInput())
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    self.didSendVerificationEmail = resendEmailVerificationEvent.values().ignoreValues()

    self.didFailToSendVerificationEmail = resendEmailVerificationEvent.errors()
      .map { $0.localizedDescription }

    self.emailText = Signal.merge(
      changeEmailEvent.values(),
      userEmailEvent.values().map { $0.me.email ?? "" }
    )

    let isEmailVerified = userEmailEvent.values().map { $0.me.isEmailVerified }.skipNil()
    let isEmailDeliverable = userEmailEvent.values().map { $0.me.isDeliverable }.skipNil()
    let emailVerifiedAndDeliverable = Signal.combineLatest(isEmailVerified, isEmailDeliverable)
      .map { isEmailVerified, isEmailDeliverable -> Bool in
        let r = isEmailVerified && isEmailDeliverable
        return r
      }

    self.resendVerificationEmailViewIsHidden = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(true),
      emailVerifiedAndDeliverable
    ).skipRepeats()

    self.unverifiedEmailLabelHidden = Signal
      .combineLatest(isEmailVerified, isEmailDeliverable)
      .map { isEmailVerified, isEmailDeliverable -> Bool in
        guard isEmailVerified else { return !isEmailDeliverable }

        return true
      }

    self.warningMessageLabelHidden = isEmailDeliverable

    self.messageLabelViewHidden = Signal
      .merge(self.unverifiedEmailLabelHidden, self.warningMessageLabelHidden)
      .filter(isFalse)

    self.saveButtonIsEnabled = Signal.combineLatest(
      self.emailText,
      self.newEmailProperty.signal,
      self.passwordProperty.signal
    )
    .map(shouldEnableSaveButton(email:newEmail:password:))

    self.passwordFieldBecomeFirstResponder = self.textFieldShouldReturnProperty.signal
      .skipNil()
      .filter { $0 == .next }
      .ignoreValues()

    self.didChangeEmail = changeEmailEvent.values().ignoreValues()

    self.resetFields = changeEmailEvent.values()
      .ignoreValues()
      .mapConst("")

    self.didFailToChangeEmail = changeEmailEvent.errors()
      .map { $0.localizedDescription }

    self.verificationEmailButtonTitle = self.viewDidLoadProperty.signal.map { _ in
      guard let user = AppEnvironment.current.currentUser else { return "" }
      return user.isCreator ? Strings.Resend_verification_email() : Strings.Send_verfication_email()
    }

    self.activityIndicatorShouldShow = Signal.merge(
      self.saveButtonTappedProperty.signal.ignoreValues().mapConst(true),
      changeEmailEvent.filter { $0.isTerminating }.mapConst(false)
    )

    self.textFieldsAreEnabled = self.activityIndicatorShouldShow.map { $0 }.negate()
  }

  private let newEmailProperty = MutableProperty<String?>(nil)
  public func emailFieldTextDidChange(text: String?) {
    self.newEmailProperty.value = text
  }

  private let passwordProperty = MutableProperty<String?>(nil)
  public func passwordFieldTextDidChange(text: String?) {
    self.passwordProperty.value = text
  }

  private let resendVerificationEmailButtonProperty = MutableProperty(())
  public func resendVerificationEmailButtonTapped() {
    self.resendVerificationEmailButtonProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let saveButtonEnabledProperty = MutableProperty(false)
  public func saveButtonIsEnabled(_ enabled: Bool) {
    self.saveButtonEnabledProperty.value = enabled
  }

  private let saveButtonTappedProperty = MutableProperty(())
  public func saveButtonTapped() {
    self.saveButtonTappedProperty.value = ()
  }

  private let textFieldShouldReturnProperty = MutableProperty<UIReturnKeyType?>(nil)
  public func textFieldShouldReturn(with returnKeyType: UIReturnKeyType) {
    self.textFieldShouldReturnProperty.value = returnKeyType
  }

  public let activityIndicatorShouldShow: Signal<Bool, Never>
  public let didChangeEmail: Signal<Void, Never>
  public let didFailToChangeEmail: Signal<String, Never>
  public let didFailToSendVerificationEmail: Signal<String, Never>
  public let didSendVerificationEmail: Signal<Void, Never>
  public let dismissKeyboard: Signal<Void, Never>
  public let emailText: Signal<String, Never>
  public let messageLabelViewHidden: Signal<Bool, Never>
  public let passwordFieldBecomeFirstResponder: Signal<Void, Never>
  public let resendVerificationEmailViewIsHidden: Signal<Bool, Never>
  public let resetFields: Signal<String, Never>
  public let saveButtonIsEnabled: Signal<Bool, Never>
  public let textFieldsAreEnabled: Signal<Bool, Never>
  public let unverifiedEmailLabelHidden: Signal<Bool, Never>
  public let verificationEmailButtonTitle: Signal<String, Never>
  public let warningMessageLabelHidden: Signal<Bool, Never>

  public var inputs: ChangeEmailViewModelInputs {
    return self
  }

  public var outputs: ChangeEmailViewModelOutputs {
    return self
  }
}

private func shouldEnableSaveButton(email: String?, newEmail: String?, password: String?) -> Bool {
  guard
    let newEmail = newEmail,
    isValidEmail(newEmail),
    email != newEmail,
    password != nil

  else { return false }

  return ![newEmail, password]
    .compact()
    .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    .contains(false)
}
