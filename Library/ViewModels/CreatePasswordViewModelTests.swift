import Foundation
import XCTest

@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers

final class CreatePasswordViewModelTests: TestCase {
  private let vm: CreatePasswordViewModelType = CreatePasswordViewModel()
  private let failureService =
    MockService(createPasswordResult: .failure(ErrorEnvelope(
      errorMessages: ["Error creating password"],
      ksrCode: nil,
      httpCode: 1,
      exception: nil
    )))
  private let successService =
    MockService(createPasswordResult: .success(EmptyResponseEnvelope()))

  private let accessibilityFocusValidationLabel = TestObserver<Void, Never>()
  private let activityIndicatorShouldShow = TestObserver<Bool, Never>()
  private let cellAtIndexPathDidBecomeFirstResponder = TestObserver<IndexPath, Never>()
  private let createPasswordFailure = TestObserver<String, Never>()
  private let createPasswordSuccess = TestObserver<Void, Never>()
  private let dismissKeyboard = TestObserver<Void, Never>()
  private let newPasswordTextFieldBecomeFirstResponder = TestObserver<Void, Never>()
  private let newPasswordConfirmationTextFieldBecomeFirstResponder = TestObserver<Void, Never>()
  private let newPasswordConfirmationTextFieldResignFirstResponder = TestObserver<Void, Never>()
  private let saveButtonIsEnabled = TestObserver<Bool, Never>()
  private let validationLabelIsHidden = TestObserver<Bool, Never>()
  private let validationLabelText = TestObserver<String?, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.accessibilityFocusValidationLabel.observe(self.accessibilityFocusValidationLabel.observer)
    self.vm.outputs.activityIndicatorShouldShow.observe(self.activityIndicatorShouldShow.observer)
    self.vm.outputs.createPasswordFailure.observe(self.createPasswordFailure.observer)
    self.vm.outputs.createPasswordSuccess.observe(self.createPasswordSuccess.observer)
    self.vm.outputs.dismissKeyboard.observe(self.dismissKeyboard.observer)
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

  func testCreatePasswordFailure() {
    withEnvironment(apiService: self.failureService) {
      self.vm.inputs.viewDidAppear()

      self.newPasswordTextFieldBecomeFirstResponder.assertValueCount(1)

      self.vm.inputs.newPasswordTextFieldChanged(text: "password")
      self.vm.inputs.newPasswordTextFieldDidReturn()
      self.newPasswordConfirmationTextFieldBecomeFirstResponder.assertValueCount(1)

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password")
      self.saveButtonIsEnabled.assertValues([true])
      self.vm.inputs.newPasswordConfirmationTextFieldDidReturn()
      self.newPasswordConfirmationTextFieldResignFirstResponder.assertValueCount(1)

      self.dismissKeyboard.assertValueCount(1)
      self.activityIndicatorShouldShow.assertValues([true])

      self.scheduler.advance()
      self.createPasswordFailure.assertValues(["Error creating password"])
      self.activityIndicatorShouldShow.assertValues([true, false])
    }
  }

  func testCreatePassword() {
    withEnvironment(apiService: self.successService) {
      self.vm.inputs.viewDidAppear()

      self.newPasswordTextFieldBecomeFirstResponder.assertValueCount(1)

      self.vm.inputs.newPasswordTextFieldChanged(text: "password")
      self.vm.inputs.newPasswordTextFieldDidReturn()
      self.newPasswordConfirmationTextFieldBecomeFirstResponder.assertValueCount(1)

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password")
      self.saveButtonIsEnabled.assertValues([true])
      self.vm.inputs.newPasswordConfirmationTextFieldDidReturn()
      self.newPasswordConfirmationTextFieldResignFirstResponder.assertValueCount(1)

      self.dismissKeyboard.assertValueCount(1)
      self.activityIndicatorShouldShow.assertValues([true])

      self.scheduler.advance()
      self.createPasswordSuccess.assertValueCount(1)
      self.activityIndicatorShouldShow.assertValues([true, false])
    }
  }

  func testDismissKeyboard_WhenSaveButtonDisabled() {
    self.vm.inputs.viewDidAppear()

    self.dismissKeyboard.assertValueCount(0)

    self.vm.inputs.newPasswordTextFieldChanged(text: "password")
    self.vm.inputs.newPasswordTextFieldDidReturn()

    self.dismissKeyboard.assertValueCount(0)

    self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "1233456")
    self.vm.inputs.newPasswordConfirmationTextFieldDidReturn()

    self.saveButtonIsEnabled.assertValues([false])
    self.dismissKeyboard.assertValueCount(1)
    self.activityIndicatorShouldShow.assertValueCount(0)
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
    withEnvironment(isVoiceOverRunning: { true }) {
      self.vm.inputs.viewDidAppear()
      self.validationLabelIsHidden.assertValues([true])
      self.validationLabelText.assertValues([nil])

      self.vm.inputs.newPasswordTextFieldChanged(text: "pass")
      self.vm.inputs.newPasswordTextFieldDidReturn()
      self.accessibilityFocusValidationLabel.assertValueCount(1)
      self.saveButtonIsEnabled.assertValueCount(0)
      self.validationLabelIsHidden.assertValues([true, false])
      self.validationLabelText.assertValues([nil, "Your password must be at least 6 characters long."])

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "p")
      self.accessibilityFocusValidationLabel.assertValueCount(2)
      self.saveButtonIsEnabled.assertValues([false])
      self.validationLabelIsHidden.assertValues([true, false, false])
      self.validationLabelText.assertValues(
        [
          nil,
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long."
        ]
      )

