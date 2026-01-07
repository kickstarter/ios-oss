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

    self.useCase.uiOutputs.goToLoginSignup.observe(self.goToLoginSignup.observer)
    self.useCase.dataOutputs.userSessionChanged.observe(self.userSessionChanged.observer)
    self.useCase.dataOutputs.isLoggedIn.observe(self.isLoggedIn.observer)
  }

  func testUseCase_SendsUserSessionChange_WhenUserSessionIsChanged() {
    self.userSessionChanged.assertDidNotEmitValue()

    self.useCase.uiInputs.userSessionDidChange()

    self.userSessionChanged.assertDidEmitValue()
  }

  func testUseCase_GoesToLoginSignup_AfterLoginSignupTapped() {
    self.goToLoginSignup.assertDidNotEmitValue()

    self.useCase.uiInputs.goToLoginSignupTapped()

    self.goToLoginSignup.assertDidEmitValue()
  }

  func testUseCase_SendsLoggedInEvent_InitiallyAndAfterSessionChanged() {
    self.isLoggedIn.assertDidNotEmitValue()

    self.initialDataObserver.send(value: ())

    self.isLoggedIn.assertLastValue(false)

    self.useCase.uiInputs.userSessionDidChange()

    self.isLoggedIn.assertLastValue(false)

    withEnvironment(currentUser: .template) {
      self.useCase.uiInputs.userSessionDidChange()
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
