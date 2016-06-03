import XCTest
@testable import KsApi
@testable import KsApi_TestHelpers
@testable import Library
@testable import ReactiveExtensions_TestHelpers
@testable import ReactiveCocoa
@testable import Result

private final class SignupViewModelTests: TestCase {
  private let vm: SignupViewModelType = SignupViewModel()
  private let emailTextFieldBecomeFirstResponder = TestObserver<(), NoError>()
  private let isSignupButtonEnabled = TestObserver<Bool, NoError>()
  private let logIntoEnvironment = TestObserver<AccessTokenEnvelope, NoError>()
  private let nameTextFieldBecomeFirstResponder = TestObserver<(), NoError>()
  private let passwordTextFieldBecomeFirstResponder = TestObserver<(), NoError>()
  private let postNotification = TestObserver<String, NoError>()
  private let setWeeklyNewsletterState = TestObserver<Bool, NoError>()
  private let showError = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.emailTextFieldBecomeFirstResponder
      .observe(self.emailTextFieldBecomeFirstResponder.observer)
    self.vm.outputs.isSignupButtonEnabled.observe(self.isSignupButtonEnabled.observer)
    self.vm.outputs.logIntoEnvironment.observe(self.logIntoEnvironment.observer)
    self.vm.outputs.nameTextFieldBecomeFirstResponder.observe(self.nameTextFieldBecomeFirstResponder.observer)
    self.vm.outputs.passwordTextFieldBecomeFirstResponder
      .observe(self.passwordTextFieldBecomeFirstResponder.observer)
    self.vm.outputs.postNotification.map { $0.name }.observe(self.postNotification.observer)
    self.vm.outputs.setWeeklyNewsletterState.observe(self.setWeeklyNewsletterState.observer)
    self.vm.outputs.showError.observe(self.showError.observer)
  }

  // Tests a standard flow for signing up.
  func testSignupFlow() {
    self.nameTextFieldBecomeFirstResponder.assertDidNotEmitValue()
    self.emailTextFieldBecomeFirstResponder.assertDidNotEmitValue()
    self.passwordTextFieldBecomeFirstResponder.assertDidNotEmitValue()

    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["User Signup"], self.trackingClient.events)
    self.setWeeklyNewsletterState.assertValues([true], "Selected when view loads.")
    self.isSignupButtonEnabled.assertValues([false], "Disabled when view loads.")
    self.nameTextFieldBecomeFirstResponder
      .assertValueCount(1, "Name field is first responder when view loads.")
    self.emailTextFieldBecomeFirstResponder.assertDidNotEmitValue("Not first responder when view loads.")
    self.passwordTextFieldBecomeFirstResponder.assertDidNotEmitValue("Not first responder when view loads.")

    self.vm.inputs.nameChanged("Native Squad")
    self.vm.inputs.nameTextFieldReturn()
    self.isSignupButtonEnabled.assertValues([false], "Disable while form is incomplete.")
    self.nameTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit again.")
    self.emailTextFieldBecomeFirstResponder.assertValueCount(1, "First responder after editing name.")
    self.passwordTextFieldBecomeFirstResponder
      .assertDidNotEmitValue("Not first responder after editing name.")

    self.vm.inputs.emailChanged("therealnativesquad@gmail.com")
    self.vm.inputs.emailTextFieldReturn()
    self.isSignupButtonEnabled.assertValues([false], "Disabled while form is incomplete.")
    self.nameTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit again.")
    self.emailTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit again.")
    self.passwordTextFieldBecomeFirstResponder.assertValueCount(1, "First responder after editing email.")

    self.vm.inputs.passwordChanged("0773rw473rm3l0n")
    self.isSignupButtonEnabled.assertValues([false, true], "Enabled when form is valid.")

    self.vm.inputs.passwordTextFieldReturn()
    self.vm.inputs.signupButtonPressed()
    XCTAssertEqual(["User Signup"], self.trackingClient.events)
    self.logIntoEnvironment.assertDidNotEmitValue("Does not immediately emit after signup button is pressed.")

    self.scheduler.advance()
    XCTAssertEqual(["User Signup", "New User"], self.trackingClient.events)
    self.logIntoEnvironment.assertValueCount(1, "Login after scheduler advances.")
    self.postNotification.assertDidNotEmitValue("Does not emit until environment logged in.")

    self.vm.inputs.environmentLoggedIn()

    self.scheduler.advance()
    XCTAssertEqual(["User Signup", "New User", "Login"], self.trackingClient.events)
    self.postNotification.assertValues([CurrentUserNotifications.sessionStarted],
                                  "Notification posted after scheduler advances.")
  }

  func testBecomeFirstResponder() {
    self.vm.inputs.viewDidLoad()
    self.nameTextFieldBecomeFirstResponder.assertValueCount(1, "Name starts as first responder.")
    self.emailTextFieldBecomeFirstResponder.assertDidNotEmitValue("Not first responder yet.")
    self.passwordTextFieldBecomeFirstResponder.assertDidNotEmitValue("Not first responder yet.")

    self.vm.inputs.nameTextFieldReturn()
    self.nameTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit another value.")
    self.emailTextFieldBecomeFirstResponder.assertValueCount(1, "Email becomes first responder.")
    self.passwordTextFieldBecomeFirstResponder.assertDidNotEmitValue("Not first responder yet.")

    self.vm.inputs.emailTextFieldReturn()
    self.nameTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit another value.")
    self.emailTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit another value.")
    self.passwordTextFieldBecomeFirstResponder.assertValueCount(1, "Password becomes first responder.")

    self.vm.inputs.passwordTextFieldReturn()
    self.nameTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit another value.")
    self.emailTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit another value.")
    self.passwordTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit another value.")
  }

  func testEmailShowError() {
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.emailChanged("nup")
    self.showError.assertDidNotEmitValue("Not finished editing yet.")

    self.vm.inputs.emailTextFieldReturn()
    self.showError.assertValueCount(1, "Email is not valid.")

    self.vm.inputs.emailTextFieldDoneEditing()
    self.showError.assertValueCount(2, "Email is not valid.")

    self.vm.inputs.emailChanged("therealnativesquad@gmail.com")
    self.showError.assertValueCount(2, "Email is now valid.")
  }

  func testSetWeeklyNewsletterState() {
    self.setWeeklyNewsletterState.assertDidNotEmitValue("Should not emit until view loads")

    self.withEnvironment(countryCode: "US") {
      self.vm.inputs.viewDidLoad()
      self.setWeeklyNewsletterState.assertValues([true], "True by default for US users")
    }

    self.withEnvironment(countryCode: "ES") {
      self.vm.inputs.viewDidLoad()
      self.setWeeklyNewsletterState.assertValues([true, false], "False by default for EU users")
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
      self.vm.inputs.viewDidLoad()

      XCTAssertEqual(["User Signup"], self.trackingClient.events)
      self.vm.inputs.emailChanged("nativesquad@kickstarter.com")
      self.vm.inputs.nameChanged("Native Squad")
      self.vm.inputs.passwordChanged("!")
      self.vm.inputs.signupButtonPressed()

      self.showError.assertDidNotEmitValue("Should not emit until scheduler advances.")

      self.scheduler.advance()
      self.logIntoEnvironment.assertValueCount(0, "Should not login.")
      self.showError.assertValues([error], "Signup error.")
      XCTAssertEqual(["User Signup", "Errored User Signup"], self.trackingClient.events)

      self.vm.inputs.passwordTextFieldReturn()
      self.showError.assertValueCount(1)

      scheduler.advance()
      self.showError.assertValues([error, error], "Signup error.")
      XCTAssertEqual(
        ["User Signup", "Errored User Signup", "Errored User Signup"],
        self.trackingClient.events)
    }
  }

  func testWeeklyNewsletterChanged() {
    self.vm.inputs.viewDidLoad()
    XCTAssertEqual(["User Signup"], self.trackingClient.events)

    self.vm.inputs.weeklyNewsletterChanged(true)
    XCTAssertEqual(["User Signup", "Signup Newsletter Toggle"], self.trackingClient.events)
    XCTAssertEqual([true],
                   self.trackingClient.properties.flatMap { $0["send_newsletters"] as? Bool })

    self.vm.inputs.weeklyNewsletterChanged(false)
    XCTAssertEqual(["User Signup", "Signup Newsletter Toggle", "Signup Newsletter Toggle"],
                   self.trackingClient.events)
    XCTAssertEqual([true, false],
                   self.trackingClient.properties.flatMap { $0["send_newsletters"] as? Bool })
  }
}
