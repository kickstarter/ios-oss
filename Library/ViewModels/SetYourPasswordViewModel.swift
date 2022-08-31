import Foundation
import KsApi
import ReactiveSwift

public protocol SetYourPasswordViewModelInputs {
  func viewDidLoad()
  func configureWith(_ userEmail: String)
  func newPasswordFieldDidChange(_ text: String)
  func confirmPasswordFieldDidChange(_ text: String)
  func newPasswordFieldDidReturn(newPassword: String)
  func confirmPasswordFieldDidReturn(confirmPassword: String)
  func saveButtonPressed()
}

public protocol SetYourPasswordViewModelOutputs {
  var saveButtonIsEnabled: Signal<Bool, Never> { get }
  var contextLabelText: Signal<String, Never> { get }
  var newPasswordLabel: Signal<String, Never> { get }
  var confirmPasswordLabel: Signal<String, Never> { get }
}

public protocol SetYourPasswordViewModelType {
  var inputs: SetYourPasswordViewModelInputs { get }
  var outputs: SetYourPasswordViewModelOutputs { get }
}

public final class SetYourPasswordViewModel: SetYourPasswordViewModelType, SetYourPasswordViewModelInputs,
  SetYourPasswordViewModelOutputs {
  public init() {
    self.contextLabelText = self.contextLabelProperty.signal
      .takeWhen(self.viewDidLoadProperty.signal)
    self.newPasswordLabel = self.newPasswordLabelProperty.signal
      .takeWhen(self.viewDidLoadProperty.signal)
    self.confirmPasswordLabel = self.confirmPasswordLabelProperty.signal
      .takeWhen(self.viewDidLoadProperty.signal)

    // MARK: Field Validations

    let combinedPasswords = Signal.combineLatest(
      self.newPasswordProperty.signal,
      self.confirmPasswordProperty.signal
    )

    let fieldsMatch = combinedPasswords.map(==)
    let fieldLengthIsValid = self.newPasswordProperty.signal.map(passwordLengthValid)

    let formIsValid = Signal.combineLatest(fieldsMatch, fieldLengthIsValid)
      .map { fieldsMatch, fieldLengthIsValid in fieldsMatch && fieldLengthIsValid }
      .skipRepeats()

    self.saveButtonIsEnabled = formIsValid
  }

  public var inputs: SetYourPasswordViewModelInputs { return self }
  public var outputs: SetYourPasswordViewModelOutputs { return self }

  // MARK: - Input Methods

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let contextLabelProperty = MutableProperty("")
  private let newPasswordLabelProperty = MutableProperty("")
  private let confirmPasswordLabelProperty = MutableProperty("")
  public func configureWith(_ userEmail: String) {
    self.contextLabelProperty
      .value =
      "We will be discontinuing the ability to log in via Facebook. To log in to your account using the email \(userEmail), please set a password that’s at least 6 characters long."
    self.newPasswordLabelProperty.value = "Enter new password"
    self.confirmPasswordLabelProperty.value = "Re-enter new password"
  }

  private let newPasswordProperty = MutableProperty<String>("")
  public func newPasswordFieldDidChange(_ text: String) {
    self.newPasswordProperty.value = text
  }

  private let confirmPasswordProperty = MutableProperty<String>("")
  public func confirmPasswordFieldDidChange(_ text: String) {
    self.confirmPasswordProperty.value = text
  }

  private var newPasswordDoneEditingProperty = MutableProperty(())
  public func newPasswordFieldDidReturn(newPassword: String) {
    self.newPasswordLabelProperty.value = newPassword
    self.newPasswordDoneEditingProperty.value = ()
  }

  private let confirmPasswordDoneEditingProperty = MutableProperty(())
  public func confirmPasswordFieldDidReturn(confirmPassword: String) {
    self.confirmPasswordLabelProperty.value = confirmPassword
    self.confirmPasswordDoneEditingProperty.value = ()
  }

  private var saveButtonTappedProperty = MutableProperty(())
  public func saveButtonTapped() {
    self.saveButtonTappedProperty.value = ()
  }

  private let saveButtonPressedProperty = MutableProperty(())
  public func saveButtonPressed() {
    self.saveButtonPressedProperty.value = ()
  }

  // MARK: - Output Properties

  public var saveButtonIsEnabled: Signal<Bool, Never>
  public var contextLabelText: Signal<String, Never>
  public var newPasswordLabel: Signal<String, Never>
  public var confirmPasswordLabel: Signal<String, Never>
}

// MARK: - Helpers

private func formFieldsNotEmpty(_ pwds: (first: String, second: String, third: String)) -> Bool {
  return !pwds.first.isEmpty && !pwds.second.isEmpty && !pwds.third.isEmpty
}
