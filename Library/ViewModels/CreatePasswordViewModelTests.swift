import Foundation
import Result

@testable import Library
@testable import ReactiveExtensions_TestHelpers

final class CreatePasswordViewModelTests: TestCase {
  private let vm: CreatePasswordViewModelType = CreatePasswordViewModel()

  private let accessibilityFocusValidationLabel = TestObserver<Void, NoError>()
  private let cellAtIndexPathDidBecomeFirstResponder = TestObserver<IndexPath, NoError>()
  private let newPasswordTextFieldBecomeFirstResponder = TestObserver<Void, NoError>()
  private let newPasswordConfirmationTextFieldBecomeFirstResponder = TestObserver<Void, NoError>()
  private let newPasswordConfirmationTextFieldResignFirstResponder = TestObserver<Void, NoError>()
  private let saveButtonIsEnabled = TestObserver<Bool, NoError>()
  private let validationLabelIsHidden = TestObserver<Bool, NoError>()
  private let validationLabelText = TestObserver<String?, NoError>()

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
    self.vm.outputs.saveButtonIsEnabled.observe(self.saveButtonIsEnabled.observer)

    self.vm.outputs.cellAtIndexPathDidBecomeFirstResponder.observe(
      self.cellAtIndexPathDidBecomeFirstResponder.observer
    )
    self.vm.outputs.validationLabelIsHidden.observe(self.validationLabelIsHidden.observer)
    self.vm.outputs.validationLabelText.observe(self.validationLabelText.observer)
  }

  func testCreatePassword() {
    self.vm.inputs.viewDidAppear()

    self.newPasswordTextFieldBecomeFirstResponder.assertValueCount(1)

    self.vm.inputs.newPasswordTextFieldChanged(text: "password")
    self.vm.inputs.newPasswordTextFieldDidReturn()
    self.newPasswordConfirmationTextFieldBecomeFirstResponder.assertValueCount(1)

    self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password")
    self.saveButtonIsEnabled.assertValues([true])

    self.vm.inputs.newPasswordConfirmationTextFieldDidReturn()
    self.newPasswordConfirmationTextFieldResignFirstResponder.assertValueCount(1)
  }

  func testTextFieldShouldBecomeFirstResponder() {
    self.vm.inputs.viewDidAppear()

    self.vm.inputs.cellAtIndexPathShouldBecomeFirstResponder(nil)
    self.cellAtIndexPathDidBecomeFirstResponder.assertValueCount(0)

    let indexPath = IndexPath(row: 0, section: 0)
    self.vm.inputs.cellAtIndexPathShouldBecomeFirstResponder(indexPath)
    self.cellAtIndexPathDidBecomeFirstResponder.assertValues([indexPath])
  }

  func testValidationErrorsWithVoiceOverOn() {
    let isVoiceOverRunning = { true }

    withEnvironment(isVoiceOverRunning: isVoiceOverRunning) {
      self.vm.inputs.viewDidAppear()
      self.validationLabelIsHidden.assertValues([true])
      self.validationLabelText.assertLastValue(nil)

      self.vm.inputs.newPasswordTextFieldChanged(text: "pass")
      self.vm.inputs.newPasswordTextFieldDidReturn()
      self.accessibilityFocusValidationLabel.assertValueCount(1)
      self.saveButtonIsEnabled.assertValueCount(0)
      self.validationLabelIsHidden.assertLastValue(false)
      self.validationLabelText.assertLastValue("Your password must be at least 6 characters long.")

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "p")
      self.accessibilityFocusValidationLabel.assertValueCount(2)
      self.saveButtonIsEnabled.assertValues([false])
      self.validationLabelIsHidden.assertLastValue(false)
      self.validationLabelText.assertLastValue("Your password must be at least 6 characters long.")

      self.vm.inputs.newPasswordTextFieldChanged(text: "password")
      self.vm.inputs.newPasswordTextFieldDidReturn()
      self.accessibilityFocusValidationLabel.assertValueCount(3)
      self.saveButtonIsEnabled.assertValues([false])
      self.validationLabelIsHidden.assertLastValue(false)
      self.validationLabelText.assertLastValue("New passwords must match.")

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "pass")
      self.accessibilityFocusValidationLabel.assertValueCount(4)
      self.saveButtonIsEnabled.assertValues([false])
      self.validationLabelIsHidden.assertLastValue(false)
      self.validationLabelText.assertLastValue("New passwords must match.")

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password")
      self.accessibilityFocusValidationLabel.assertValueCount(4)
      self.saveButtonIsEnabled.assertValues([false, true])
      self.validationLabelIsHidden.assertLastValue(true)
      self.validationLabelText.assertLastValue(nil)

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password123")
      self.accessibilityFocusValidationLabel.assertValueCount(5)
      self.saveButtonIsEnabled.assertValues([false, true, false])
      self.validationLabelIsHidden.assertLastValue(false)
      self.validationLabelText.assertLastValue("New passwords must match.")

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password")
      self.accessibilityFocusValidationLabel.assertValueCount(5)
      self.saveButtonIsEnabled.assertValues([false, true, false, true])
      self.validationLabelIsHidden.assertLastValue(true)
      self.validationLabelText.assertLastValue(nil)
    }
  }

  func testValidationErrorsWithVoiceOverOff() {
    let isVoiceOverRunning = { false }

    withEnvironment(isVoiceOverRunning: isVoiceOverRunning) {
      self.vm.inputs.viewDidAppear()
      self.validationLabelIsHidden.assertValues([true])
      self.validationLabelText.assertLastValue(nil)

      self.vm.inputs.newPasswordTextFieldChanged(text: "pass")
      self.vm.inputs.newPasswordTextFieldDidReturn()
      self.accessibilityFocusValidationLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValueCount(0)
      self.validationLabelIsHidden.assertLastValue(false)
      self.validationLabelText.assertLastValue("Your password must be at least 6 characters long.")

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "p")
      self.accessibilityFocusValidationLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false])
      self.validationLabelIsHidden.assertLastValue(false)
      self.validationLabelText.assertLastValue("Your password must be at least 6 characters long.")

      self.vm.inputs.newPasswordTextFieldChanged(text: "password")
      self.vm.inputs.newPasswordTextFieldDidReturn()
      self.accessibilityFocusValidationLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false])
      self.validationLabelIsHidden.assertLastValue(false)
      self.validationLabelText.assertLastValue("New passwords must match.")

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "pass")
      self.accessibilityFocusValidationLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false])
      self.validationLabelIsHidden.assertLastValue(false)
      self.validationLabelText.assertLastValue("New passwords must match.")

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password")
      self.accessibilityFocusValidationLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false, true])
      self.validationLabelIsHidden.assertLastValue(true)
      self.validationLabelText.assertLastValue(nil)

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password123")
      self.accessibilityFocusValidationLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false, true, false])
      self.validationLabelIsHidden.assertLastValue(false)
      self.validationLabelText.assertLastValue("New passwords must match.")

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password")
      self.accessibilityFocusValidationLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false, true, false, true])
      self.validationLabelIsHidden.assertLastValue(true)
      self.validationLabelText.assertLastValue(nil)
    }
  }
}
