import Foundation
import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol ChangePasswordViewModelInputs {
  func currentPasswordFieldTextChanged(text: String)
  func currentPasswordFieldDidReturn(currentPassword: String)
  func newPasswordFieldTextChanged(text: String)
  func newPasswordFieldDidReturn(newPassword: String)
  func newPasswordConfirmationFieldTextChanged(text: String)
  func newPasswordConfirmationFieldDidReturn(newPasswordConfirmed: String)
  func onePasswordButtonTapped()
  func onePassword(isAvailable available: Bool)
  func onePasswordFoundPassword(password: String)
  func saveButtonTapped()
  func viewDidAppear()
}

public protocol ChangePasswordViewModelOutputs {
  var activityIndicatorShouldShow: Signal<Bool, NoError> { get }
  var changePasswordFailure: Signal<String, NoError> { get }
  var changePasswordSuccess: Signal<Void, NoError> { get }
  var confirmNewPasswordBecomeFirstResponder: Signal<Void, NoError> { get }
  var currentPasswordBecomeFirstResponder: Signal<Void, NoError> { get }
  var currentPasswordPrefillValue: Signal<String, NoError> { get }
  var dismissKeyboard: Signal<Void, NoError> { get }
  var newPasswordBecomeFirstResponder: Signal<Void, NoError> { get }
  var onePasswordButtonIsHidden: Signal<Bool, NoError> { get }
  var onePasswordFindPasswordForURLString: Signal<String, NoError> { get }
  var saveButtonIsEnabled: Signal<Bool, NoError> { get }
  var validationErrorLabelIsHidden: Signal<Bool, NoError> { get }
  var validationErrorLabelMessage: Signal<String, NoError> { get }
}

public protocol ChangePasswordViewModelType {
  var inputs: ChangePasswordViewModelInputs { get }
  var outputs: ChangePasswordViewModelOutputs { get }
}

