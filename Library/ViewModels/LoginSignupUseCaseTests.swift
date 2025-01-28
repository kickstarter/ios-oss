@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class LoginSignupUseCaseTests: TestCase {
  let userSessionChanged = TestObserver<Void, Never>()
  let goToLoginSignup = TestObserver<LoginIntent, Never>()
  let isLoggedIn = TestObserver<Bool, Never>()

  let (initialDataSignal, initialDataObserver) = Signal<Void, Never>.pipe()
  var useCase: LoginSignupUseCase!

  override func setUp() {
    super.setUp()

    self.useCase = LoginSignupUseCase(withLoginIntent: .generic, initialData: self.initialDataSignal)

    self.useCase.outputs.goToLoginSignup.observe(self.goToLoginSignup.observer)
    self.useCase.inbetween.userSessionChanged.observe(self.userSessionChanged.observer)
    self.useCase.inbetween.isLoggedIn.observe(self.isLoggedIn.observer)
  }

  func testUseCase_SendsUserSessionChange_WhenUserSessionIsChanged() {
    self.userSessionChanged.assertDidNotEmitValue()

    self.useCase.inputs.userSessionDidChange()

    self.userSessionChanged.assertDidEmitValue()
  }

  func testUseCase_GoesToLoginSignup_AfterLoginSignupTapped() {
    self.goToLoginSignup.assertDidNotEmitValue()

    self.useCase.inputs.goToLoginSignupTapped()

    self.goToLoginSignup.assertDidEmitValue()
  }

  func testUseCase_SendsLoggedInEvent_InitiallyAndAfterSessionChanged() {
    self.isLoggedIn.assertDidNotEmitValue()

    self.initialDataObserver.send(value: ())

    self.isLoggedIn.assertLastValue(false)

    self.useCase.inputs.userSessionDidChange()

    self.isLoggedIn.assertLastValue(false)

    withEnvironment(currentUser: .template) {
      self.useCase.inputs.userSessionDidChange()
      self.isLoggedIn.assertLastValue(true)
    }
  }

  func testUseCase_LoggedIn_SendsInitialLoggedInEvent() {
    withEnvironment(currentUser: .template) {
      self.isLoggedIn.assertDidNotEmitValue()
      self.initialDataObserver.send(value: ())
      self.isLoggedIn.assertLastValue(true)
    }
  }
}
