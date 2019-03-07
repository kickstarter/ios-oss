import Foundation
import Prelude
import ReactiveSwift
import Result
import UIKit.UITextField

public protocol CreatePasswordViewModelInputs {
  func newPasswordTextFieldChanged(text: String?)
  func newPasswordTextFieldDidReturn()
  func newPasswordConfirmationTextFieldChanged(text: String?)
  func newPasswordConfirmationTextFieldDidReturn()
  func textFieldShouldBecomeFirstResponder(_ textField: UITextField?)
  func viewDidAppear()
}

public protocol CreatePasswordViewModelOutputs {
  var accessibilityFocusValidationLabel: Signal<Void, NoError> { get }
  var newPasswordTextFieldDidBecomeFirstResponder: Signal<Void, NoError> { get }
  var newPasswordConfirmationTextFieldDidBecomeFirstResponder: Signal<Void, NoError> { get }
  var newPasswordConfirmationTextFieldDidResignFirstResponder: Signal<Void, NoError> { get }
  var saveButtonIsEnabled: Signal<Bool, NoError> { get }
  var textFieldDidBecomeFirstResponder: Signal<UITextField, NoError> { get }
  var validationLabelIsHidden: Signal<Bool, NoError> { get }
  var validationLabelText: Signal<String?, NoError> { get }

  func currentValidationLabelText() -> String?
}

public protocol CreatePasswordViewModelType {
  var inputs: CreatePasswordViewModelInputs { get }
  var outputs: CreatePasswordViewModelOutputs { get }
}

public class CreatePasswordViewModel: CreatePasswordViewModelType,
CreatePasswordViewModelInputs, CreatePasswordViewModelOutputs {
  public init() {
    self.newPasswordTextFieldDidBecomeFirstResponder = self.viewDidAppearProperty.signal
    self.newPasswordConfirmationTextFieldDidBecomeFirstResponder = self.newPasswordDidReturnProperty.signal
    self.newPasswordConfirmationTextFieldDidResignFirstResponder =
      self.newPasswordConfirmationDidReturnProperty.signal

    let combinedPasswords = Signal.combineLatest(
      self.newPasswordChangedProperty.signal.skipNil(),
      self.newPasswordConfirmationChangedProperty.signal.skipNil()
    )

    let fieldsMatch = combinedPasswords.map(==)
    let fieldLengthIsValid = self.newPasswordChangedProperty.signal.skipNil().map(passwordLengthValid)

    self.validationLabelText = Signal.combineLatest(fieldsMatch, fieldLengthIsValid)
      .map(passwordValidationText)
      .skipRepeats()

    self.currentValidationLabelTextProperty <~ self.validationLabelText

    let fieldsNotEmpty = combinedPasswords.map(passwordFieldsNotEmpty)

    let formIsValid = Signal.combineLatest(fieldsNotEmpty, fieldsMatch, fieldLengthIsValid)
      .map(passwordFormValid)
      .skipRepeats()

    let inputsChanged = Signal.merge(
      self.newPasswordChangedProperty.signal, self.newPasswordConfirmationChangedProperty.signal
    )

    self.accessibilityFocusValidationLabel = formIsValid
      .takeWhen(inputsChanged)
      .filter { _ in AppEnvironment.current.isVoiceOverRunning() }
      .filter(isFalse)
      .ignoreValues()

    self.saveButtonIsEnabled = formIsValid
    self.textFieldDidBecomeFirstResponder = self.textFieldDidBecomeFirstResponderProperty.signal.skipNil()
    self.validationLabelIsHidden = formIsValid
  }

  private var newPasswordChangedProperty = MutableProperty<String?>(nil)
  public func newPasswordTextFieldChanged(text: String?) {
    self.newPasswordChangedProperty.value = text
  }

  private var newPasswordDidReturnProperty = MutableProperty(())
  public func newPasswordTextFieldDidReturn() {
    self.newPasswordDidReturnProperty.value = ()
  }

  private var newPasswordConfirmationChangedProperty = MutableProperty<String?>(nil)
  public func newPasswordConfirmationTextFieldChanged(text: String?) {
    self.newPasswordConfirmationChangedProperty.value = text
  }

  private var newPasswordConfirmationDidReturnProperty = MutableProperty(())
  public func newPasswordConfirmationTextFieldDidReturn() {
    self.newPasswordConfirmationDidReturnProperty.value = ()
  }

  private var textFieldDidBecomeFirstResponderProperty = MutableProperty<UITextField?>(nil)
  public func textFieldShouldBecomeFirstResponder(_ textField: UITextField?) {
    self.textFieldDidBecomeFirstResponderProperty.value = textField
  }

  public let accessibilityFocusValidationLabel: Signal<Void, NoError>
  public let newPasswordTextFieldDidBecomeFirstResponder: Signal<Void, NoError>
  public let newPasswordConfirmationTextFieldDidBecomeFirstResponder: Signal<Void, NoError>
  public let newPasswordConfirmationTextFieldDidResignFirstResponder: Signal<Void, NoError>
  public let saveButtonIsEnabled: Signal<Bool, NoError>
  public let textFieldDidBecomeFirstResponder: Signal<UITextField, NoError>
  public let validationLabelIsHidden: Signal<Bool, NoError>
  public let validationLabelText: Signal<String?, NoError>

  private let currentValidationLabelTextProperty = MutableProperty<String?>(nil)
  public func currentValidationLabelText() -> String? {
    return self.currentValidationLabelTextProperty.value
  }

  private let viewDidAppearProperty = MutableProperty(())
  public func viewDidAppear() {
    self.viewDidAppearProperty.value = ()
  }

  public var inputs: CreatePasswordViewModelInputs {
    return self
  }

  public var outputs: CreatePasswordViewModelOutputs {
    return self
  }
}

// MARK: - Functions

private func passwordFieldsNotEmpty(_ pwds: (first: String, second: String)) -> Bool {
  return !pwds.first.isEmpty && !pwds.second.isEmpty
}
