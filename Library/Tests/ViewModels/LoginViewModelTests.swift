import XCTest
@testable import KsApi
@testable import ReactiveCocoa
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import Result
@testable import Library

final class LoginViewModelTests: TestCase {
  let vm: LoginViewModelType = LoginViewModel()
  let passwordTextFieldBecomeFirstResponder = TestObserver<(), NoError>()
  let isFormValid = TestObserver<Bool, NoError>()
  let dismissKeyboard = TestObserver<(), NoError>()
  let postNotificationName = TestObserver<String, NoError>()
  let logIntoEnvironment = TestObserver<AccessTokenEnvelope, NoError>()
  let showError = TestObserver<String, NoError>()
  let tfaChallenge = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    vm.outputs.passwordTextFieldBecomeFirstResponder.observe(passwordTextFieldBecomeFirstResponder.observer)
    vm.outputs.isFormValid.observe(isFormValid.observer)
    vm.outputs.dismissKeyboard.observe(dismissKeyboard.observer)
    vm.outputs.postNotification.map { $0.name }.observe(postNotificationName.observer)
    vm.outputs.logIntoEnvironment.observe(logIntoEnvironment.observer)
    vm.errors.showError.observe(showError.observer)
    vm.errors.tfaChallenge.map { $0.email }.observe(tfaChallenge.observer)
  }

  func testLoginFlow() {
    vm.inputs.viewWillAppear()

    isFormValid.assertValues([false], "Form is not valid")

    vm.inputs.emailChanged("Gina@rules.com")
    isFormValid.assertValues([false], "Form is not valid")

    vm.inputs.emailTextFieldDoneEditing()
    passwordTextFieldBecomeFirstResponder.assertValueCount(1, "Password textfield becomes first responder")

    vm.inputs.passwordChanged("hello")
    isFormValid.assertValues([false, true], "Form is valid")

    vm.inputs.passwordTextFieldDoneEditing()
    dismissKeyboard.assertValueCount(1, "Keyboard is dismissed")

    vm.inputs.loginButtonPressed()
    logIntoEnvironment.assertValueCount(1, "Log into environment.")
    XCTAssertEqual(["Login"], trackingClient.events, "Koala login is tracked")

    vm.inputs.environmentLoggedIn()
    postNotificationName.assertValues([CurrentUserNotifications.sessionStarted],
                                      "Login notification posted.")

    showError.assertValueCount(0, "Error did not happen")
    tfaChallenge.assertValueCount(0, "TFA challenge did not happen")
  }

  func testLoginError() {
    let error = ErrorEnvelope(
      errorMessages: ["Unable to log in."],
      ksrCode: .InvalidXauthLogin,
      httpCode: 400,
      exception: nil
    )

    withEnvironment(apiService: MockService(loginError: error)) {
      vm.inputs.viewWillAppear()
      vm.inputs.emailChanged("nativesquad@kickstarter.com")
      vm.inputs.passwordChanged("helloooooo")
      vm.inputs.loginButtonPressed()

      logIntoEnvironment.assertValueCount(0, "Did not log into environment.")
      XCTAssertEqual(["Errored User Login"], trackingClient.events)
      showError.assertValues(["Unable to log in."], "Login errored")
      tfaChallenge.assertValueCount(0, "TFA challenge did not happen")
    }
  }

  func testLoginError_WithNoErrorMessage() {
    let error = ErrorEnvelope(
      errorMessages: [],
      ksrCode: .InvalidXauthLogin,
      httpCode: 400,
      exception: nil
    )

    withEnvironment(apiService: MockService(loginError: error)) {
      vm.inputs.viewWillAppear()
      vm.inputs.emailChanged("nativesquad@kickstarter.com")
      vm.inputs.passwordChanged("helloooooo")
      vm.inputs.loginButtonPressed()

      logIntoEnvironment.assertValueCount(0, "Did not log into environment.")
      XCTAssertEqual(["Errored User Login"], trackingClient.events)
      showError.assertValueCount(1, "Login errored")
      tfaChallenge.assertValueCount(0, "TFA challenge did not happen")
    }
  }

  func testTfaChallenge() {
    let error = ErrorEnvelope(
      errorMessages: ["Two Factor Authenticaion is required."],
      ksrCode: .TfaRequired,
      httpCode: 403,
      exception: nil
    )

    withEnvironment(apiService: MockService(loginError: error)) {
      vm.inputs.viewWillAppear()
      vm.inputs.emailChanged("nativesquad@kickstarter.com")
      vm.inputs.passwordChanged("helloooooo")
      vm.inputs.loginButtonPressed()

      logIntoEnvironment.assertValueCount(0, "Did not log into environment.")
      XCTAssertEqual([], trackingClient.events, "Tfa Challenge error was not tracked")
      showError.assertValueCount(0, "Login error did not happen")
      tfaChallenge.assertValues(["nativesquad@kickstarter.com"],
                                "Two factor challenge emitted with email and password")
    }
  }
}
