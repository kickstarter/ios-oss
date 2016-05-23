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
  let isSignupButtonEnabled = TestObserver<Bool, NoError>()
  let logIntoEnvironment = TestObserver<AccessTokenEnvelope, NoError>()
  let postNotification = TestObserver<String, NoError>()
  let setWeeklyNewsletterState = TestObserver<Bool, NoError>()
  let showError = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    vm.outputs.isSignupButtonEnabled.observe(isSignupButtonEnabled.observer)
    vm.outputs.logIntoEnvironment.observe(logIntoEnvironment.observer)
    vm.outputs.postNotification.map { $0.name } .observe(postNotification.observer)
    vm.outputs.setWeeklyNewsletterState.observe(setWeeklyNewsletterState.observer)
    vm.outputs.showError.observe(showError.observer)
  }

  // Tests a standard flow for signing up.
  func testFlow() {
    vm.inputs.viewDidLoad()

    setWeeklyNewsletterState.assertValues([true], "Selected when view loads.")
    isSignupButtonEnabled.assertValues([false], "Disabled when view loads.")

    vm.inputs.nameChanged("Native Squad")
    isSignupButtonEnabled.assertValues([false], "Disable while form is incomplete.")

    vm.inputs.emailChanged("therealnativesquad@gmail.com")
    isSignupButtonEnabled.assertValues([false], "Disabled while form is incomplete.")

    vm.inputs.passwordChanged("0773rw473rm3l0n")
    isSignupButtonEnabled.assertValues([false, true], "Enabled when form has been filled out.")

    vm.inputs.signupButtonPressed()
    logIntoEnvironment.assertDidNotEmitValue("Does not immediately emit after signup button is pressed.")

    scheduler.advance()
    logIntoEnvironment.assertValueCount(1, "Login after scheduler advances.")
    postNotification.assertDidNotEmitValue("Does not emit until environment logged in.")

    vm.inputs.environmentLoggedIn()

    scheduler.advance()
    postNotification.assertValues([CurrentUserNotifications.sessionStarted],
                                  "Notification posted after scheduler advances.")

    // MILK: Koala tests
    // MILK: Disable keyboard?
    // MILK: first responder events?
    // MILK:
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

      vm.inputs.emailChanged("nativesquad@kickstarter.com")
      vm.inputs.nameChanged("Native Squad")
      vm.inputs.passwordChanged("!")
      vm.inputs.signupButtonPressed()

      showError.assertDidNotEmitValue("Should not emit until scheduler advances.")

      scheduler.advance()
      logIntoEnvironment.assertValueCount(0, "Should not login.")
      showError.assertValues(errorMessages)
    }
  }
}
