import XCTest
@testable import Kickstarter_iOS
@testable import KsApi
@testable import KsApi_TestHelpers
@testable import Library
@testable import ReactiveExtensions_TestHelpers
@testable import ReactiveCocoa
@testable import Result

final class SignupViewModelTests: TestCase {
  let vm: SignupViewModelType = SignupViewModel()
  let emailTextFieldFirstResponder = TestObserver<(), NoError>()
  let dismissKeyboard = TestObserver<(), NoError>()
  let isSignupButtonEnabled = TestObserver<Bool, NoError>()
  let logIntoEnvironment = TestObserver<AccessTokenEnvelope, NoError>()
  let nameTextFieldFirstResponder = TestObserver<(), NoError>()
  let passwordTextFieldFirstResponder = TestObserver<(), NoError>()
  let postNotification = TestObserver<String, NoError>()
  let setWeeklyNewsletterState = TestObserver<Bool, NoError>()
  let showError = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    vm.outputs.dismissKeyboard.observe(dismissKeyboard.observer)
    vm.outputs.emailTextFieldFirstResponder.observe(emailTextFieldFirstResponder.observer)
    vm.outputs.isSignupButtonEnabled.observe(isSignupButtonEnabled.observer)
    vm.outputs.logIntoEnvironment.observe(logIntoEnvironment.observer)
    vm.outputs.nameTextFieldFirstResponder.observe(nameTextFieldFirstResponder.observer)
    vm.outputs.passwordTextFieldFirstResponder.observe(passwordTextFieldFirstResponder.observer)
    vm.outputs.postNotification.map { $0.name }.observe(postNotification.observer)
    vm.outputs.setWeeklyNewsletterState.observe(setWeeklyNewsletterState.observer)
    vm.outputs.showError.observe(showError.observer)
  }

  // Tests a standard flow for signing up.
  func testFlow() {
    nameTextFieldFirstResponder.assertDidNotEmitValue()
    emailTextFieldFirstResponder.assertDidNotEmitValue()
    passwordTextFieldFirstResponder.assertDidNotEmitValue()

    vm.inputs.viewDidLoad()

    XCTAssertEqual(["User Signup"], trackingClient.events)
    setWeeklyNewsletterState.assertValues([true], "Selected when view loads.")
    isSignupButtonEnabled.assertValues([false], "Disabled when view loads.")
    nameTextFieldFirstResponder.assertValueCount(1, "Name field is first responder when view loads.")
    emailTextFieldFirstResponder.assertDidNotEmitValue("Not first responder when view loads.")
    passwordTextFieldFirstResponder.assertDidNotEmitValue("Not first responder when view loads.")

    vm.inputs.nameChanged("Native Squad")
    vm.inputs.nameTextFieldDoneEditing()
    isSignupButtonEnabled.assertValues([false], "Disable while form is incomplete.")
    nameTextFieldFirstResponder.assertValueCount(1, "Does not emit again after editing name.")
    emailTextFieldFirstResponder.assertValueCount(1, "First responder after editing name.")
    passwordTextFieldFirstResponder.assertDidNotEmitValue("Not first responder after editing name.")

    vm.inputs.emailChanged("therealnativesquad@gmail.com")
    vm.inputs.emailTextFieldDoneEditing()
    isSignupButtonEnabled.assertValues([false], "Disabled while form is incomplete.")
    nameTextFieldFirstResponder.assertValueCount(1, "Does not emit again after editing email.")
    emailTextFieldFirstResponder.assertValueCount(1, "Does not emit again after editing email.")
    passwordTextFieldFirstResponder.assertValueCount(1, "First responder after editing email.")
    dismissKeyboard.assertDidNotEmitValue("Don't dismiss until all fields have been edited.")

    vm.inputs.passwordChanged("0773rw473rm3l0n")
    isSignupButtonEnabled.assertValues([false, true], "Enabled when form has been filled out.")
    vm.inputs.passwordTextFieldDoneEditing()
    dismissKeyboard.assertValueCount(1, "Dismiss when all fields have been edited.")

    vm.inputs.signupButtonPressed()
    XCTAssertEqual(["User Signup"], trackingClient.events)
    logIntoEnvironment.assertDidNotEmitValue("Does not immediately emit after signup button is pressed.")

    scheduler.advance()
    XCTAssertEqual(["User Signup", "New User"], trackingClient.events)
    logIntoEnvironment.assertValueCount(1, "Login after scheduler advances.")
    postNotification.assertDidNotEmitValue("Does not emit until environment logged in.")

    vm.inputs.environmentLoggedIn()

    scheduler.advance()
    postNotification.assertValues([CurrentUserNotifications.sessionStarted],
                                  "Notification posted after scheduler advances.")
  }

  func testSetWeeklyNewsletterState() {
    setWeeklyNewsletterState.assertDidNotEmitValue("Should not emit until view loads")

    withEnvironment(countryCode: "US") {
      vm.inputs.viewDidLoad()
      setWeeklyNewsletterState.assertValues([true], "True by default for US users")
    }

    withEnvironment(countryCode: "ES") {
      vm.inputs.viewDidLoad()
      setWeeklyNewsletterState.assertValues([true, false], "False by default for EU users")
    }
  }

  func testShowError() {
    let errorMessages = ["Password is too short (minimum is 6 characters)"]
    let error = ErrorEnvelope(
      errorMessages: errorMessages,
      ksrCode: nil,
      httpCode: 422,
      exception: nil
    )

    withEnvironment(apiService: MockService(signupError: error)) {
      vm.inputs.viewDidLoad()

      XCTAssertEqual(["User Signup"], trackingClient.events)
      vm.inputs.emailChanged("nativesquad@kickstarter.com")
      vm.inputs.nameChanged("Native Squad")
      vm.inputs.passwordChanged("!")
      vm.inputs.signupButtonPressed()

      showError.assertDidNotEmitValue("Should not emit until scheduler advances.")

      scheduler.advance()
      logIntoEnvironment.assertValueCount(0, "Should not login.")
      showError.assertValues(errorMessages, "Signup error.")
      XCTAssertEqual(["User Signup", "Errored User Signup"], trackingClient.events)
    }
  }
}
