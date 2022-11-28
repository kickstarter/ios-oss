import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol SetYourPasswordViewModelInputs {
  func viewDidLoad()
  func viewWillAppear()
  func newPasswordFieldDidChange(_ text: String)
  func confirmPasswordFieldDidChange(_ text: String)
  func newPasswordFieldDidReturn(newPassword: String)
  func confirmPasswordFieldDidReturn(confirmPassword: String)
  func saveButtonPressed()
}

public protocol SetYourPasswordViewModelOutputs {
  var shouldShowActivityIndicator: Signal<Bool, Never> { get }
  var saveButtonIsEnabled: Signal<Bool, Never> { get }
  var contextLabelText: Signal<String, Never> { get }
  var newPasswordLabel: Signal<String, Never> { get }
  var confirmPasswordLabel: Signal<String, Never> { get }
  var setPasswordFailure: Signal<String, Never> { get }
  var setPasswordSuccess: Signal<Void, Never> { get }
  var textFieldsAndSaveButtonAreEnabled: Signal<Bool, Never> { get }
}

public protocol SetYourPasswordViewModelType {
  var inputs: SetYourPasswordViewModelInputs { get }
  var outputs: SetYourPasswordViewModelOutputs { get }
}

public final class SetYourPasswordViewModel: SetYourPasswordViewModelType, SetYourPasswordViewModelInputs,
  SetYourPasswordViewModelOutputs {
  public init() {
    let fetchUserEmailEvent = self.viewDidLoadProperty.signal
      .switchMap { _ in
        AppEnvironment.current
          .apiService
          .fetchGraphUser(withStoredCards: false)
          .materialize()
      }

    self.contextLabelText = Signal.combineLatest(
      self.viewWillAppearProperty.signal,
      fetchUserEmailEvent.values()
    )
    .map { _, userEnvelope in
      Strings
        .We_will_be_discontinuing_the_ability_to_log_in_via_Facebook(email: userEnvelope.me.email ?? "")
    }

    self.newPasswordLabel = self.viewWillAppearProperty.signal
      .map { Strings.New_password() }
    self.confirmPasswordLabel = self.viewWillAppearProperty.signal
      .map { Strings.Confirm_password() }

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

    let submitFormEvent = self.saveButtonPressedProperty.signal

    let saveAction = formIsValid
      .takeWhen(submitFormEvent)
      .filter(isTrue)
      .ignoreValues()

    let setPasswordEvent = combinedPasswords
      .takeWhen(saveAction)
      .map { CreatePasswordInput(password: $0.0, passwordConfirmation: $0.1) }
      .switchMap { input in
        AppEnvironment.current.apiService.createPassword(input: input)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    self.setPasswordFailure = setPasswordEvent.errors().map { $0.localizedDescription }
    self.setPasswordSuccess = setPasswordEvent.values().ignoreValues()

    self.shouldShowActivityIndicator = Signal.merge(
      saveAction.signal.ignoreValues().mapConst(true),
      setPasswordEvent.filter { $0.isTerminating }.mapConst(false)
    )

    self.textFieldsAndSaveButtonAreEnabled = self.shouldShowActivityIndicator.map { $0 }.negate()
  }

  public var inputs: SetYourPasswordViewModelInputs { return self }
  public var outputs: SetYourPasswordViewModelOutputs { return self }

  // MARK: - Input Methods

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
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
  public func newPasswordFieldDidReturn(newPassword _: String) {
    self.newPasswordDoneEditingProperty.value = ()
  }

  private let confirmPasswordDoneEditingProperty = MutableProperty(())
  public func confirmPasswordFieldDidReturn(confirmPassword _: String) {
    self.confirmPasswordDoneEditingProperty.value = ()
  }

  private let saveButtonPressedProperty = MutableProperty(())
  public func saveButtonPressed() {
    self.saveButtonPressedProperty.value = ()
  }

  // MARK: - Output Properties

  public var shouldShowActivityIndicator: Signal<Bool, Never>
  public var saveButtonIsEnabled: Signal<Bool, Never>
  public var contextLabelText: Signal<String, Never>
  public var newPasswordLabel: Signal<String, Never>
  public var confirmPasswordLabel: Signal<String, Never>
  public var setPasswordFailure: Signal<String, Never>
  public var setPasswordSuccess: Signal<Void, Never>
  public var textFieldsAndSaveButtonAreEnabled: Signal<Bool, Never>
}

// MARK: - Helpers

private func formFieldsNotEmpty(_ pwds: (first: String, second: String, third: String)) -> Bool {
  return !pwds.first.isEmpty && !pwds.second.isEmpty && !pwds.third.isEmpty
}
