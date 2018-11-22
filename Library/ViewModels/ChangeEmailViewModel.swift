import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol ChangeEmailViewModelInputs {
  func emailFieldTextDidChange(text: String?)
  func onePasswordButtonTapped()
  func onePasswordFound(password: String?)
  func onePassword(isAvailable available: Bool)
  func passwordFieldTextDidChange(text: String?)
  func resendVerificationEmailButtonTapped()
  func saveButtonTapped()
  func textFieldShouldReturn(with returnKeyType: UIReturnKeyType)
  func viewDidLoad()
  func viewDidAppear()
}

public protocol ChangeEmailViewModelOutputs {
  var activityIndicatorShouldShow: Signal<Bool, NoError> { get }
  var didChangeEmail: Signal<Void, NoError> { get }
  var didFailToChangeEmail: Signal<String, NoError> { get }
  var didFailToSendVerificationEmail: Signal<String, NoError> { get }
  var didSendVerificationEmail: Signal<Void, NoError> { get }
  var dismissKeyboard: Signal<Void, NoError> { get }
  var emailText: Signal<String, NoError> { get }
  var messageLabelViewHidden: Signal<Bool, NoError> { get }
  var onePasswordButtonIsHidden: Signal<Bool, NoError> { get }
  var onePasswordFindLoginForURLString: Signal<String, NoError> { get }
  var passwordText: Signal<String, NoError> { get }
  var passwordFieldBecomeFirstResponder: Signal<Void, NoError> { get }
  var resendVerificationEmailViewIsHidden: Signal<Bool, NoError> { get }
  var resetFields: Signal<String, NoError> { get }
  var saveButtonIsEnabled: Signal<Bool, NoError> { get }
  var textFieldsAreEnabled: Signal<Bool, NoError> { get }
  var unverifiedEmailLabelHidden: Signal<Bool, NoError> { get }
  var warningMessageLabelHidden: Signal<Bool, NoError> { get }
  var verificationEmailButtonTitle: Signal<String, NoError> { get }
}

public protocol ChangeEmailViewModelType {
  var inputs: ChangeEmailViewModelInputs { get }
  var outputs: ChangeEmailViewModelOutputs { get }
}