public class ChangePasswordViewModel: ChangePasswordViewModelType,
ChangePasswordViewModelInputs, ChangePasswordViewModelOutputs {
  public init() {
    let combinedPasswords = Signal
      .combineLatest(newPasswordProperty.signal, confirmNewPasswordProperty.signal)
    let currentPasswordSignal: Signal<String, NoError> = Signal
      .merge(self.currentPasswordProperty.signal,
             self.onePasswordPrefillPasswordProperty.signal.skipNil())

    let fieldsNotEmpty = Signal
      .combineLatest(
        currentPasswordSignal,
        self.newPasswordProperty.signal,
        self.confirmNewPasswordProperty.signal)
      .map { valuesInFields in
        return !valuesInFields.0.isEmpty && !valuesInFields.1.isEmpty && !valuesInFields.2.isEmpty
    }

    let passwordsMatch: Signal<Bool, NoError> = combinedPasswords
      .map { (newPassword, confirmNewPassword) -> Bool in
        return newPassword == confirmNewPassword
    }

    let lengthMeetsReq: Signal<Bool, NoError> = self.newPasswordProperty.signal
      .map { newPassword -> Bool in
        return newPassword.count > 5
    }

    self.saveButtonIsEnabled = Signal
      .combineLatest(fieldsNotEmpty, passwordsMatch, lengthMeetsReq)
      .map { requirements in
        return requirements.0 && requirements.1 && requirements.2
    }.skipRepeats()

    let autoSaveSignal = self.saveButtonIsEnabled
      .takeWhen(self.confirmNewPasswordDoneEditingProperty.signal)
      .filter { isTrue($0) }
      .ignoreValues()

    let triggerSaveAction = Signal.merge(autoSaveSignal, self.saveButtonTappedProperty.signal)

    let combinedInput = Signal.combineLatest(currentPasswordSignal, combinedPasswords)

    let passwordUpdateEvent = combinedInput
      .takeWhen(triggerSaveAction)
      .map(unpack)
      .map { ChangePasswordInput(currentPassword: $0.0, newPassword: $0.1, newPasswordConfirmation: $0.2) }
      .flatMap {
        AppEnvironment.current.apiService.changePassword(input: $0)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
    }

    passwordUpdateEvent.values()
      .observeValues { _ in AppEnvironment.current.koala.trackChangePassword() }

    self.changePasswordSuccess = passwordUpdateEvent.values().ignoreValues()
    self.changePasswordFailure = passwordUpdateEvent.errors().map { $0.localizedDescription }

    self.activityIndicatorShouldShow = Signal.merge(
      triggerSaveAction.signal.mapConst(true),
      self.changePasswordSuccess.mapConst(false),
      self.changePasswordFailure.mapConst(false)
      )

    self.dismissKeyboard = triggerSaveAction

    self.currentPasswordBecomeFirstResponder = self.viewDidAppearProperty.signal
    self.newPasswordBecomeFirstResponder = self.currentPasswordDoneEditingProperty.signal
    self.onePasswordButtonIsHidden = self.onePasswordIsAvailableProperty.signal.map(negate)
      .map(is1PasswordButtonHidden)
    self.confirmNewPasswordBecomeFirstResponder = self.newPasswordDoneEditingProperty.signal
    self.currentPasswordPrefillValue = self.onePasswordPrefillPasswordProperty.signal.skipNil()
    self.onePasswordFindPasswordForURLString = self.onePasswordButtonTappedProperty.signal
      .map { AppEnvironment.current.apiService.serverConfig.webBaseUrl.absoluteString }

    self.validationErrorLabelIsHidden = Signal.combineLatest(passwordsMatch, lengthMeetsReq)
      .map { $0.0 && $0.1 }
      .skipRepeats()

    self.validationErrorLabelMessage = Signal.combineLatest(passwordsMatch, lengthMeetsReq)
      .map { requirements -> String? in
        if !requirements.1 {
          return Strings.Password_min_length_message()
        } else if !requirements.0 {
          return Strings.Passwords_matching_message()
        } else {
          return nil
        }
    }.skipNil()
    .skipRepeats()

    self.viewDidAppearProperty.signal
      .observeValues { _ in AppEnvironment.current.koala.trackChangePasswordView() }
  }

  private var currentPasswordDoneEditingProperty = MutableProperty(())
  public func currentPasswordFieldDidReturn(currentPassword: String) {
    self.currentPasswordProperty.value = currentPassword
    self.currentPasswordDoneEditingProperty.value = ()
  }

  private var currentPasswordProperty = MutableProperty<String>("")
  public func currentPasswordFieldTextChanged(text: String) {
    self.currentPasswordProperty.value = text
  }

  private var newPasswordDoneEditingProperty = MutableProperty(())
  public func newPasswordFieldDidReturn(newPassword: String) {
    self.newPasswordProperty.value = newPassword
    self.newPasswordDoneEditingProperty.value = ()
  }

  private var newPasswordProperty = MutableProperty<String>("")
  public func newPasswordFieldTextChanged(text: String) {
    self.newPasswordProperty.value = text
  }

  private var confirmNewPasswordDoneEditingProperty = MutableProperty(())
  public func newPasswordConfirmationFieldDidReturn(newPasswordConfirmed: String) {
    self.confirmNewPasswordProperty.value = newPasswordConfirmed
    self.confirmNewPasswordDoneEditingProperty.value = ()
  }

  private var confirmNewPasswordProperty = MutableProperty<String>("")
  public func newPasswordConfirmationFieldTextChanged(text: String) {
    self.confirmNewPasswordProperty.value = text
  }

  private var saveButtonTappedProperty = MutableProperty(())
  public func saveButtonTapped() {
    self.saveButtonTappedProperty.value = ()
  }

  private var onePasswordIsAvailableProperty = MutableProperty(true)
  public func onePassword(isAvailable available: Bool) {
    self.onePasswordIsAvailableProperty.value = available
  }

  private var onePasswordButtonTappedProperty = MutableProperty(())
  public func onePasswordButtonTapped() {
    self.onePasswordButtonTappedProperty.value = ()
  }

  private var onePasswordPrefillPasswordProperty = MutableProperty<String?>(nil)
  public func onePasswordFoundPassword(password: String) {
    self.onePasswordPrefillPasswordProperty.value = password
  }

  private var viewDidAppearProperty = MutableProperty(())
  public func viewDidAppear() {
    self.viewDidAppearProperty.value = ()
  }

  public let activityIndicatorShouldShow: Signal<Bool, NoError>
  public let changePasswordFailure: Signal<String, NoError>
  public let changePasswordSuccess: Signal<Void, NoError>
  public let confirmNewPasswordBecomeFirstResponder: Signal<Void, NoError>
  public let currentPasswordBecomeFirstResponder: Signal<Void, NoError>
  public let currentPasswordPrefillValue: Signal<String, NoError>
  public let dismissKeyboard: Signal<Void, NoError>
  public let validationErrorLabelIsHidden: Signal<Bool, NoError>
  public let validationErrorLabelMessage: Signal<String, NoError>
  public let newPasswordBecomeFirstResponder: Signal<Void, NoError>
  public let onePasswordButtonIsHidden: Signal<Bool, NoError>
  public let onePasswordFindPasswordForURLString: Signal<String, NoError>
  public let saveButtonIsEnabled: Signal<Bool, NoError>

  public var inputs: ChangePasswordViewModelInputs {
    return self
  }

  public var outputs: ChangePasswordViewModelOutputs {
    return self
  }
}
