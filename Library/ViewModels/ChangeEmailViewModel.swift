import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol ChangeEmailViewModelInputs {
  func emailFieldDidEndEditing(email: String?)
  func emailFieldTextDidChange(text: String?)
  func onePasswordButtonTapped()
  func onePasswordFound(password: String?)
  func onePassword(isAvailable available: Bool)
  func passwordFieldDidEndEditing(password: String?)
  func passwordFieldDidTapGo(newEmail: String, password: String)
  func passwordFieldTextDidChange(text: String?)
  func saveButtonTapped()
  func viewDidLoad()
}

public protocol ChangeEmailViewModelOutputs {
  var dismissKeyboard: Signal<Void, NoError> { get }
  var didChangeEmail: Signal<Void, NoError> { get }
  var didFailToChangeEmail: Signal<String, NoError> { get }
  var errorLabelIsHidden: Signal<Bool, NoError> { get }
  var messageBannerViewIsHidden: Signal<Bool, NoError> { get }
  var onePasswordButtonIsHidden: Signal<Bool, NoError> { get }
  var onePasswordFindLoginForURLString: Signal<String, NoError> { get }
  var emailText: Signal<String, NoError> { get }
  var passwordText: Signal<String, NoError> { get }
  var resendVerificationEmailButtonIsHidden: Signal<Bool, NoError> { get }
  var saveButtonIsEnabled: Signal<Bool, NoError> { get }
  var showConfirmationEmailSentBanner: Signal<Bool, NoError> { get }
}

public protocol ChangeEmailViewModelType {
  var inputs: ChangeEmailViewModelInputs { get }
  var outputs: ChangeEmailViewModelOutputs { get }
}

public let userEmailQuery: NonEmptySet<Query> = Query.user(.email +| []) +| []

public final class ChangeEmailViewModel: ChangeEmailViewModelType, ChangeEmailViewModelInputs,
ChangeEmailViewModelOutputs {

  public init() {

    let changeEmailEvent = self.changePasswordProperty.signal.skipNil().map { email, password in
      return ChangeEmailInput(email: email, currentPassword: password)
      }.switchMap { input in
        AppEnvironment.current.apiService.changeEmail(input: input)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
    }

    let userEmailEvent = Signal.merge(
        self.viewDidLoadProperty.signal,
        changeEmailEvent.values().ignoreValues()
      )
      .switchMap { _ in
        AppEnvironment.current.apiService.fetchGraphUserEmail(query: userEmailQuery)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .map { $0.email }
          .materialize()
    }

    self.emailText = userEmailEvent.values()

    self.errorLabelIsHidden = viewDidLoadProperty.signal.mapConst(false)
    self.resendVerificationEmailButtonIsHidden = viewDidLoadProperty.signal.mapConst(false)
    self.saveButtonIsEnabled = viewDidLoadProperty.signal.mapConst(true)
    self.dismissKeyboard = saveButtonTappedProperty.signal.ignoreValues()
    self.showConfirmationEmailSentBanner = saveButtonTappedProperty.signal.mapConst(true)

    self.messageBannerViewIsHidden = viewDidLoadProperty.signal.mapConst(false)

    self.onePasswordButtonIsHidden = self.onePasswordIsAvailable.signal.map { $0 }.negate()

    self.onePasswordIsAvailable.signal
      .observeValues { AppEnvironment.current.koala.trackLoginFormView(onePasswordIsAvailable: $0) }

    self.passwordText = self.prefillPasswordProperty.signal.skipNil().map { $0 }

    self.onePasswordFindLoginForURLString = self.onePasswordButtonTappedProperty.signal
      .map { AppEnvironment.current.apiService.serverConfig.webBaseUrl.absoluteString }

    self.didChangeEmail = changeEmailEvent.values().ignoreValues()

    self.didFailToChangeEmail = changeEmailEvent.errors().map { error in
        error.localizedDescription
    }
  }

  private let changePasswordProperty = MutableProperty<(String, String)?>(nil)
  public func passwordFieldDidTapGo(newEmail: String, password: String) {
    self.changePasswordProperty.value = (newEmail, password)
  }

  private let emailProperty = MutableProperty<String?>(nil)
  public func emailFieldTextDidChange(text: String?) {
    self.emailProperty.value = text
  }

  public func emailFieldDidEndEditing(email: String?) {
    self.emailProperty.value = email
  }

  private let onePasswordIsAvailable = MutableProperty(false)
  public func onePassword(isAvailable available: Bool) {
    self.onePasswordIsAvailable.value = available
  }

  private let prefillPasswordProperty = MutableProperty<String?>(nil)
  public func onePasswordFound(password: String?) {
    self.prefillPasswordProperty.value = password
  }

  private let onePasswordButtonTappedProperty = MutableProperty(())
  public func onePasswordButtonTapped() {
    self.onePasswordButtonTappedProperty.value = ()
  }

  private let passwordProperty = MutableProperty<String?>(nil)
  public func passwordFieldDidEndEditing(password: String?) {
    self.passwordProperty.value = password
  }

  public func passwordFieldTextDidChange(text: String?) {
    self.passwordProperty.value = text
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let saveButtonTappedProperty = MutableProperty(())
  public func saveButtonTapped() {
    self.saveButtonTappedProperty.value = ()
  }

  public let didChangeEmail: Signal<Void, NoError>
  public let didFailToChangeEmail: Signal<String, NoError>
  public let dismissKeyboard: Signal<Void, NoError>
  public let emailText: Signal<String, NoError>
  public let errorLabelIsHidden: Signal<Bool, NoError>
  public let messageBannerViewIsHidden: Signal<Bool, NoError>
  public let onePasswordButtonIsHidden: Signal<Bool, NoError>
  public let onePasswordFindLoginForURLString: Signal<String, NoError>
  public let passwordText: Signal<String, NoError>
  public let resendVerificationEmailButtonIsHidden: Signal<Bool, NoError>
  public let saveButtonIsEnabled: Signal<Bool, NoError>
  public let showConfirmationEmailSentBanner: Signal<Bool, NoError>

  public var inputs: ChangeEmailViewModelInputs {
    return self
  }

  public var outputs: ChangeEmailViewModelOutputs {
    return self
  }
}
