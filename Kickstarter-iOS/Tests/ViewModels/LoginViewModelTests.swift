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

final class LoginViewModelTests: XCTestCase {
  var vm: LoginViewModelType!
  let trackingClient = MockTrackingClient()
  let service = MockService()
  lazy var koala: Koala = { return Koala(client: self.trackingClient) }()
  lazy var currentUser: CurrentUserType = { return CurrentUser(apiService: self.service) }()

  override func setUp() {
    super.setUp()
    self.currentUser.logout()
    AppEnvironment.pushEnvironment(apiService: service, currentUser: currentUser, koala: koala)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.popEnvironment()
  }

  func testFlow() {
    self.vm = LoginViewModel()

    let currentUserPresent = TestObserver<Bool, NoError>()
    self.currentUser.producer.map { $0 != nil}.start(currentUserPresent.observer)

    let passwordTextFieldBecomeFirstResponder = TestObserver<(), NoError>()
    vm.outputs.passwordTextFieldBecomeFirstResponder.observe(passwordTextFieldBecomeFirstResponder.observer)

    let isFormValid = TestObserver<Bool, NoError>()
    vm.outputs.isFormValid.producer.start(isFormValid.observer)

    let dismissKeyboard = TestObserver<(), NoError>()
    vm.outputs.dismissKeyboard.observe(dismissKeyboard.observer)

    let loginSuccess = TestObserver<(), NoError>()
    vm.outputs.logInSuccess.observe(loginSuccess.observer)

    let invalidLogin = TestObserver<String, NoError>()
    vm.errors.invalidLogin.observe(invalidLogin.observer)

    let genericError = TestObserver<(), NoError>()
    vm.errors.genericError.observe(genericError.observer)

    let tfaChallenge = TestObserver<(), NoError>()
    vm.errors.tfaChallenge.observe(tfaChallenge.observer)

    currentUserPresent.assertValues([false], "No user is currently logged in")

    isFormValid.assertValues([false], "Form is not valid")

    vm.inputs.email.value = "Gina@rules.com"
    isFormValid.assertValues([false], "Form is not valid")

    vm.inputs.emailTextFieldDoneEditing()
    passwordTextFieldBecomeFirstResponder.assertValueCount(1, "Password textfield becomes first responder")

    vm.inputs.password.value = "hello"
    isFormValid.assertValues([false, true], "Form is valid")

    vm.inputs.passwordTextFieldDoneEditing()
    dismissKeyboard.assertValueCount(1, "Keyboard is dismissed")

    vm.inputs.loginButtonPressed()
    currentUserPresent.assertValues([false, true], "A user is currently logged in")
    loginSuccess.assertValueCount(1, "Login is successful")
    XCTAssertEqual(["Login"], trackingClient.events, "Koala login is tracked")

    invalidLogin.assertValueCount(0, "Invalid login error did not happen")
    genericError.assertValueCount(0, "Generic error did not happen")
    tfaChallenge.assertValueCount(0, "TFA error did not happen")
  }
}