public final class ChangeEmailViewModel: ChangeEmailViewModelType, ChangeEmailViewModelInputs,
ChangeEmailViewModelOutputs {
  public init() {

    let changeEmailEvent = Signal.combineLatest(
      self.newEmailProperty.signal.skipNil(),
      self.passwordProperty.signal.skipNil()
      )
      .takeWhen(self.saveButtonTappedProperty.signal)
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

    let userEmailEvent = Signal.merge(
        self.viewDidLoadProperty.signal,
        changeEmailEvent.values().ignoreValues()
      )
      .switchMap { _ in
        AppEnvironment.current
          .apiService
          .fetchGraphUserEmailFields(query: NonEmptySet(Query.user(changeEmailQueryFields())))
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
    }

    let resendEmailVerificationEvent = self.resendVerificationEmailButtonProperty.signal
      .switchMap { _ in
        AppEnvironment.current.apiService.sendVerificationEmail(input: EmptyInput())
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
    }

    resendEmailVerificationEvent.values()
      .observeValues { _ in AppEnvironment.current.koala.trackResentVerificationEmail() }

    self.didSendVerificationEmail = resendEmailVerificationEvent.values().ignoreValues()

    self.didFailToSendVerificationEmail = resendEmailVerificationEvent.errors()
      .map { $0.localizedDescription }

    self.emailText = Signal.merge(
      changeEmailEvent.values(),
      userEmailEvent.values().map { $0.me.email }
    )

    let isEmailVerified = userEmailEvent.values().map { $0.me.isEmailVerified }.skipNil()
    let isEmailDeliverable = userEmailEvent.values().map { $0.me.isDeliverable }.skipNil()

    self.resendVerificationEmailViewIsHidden = Signal.combineLatest(isEmailVerified, isEmailDeliverable)
      .map { $0 && $1 }

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

    self.dismissKeyboard = Signal.merge(
      self.textFieldShouldReturnProperty.signal.skipNil()
        .filter { $0 == .done }
        .ignoreValues(),
      self.saveButtonTappedProperty.signal.ignoreValues()
    )

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

    self.onePasswordButtonIsHidden = self.onePasswordIsAvailableProperty.signal.map(negate)
      .map(is1PasswordButtonHidden)

    self.onePasswordIsAvailableProperty.signal
      .observeValues { AppEnvironment.current.koala.trackLoginFormView(onePasswordIsAvailable: $0) }

    self.passwordText = self.prefillPasswordProperty.signal.skipNil().map { $0 }

    self.onePasswordFindLoginForURLString = self.onePasswordButtonTappedProperty.signal
      .map { AppEnvironment.current.apiService.serverConfig.webBaseUrl.absoluteString }

    changeEmailEvent.values()
      .observeValues { _ in AppEnvironment.current.koala.trackChangeEmail() }

    self.didChangeEmail = changeEmailEvent.values().ignoreValues()

    self.resetFields = changeEmailEvent.values()
                        .ignoreValues()
                        .mapConst("")

    self.didFailToChangeEmail = changeEmailEvent.errors()
      .map { $0.localizedDescription  }

    self.verificationEmailButtonTitle = self.viewDidLoadProperty.signal.map { _ in
      guard let user = AppEnvironment.current.currentUser else { return "" }
      return user.isCreator ? Strings.Resend_verification_email() : Strings.Send_verfication_email()
    }

    self.activityIndicatorShouldShow = Signal.merge(
      self.saveButtonTappedProperty.signal.ignoreValues().mapConst(true),
      changeEmailEvent.filter { $0.isTerminating }.mapConst(false)
    )

    self.textFieldsAreEnabled = self.activityIndicatorShouldShow.map { $0 }.negate()

    self.viewDidAppearProperty.signal
      .observeValues { _ in AppEnvironment.current.koala.trackChangeEmailView() }
  }

  private let newEmailProperty = MutableProperty<String?>(nil)
  public func emailFieldTextDidChange(text: String?) {
    self.newEmailProperty.value = text
  }

  private let onePasswordIsAvailableProperty = MutableProperty(false)
  public func onePassword(isAvailable available: Bool) {
    self.onePasswordIsAvailableProperty.value = available
  }

  private let prefillPasswordProperty = MutableProperty<String?>(nil)
  public func onePasswordFound(password: String?) {
    self.prefillPasswordProperty.value = password
    self.passwordProperty.value = password
  }

  private let onePasswordButtonTappedProperty = MutableProperty(())
  public func onePasswordButtonTapped() {
    self.onePasswordButtonTappedProperty.value = ()
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

  private let saveButtonTappedProperty = MutableProperty(())
  public func saveButtonTapped() {
    self.saveButtonTappedProperty.value = ()
  }

  private let viewDidAppearProperty = MutableProperty(())
  public func viewDidAppear() {
    self.viewDidAppearProperty.value = ()
  }

  private let textFieldShouldReturnProperty = MutableProperty<UIReturnKeyType?>(nil)
  public func textFieldShouldReturn(with returnKeyType: UIReturnKeyType) {
    self.textFieldShouldReturnProperty.value = returnKeyType
  }

  public let activityIndicatorShouldShow: Signal<Bool, NoError>
  public let didChangeEmail: Signal<Void, NoError>
  public let didFailToChangeEmail: Signal<String, NoError>
  public let didFailToSendVerificationEmail: Signal<String, NoError>
  public let didSendVerificationEmail: Signal<Void, NoError>
  public let dismissKeyboard: Signal<Void, NoError>
  public let emailText: Signal<String, NoError>
  public let messageLabelViewHidden: Signal<Bool, NoError>
  public let onePasswordButtonIsHidden: Signal<Bool, NoError>
  public let onePasswordFindLoginForURLString: Signal<String, NoError>
  public let passwordFieldBecomeFirstResponder: Signal<Void, NoError>
  public let passwordText: Signal<String, NoError>
  public let resendVerificationEmailViewIsHidden: Signal<Bool, NoError>
  public let resetFields: Signal<String, NoError>
  public let saveButtonIsEnabled: Signal<Bool, NoError>
  public let textFieldsAreEnabled: Signal<Bool, NoError>
  public let unverifiedEmailLabelHidden: Signal<Bool, NoError>
  public let verificationEmailButtonTitle: Signal<String, NoError>
  public let warningMessageLabelHidden: Signal<Bool, NoError>

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
    .compactMap { $0 }
    .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    .contains(false)
}
