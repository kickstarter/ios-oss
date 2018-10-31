import Foundation
import Prelude
import Result
import XCTest

@testable import KsApi
@testable import Kickstarter_Framework
@testable import ReactiveExtensions_TestHelpers

final class ChangePasswordViewModelTests: TestCase {
  private let vm: ChangePasswordViewModelType = ChangePasswordViewModel()

  private let activityIndicatorShouldShowObserver = TestObserver<Bool, NoError>()
  private let changePasswordFailureObserver = TestObserver<String, NoError>()
  private let changePasswordSuccessObserver = TestObserver<Void, NoError>()
  private let confirmNewPasswordBecomeFirstResponderObserver = TestObserver<Void, NoError>()
  private let currentPasswordBecomeFirstResponder = TestObserver<Void, NoError>()
  private let currentPasswordPrefillValueObserver = TestObserver<String, NoError>()
  private let dismissKeyboardObserver = TestObserver<Void, NoError>()
  private let newPasswordBecomeFirstResponderObserver = TestObserver<Void, NoError>()
  private let onePasswordButtonIsHiddenObserver = TestObserver<Bool, NoError>()
  private let onePasswordFindPasswordForURLStringObserver = TestObserver<String, NoError>()
  private let saveButtonIsEnabledObserver = TestObserver<Bool, NoError>()
  private let validationErrorLabelIsHiddenObserver = TestObserver<Bool, NoError>()
  private let validationErrorLabelMessageObserver = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.activityIndicatorShouldShow.observe(activityIndicatorShouldShowObserver.observer)
    self.vm.outputs.changePasswordFailure.observe(changePasswordFailureObserver.observer)
    self.vm.outputs.changePasswordSuccess.observe(changePasswordSuccessObserver.observer)
    self.vm.outputs.confirmNewPasswordBecomeFirstResponder
      .observe(confirmNewPasswordBecomeFirstResponderObserver.observer)
    self.vm.outputs.currentPasswordBecomeFirstResponder.observe(currentPasswordBecomeFirstResponder.observer)
    self.vm.outputs.currentPasswordPrefillValue.observe(currentPasswordPrefillValueObserver.observer)
    self.vm.outputs.dismissKeyboard.observe(dismissKeyboardObserver.observer)
    self.vm.outputs.newPasswordBecomeFirstResponder.observe(newPasswordBecomeFirstResponderObserver.observer)
    self.vm.outputs.onePasswordFindPasswordForURLString
      .observe(onePasswordFindPasswordForURLStringObserver.observer)
    self.vm.outputs.onePasswordButtonIsHidden.observe(onePasswordButtonIsHiddenObserver.observer)
    self.vm.outputs.saveButtonIsEnabled.observe(saveButtonIsEnabledObserver.observer)
    self.vm.outputs.validationErrorLabelIsHidden.observe(validationErrorLabelIsHiddenObserver.observer)
    self.vm.outputs.validationErrorLabelMessage.observe(validationErrorLabelMessageObserver.observer)
  }

  func testChangePassword() {
    let service = MockService()

    withEnvironment(apiService: service) {
      self.vm.inputs.viewDidAppear()

      self.currentPasswordBecomeFirstResponder.assertValueCount(1)

      self.vm.inputs.currentPasswordFieldDidReturn(currentPassword: "password")

      self.newPasswordBecomeFirstResponderObserver.assertValueCount(1)

      self.vm.inputs.newPasswordFieldDidReturn(newPassword: "123456")

      self.confirmNewPasswordBecomeFirstResponderObserver.assertValueCount(1)

      self.vm.inputs.newPasswordConfirmationFieldDidReturn(newPasswordConfirmed: "123456")

      self.saveButtonIsEnabledObserver.assertValues([true])
      self.dismissKeyboardObserver.assertValueCount(1)
      self.activityIndicatorShouldShowObserver.assertValues([true])

      scheduler.advance()

      let discoverParams = DiscoveryParams.defaults
        |> DiscoveryParams.lens.includePOTD .~ true
        |> DiscoveryParams.lens.sort .~ .magic

      self.changePasswordSuccessObserver.assertValueCount(1)

      self.activityIndicatorShouldShowObserver.assertValues([true, false])
    }
  }

  func testOnePasswordAutofill() {
    let mockService = MockService(serverConfig: ServerConfig.local)

    withEnvironment(apiService: mockService) {
      self.vm.inputs.onePasswordIsAvailable(available: true)
      self.vm.inputs.viewDidAppear()

      self.currentPasswordBecomeFirstResponder.assertValueCount(1)
      self.onePasswordButtonIsHiddenObserver.assertValue(false)

      self.vm.inputs.onePasswordButtonTapped()

      self.onePasswordFindPasswordForURLStringObserver.assertValues(["http://ksr.test"])

      self.vm.inputs.onePasswordFoundPassword(password: "password")

      self.currentPasswordPrefillValueObserver.assertValue("password")
    }
  }

  func testValidationErrors() {
    self.vm.inputs.viewDidAppear()

    self.vm.inputs.currentPasswordFieldDidReturn(currentPassword: "password")
    self.vm.inputs.newPasswordFieldDidReturn(newPassword: "12345")
    self.vm.inputs.newPasswordConfirmationFieldDidReturn(newPasswordConfirmed: "1234567")

    self.validationErrorLabelIsHiddenObserver.assertValues([false])
    self.validationErrorLabelMessageObserver
      .assertValues(["Your password must be at least 6 characters long."])
    self.saveButtonIsEnabledObserver.assertValues([false])

    self.vm.inputs.newPasswordFieldTextChanged(text: "123456")

    self.validationErrorLabelIsHiddenObserver.assertValues([false])
    self.validationErrorLabelMessageObserver
      .assertValues(["Your password must be at least 6 characters long.", "New passwords must match."])
    self.saveButtonIsEnabledObserver.assertValues([false])

    self.vm.inputs.newPasswordFieldTextChanged(text: "1234567")

    self.validationErrorLabelIsHiddenObserver.assertValues([false, true])
    self.saveButtonIsEnabledObserver.assertValues([false, true])
  }

  func testChangePasswordFailure() {
    let graphError = GraphError.decodeError(GraphResponseError(message: "Error changing password"))
    let service = MockService(changePasswordError: graphError)

    withEnvironment(apiService: service) {
      self.vm.inputs.viewDidAppear()

      self.currentPasswordBecomeFirstResponder.assertValueCount(1)

      self.vm.inputs.currentPasswordFieldDidReturn(currentPassword: "password")

      self.newPasswordBecomeFirstResponderObserver.assertValueCount(1)

      self.vm.inputs.newPasswordFieldDidReturn(newPassword: "123456")

      self.confirmNewPasswordBecomeFirstResponderObserver.assertValueCount(1)

      self.vm.inputs.newPasswordConfirmationFieldTextChanged(text: "123456")

      self.saveButtonIsEnabledObserver.assertValues([true])

      self.vm.inputs.saveButtonTapped()

      self.dismissKeyboardObserver.assertValueCount(1)
      self.activityIndicatorShouldShowObserver.assertValues([true])

      scheduler.advance()

      self.changePasswordFailureObserver.assertValues(["Error changing password"])

      self.activityIndicatorShouldShowObserver.assertValues([true, false])
    }
  }
}
