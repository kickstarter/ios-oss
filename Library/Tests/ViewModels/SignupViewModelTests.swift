import XCTest
@testable import KsApi
@testable import KsApi_TestHelpers
@testable import Library
@testable import ReactiveExtensions_TestHelpers
@testable import ReactiveCocoa
@testable import Result

final class SignupViewModelTests: TestCase {
  let vm: SignupViewModelType = SignupViewModel()
  let emailTextFieldBecomeFirstResponder = TestObserver<(), NoError>()
  let isSignupButtonEnabled = TestObserver<Bool, NoError>()
  let logIntoEnvironment = TestObserver<AccessTokenEnvelope, NoError>()
  let nameTextFieldBecomeFirstResponder = TestObserver<(), NoError>()
  let passwordTextFieldBecomeFirstResponder = TestObserver<(), NoError>()
  let postNotification = TestObserver<String, NoError>()
  let setWeeklyNewsletterState = TestObserver<Bool, NoError>()
  let showError = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    vm.outputs.emailTextFieldBecomeFirstResponder.observe(emailTextFieldBecomeFirstResponder.observer)
    vm.outputs.isSignupButtonEnabled.observe(isSignupButtonEnabled.observer)
    vm.outputs.logIntoEnvironment.observe(logIntoEnvironment.observer)
    vm.outputs.nameTextFieldBecomeFirstResponder.observe(nameTextFieldBecomeFirstResponder.observer)
    vm.outputs.passwordTextFieldBecomeFirstResponder.observe(passwordTextFieldBecomeFirstResponder.observer)
    vm.outputs.postNotification.map { $0.name }.observe(postNotification.observer)
    vm.outputs.setWeeklyNewsletterState.observe(setWeeklyNewsletterState.observer)
    vm.outputs.showError.observe(showError.observer)
  }

  // Tests a standard flow for signing up.
  func testFlow() {
    nameTextFieldBecomeFirstResponder.assertDidNotEmitValue()
    emailTextFieldBecomeFirstResponder.assertDidNotEmitValue()
    passwordTextFieldBecomeFirstResponder.assertDidNotEmitValue()

    vm.inputs.viewDidLoad()

    XCTAssertEqual(["User Signup"], trackingClient.events)
    setWeeklyNewsletterState.assertValues([true], "Selected when view loads.")
    isSignupButtonEnabled.assertValues([false], "Disabled when view loads.")
    nameTextFieldBecomeFirstResponder.assertValueCount(1, "Name field is first responder when view loads.")
    emailTextFieldBecomeFirstResponder.assertDidNotEmitValue("Not first responder when view loads.")
    passwordTextFieldBecomeFirstResponder.assertDidNotEmitValue("Not first responder when view loads.")

    vm.inputs.nameChanged("Native Squad")
    vm.inputs.nameTextFieldReturn()
    isSignupButtonEnabled.assertValues([false], "Disable while form is incomplete.")
    nameTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit again.")
    emailTextFieldBecomeFirstResponder.assertValueCount(1, "First responder after editing name.")
    passwordTextFieldBecomeFirstResponder.assertDidNotEmitValue("Not first responder after editing name.")

    vm.inputs.emailChanged("therealnativesquad@gmail.com")
    vm.inputs.emailTextFieldReturn()
    isSignupButtonEnabled.assertValues([false], "Disabled while form is incomplete.")
    nameTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit again.")
    emailTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit again.")
    passwordTextFieldBecomeFirstResponder.assertValueCount(1, "First responder after editing email.")

    vm.inputs.passwordChanged("0773rw473rm3l0n")
    isSignupButtonEnabled.assertValues([false, true], "Enabled when form is valid.")

    vm.inputs.passwordTextFieldReturn()
    vm.inputs.signupButtonPressed()
    XCTAssertEqual(["User Signup"], trackingClient.events)
    logIntoEnvironment.assertDidNotEmitValue("Does not immediately emit after signup button is pressed.")

    scheduler.advance()
    XCTAssertEqual(["User Signup", "New User"], trackingClient.events)
    logIntoEnvironment.assertValueCount(1, "Login after scheduler advances.")
    postNotification.assertDidNotEmitValue("Does not emit until environment logged in.")

    vm.inputs.environmentLoggedIn()

    scheduler.advance()
    XCTAssertEqual(["User Signup", "New User", "Login"], trackingClient.events)
    postNotification.assertValues([CurrentUserNotifications.sessionStarted],
                                  "Notification posted after scheduler advances.")
  }

  func testBecomeFirstResponder() {
    vm.inputs.viewDidLoad()
    nameTextFieldBecomeFirstResponder.assertValueCount(1, "Name starts as first responder.")
    emailTextFieldBecomeFirstResponder.assertDidNotEmitValue("Not first responder yet.")
    passwordTextFieldBecomeFirstResponder.assertDidNotEmitValue("Not first responder yet.")

    vm.inputs.nameTextFieldReturn()
    nameTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit another value.")
    emailTextFieldBecomeFirstResponder.assertValueCount(1, "Email becomes first responder.")
    passwordTextFieldBecomeFirstResponder.assertDidNotEmitValue("Not first responder yet.")

    vm.inputs.emailTextFieldReturn()
    nameTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit another value.")
    emailTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit another value.")
    passwordTextFieldBecomeFirstResponder.assertValueCount(1, "Password becomes first responder.")

    vm.inputs.passwordTextFieldReturn()
    nameTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit another value.")
    emailTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit another value.")
    passwordTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit another value.")
  }

  func testEmailValidity() {
    vm.inputs.viewDidLoad()

    vm.inputs.emailChanged("nup")
    showError.assertDidNotEmitValue("Not finished editing yet.")

    vm.inputs.emailTextFieldReturn()
    showError.assertValueCount(1, "Email is not valid.")

    vm.inputs.emailTextFieldDoneEditing()
    showError.assertValueCount(2, "Email is not valid.")

    vm.inputs.emailChanged("therealnativesquad@gmail.com")
    showError.assertValueCount(2, "Email is now valid.")
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
    let error = "Password is too short (minimum is 6 characters)"
    let errorEnvelope = ErrorEnvelope(
      errorMessages: [error],
      ksrCode: nil,
      httpCode: 422,
      exception: nil
    )

    withEnvironment(apiService: MockService(signupError: errorEnvelope)) {
      vm.inputs.viewDidLoad()

      XCTAssertEqual(["User Signup"], trackingClient.events)
      vm.inputs.emailChanged("nativesquad@kickstarter.com")
      vm.inputs.nameChanged("Native Squad")
      vm.inputs.passwordChanged("!")
      vm.inputs.signupButtonPressed()

      showError.assertDidNotEmitValue("Should not emit until scheduler advances.")

      scheduler.advance()
      logIntoEnvironment.assertValueCount(0, "Should not login.")
      showError.assertValues([error], "Signup error.")
      XCTAssertEqual(["User Signup", "Errored User Signup"], trackingClient.events)

      vm.inputs.passwordTextFieldReturn()
      showError.assertValueCount(1)

      scheduler.advance()
      showError.assertValues([error, error], "Signup error.")
      XCTAssertEqual(["User Signup", "Errored User Signup", "Errored User Signup"], trackingClient.events)
    }
  }

  func testWeeklyNewsletterChanged() {
    vm.inputs.viewDidLoad()
    XCTAssertEqual(["User Signup"], trackingClient.events)

    vm.inputs.weeklyNewsletterChanged(true)
    XCTAssertEqual(["User Signup", "Signup Newsletter Toggle"], trackingClient.events)
    XCTAssertEqual([true],
                   trackingClient.properties.flatMap { $0["send_newsletters"] as? Bool })

    vm.inputs.weeklyNewsletterChanged(false)
    XCTAssertEqual(["User Signup", "Signup Newsletter Toggle", "Signup Newsletter Toggle"],
                   trackingClient.events)
    XCTAssertEqual([true, false],
                   trackingClient.properties.flatMap { $0["send_newsletters"] as? Bool })
  }
}
