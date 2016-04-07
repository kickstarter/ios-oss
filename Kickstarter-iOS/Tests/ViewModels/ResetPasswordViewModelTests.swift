import XCTest
@testable import Kickstarter_iOS
@testable import ReactiveCocoa
@testable import ReactiveExtensions_TestHelpers
@testable import KsApi_TestHelpers
@testable import Result
@testable import Library

final class ResetPasswordViewModelTests: TestCase {
  var vm: ResetPasswordViewModelType = ResetPasswordViewModel()

  let formIsValid = TestObserver<Bool, NoError>()
  let showResetSuccess = TestObserver<String, NoError>()
  let returnToLogin = TestObserver<(), NoError>()

  override func setUp() {
    super.setUp()

    vm.outputs.formIsValid.observe(formIsValid.observer)
    vm.outputs.showResetSuccess.observe(showResetSuccess.observer)
    vm.outputs.returnToLogin.observe(returnToLogin.observer)
  }

  func testViewWillAppear() {
    vm.inputs.viewWillAppear()

    XCTAssertEqual(["Forgot Password View"], trackingClient.events)
  }

  func testFormIsValid() {
    formIsValid.assertDidNotEmitValue("Form is valid did not emit any values")

    vm.inputs.viewWillAppear()

    formIsValid.assertValues([false])

    vm.inputs.emailChanged("bad")

    formIsValid.assertValues([false])

    vm.inputs.emailChanged("gina@kickstarter.com")

    formIsValid.assertValues([false, true])
  }

  func testResetSuccess() {
    vm.inputs.viewWillAppear()
    vm.inputs.emailChanged("lisa@kickstarter.com")
    vm.inputs.resetButtonPressed()

    showResetSuccess.assertValues(["We've sent an email to lisa@kickstarter.com with instructions to reset your password."])
    XCTAssertEqual(["Forgot Password View", "Forgot Password Requested"], trackingClient.events)
  }

  func testResetConfirmation() {
    vm.inputs.viewWillAppear()
    vm.inputs.confirmResetButtonPressed()

    returnToLogin.assertValueCount(1)
  }
}
