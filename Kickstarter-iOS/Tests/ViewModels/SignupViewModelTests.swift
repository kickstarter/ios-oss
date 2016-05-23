import Foundation
import KsApi
import Library
@testable import Kickstarter_iOS
@testable import ReactiveExtensions_TestHelpers
import ReactiveCocoa
import Result
import XCTest

final class SignupViewModelTests: TestCase {
  let vm: SignupViewModelType = SignupViewModel()
  let setWeeklyNewsletterState = TestObserver<Bool, NoError>()
  let isSignupButtonEnabled = TestObserver<Bool, NoError>()
  let postNotification = TestObserver<String, NoError>()
  let logIntoEnvironment = TestObserver<AccessTokenEnvelope, NoError>()
  let showError = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    vm.outputs.setWeeklyNewsletterState.observe(setWeeklyNewsletterState.observer)
    vm.outputs.isSignupButtonEnabled.observe(isSignupButtonEnabled.observer)
    vm.outputs.postNotification.map { $0.name } .observe(postNotification.observer)
    vm.outputs.logIntoEnvironment.observe(logIntoEnvironment.observer)
    vm.errors.showError.observe(showError.observer)
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
}
