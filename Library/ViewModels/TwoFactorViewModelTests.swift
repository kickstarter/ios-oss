@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class TwoFactorViewModelTests: TestCase {
  let vm: TwoFactorViewModelType = TwoFactorViewModel()
  var codeTextFieldBecomeFirstResponder = TestObserver<(), Never>()
  var isFormValid = TestObserver<Bool, Never>()
  var isLoading = TestObserver<Bool, Never>()
  var logIntoEnvironment = TestObserver<AccessTokenEnvelope, Never>()
  var postNotificationName = TestObserver<(Notification.Name, Notification.Name), Never>()
  var resendSuccess = TestObserver<(), Never>()
  var showError = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.codeTextFieldBecomeFirstResponder.observe(self.codeTextFieldBecomeFirstResponder.observer)
    self.vm.outputs.isFormValid.observe(self.isFormValid.observer)
    self.vm.outputs.isLoading.observe(self.isLoading.observer)
    self.vm.outputs.logIntoEnvironment.observe(self.logIntoEnvironment.observer)
    self.vm.outputs.postNotification.map { ($0.0.name, $0.1.name) }
      .observe(self.postNotificationName.observer)
    self.vm.outputs.resendSuccess.observe(self.resendSuccess.observer)
    self.vm.outputs.showError.observe(self.showError.observer)
  }

  func testCodeTextFieldBecomesFirstResponder() {
    self.vm.inputs.viewDidLoad()
    self.codeTextFieldBecomeFirstResponder.assertValueCount(1)
  }

  func testFormIsValid_forEmailPasswordFlow() {
    self.vm.inputs.viewWillAppear()

    self.isFormValid.assertValues([false])

    self.vm.inputs.email("gina@kickstarter.com", password: "blah")

    self.isFormValid.assertValues([false])

    self.vm.inputs.codeChanged("8")

    self.isFormValid.assertValues([false])

    self.vm.inputs.codeChanged("888888")

    self.isFormValid.assertValues([false, true])

    self.vm.inputs.codeChanged("88888")

    self.isFormValid.assertValues([false, true, false])
  }

  func testFormIsValid_forFacebookFlow() {
    self.vm.inputs.viewWillAppear()

    self.isFormValid.assertValues([false])

    self.vm.inputs.facebookToken("204938023948")

    self.isFormValid.assertValues([false])

    self.vm.inputs.codeChanged("8")

    self.isFormValid.assertValues([false])

    self.vm.inputs.codeChanged("888888")

    self.isFormValid.assertValues([false, true])

    self.vm.inputs.codeChanged("88888")

    self.isFormValid.assertValues([false, true, false])
  }

  func testLogin_withEmailPasswordFlow() {
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.email("gina@kickstarter.com", password: "lkjkl")
    self.vm.inputs.codeChanged("454545")
    self.vm.inputs.submitPressed()

    self.isLoading.assertValues([true, false])
    self.logIntoEnvironment.assertValueCount(1, "Log into environment.")

    self.vm.inputs.environmentLoggedIn()

    XCTAssertEqual(
      self.postNotificationName.values.first?.0, .ksr_sessionStarted,
      "Login notification posted."
    )
    XCTAssertEqual(
      self.postNotificationName.values.first?.1, .ksr_showNotificationsDialog,
      "Contextual dialog notification posted."
    )
  }

  func testLogin_withFacebookFlow() {
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.facebookToken("293jhapiapdoi")
    self.vm.inputs.codeChanged("454545")

    self.vm.inputs.submitPressed()

    self.isLoading.assertValues([true, false])
    self.logIntoEnvironment.assertValueCount(1, "Log into environment.")

    self.vm.inputs.environmentLoggedIn()

    XCTAssertEqual(
      self.postNotificationName.values.first?.0, .ksr_sessionStarted,
      "Login notification posted."
    )
    XCTAssertEqual(
      self.postNotificationName.values.first?.1, .ksr_showNotificationsDialog,
      "Contextual dialog notification posted."
    )
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
      showError.assertValues(["The code provided does not match."], "Code does not match error emitted")
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
      showError.assertValues(["The code provided does not match."], "Code does not match error emitted")
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
      showError.assertValues(["Unable to login."], "Login errored")
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
      showError.assertValues(["Unable to login."], "Errored user login")
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
      showError.assertValueCount(0, "No error was emitted")
      resendSuccess.assertValueCount(1, "Code resent successfully")
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
      showError.assertValueCount(0, "No error was emitted")
      resendSuccess.assertValueCount(1, "Code resent successfully")
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
      showError.assertValueCount(0, "No error was emitted")
      resendSuccess.assertValueCount(0, "Code was not resent")
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
      showError.assertValueCount(0, "No error was emitted")
      resendSuccess.assertValueCount(0, "Code was not resent")
    }
  }

  func testTracking() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    XCTAssertEqual(["Two-Factor Confirmation Viewed"], self.trackingClient.events)
  }
}
