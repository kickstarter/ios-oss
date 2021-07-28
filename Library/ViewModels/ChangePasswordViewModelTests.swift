import Foundation
import Prelude
import XCTest

@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers

final class ChangePasswordViewModelTests: TestCase {
  private let vm: ChangePasswordViewModelType = ChangePasswordViewModel()

  private let accessibilityFocusValidationErrorLabel = TestObserver<Void, Never>()
  private let activityIndicatorShouldShow = TestObserver<Bool, Never>()
  private let changePasswordFailure = TestObserver<String, Never>()
  private let changePasswordSuccess = TestObserver<Void, Never>()
  private let confirmNewPasswordBecomeFirstResponder = TestObserver<Void, Never>()
  private let currentPasswordBecomeFirstResponder = TestObserver<Void, Never>()
  private let dismissKeyboard = TestObserver<Void, Never>()
  private let newPasswordBecomeFirstResponder = TestObserver<Void, Never>()
  private let saveButtonIsEnabled = TestObserver<Bool, Never>()
  private let validationErrorLabelIsHidden = TestObserver<Bool, Never>()
  private let validationErrorLabelMessage = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.accessibilityFocusValidationErrorLabel
      .observe(self.accessibilityFocusValidationErrorLabel.observer)
    self.vm.outputs.activityIndicatorShouldShow.observe(self.activityIndicatorShouldShow.observer)
    self.vm.outputs.changePasswordFailure.observe(self.changePasswordFailure.observer)
    self.vm.outputs.changePasswordSuccess.observe(self.changePasswordSuccess.observer)
    self.vm.outputs.confirmNewPasswordBecomeFirstResponder
      .observe(self.confirmNewPasswordBecomeFirstResponder.observer)
    self.vm.outputs.currentPasswordBecomeFirstResponder
      .observe(self.currentPasswordBecomeFirstResponder.observer)
    self.vm.outputs.dismissKeyboard.observe(self.dismissKeyboard.observer)
    self.vm.outputs.newPasswordBecomeFirstResponder.observe(self.newPasswordBecomeFirstResponder.observer)
    self.vm.outputs.saveButtonIsEnabled.observe(self.saveButtonIsEnabled.observer)
    self.vm.outputs.validationErrorLabelIsHidden.observe(self.validationErrorLabelIsHidden.observer)
    self.vm.outputs.validationErrorLabelMessage.observe(self.validationErrorLabelMessage.observer)
  }

  func testChangePassword() {
    let service = MockService(changePasswordResult: .success(EmptyResponseEnvelope()))

    withEnvironment(apiService: service) {
      self.vm.inputs.viewDidAppear()

      self.currentPasswordBecomeFirstResponder.assertValueCount(1)

      self.vm.inputs.currentPasswordFieldDidReturn(currentPassword: "password")
      self.newPasswordBecomeFirstResponder.assertValueCount(1)

      self.vm.inputs.newPasswordFieldDidReturn(newPassword: "123456")
      self.confirmNewPasswordBecomeFirstResponder.assertValueCount(1)

      self.vm.inputs.newPasswordConfirmationFieldDidReturn(newPasswordConfirmed: "123456")
      self.saveButtonIsEnabled.assertValues([true])
      self.dismissKeyboard.assertValueCount(1)
      self.activityIndicatorShouldShow.assertValues([true])

      self.scheduler.advance()

      self.changePasswordSuccess.assertValueCount(1)
      self.activityIndicatorShouldShow.assertValues([true, false])
    }
  }

  func testDismissKeyboard_WhenSaveButtonDisabled() {
    self.vm.inputs.viewDidAppear()

    self.dismissKeyboard.assertValueCount(0)

    self.vm.inputs.currentPasswordFieldDidReturn(currentPassword: "password")

    self.dismissKeyboard.assertValueCount(0)

    self.vm.inputs.newPasswordFieldDidReturn(newPassword: "123456")

    self.dismissKeyboard.assertValueCount(0)

    self.vm.inputs.newPasswordConfirmationFieldDidReturn(newPasswordConfirmed: "1")

    self.saveButtonIsEnabled.assertValues([false])
    self.dismissKeyboard.assertValueCount(1)
    self.activityIndicatorShouldShow.assertValueCount(0)
  }

  func testValidationErrors_VoiceOverON() {
    withEnvironment(isVoiceOverRunning: { true }) {
      self.vm.inputs.viewDidAppear()
      self.validationErrorLabelIsHidden.assertValues([true])
      self.validationErrorLabelMessage.assertValues([""])

      self.vm.inputs.currentPasswordFieldTextChanged(text: "password")
      self.accessibilityFocusValidationErrorLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValueCount(0)
      self.validationErrorLabelIsHidden.assertValues([true])
      self.validationErrorLabelMessage.assertValues([""])

      self.vm.inputs.newPasswordFieldTextChanged(text: "new")
      self.accessibilityFocusValidationErrorLabel.assertValueCount(1)
      self.saveButtonIsEnabled.assertValueCount(0)
      self.validationErrorLabelIsHidden.assertValues([true, false])
      self.validationErrorLabelMessage.assertValues(["", "Your password must be at least 6 characters long."])

      self.vm.inputs.newPasswordConfirmationFieldTextChanged(text: "n")
      self.accessibilityFocusValidationErrorLabel.assertValueCount(2)
      self.saveButtonIsEnabled.assertValues([false])
      self.validationErrorLabelIsHidden.assertValues([true, false, false])
      self.validationErrorLabelMessage.assertValues(
        [
          "",
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long."
        ]
      )

      self.vm.inputs.newPasswordFieldDidReturn(newPassword: "newPassword")
      self.accessibilityFocusValidationErrorLabel.assertValueCount(3)
      self.saveButtonIsEnabled.assertValues([false])
      self.validationErrorLabelIsHidden.assertValues([true, false, false, true, false])
      self.validationErrorLabelMessage.assertValues(
        [
          "",
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long.",
          "",
          "New passwords must match."
        ]
      )

      self.vm.inputs.newPasswordConfirmationFieldDidReturn(newPasswordConfirmed: "new")
      self.accessibilityFocusValidationErrorLabel.assertValueCount(4)
      self.saveButtonIsEnabled.assertValues([false])
      self.validationErrorLabelIsHidden.assertValues([true, false, false, true, false])
      self.validationErrorLabelMessage.assertValues(
        [
          "",
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long.",
          "",
          "New passwords must match."
        ]
      )

      self.vm.inputs.newPasswordConfirmationFieldDidReturn(newPasswordConfirmed: "newPassword")
      self.accessibilityFocusValidationErrorLabel.assertValueCount(4)
      self.saveButtonIsEnabled.assertValues([false, true])
      self.validationErrorLabelIsHidden.assertValues([true, false, false, true, false, true])
      self.validationErrorLabelMessage.assertValues(
        [
          "",
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long.",
          "",
          "New passwords must match.",
          ""
        ]
      )

      self.vm.inputs.newPasswordConfirmationFieldDidReturn(newPasswordConfirmed: "wrongConfirmationPassword")
      self.accessibilityFocusValidationErrorLabel.assertValueCount(5)
      self.saveButtonIsEnabled.assertValues([false, true, false])
      self.validationErrorLabelIsHidden.assertValues([true, false, false, true, false, true, false])
      self.validationErrorLabelMessage.assertValues(
        [
          "",
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long.",
          "",
          "New passwords must match.",
          "",
          "New passwords must match."
        ]
      )

      self.vm.inputs.newPasswordConfirmationFieldDidReturn(newPasswordConfirmed: "newPassword")
      self.accessibilityFocusValidationErrorLabel.assertValueCount(5)
      self.saveButtonIsEnabled.assertValues([false, true, false, true])
      self.validationErrorLabelIsHidden.assertValues([true, false, false, true, false, true, false, true])
      self.validationErrorLabelMessage.assertValues(
        [
          "",
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long.",
          "",
          "New passwords must match.",
          "",
          "New passwords must match.",
          ""
        ]
      )
    }
  }

  func testValidationErrors_VoiceOverOFF() {
    withEnvironment(isVoiceOverRunning: { false }) {
      self.vm.inputs.viewDidAppear()
      self.validationErrorLabelIsHidden.assertValues([true])
      self.validationErrorLabelMessage.assertValues([""])

      self.vm.inputs.currentPasswordFieldTextChanged(text: "password")
      self.accessibilityFocusValidationErrorLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValueCount(0)
      self.validationErrorLabelIsHidden.assertValues([true])
      self.validationErrorLabelMessage.assertValues([""])

      self.vm.inputs.newPasswordFieldTextChanged(text: "new")
      self.accessibilityFocusValidationErrorLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValueCount(0)
      self.validationErrorLabelIsHidden.assertValues([true, false])
      self.validationErrorLabelMessage.assertValues(["", "Your password must be at least 6 characters long."])

      self.vm.inputs.newPasswordConfirmationFieldTextChanged(text: "n")
      self.accessibilityFocusValidationErrorLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false])
      self.validationErrorLabelIsHidden.assertValues([true, false, false])
      self.validationErrorLabelMessage.assertValues(
        [
          "",
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long."
        ]
      )

      self.vm.inputs.newPasswordFieldDidReturn(newPassword: "newPassword")
      self.accessibilityFocusValidationErrorLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false])
      self.validationErrorLabelIsHidden.assertValues([true, false, false, true, false])
      self.validationErrorLabelMessage.assertValues(
        [
          "",
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long.",
          "",
          "New passwords must match."
        ]
      )

      self.vm.inputs.newPasswordConfirmationFieldDidReturn(newPasswordConfirmed: "new")
      self.accessibilityFocusValidationErrorLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false])
      self.validationErrorLabelIsHidden.assertValues([true, false, false, true, false])
      self.validationErrorLabelMessage.assertValues(
        [
          "",
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long.",
          "",
          "New passwords must match."
        ]
      )

      self.vm.inputs.newPasswordConfirmationFieldDidReturn(newPasswordConfirmed: "newPassword")
      self.accessibilityFocusValidationErrorLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false, true])
      self.validationErrorLabelIsHidden.assertValues([true, false, false, true, false, true])
      self.validationErrorLabelMessage.assertValues(
        [
          "",
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long.",
          "",
          "New passwords must match.",
          ""
        ]
      )

      self.vm.inputs.newPasswordConfirmationFieldDidReturn(newPasswordConfirmed: "wrongConfirmationPassword")
      self.accessibilityFocusValidationErrorLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false, true, false])
      self.validationErrorLabelIsHidden.assertValues([true, false, false, true, false, true, false])
      self.validationErrorLabelMessage.assertValues(
        [
          "",
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long.",
          "",
          "New passwords must match.",
          "",
          "New passwords must match."
        ]
      )

      self.vm.inputs.newPasswordConfirmationFieldDidReturn(newPasswordConfirmed: "newPassword")
      self.accessibilityFocusValidationErrorLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false, true, false, true])
      self.validationErrorLabelIsHidden.assertValues([true, false, false, true, false, true, false, true])
      self.validationErrorLabelMessage.assertValues(
        [
          "",
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long.",
          "",
          "New passwords must match.",
          "",
          "New passwords must match.",
          ""
        ]
      )
    }
  }

  func testChangePasswordFailure() {
    let service =
      MockService(changePasswordResult: .failure(ErrorEnvelope(
        errorMessages: ["Error changing password"],
        ksrCode: nil,
        httpCode: 1,
        exception: nil
      )))

    withEnvironment(apiService: service) {
      self.vm.inputs.viewDidAppear()

      self.currentPasswordBecomeFirstResponder.assertValueCount(1)

      self.vm.inputs.currentPasswordFieldDidReturn(currentPassword: "password")

      self.newPasswordBecomeFirstResponder.assertValueCount(1)

      self.vm.inputs.newPasswordFieldDidReturn(newPassword: "123456")

      self.confirmNewPasswordBecomeFirstResponder.assertValueCount(1)

      self.vm.inputs.newPasswordConfirmationFieldTextChanged(text: "123456")

      self.saveButtonIsEnabled.assertValues([true])

      self.vm.inputs.saveButtonTapped()

      self.dismissKeyboard.assertValueCount(1)
      self.activityIndicatorShouldShow.assertValues([true])

      self.scheduler.advance()

      self.changePasswordFailure.assertValues(["Error changing password"])

      self.activityIndicatorShouldShow.assertValues([true, false])
    }
  }
}
