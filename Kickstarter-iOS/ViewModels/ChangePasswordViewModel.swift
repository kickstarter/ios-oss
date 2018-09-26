import Foundation
import Library
import Prelude
import ReactiveSwift
import Result

protocol ChangePasswordViewModelOutputs {
  /* Test */
  var testPasswordInput: Signal<(String, String, String), NoError> { get }

  var activityIndicatorShouldShow: Signal<Bool, NoError> { get }
  var confirmNewPasswordBecomeFirstResponder: Signal<Void, NoError> { get }
  var currentPasswordBecomeFirstResponder: Signal<Void, NoError> { get }
  var dismissKeyboard: Signal<Void, NoError> { get }
  var errorLabelIsHidden: Signal<Bool, NoError> { get }
  var messageControllerIsHidden: Signal<Bool, NoError> { get }
  var newPasswordBecomeFirstResponder: Signal<Void, NoError> { get }
  var saveButtonIsEnabled: Signal<Bool, NoError> { get }
}

protocol ChangePasswordViewModelInputs {
  func currentPasswordFieldTextChanged(text: String)
  func currentPasswordFieldDidEndEditing(currentPassword: String)
  func fieldDidBeginEditing()
  func newPasswordFieldTextChanged(text: String)
  func newPasswordFieldDidEndEditing(newPassword: String)
  func newPasswordConfirmationFieldTextChanged(text: String)
  func newPasswordConfirmationFieldDidEndEditing(newPasswordConfirmed: String)
  func saveButtonTapped()
  func viewDidAppear()
}

protocol ChangePasswordViewModelType {
  var inputs: ChangePasswordViewModelInputs { get }
  var outputs: ChangePasswordViewModelOutputs { get }
}

struct ChangePasswordViewModel: ChangePasswordViewModelType, ChangePasswordViewModelInputs, ChangePasswordViewModelOutputs {
  public init() {
    self.saveButtonIsEnabled = fieldDidBeginEditingProperty.signal.mapConst(true)

    let zippedPasswords = Signal.combineLatest(newPasswordProperty.signal, confirmNewPasswordProperty.signal)

    let passwordsMatch: Signal<Bool, NoError> = zippedPasswords
      .takeWhen(self.saveButtonTappedProperty.signal)
      .map { (newPassword, confirmNewPassword) -> Bool in
        return newPassword == confirmNewPassword
    }

    let lengthMeetsReq: Signal<Bool, NoError> = zippedPasswords
      .takeWhen(self.saveButtonTappedProperty.signal)
      .map { (newPassword, confirmNewPassword) -> Bool in
        return newPassword.count > 6 && confirmNewPassword.count > 6
    }

    let combinedInput = Signal.combineLatest(currentPasswordProperty.signal, zippedPasswords)

    self.testPasswordInput = combinedInput
      .takeWhen(self.saveButtonTappedProperty.signal)
      .map(unpack)

    self.activityIndicatorShouldShow = saveButtonTappedProperty.signal.mapConst(true)
    self.errorLabelIsHidden = Signal.merge(passwordsMatch, lengthMeetsReq)
    self.dismissKeyboard = Signal.merge(
      self.saveButtonTappedProperty.signal,
      self.confirmNewPasswordDoneEditingProperty.signal)

    self.messageControllerIsHidden = MutableProperty(true).signal

    self.currentPasswordBecomeFirstResponder = self.viewDidAppearProperty.signal
    self.newPasswordBecomeFirstResponder = self.currentPasswordDoneEditingProperty.signal
    self.confirmNewPasswordBecomeFirstResponder = self.newPasswordDoneEditingProperty.signal
  }

  private var currentPasswordDoneEditingProperty = MutableProperty(())
  func currentPasswordFieldDidEndEditing(currentPassword: String) {
    self.currentPasswordProperty.value = currentPassword
    self.currentPasswordDoneEditingProperty.value = ()
  }

  private var currentPasswordProperty = MutableProperty<String>("")
  func currentPasswordFieldTextChanged(text: String) {
    self.currentPasswordProperty.value = text
  }

  private var fieldDidBeginEditingProperty = MutableProperty(())
  func fieldDidBeginEditing() {
    self.fieldDidBeginEditingProperty.value = ()
  }

  private var newPasswordDoneEditingProperty = MutableProperty(())
  func newPasswordFieldDidEndEditing(newPassword: String) {
    self.newPasswordProperty.value = newPassword
    self.newPasswordDoneEditingProperty.value = ()
  }

  private var newPasswordProperty = MutableProperty<String>("")
  func newPasswordFieldTextChanged(text: String) {
    self.newPasswordProperty.value = text
  }

  private var confirmNewPasswordDoneEditingProperty = MutableProperty(())
  func newPasswordConfirmationFieldDidEndEditing(newPasswordConfirmed: String) {
    self.confirmNewPasswordProperty.value = newPasswordConfirmed
    self.confirmNewPasswordDoneEditingProperty.value = ()
  }

  private var confirmNewPasswordProperty = MutableProperty<String>("")
  func newPasswordConfirmationFieldTextChanged(text: String) {
    self.confirmNewPasswordProperty.value = text
  }

  private var saveButtonTappedProperty = MutableProperty(())
  func saveButtonTapped() {
    self.saveButtonTappedProperty.value = ()
  }

  private var viewDidAppearProperty = MutableProperty(())
  func viewDidAppear() {
    self.viewDidAppearProperty.value = ()
  }

  public let activityIndicatorShouldShow: Signal<Bool, NoError>
  public let confirmNewPasswordBecomeFirstResponder: Signal<Void, NoError>
  public let currentPasswordBecomeFirstResponder: Signal<Void, NoError>
  public let dismissKeyboard: Signal<Void, NoError>
  public let errorLabelIsHidden: Signal<Bool, NoError>
  public let messageControllerIsHidden: Signal<Bool, NoError>
  public let newPasswordBecomeFirstResponder: Signal<Void, NoError>
  public let saveButtonIsEnabled: Signal<Bool, NoError>

  public let testPasswordInput: Signal<(String, String, String), NoError>

  var inputs: ChangePasswordViewModelInputs {
    return self
  }

  var outputs: ChangePasswordViewModelOutputs {
    return self
  }
}
