// swiftlint:disable force_unwrapping
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers
@testable import ReactiveSwift
@testable import Result

internal final class SignupViewModelTests: TestCase {
  fileprivate let vm = SignupViewModel()
  fileprivate let emailTextFieldBecomeFirstResponder = TestObserver<(), NoError>()
  fileprivate let isSignupButtonEnabled = TestObserver<Bool, NoError>()
  fileprivate let logIntoEnvironment = TestObserver<AccessTokenEnvelope, NoError>()
  fileprivate let nameTextFieldBecomeFirstResponder = TestObserver<(), NoError>()
  fileprivate let passwordTextFieldBecomeFirstResponder = TestObserver<(), NoError>()
  fileprivate let postNotification = TestObserver<Notification.Name, NoError>()
  fileprivate let setWeeklyNewsletterState = TestObserver<Bool, NoError>()
  fileprivate let showError = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    let (
      emailTextFieldBecomeFirstResponder,
      isSignupButtonEnabled,
      logIntoEnvironment,
      passwordTextFieldBecomeFirstResponder,
      postNotification,
      nameTextFieldBecomeFirstResponder,
      setWeeklyNewsletterState,
      showError
    ) = self.vm.outputs(from: self.vm.inputs)

    emailTextFieldBecomeFirstResponder
      .observe(self.emailTextFieldBecomeFirstResponder.observer)
    isSignupButtonEnabled.observe(self.isSignupButtonEnabled.observer)
    logIntoEnvironment.observe(self.logIntoEnvironment.observer)
    nameTextFieldBecomeFirstResponder.observe(self.nameTextFieldBecomeFirstResponder.observer)
    passwordTextFieldBecomeFirstResponder.observe(self.passwordTextFieldBecomeFirstResponder.observer)
    postNotification.map { $0.name }.observe(self.postNotification.observer)
    setWeeklyNewsletterState.observe(self.setWeeklyNewsletterState.observer)
    showError.observe(self.showError.observer)
  }

  // Tests a standard flow for signing up.
  func testSignupFlow() {
    self.nameTextFieldBecomeFirstResponder.assertDidNotEmitValue()
    self.emailTextFieldBecomeFirstResponder.assertDidNotEmitValue()
    self.passwordTextFieldBecomeFirstResponder.assertDidNotEmitValue()

    self.vm.inputs.viewDidLoad.value = ()

    XCTAssertEqual(["User Signup", "Viewed Signup"], self.trackingClient.events)
    self.setWeeklyNewsletterState.assertValues([false], "Unselected when view loads.")
    self.isSignupButtonEnabled.assertValues([false], "Disabled when view loads.")
    self.nameTextFieldBecomeFirstResponder
      .assertValueCount(1, "Name field is first responder when view loads.")
    self.emailTextFieldBecomeFirstResponder.assertDidNotEmitValue("Not first responder when view loads.")
    self.passwordTextFieldBecomeFirstResponder.assertDidNotEmitValue("Not first responder when view loads.")

    self.vm.inputs.nameTextChanged.value = "Native Squad"
    self.vm.inputs.nameTextFieldDidReturn.value = ()
    self.isSignupButtonEnabled.assertValues([false], "Disable while form is incomplete.")
    self.nameTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit again.")
    self.emailTextFieldBecomeFirstResponder.assertValueCount(1, "First responder after editing name.")
    self.passwordTextFieldBecomeFirstResponder
      .assertDidNotEmitValue("Not first responder after editing name.")

    self.vm.inputs.emailTextChanged.value = "therealnativesquad@gmail.com"
    self.vm.inputs.emailTextFieldDidReturn.value = ()
    self.isSignupButtonEnabled.assertValues([false], "Disabled while form is incomplete.")
    self.nameTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit again.")
    self.emailTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit again.")
    self.passwordTextFieldBecomeFirstResponder.assertValueCount(1, "First responder after editing email.")

    self.vm.inputs.passwordTextChanged.value = "0773rw473rm3l0n"
    self.isSignupButtonEnabled.assertValues([false, true], "Enabled when form is valid.")

    self.vm.inputs.passwordTextFieldDidReturn.value = ()
    self.vm.inputs.signupButtonPressed.value = ()
    XCTAssertEqual(["User Signup", "Viewed Signup"], self.trackingClient.events)
    self.logIntoEnvironment.assertDidNotEmitValue("Does not immediately emit after signup button is pressed.")

    self.scheduler.advance()
    XCTAssertEqual(["User Signup", "Viewed Signup", "New User", "Signed Up"], self.trackingClient.events)
    XCTAssertEqual("Email", trackingClient.properties.last!["auth_type"] as? String)
    self.logIntoEnvironment.assertValueCount(1, "Login after scheduler advances.")
    self.postNotification.assertDidNotEmitValue("Does not emit until environment logged in.")

    self.vm.inputs.environmentLoggedIn.value = ()

    self.scheduler.advance()
    XCTAssertEqual(["User Signup", "Viewed Signup", "New User", "Signed Up", "Login", "Logged In"],
                   self.trackingClient.events)
    self.postNotification.assertValues([.ksr_sessionStarted],
                                  "Notification posted after scheduler advances.")
  }

  func testBecomeFirstResponder() {
    self.vm.inputs.viewDidLoad.value = ()
    self.nameTextFieldBecomeFirstResponder.assertValueCount(1, "Name starts as first responder.")
    self.emailTextFieldBecomeFirstResponder.assertDidNotEmitValue("Not first responder yet.")
    self.passwordTextFieldBecomeFirstResponder.assertDidNotEmitValue("Not first responder yet.")

    self.vm.inputs.nameTextFieldDidReturn.value = ()
    self.nameTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit another value.")
    self.emailTextFieldBecomeFirstResponder.assertValueCount(1, "Email becomes first responder.")
    self.passwordTextFieldBecomeFirstResponder.assertDidNotEmitValue("Not first responder yet.")

    self.vm.inputs.emailTextFieldDidReturn.value = ()
    self.nameTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit another value.")
    self.emailTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit another value.")
    self.passwordTextFieldBecomeFirstResponder.assertValueCount(1, "Password becomes first responder.")

    self.vm.inputs.passwordTextFieldDidReturn.value = ()
    self.nameTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit another value.")
    self.emailTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit another value.")
    self.passwordTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit another value.")
  }

  func testSetWeeklyNewsletterStateFalseOnViewDidLoad() {
    self.setWeeklyNewsletterState.assertDidNotEmitValue("Should not emit until view loads")

    self.withEnvironment(config: Config.deConfig) {
      self.vm.inputs.viewDidLoad.value = ()
      self.setWeeklyNewsletterState.assertValues([false], "False by default for non-US users.")
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

    self.withEnvironment(apiService: MockService(signupError: errorEnvelope)) {
      self.vm.inputs.viewDidLoad.value = ()

      XCTAssertEqual(["User Signup", "Viewed Signup"], self.trackingClient.events)
      self.vm.inputs.emailTextChanged.value = "nativesquad@kickstarter.com"
      self.vm.inputs.nameTextChanged.value = "Native Squad"
      self.vm.inputs.passwordTextChanged.value = "!"
      self.vm.inputs.signupButtonPressed.value = ()

      self.showError.assertDidNotEmitValue("Should not emit until scheduler advances.")

      self.scheduler.advance()
      self.logIntoEnvironment.assertValueCount(0, "Should not login.")
      self.showError.assertValues([error], "Signup error.")
      XCTAssertEqual(["User Signup", "Viewed Signup", "Errored User Signup", "Errored Signup"],
                     self.trackingClient.events)

      self.vm.inputs.passwordTextFieldDidReturn.value = ()
      self.showError.assertValueCount(1)

      scheduler.advance()
      self.showError.assertValues([error, error], "Signup error.")
      XCTAssertEqual(["User Signup", "Viewed Signup", "Errored User Signup", "Errored Signup",
        "Errored User Signup", "Errored Signup"], self.trackingClient.events)
      XCTAssertEqual("Email", trackingClient.properties.last!["auth_type"] as? String)
    }
  }

  func testWeeklyNewsletterChanged() {
    self.vm.inputs.viewDidLoad.value = ()
    XCTAssertEqual(["User Signup", "Viewed Signup"], self.trackingClient.events)

    self.vm.inputs.weeklyNewsletterChanged.value = true
    XCTAssertEqual(["User Signup", "Viewed Signup", "Subscribed To Newsletter", "Signup Newsletter Toggle"],
                   self.trackingClient.events)
    XCTAssertEqual([true],
                   self.trackingClient.properties.compactMap { $0["send_newsletters"] as? Bool })

    self.vm.inputs.weeklyNewsletterChanged.value = false
    XCTAssertEqual(
      ["User Signup", "Viewed Signup", "Subscribed To Newsletter", "Signup Newsletter Toggle",
       "Unsubscribed From Newsletter", "Signup Newsletter Toggle"],
      self.trackingClient.events
    )
    XCTAssertEqual([true, false],
                   self.trackingClient.properties.compactMap { $0["send_newsletters"] as? Bool })
  }
}
