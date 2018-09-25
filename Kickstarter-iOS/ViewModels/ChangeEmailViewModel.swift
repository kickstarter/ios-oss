import Foundation
import ReactiveSwift
import Result

protocol ChangeEmailViewModelOutputs {
  var dismissKeyboard: Signal<Void, NoError> { get }
  var errorLabelIsHidden: Signal<Bool, NoError> { get }
  var messageBannerViewIsHidden: Signal<Bool, NoError> { get }
  var resendVerificationEmailButtonIsHidden: Signal<Bool, NoError> { get }
  var saveButtonIsEnabled: Signal<Bool, NoError> { get }
  var showConfirmationEmailSentBanner: Signal<Bool, NoError> { get }
}

protocol ChangeEmailViewModelInputs {
  func emailFieldDidEndEditing(email: String?)
  func emailFieldTextDidChange(text: String?)
  func passwordFieldDidEndEditing(password: String?)
  func passwordFieldTextDidChange(text: String?)
  func viewDidLoad()
  func saveButtonTapped()
}

protocol ChangeEmailViewModelType {
  var inputs: ChangeEmailViewModelInputs { get }
  var outputs: ChangeEmailViewModelOutputs { get }
}

struct ChangeEmailViewModel: ChangeEmailViewModelType, ChangeEmailViewModelInputs,
ChangeEmailViewModelOutputs {
  public init() {
    self.errorLabelIsHidden = viewDidLoadProperty.signal.mapConst(false)
    self.resendVerificationEmailButtonIsHidden = viewDidLoadProperty.signal.mapConst(false)
    self.saveButtonIsEnabled = viewDidLoadProperty.signal.mapConst(true)
    self.dismissKeyboard = saveButtonTappedProperty.signal.ignoreValues()
    self.showConfirmationEmailSentBanner = saveButtonTappedProperty.signal.mapConst(true)
    self.messageBannerViewIsHidden = viewDidLoadProperty.signal.mapConst(false)
  }

  private let emailProperty = MutableProperty<String?>(nil)
  func emailFieldTextDidChange(text: String?) {
    self.emailProperty.value = text
  }

  func emailFieldDidEndEditing(email: String?) {
    self.emailProperty.value = email
  }

  private let passwordProperty = MutableProperty<String?>(nil)
  func passwordFieldDidEndEditing(password: String?) {
    self.passwordProperty.value = password
  }

  func passwordFieldTextDidChange(text: String?) {
    self.passwordProperty.value = text
  }

  private let viewDidLoadProperty = MutableProperty(())
  func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let saveButtonTappedProperty = MutableProperty(())
  func saveButtonTapped() {
    self.saveButtonTappedProperty.value = ()
  }

  public let dismissKeyboard: Signal<Void, NoError>
  public let errorLabelIsHidden: Signal<Bool, NoError>
  public let messageBannerViewIsHidden: Signal<Bool, NoError>
  public let resendVerificationEmailButtonIsHidden: Signal<Bool, NoError>
  public let saveButtonIsEnabled: Signal<Bool, NoError>
  public let showConfirmationEmailSentBanner: Signal<Bool, NoError>

  var inputs: ChangeEmailViewModelInputs {
    return self
  }

  var outputs: ChangeEmailViewModelOutputs {
    return self
  }
}
