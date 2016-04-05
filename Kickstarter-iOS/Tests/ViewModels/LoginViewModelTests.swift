import XCTest
@testable import Kickstarter_iOS
@testable import KsApi
@testable import KsApi_TestHelpers
@testable import ReactiveCocoa
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import Models
@testable import Result
@testable import Library

final class LoginViewModelTests: TestCase {
  var vm: LoginViewModelType!

  override func setUp() {
    super.setUp()
    self.vm = LoginViewModel()
  }

  func testLoginFlow() {
    let passwordTextFieldBecomeFirstResponder = TestObserver<(), NoError>()
    vm.outputs.passwordTextFieldBecomeFirstResponder.observe(passwordTextFieldBecomeFirstResponder.observer)

    let isFormValid = TestObserver<Bool, NoError>()
    vm.outputs.isFormValid.observe(isFormValid.observer)

    let dismissKeyboard = TestObserver<(), NoError>()
    vm.outputs.dismissKeyboard.observe(dismissKeyboard.observer)

    let postNotificationName = TestObserver<String, NoError>()
    vm.outputs.postNotification.map { $0.name }.observe(postNotificationName.observer)

    let logIntoEnvironment = TestObserver<AccessTokenEnvelope, NoError>()
    vm.outputs.logIntoEnvironment.observe(logIntoEnvironment.observer)

    let presentError = TestObserver<String, NoError>()
    vm.errors.presentError.observe(presentError.observer)

    let tfaChallenge = TestObserver<(), NoError>()
    vm.errors.tfaChallenge.observe(tfaChallenge.observer)

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

    presentError.assertValueCount(0, "Error did not happen")
    tfaChallenge.assertValueCount(0, "TFA challenge did not happen")
  }
}
