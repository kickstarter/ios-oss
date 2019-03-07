import Foundation
import Prelude
import Result
import XCTest

@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

final class ChangePasswordViewModelTests: TestCase {
  private let vm: ChangePasswordViewModelType = ChangePasswordViewModel()

  private let activityIndicatorShouldShow = TestObserver<Bool, NoError>()
  private let changePasswordFailure = TestObserver<String, NoError>()
  private let changePasswordSuccess = TestObserver<Void, NoError>()
  private let confirmNewPasswordBecomeFirstResponder = TestObserver<Void, NoError>()
  private let currentPasswordBecomeFirstResponder = TestObserver<Void, NoError>()
  private let currentPasswordPrefillValue = TestObserver<String, NoError>()
  private let dismissKeyboard = TestObserver<Void, NoError>()
  private let newPasswordBecomeFirstResponder = TestObserver<Void, NoError>()
  private let onePasswordButtonIsHidden = TestObserver<Bool, NoError>()
  private let onePasswordFindPasswordForURLString = TestObserver<String, NoError>()
  private let saveButtonIsEnabled = TestObserver<Bool, NoError>()
  private let validationErrorLabelIsHidden = TestObserver<Bool, NoError>()
  private let validationErrorLabelMessage = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.activityIndicatorShouldShow.observe(activityIndicatorShouldShow.observer)
    self.vm.outputs.changePasswordFailure.observe(changePasswordFailure.observer)
    self.vm.outputs.changePasswordSuccess.observe(changePasswordSuccess.observer)
    self.vm.outputs.confirmNewPasswordBecomeFirstResponder
      .observe(confirmNewPasswordBecomeFirstResponder.observer)
    self.vm.outputs.currentPasswordBecomeFirstResponder.observe(currentPasswordBecomeFirstResponder.observer)
    self.vm.outputs.currentPasswordPrefillValue.observe(currentPasswordPrefillValue.observer)
    self.vm.outputs.dismissKeyboard.observe(dismissKeyboard.observer)
    self.vm.outputs.newPasswordBecomeFirstResponder.observe(newPasswordBecomeFirstResponder.observer)
    self.vm.outputs.onePasswordFindPasswordForURLString
      .observe(onePasswordFindPasswordForURLString.observer)
    self.vm.outputs.onePasswordButtonIsHidden.observe(onePasswordButtonIsHidden.observer)
    self.vm.outputs.saveButtonIsEnabled.observe(saveButtonIsEnabled.observer)
    self.vm.outputs.validationErrorLabelIsHidden.observe(validationErrorLabelIsHidden.observer)
    self.vm.outputs.validationErrorLabelMessage.observe(validationErrorLabelMessage.observer)
  }

  func testChangePassword() {
    let service = MockService()

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

  func testOnePasswordButtonHidesProperly_OnIOS11AndEarlier() {
    let iOS12: (Double) -> Bool = { _ in false }
    withEnvironment(isOSVersionAvailable: iOS12) {
      self.vm.inputs.onePassword(isAvailable: true)

      self.onePasswordButtonIsHidden.assertValues([false])

      self.vm.inputs.onePassword(isAvailable: false)

      self.onePasswordButtonIsHidden.assertValues([false, true])
    }
  }

  func testOnePasswordButtonHidesProperly_OnIOS12AndLater() {
    let iOS12: (Double) -> Bool = { _ in true }
    withEnvironment(isOSVersionAvailable: iOS12) {
      self.vm.inputs.onePassword(isAvailable: true)

      self.onePasswordButtonIsHidden.assertValues([true])

      self.vm.inputs.onePassword(isAvailable: false)

      self.onePasswordButtonIsHidden.assertValues([true, true])
    }
  }

  func testOnePasswordAutofill() {
    let mockService = MockService(serverConfig: ServerConfig.local)
    let iOS12: (Double) -> Bool = { _ in false }

    withEnvironment(apiService: mockService, isOSVersionAvailable: iOS12) {
      self.vm.inputs.onePassword(isAvailable: true)
      self.vm.inputs.viewDidAppear()

      self.currentPasswordBecomeFirstResponder.assertValueCount(1)
      self.onePasswordButtonIsHidden.assertValue(false)

      self.vm.inputs.onePasswordButtonTapped()

      self.onePasswordFindPasswordForURLString.assertValues(["http://ksr.test"])

      self.vm.inputs.onePasswordFoundPassword(password: "password")

      self.currentPasswordPrefillValue.assertValue("password")
    }
  }

  func testValidationErrors() {
    self.vm.inputs.viewDidAppear()
    self.validationErrorLabelIsHidden.assertLastValue(true)
    self.validationErrorLabelMessage.assertLastValue("")

    self.vm.inputs.currentPasswordFieldTextChanged(text: "password")
    self.saveButtonIsEnabled.assertValueCount(0)
    self.validationErrorLabelIsHidden.assertLastValue(true)
    self.validationErrorLabelMessage.assertLastValue("")

    self.vm.inputs.newPasswordFieldTextChanged(text: "new")
    self.saveButtonIsEnabled.assertValueCount(0)
    self.validationErrorLabelIsHidden.assertLastValue(false)
    self.validationErrorLabelMessage.assertLastValue("Your password must be at least 6 characters long.")

    self.vm.inputs.newPasswordConfirmationFieldTextChanged(text: "n")
    self.saveButtonIsEnabled.assertValues([false])
    self.validationErrorLabelIsHidden.assertLastValue(false)
    self.validationErrorLabelMessage.assertLastValue("Your password must be at least 6 characters long.")

    self.vm.inputs.newPasswordFieldDidReturn(newPassword: "newPassword")
    self.saveButtonIsEnabled.assertValues([false])
    self.validationErrorLabelIsHidden.assertLastValue(false)
    self.validationErrorLabelMessage.assertLastValue("New passwords must match.")

    self.vm.inputs.newPasswordConfirmationFieldDidReturn(newPasswordConfirmed: "new")
    self.saveButtonIsEnabled.assertValues([false])
    self.validationErrorLabelIsHidden.assertLastValue(false)
    self.validationErrorLabelMessage.assertLastValue("New passwords must match.")

    self.vm.inputs.newPasswordConfirmationFieldDidReturn(newPasswordConfirmed: "newPassword")
    self.saveButtonIsEnabled.assertValues([false, true])
    self.validationErrorLabelIsHidden.assertLastValue(true)
    self.validationErrorLabelMessage.assertLastValue("")

    self.vm.inputs.newPasswordConfirmationFieldDidReturn(newPasswordConfirmed: "wrongConfirmationPassword")
    self.saveButtonIsEnabled.assertValues([false, true, false])
    self.validationErrorLabelIsHidden.assertLastValue(false)
    self.validationErrorLabelMessage.assertLastValue("New passwords must match.")

    self.vm.inputs.newPasswordConfirmationFieldDidReturn(newPasswordConfirmed: "newPassword")
    self.saveButtonIsEnabled.assertValues([false, true, false, true])
    self.validationErrorLabelIsHidden.assertLastValue(true)
    self.validationErrorLabelMessage.assertLastValue("")
  }

  func testChangePasswordFailure() {
    let graphError = GraphError.decodeError(GraphResponseError(message: "Error changing password"))
    let service = MockService(changePasswordError: graphError)

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

  func testTrackViewedChangePassword() {
    let client = MockTrackingClient()

    withEnvironment(koala: Koala(client: client)) {
      XCTAssertEqual([], client.events)

      self.vm.inputs.viewDidAppear()

      XCTAssertEqual(["Viewed Change Password"], client.events)

      self.vm.inputs.viewDidAppear()

      XCTAssertEqual(["Viewed Change Password", "Viewed Change Password"], client.events)
    }
  }

  func testTrackChangePassword() {
    let service = MockService()
    let client = MockTrackingClient()

    withEnvironment(apiService: service, koala: Koala(client: client)) {
      self.vm.inputs.currentPasswordFieldDidReturn(currentPassword: "password")
      self.vm.inputs.newPasswordFieldDidReturn(newPassword: "123456")
      self.vm.inputs.newPasswordConfirmationFieldDidReturn(newPasswordConfirmed: "123456")

      self.scheduler.advance()

      XCTAssertEqual(["Changed Password"], client.events)
    }
  }
}
