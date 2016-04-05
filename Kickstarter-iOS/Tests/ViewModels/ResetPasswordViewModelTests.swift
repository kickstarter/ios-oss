import XCTest
@testable import Kickstarter_iOS
@testable import ReactiveCocoa
@testable import ReactiveExtensions_TestHelpers
@testable import KsApi_TestHelpers
@testable import Result
@testable import Library

final class ResetPasswordViewModelTests: TestCase {
  var vm: ResetPasswordViewModelType!

  override func setUp() {
    super.setUp()
    self.vm = ResetPasswordViewModel()
  }

  func testViewWillAppear() {
    vm.inputs.viewWillAppear()

    XCTAssertEqual(["Forgot Password View"], trackingClient.events)
  }

  func testFormIsValid() {
    let formIsValid = TestObserver<Bool, NoError>()
    vm.outputs.formIsValid.observe(formIsValid.observer)

    formIsValid.assertDidNotEmitValue("Form is valid did not emit any values")

    vm.inputs.viewWillAppear()

    formIsValid.assertValues([false])

    vm.inputs.email("bad")

    formIsValid.assertValues([false])

    vm.inputs.email("gina@kickstarter.com")

    formIsValid.assertValues([false, true])
  }

  func testResetSuccess() {
    let resetSuccess = TestObserver<String, NoError>()
    vm.outputs.resetSuccess.observe(resetSuccess.observer)

    vm.inputs.viewWillAppear()
    vm.inputs.email("lisa@kickstarter.com")
    vm.inputs.resetButtonPressed()

    resetSuccess.assertValues(["lisa@kickstarter.com"])
    XCTAssertEqual(["Forgot Password View", "Forgot Password Requested"], trackingClient.events)
  }

  func testResetConfirmation() {
    let returnToLogin = TestObserver<(), NoError>()
    vm.outputs.returnToLogin.observe(returnToLogin.observer)

    vm.inputs.viewWillAppear()
    vm.inputs.confirmResetButtonPressed()

    returnToLogin.assertValueCount(1)
  }
}