      self.vm.inputs.newPasswordTextFieldChanged(text: "password")
      self.vm.inputs.newPasswordTextFieldDidReturn()
      self.accessibilityFocusValidationLabel.assertValueCount(3)
      self.saveButtonIsEnabled.assertValues([false])
      self.validationLabelIsHidden.assertValues([true, false, false, true, false])
      self.validationLabelText.assertValues(
        [
          nil,
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long.",
          nil,
          "New passwords must match."
        ]
      )

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "pass")
      self.accessibilityFocusValidationLabel.assertValueCount(4)
      self.saveButtonIsEnabled.assertValues([false])
      self.validationLabelIsHidden.assertValues([true, false, false, true, false])
      self.validationLabelText.assertValues(
        [
          nil,
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long.",
          nil,
          "New passwords must match."
        ]
      )

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password")
      self.accessibilityFocusValidationLabel.assertValueCount(4)
      self.saveButtonIsEnabled.assertValues([false, true])
      self.validationLabelIsHidden.assertValues([true, false, false, true, false, true])
      self.validationLabelText.assertValues(
        [
          nil,
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long.",
          nil,
          "New passwords must match.",
          nil
        ]
      )

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password123")
      self.accessibilityFocusValidationLabel.assertValueCount(5)
      self.saveButtonIsEnabled.assertValues([false, true, false])
      self.validationLabelIsHidden.assertValues([true, false, false, true, false, true, false])
      self.validationLabelText.assertValues(
        [
          nil,
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long.",
          nil,
          "New passwords must match.",
          nil,
          "New passwords must match."
        ]
      )

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password")
      self.accessibilityFocusValidationLabel.assertValueCount(5)
      self.saveButtonIsEnabled.assertValues([false, true, false, true])
      self.validationLabelIsHidden.assertLastValue(true)
      self.validationLabelText.assertLastValue(nil)

      self.validationLabelIsHidden.assertValues([true, false, false, true, false, true, false, true])
      self.validationLabelText.assertValues(
        [
          nil,
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long.",
          nil,
          "New passwords must match.",
          nil,
          "New passwords must match.",
          nil
        ]
      )
    }
  }

  func testValidationErrorsWithVoiceOverOff() {
    withEnvironment(isVoiceOverRunning: { false }) {
      self.vm.inputs.viewDidAppear()
      self.validationLabelIsHidden.assertValues([true])
      self.validationLabelText.assertValues([nil])

      self.vm.inputs.newPasswordTextFieldChanged(text: "pass")
      self.vm.inputs.newPasswordTextFieldDidReturn()
      self.accessibilityFocusValidationLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValueCount(0)
      self.validationLabelIsHidden.assertValues([true, false])
      self.validationLabelText.assertValues([nil, "Your password must be at least 6 characters long."])

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "p")
      self.accessibilityFocusValidationLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false])
      self.validationLabelIsHidden.assertValues([true, false, false])
      self.validationLabelText.assertValues(
        [
          nil,
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long."
        ]
      )

      self.vm.inputs.newPasswordTextFieldChanged(text: "password")
      self.vm.inputs.newPasswordTextFieldDidReturn()
      self.accessibilityFocusValidationLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false])
      self.validationLabelIsHidden.assertValues([true, false, false, true, false])
      self.validationLabelText.assertValues(
        [
          nil,
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long.",
          nil,
          "New passwords must match."
        ]
      )

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "pass")
      self.accessibilityFocusValidationLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false])
      self.validationLabelIsHidden.assertValues([true, false, false, true, false])
      self.validationLabelText.assertValues(
        [
          nil,
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long.",
          nil,
          "New passwords must match."
        ]
      )

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password")
      self.accessibilityFocusValidationLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false, true])
      self.validationLabelIsHidden.assertValues([true, false, false, true, false, true])
      self.validationLabelText.assertValues(
        [
          nil,
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long.",
          nil,
          "New passwords must match.",
          nil
        ]
      )

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password123")
      self.accessibilityFocusValidationLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false, true, false])
      self.validationLabelIsHidden.assertValues([true, false, false, true, false, true, false])
      self.validationLabelText.assertValues(
        [
          nil,
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long.",
          nil,
          "New passwords must match.",
          nil,
          "New passwords must match."
        ]
      )

      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password")
      self.accessibilityFocusValidationLabel.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false, true, false, true])
      self.validationLabelIsHidden.assertLastValue(true)
      self.validationLabelText.assertLastValue(nil)

      self.validationLabelIsHidden.assertValues([true, false, false, true, false, true, false, true])
      self.validationLabelText.assertValues(
        [
          nil,
          "Your password must be at least 6 characters long.",
          "Your password must be at least 6 characters long.",
          nil,
          "New passwords must match.",
          nil,
          "New passwords must match.",
          nil
        ]
      )
    }
  }

  func testCreatePassword_eventTracking() {
    let segmentClient = MockTrackingClient()

    withEnvironment(
      apiService: successService,
      ksrAnalytics: KSRAnalytics(segmentClient: segmentClient)
    ) {
      XCTAssertEqual([], segmentClient.events)

      self.vm.inputs.viewDidAppear()

      self.vm.inputs.newPasswordTextFieldChanged(text: "password")
      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password")

      self.saveButtonIsEnabled.assertValues([true])

      self.vm.inputs.saveButtonTapped()

      self.scheduler.advance()

      self.createPasswordSuccess.assertValueCount(1)
    }
  }
}
