import Result

@testable import Library
@testable import ReactiveExtensions_TestHelpers

final class CreatePasswordViewModelTests: TestCase {
  private let vm: CreatePasswordViewModelType = CreatePasswordViewModel()

  private let accessibilityFocusValidationLabel = TestObserver<Void, NoError>()
  private let newPasswordTextFieldBecomeFirstResponder = TestObserver<Void, NoError>()
  private let newPasswordConfirmationTextFieldBecomeFirstResponder = TestObserver<Void, NoError>()
  private let newPasswordConfirmationTextFieldResignFirstResponder = TestObserver<Void, NoError>()
  private let validationLabelIsHidden = TestObserver<Bool, NoError>()
  private let validationLabelText = TestObserver<String?, NoError>()
  private let saveButtonIsEnabled = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.accessibilityFocusValidationLabel.observe(accessibilityFocusValidationLabel.observer)
    self.vm.outputs.newPasswordTextFieldDidBecomeFirstResponder.observe(
      self.newPasswordTextFieldBecomeFirstResponder.observer
    )
    self.vm.outputs.newPasswordConfirmationTextFieldDidBecomeFirstResponder.observe(
      self.newPasswordConfirmationTextFieldBecomeFirstResponder.observer
    )
    self.vm.outputs.newPasswordConfirmationTextFieldDidResignFirstResponder.observe(
      self.newPasswordConfirmationTextFieldResignFirstResponder.observer
    )
    self.vm.outputs.validationLabelIsHidden.observe(self.validationLabelIsHidden.observer)
    self.vm.outputs.validationLabelText.observe(self.validationLabelText.observer)
    self.vm.outputs.saveButtonIsEnabled.observe(self.saveButtonIsEnabled.observer)
  }

  func testCreatePassword() {
    self.vm.inputs.viewDidAppear()
    self.newPasswordTextFieldBecomeFirstResponder.assertValueCount(1)

    self.vm.inputs.newPasswordTextFieldChanged(text: "password")
    self.vm.inputs.newPasswordTextFieldDidReturn()
    self.newPasswordConfirmationTextFieldBecomeFirstResponder.assertValueCount(1)

    self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password")
    self.validationLabelIsHidden.assertValues([true])
    self.validationLabelText.assertValues([nil])
    self.saveButtonIsEnabled.assertValues([true])

    self.vm.inputs.newPasswordConfirmationTextFieldDidReturn()
    self.newPasswordConfirmationTextFieldResignFirstResponder.assertValueCount(1)
  }

  func testValidationErrorsWithVoiceOverOn() {
    let isVoiceOverRunning = { true }

    withEnvironment(isVoiceOverRunning: isVoiceOverRunning) {
      self.vm.inputs.newPasswordTextFieldChanged(text: "pass")
      self.vm.inputs.newPasswordTextFieldDidReturn()
      self.newPasswordConfirmationTextFieldBecomeFirstResponder.assertValueCount(1)

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "p")
      self.accessibilityFocusValidationLabel.assertValueCount(1)
      self.saveButtonIsEnabled.assertValues([false])
      self.validationLabelIsHidden.assertValues([false])
      self.validationLabelText.assertLastValue("Your password must be at least 6 characters long.")

      self.vm.inputs.newPasswordTextFieldChanged(text: "password")
      self.vm.inputs.newPasswordTextFieldDidReturn()
      self.accessibilityFocusValidationLabel.assertValueCount(2)
      self.newPasswordConfirmationTextFieldBecomeFirstResponder.assertValueCount(2)

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "pass")
      self.accessibilityFocusValidationLabel.assertValueCount(3)
      self.saveButtonIsEnabled.assertValues([false])
      self.validationLabelIsHidden.assertValues([false])
      self.validationLabelText.assertLastValue("New passwords must match.")

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password")
      self.accessibilityFocusValidationLabel.assertValueCount(3)
      self.saveButtonIsEnabled.assertValues([false, true])
      self.validationLabelIsHidden.assertValues([false, true])
      self.validationLabelText.assertLastValue(nil)

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password123")
      self.accessibilityFocusValidationLabel.assertValueCount(4)
      self.saveButtonIsEnabled.assertValues([false, true, false])
      self.validationLabelIsHidden.assertValues([false, true, false])
      self.validationLabelText.assertLastValue("New passwords must match.")

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password")
      self.accessibilityFocusValidationLabel.assertValueCount(4)
      self.saveButtonIsEnabled.assertValues([false, true, false, true])
      self.validationLabelIsHidden.assertValues([false, true, false, true])
      self.validationLabelText.assertLastValue(nil)
    }
  }

  func testValidationErrorsWithVoiceOverOff() {
    let isVoiceOverRunning = { false }

    withEnvironment(isVoiceOverRunning: isVoiceOverRunning) {
      self.vm.inputs.newPasswordTextFieldChanged(text: "pass")
      self.vm.inputs.newPasswordTextFieldDidReturn()
      self.newPasswordConfirmationTextFieldBecomeFirstResponder.assertValueCount(1)

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "p")
      self.accessibilityFocusValidationLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false])
      self.validationLabelIsHidden.assertValues([false])
      self.validationLabelText.assertLastValue("Your password must be at least 6 characters long.")

      self.vm.inputs.newPasswordTextFieldChanged(text: "password")
      self.vm.inputs.newPasswordTextFieldDidReturn()
      self.accessibilityFocusValidationLabel.assertValueCount(0)
      self.newPasswordConfirmationTextFieldBecomeFirstResponder.assertValueCount(2)

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "pass")
      self.accessibilityFocusValidationLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false])
      self.validationLabelIsHidden.assertValues([false])
      self.validationLabelText.assertLastValue("New passwords must match.")

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password")
      self.accessibilityFocusValidationLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false, true])
      self.validationLabelIsHidden.assertValues([false, true])
      self.validationLabelText.assertLastValue(nil)

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password123")
      self.accessibilityFocusValidationLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false, true, false])
      self.validationLabelIsHidden.assertValues([false, true, false])
      self.validationLabelText.assertLastValue("New passwords must match.")

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password")
      self.accessibilityFocusValidationLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false, true, false, true])
      self.validationLabelIsHidden.assertValues([false, true, false, true])
      self.validationLabelText.assertLastValue(nil)
    }
  }
}
