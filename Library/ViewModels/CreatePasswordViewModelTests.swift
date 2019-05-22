import Foundation
import Result
import XCTest

@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers

final class CreatePasswordViewModelTests: TestCase {
  private let vm: CreatePasswordViewModelType = CreatePasswordViewModel()

  private let accessibilityFocusValidationLabel = TestObserver<Void, NoError>()
  private let activityIndicatorShouldShow = TestObserver<Bool, NoError>()
  private let cellAtIndexPathDidBecomeFirstResponder = TestObserver<IndexPath, NoError>()
  private let createPasswordFailure = TestObserver<String, NoError>()
  private let createPasswordSuccess = TestObserver<Void, NoError>()
  private let dismissKeyboard = TestObserver<Void, NoError>()
  private let newPasswordTextFieldBecomeFirstResponder = TestObserver<Void, NoError>()
  private let newPasswordConfirmationTextFieldBecomeFirstResponder = TestObserver<Void, NoError>()
  private let newPasswordConfirmationTextFieldResignFirstResponder = TestObserver<Void, NoError>()
  private let saveButtonIsEnabled = TestObserver<Bool, NoError>()
  private let validationLabelIsHidden = TestObserver<Bool, NoError>()
  private let validationLabelText = TestObserver<String?, NoError>()

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
    let graphError = GraphError.decodeError(GraphResponseError(message: "Error creating password"))
    let service = MockService(createPasswordError: graphError)

    withEnvironment(apiService: service) {
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
    withEnvironment(apiService: MockService()) {
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
    let isVoiceOverRunning = { true }

    withEnvironment(isVoiceOverRunning: isVoiceOverRunning) {
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
    let isVoiceOverRunning = { false }

    withEnvironment(isVoiceOverRunning: isVoiceOverRunning) {
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
    let client = MockTrackingClient()

    withEnvironment(apiService: MockService(), koala: Koala(client: client)) {
      XCTAssertEqual([], client.events)

      self.vm.inputs.viewDidAppear()

      XCTAssertEqual([Koala.CreatePasswordTrackingEvent.viewed.rawValue], client.events)

      self.vm.inputs.newPasswordTextFieldChanged(text: "password")
      self.vm.inputs.newPasswordConfirmationTextFieldChanged(text: "password")

      self.saveButtonIsEnabled.assertValues([true])

      self.vm.inputs.saveButtonTapped()

      self.scheduler.advance()

      self.createPasswordSuccess.assertValueCount(1)

      XCTAssertEqual([Koala.CreatePasswordTrackingEvent.viewed.rawValue,
                      Koala.CreatePasswordTrackingEvent.passwordCreated.rawValue], client.events)
    }
  }
}
