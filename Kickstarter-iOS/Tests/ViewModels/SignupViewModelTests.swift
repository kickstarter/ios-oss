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

  func testFlow() {
    // MILK: initial state for weekly newsletter (german)
    // ping viewDidLoad
    vm.inputs.viewDidLoad()

    // assert that isSignupButtonenabled is false
    setWeeklyNewsletterState.assertValues([true])
    isSignupButtonEnabled.assertValues([false])

    // enter value for name, email, password, toggle weekly newsletter
    vm.inputs.nameChanged("Milky C")
    isSignupButtonEnabled.assertValues([false])

    vm.inputs.emailChanged("therealnativesquad@gmail.com")
    isSignupButtonEnabled.assertValues([false])

    vm.inputs.passwordChanged("otter")

    // assert that the form is now enabled (do this between each input)
    isSignupButtonEnabled.assertValues([false, true])

    // hit signuppressed
    vm.inputs.signupButtonPressed()

    // assert logintoenvironment has not emitted
    logIntoEnvironment.assertDidNotEmitValue()

    // advance time
    scheduler.advance()

    // assert logintoenvironment emits
    logIntoEnvironment.assertValueCount(1) // MILK: Change to inspect envelope?

    // hit environmentloggedin
    vm.inputs.environmentLoggedIn()

    // assert postnotification emits
    postNotification.assertValues([CurrentUserNotifications.sessionStarted])

    // MILK: Koala tests
  }
}
