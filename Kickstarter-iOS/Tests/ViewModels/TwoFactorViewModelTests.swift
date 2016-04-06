import XCTest
import ReactiveCocoa
import Result
@testable import KsApi
@testable import Kickstarter_iOS
@testable import ReactiveExtensions_TestHelpers
@testable import KsApi_TestHelpers
@testable import Models
@testable import Models_TestHelpers
@testable import Library

final class TwoFactorViewModelTests: TestCase {
  let vm: TwoFactorViewModelType = TwoFactorViewModel()
  var isFormValid = TestObserver<Bool, NoError>()
  var isLoading = TestObserver<Bool, NoError>()
  var logIntoEnvironment = TestObserver<AccessTokenEnvelope, NoError>()
  var postNotificationName = TestObserver<String, NoError>()
  var resendSuccess = TestObserver<(), NoError>()
  var codeMismatch = TestObserver<String, NoError>()
  var genericFail = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    vm.outputs.isFormValid.observe(isFormValid.observer)
    vm.outputs.isLoading.observe(isLoading.observer)
    vm.outputs.logIntoEnvironment.observe(logIntoEnvironment.observer)
    vm.outputs.postNotification.map { $0.name }.observe(postNotificationName.observer)
    vm.outputs.resendSuccess.observe(resendSuccess.observer)
    vm.errors.codeMismatch.observe(codeMismatch.observer)
    vm.errors.genericFail.observe(genericFail.observer)
  }

  func testKoala_viewEvents() {
    vm.inputs.viewWillAppear()

    XCTAssertEqual(["Two-factor Authentication Confirm View"], trackingClient.events)
  }

  func testFormIsValid_forEmailPasswordFlow() {
    vm.inputs.viewWillAppear()

    isFormValid.assertValues([false])

    vm.inputs.email("gina@kickstarter.com", password: "blah")

    isFormValid.assertValues([false])

    vm.inputs.codeChanged("8")

    isFormValid.assertValues([false])

    vm.inputs.codeChanged("888888")

    isFormValid.assertValues([false, true])

    vm.inputs.codeChanged("88888")

    isFormValid.assertValues([false, true, false])
  }

  func testFormIsValid_forFacebookFlow() {
    vm.inputs.viewWillAppear()

    isFormValid.assertValues([false])

    vm.inputs.facebookToken("204938023948")

    isFormValid.assertValues([false])

    vm.inputs.codeChanged("8")

    isFormValid.assertValues([false])

    vm.inputs.codeChanged("888888")

    isFormValid.assertValues([false, true])

    vm.inputs.codeChanged("88888")

    isFormValid.assertValues([false, true, false])
  }

  func testLogin_withEmailPasswordFlow() {
    vm.inputs.viewWillAppear()
    vm.inputs.email("gina@kickstarter.com", password: "lkjkl")
    vm.inputs.codeChanged("454545")
    vm.inputs.submitPressed()

    isLoading.assertValues([true, false])
    logIntoEnvironment.assertValueCount(1, "Log into environment.")
    XCTAssertEqual(["Two-factor Authentication Confirm View", "Login"], trackingClient.events)

    vm.inputs.environmentLoggedIn()

    postNotificationName.assertValues([CurrentUserNotifications.sessionStarted],
                                      "Login notification posted.")
  }

  func testLogin_withFacebookFlow() {
    vm.inputs.viewWillAppear()
    vm.inputs.facebookToken("293jhapiapdoi")
    vm.inputs.codeChanged("454545")

    vm.inputs.submitPressed()

    isLoading.assertValues([true, false])
    logIntoEnvironment.assertValueCount(1, "Log into environment.")
    XCTAssertEqual(["Two-factor Authentication Confirm View", "Login"], trackingClient.events)

    vm.inputs.environmentLoggedIn()

    postNotificationName.assertValues([CurrentUserNotifications.sessionStarted],
                                      "Login notification posted.")
  }

  func testLoginCodeMismatch_withEmailPasswordFlow() {
    let error = ErrorEnvelope(
      errorMessages: ["The code provided does not match."],
      ksrCode: .TfaFailed,
      httpCode: 403,
      exception: nil
    )

    withEnvironment(apiService: MockService(loginError: error)) {
      vm.inputs.viewWillAppear()
      vm.inputs.email("gina@kickstarter.com", password: "lkjkl")
      vm.inputs.codeChanged("454545")
      vm.inputs.submitPressed()

      isLoading.assertValues([true, false])
      logIntoEnvironment.assertValueCount(0, "Did not log into environment.")
      codeMismatch.assertValues(["The code provided does not match."], "Code does not match error emitted")

      XCTAssertEqual(["Two-factor Authentication Confirm View"], trackingClient.events)
    }
  }

  func testLoginCodeMismatch_withFacebookFlow() {
    let error = ErrorEnvelope(
      errorMessages: ["The code provided does not match."],
      ksrCode: .TfaFailed,
      httpCode: 403,
      exception: nil
    )

    withEnvironment(apiService: MockService(loginError: error)) {
      vm.inputs.viewWillAppear()
      vm.inputs.facebookToken("2934ohhailisa")
      vm.inputs.codeChanged("454545")
      vm.inputs.submitPressed()

      isLoading.assertValues([true, false])
      logIntoEnvironment.assertValueCount(0, "Did not log into environment.")
      codeMismatch.assertValues(["The code provided does not match."], "Code does not match error emitted")

      XCTAssertEqual(["Two-factor Authentication Confirm View"], trackingClient.events)
    }
  }

  func testLoginGenericFail_withEmailPasswordFlow() {
    let error = ErrorEnvelope(
      errorMessages: ["Unable to login."],
      ksrCode: .UnknownCode,
      httpCode: 403,
      exception: nil
    )

    withEnvironment(apiService: MockService(loginError: error)) {
      vm.inputs.viewWillAppear()
      vm.inputs.email("gina@kickstarter.com", password: "lkjkl")
      vm.inputs.codeChanged("454545")
      vm.inputs.submitPressed()

      isLoading.assertValues([true, false])
      logIntoEnvironment.assertValueCount(0, "Did not log into environment.")
      genericFail.assertValues(["Unable to login."], "Login errored")

      XCTAssertEqual(["Two-factor Authentication Confirm View", "Errored User Login"], trackingClient.events)
    }
  }

  func testLoginGenericFail_withFacebookFlow() {
    let error = ErrorEnvelope(
      errorMessages: ["Unable to login."],
      ksrCode: .UnknownCode,
      httpCode: 403,
      exception: nil
    )

    withEnvironment(apiService: MockService(loginError: error)) {
      vm.inputs.viewWillAppear()
      vm.inputs.facebookToken("2934ohhailisa")
      vm.inputs.codeChanged("454545")
      vm.inputs.submitPressed()

      isLoading.assertValues([true, false])
      logIntoEnvironment.assertValueCount(0, "Did not log into environment.")
      genericFail.assertValues(["Unable to login."], "Errored user login")

      XCTAssertEqual(["Two-factor Authentication Confirm View", "Errored User Login"], trackingClient.events)
    }
  }

  func testResend_withEmailPasswordFlow() {
    let error = ErrorEnvelope(
      errorMessages: ["Two-factor authentication is enabled on this account."],
      ksrCode: .TfaRequired,
      httpCode: 403,
      exception: nil
    )

    withEnvironment(apiService: MockService(resendCodeResponse: error)) {
      vm.inputs.viewWillAppear()
      vm.inputs.email("gina@kickstarter.com", password: "lkjkl")
      vm.inputs.resendPressed()

      isLoading.assertValues([true, false])

      resendSuccess.assertValueCount(1, "Code resent successfully")

      XCTAssertEqual(["Two-factor Authentication Confirm View", "Two-factor Authentication Resend Code"], trackingClient.events)
    }
  }

  func testResend_withFacebookFlow() {
    let error = ErrorEnvelope(
      errorMessages: ["Two-factor authentication is enabled on this account."],
      ksrCode: .TfaRequired,
      httpCode: 403,
      exception: nil
    )

    withEnvironment(apiService: MockService(resendCodeResponse: error)) {
      vm.inputs.viewWillAppear()
      vm.inputs.facebookToken("2934ohhailisa")
      vm.inputs.resendPressed()

      isLoading.assertValues([true, false])

      resendSuccess.assertValueCount(1, "Code resent successfully")

      XCTAssertEqual(["Two-factor Authentication Confirm View", "Two-factor Authentication Resend Code"], trackingClient.events)
    }
  }

  func testResendError_withEmailPasswordFlow() {
    let error = ErrorEnvelope(
      errorMessages: [],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    withEnvironment(apiService: MockService(resendCodeError: error)) {
      vm.inputs.viewWillAppear()
      vm.inputs.email("gina@kickstarter.com", password: "lkjkl")
      vm.inputs.resendPressed()

      isLoading.assertValues([true, false])

      resendSuccess.assertValueCount(0, "Code was not resent")

      XCTAssertEqual(["Two-factor Authentication Confirm View", "Two-factor Authentication Resend Code"], trackingClient.events)
    }
  }

  func testResendError_withFacebookFlow() {
    let error = ErrorEnvelope(
      errorMessages: [],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    withEnvironment(apiService: MockService(resendCodeError: error)) {
      vm.inputs.viewWillAppear()
      vm.inputs.facebookToken("2934ohhailisa")
      vm.inputs.resendPressed()

      isLoading.assertValues([true, false])

      resendSuccess.assertValueCount(0, "Code was not resent")

      XCTAssertEqual(["Two-factor Authentication Confirm View", "Two-factor Authentication Resend Code"], trackingClient.events)
    }
  }
}
