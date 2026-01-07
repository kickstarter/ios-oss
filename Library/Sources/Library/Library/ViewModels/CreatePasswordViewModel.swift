import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol CreatePasswordViewModelInputs {
  func cellAtIndexPathShouldBecomeFirstResponder(_ indexPath: IndexPath?)
  func newPasswordTextFieldChanged(text: String?)
  func newPasswordTextFieldDidReturn()
  func newPasswordConfirmationTextFieldChanged(text: String?)
  func newPasswordConfirmationTextFieldDidReturn()
  func saveButtonTapped()
  func viewDidAppear()
}

public protocol CreatePasswordViewModelOutputs {
  var accessibilityFocusValidationLabel: Signal<Void, Never> { get }
  var activityIndicatorShouldShow: Signal<Bool, Never> { get }
  var cellAtIndexPathDidBecomeFirstResponder: Signal<IndexPath, Never> { get }
  var createPasswordFailure: Signal<String, Never> { get }
  var createPasswordSuccess: Signal<Void, Never> { get }
  var dismissKeyboard: Signal<Void, Never> { get }
  var newPasswordTextFieldDidBecomeFirstResponder: Signal<Void, Never> { get }
  var newPasswordConfirmationTextFieldDidBecomeFirstResponder: Signal<Void, Never> { get }
  var newPasswordConfirmationTextFieldDidResignFirstResponder: Signal<Void, Never> { get }
  var saveButtonIsEnabled: Signal<Bool, Never> { get }
  var validationLabelIsHidden: Signal<Bool, Never> { get }
  var validationLabelText: Signal<String?, Never> { get }

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
    let fieldsNotEmpty = combinedPasswords.map(formFieldsNotEmpty)

    let formIsValid = Signal.combineLatest(fieldsNotEmpty, fieldsMatch, fieldLengthIsValid)
      .map(passwordFormValid)
      .skipRepeats()

    let newPasswordValidationText = fieldLengthIsValid
      .map(passwordValidationText)
      .skipRepeats()

    let newPasswordAndConfirmationValidationText = Signal.combineLatest(fieldLengthIsValid, fieldsMatch)
      .map(passwordValidationText)
      .skipRepeats()

    self.validationLabelText = Signal.merge(
      self.viewDidAppearProperty.signal.mapConst(nil),
      newPasswordValidationText,
      newPasswordAndConfirmationValidationText
    )

    self.currentValidationLabelTextProperty <~ self.validationLabelText

    let validationLabelTextIsNil = self.validationLabelText
      .map(isNil)

    let inputsChanged = Signal.merge(
      self.newPasswordChangedProperty.signal, self.newPasswordConfirmationChangedProperty.signal
    )

    self.accessibilityFocusValidationLabel = validationLabelTextIsNil
      .takeWhen(inputsChanged)
      .filter { _ in AppEnvironment.current.isVoiceOverRunning() }
      .filter(isFalse)
      .ignoreValues()

    self.saveButtonIsEnabled = formIsValid

    let submitFormEvent = Signal.merge(
      self.newPasswordConfirmationDidReturnProperty.signal,
      self.saveButtonTappedProperty.signal
    )

    let saveAction = formIsValid
      .takeWhen(submitFormEvent)
      .filter(isTrue)
      .ignoreValues()

    let createPasswordEvent = combinedPasswords
      .takeWhen(saveAction)
      .map { CreatePasswordInput(password: $0.0, passwordConfirmation: $0.1) }
      .switchMap { input in
        AppEnvironment.current.apiService.createPassword(input: input)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    self.createPasswordFailure = createPasswordEvent.errors().map { $0.localizedDescription }
    self.createPasswordSuccess = createPasswordEvent.values().ignoreValues()

    self.activityIndicatorShouldShow = Signal.merge(
      saveAction.signal.mapConst(true),
      self.createPasswordFailure.mapConst(false),
      self.createPasswordSuccess.mapConst(false)
    )

    self.dismissKeyboard = submitFormEvent

    self.cellAtIndexPathDidBecomeFirstResponder = Signal.combineLatest(
      self.viewDidAppearProperty.signal,
      self.cellAtIndexPathShouldBecomeFirstResponderProperty.signal.skipNil()
    ).map { $0.1 }

    self.validationLabelIsHidden = validationLabelTextIsNil
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

  private var saveButtonTappedProperty = MutableProperty(())
  public func saveButtonTapped() {
    self.saveButtonTappedProperty.value = ()
  }

  private var cellAtIndexPathShouldBecomeFirstResponderProperty = MutableProperty<IndexPath?>(nil)
  public func cellAtIndexPathShouldBecomeFirstResponder(_ indexPath: IndexPath?) {
    self.cellAtIndexPathShouldBecomeFirstResponderProperty.value = indexPath
  }

  public let accessibilityFocusValidationLabel: Signal<Void, Never>
  public let activityIndicatorShouldShow: Signal<Bool, Never>
  public let cellAtIndexPathDidBecomeFirstResponder: Signal<IndexPath, Never>
  public let createPasswordFailure: Signal<String, Never>
  public let createPasswordSuccess: Signal<Void, Never>
  public let dismissKeyboard: Signal<Void, Never>
  public let newPasswordTextFieldDidBecomeFirstResponder: Signal<Void, Never>
  public let newPasswordConfirmationTextFieldDidBecomeFirstResponder: Signal<Void, Never>
  public let newPasswordConfirmationTextFieldDidResignFirstResponder: Signal<Void, Never>
  public let saveButtonIsEnabled: Signal<Bool, Never>
  public let validationLabelIsHidden: Signal<Bool, Never>
  public let validationLabelText: Signal<String?, Never>

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

private func formFieldsNotEmpty(_ pwds: (first: String, second: String)) -> Bool {
  return !pwds.first.isEmpty && !pwds.second.isEmpty
}
