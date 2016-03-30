import XCTest
import ReactiveCocoa
import Result
@testable import Kickstarter_iOS
@testable import ReactiveExtensions_TestHelpers
@testable import KsApi_TestHelpers
@testable import Library

final class TwoFactorViewModelTests: XCTestCase {
  let apiService = MockService()
  let trackingClient = MockTrackingClient()
  var vm: TwoFactorViewModelType!

  override func setUp() {
    super.setUp()

    let koala = Koala(client: trackingClient)

    AppEnvironment.pushEnvironment(apiService: apiService, koala: koala)

    vm = TwoFactorViewModel()
  }

  override func tearDown() {
    super.tearDown()

    AppEnvironment.popEnvironment()
  }

  func testKoala_viewEvents() {
    vm.inputs.viewWillAppear()

    XCTAssertEqual(["Two-factor Authentication Confirm View"], trackingClient.events)
  }

  func testFormIsValid_forEmailPasswordFlow() {
    let isFormValid = TestObserver<Bool, NoError>()
    vm.outputs.isFormValid.observe(isFormValid.observer)

    vm.inputs.viewWillAppear()

    isFormValid.assertValues([false])

    vm.inputs.email("gina@kickstarter.com", andPassword: "blah")

    isFormValid.assertValues([false])

    vm.inputs.code("8")

    isFormValid.assertValues([false])

    vm.inputs.code("888888")

    isFormValid.assertValues([false, true])

    vm.inputs.code("88888")

    isFormValid.assertValues([false, true, false])
  }

  func testFormIsValid_forFacebookFlow() {
    let isFormValid = TestObserver<Bool, NoError>()
    vm.outputs.isFormValid.observe(isFormValid.observer)

    vm.inputs.viewWillAppear()

    isFormValid.assertValues([false])

    vm.inputs.facebookToken("204938023948")

    isFormValid.assertValues([false])

    vm.inputs.code("8")

    isFormValid.assertValues([false])

    vm.inputs.code("888888")

    isFormValid.assertValues([false, true])

    vm.inputs.code("88888")

    isFormValid.assertValues([false, true, false])
  }

  func testLogin_withEmalPasswordFlow() {
    let isLoading = TestObserver<Bool, NoError>()
    vm.outputs.isLoading.observe(isLoading.observer)

    let loginSuccess = TestObserver<(), NoError>()
    vm.outputs.loginSuccess.observe(loginSuccess.observer)

    vm.inputs.viewWillAppear()
    vm.inputs.email("gina@kickstarter.com", andPassword: "lkjkl")
    vm.inputs.code("454545")
    vm.inputs.submitPressed()

    isLoading.assertValues([true, false])
    loginSuccess.assertValueCount(1)

    XCTAssertEqual(["Two-factor Authentication Confirm View", "Login"], trackingClient.events)
  }

  func testLogin_withFacebookFlow() {
    let isLoading = TestObserver<Bool, NoError>()
    vm.outputs.isLoading.observe(isLoading.observer)

    let loginSuccess = TestObserver<(), NoError>()
    vm.outputs.loginSuccess.observe(loginSuccess.observer)

    vm.inputs.viewWillAppear()
    vm.inputs.facebookToken("293jhapiapdoi")
    vm.inputs.code("454545")

    vm.inputs.submitPressed()

    isLoading.assertValues([true, false])
    loginSuccess.assertValueCount(1)

    XCTAssertEqual(["Two-factor Authentication Confirm View", "Login"], trackingClient.events)
  }

  func testResend_withEmailPasswordFlow() {
    let isLoading = TestObserver<Bool, NoError>()
    vm.outputs.isLoading.observe(isLoading.observer)

    vm.inputs.viewWillAppear()
    vm.inputs.email("gina@kickstarter.com", andPassword: "lkjkl")
    vm.inputs.resendPressed()

    isLoading.assertValues([true, false])

    XCTAssertEqual(["Two-factor Authentication Confirm View", "Two-factor Authentication Resend Code"], trackingClient.events)
  }

  func testResend_withFacebookFlow() {
    let isLoading = TestObserver<Bool, NoError>()
    vm.outputs.isLoading.observe(isLoading.observer)

    vm.inputs.viewWillAppear()
    vm.inputs.facebookToken("293jhapiapdoi")
    vm.inputs.resendPressed()

    isLoading.assertValues([true, false])

    XCTAssertEqual(["Two-factor Authentication Confirm View", "Two-factor Authentication Resend Code"], trackingClient.events)
  }
}

















