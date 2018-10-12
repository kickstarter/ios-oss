import Prelude
import XCTest
@testable import Library
@testable import KsApi
@testable import ReactiveSwift
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import Result

final class ChangeEmailViewModelTests: TestCase {
  fileprivate let vm: ChangeEmailViewModelType = ChangeEmailViewModel()

  private let didChangeEmail = TestObserver<Void, NoError>()
  private let didFailToChangeEmail = TestObserver<String, NoError>()
  private let dismissKeyboard = TestObserver<(), NoError>()
  private let emailText = TestObserver<String, NoError>()
  private let onePasswordButtonHidden = TestObserver<Bool, NoError>()
  private let onePasswordFindLoginForURLString = TestObserver<String, NoError>()
  private let passwordText = TestObserver<String, NoError>()
  private let saveButtonIsEnabled = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.didChangeEmail.observe(self.didChangeEmail.observer)
    self.vm.outputs.didFailToChangeEmail.observe(self.didFailToChangeEmail.observer)
    self.vm.outputs.emailText.observe(self.emailText.observer)

    self.vm.outputs.dismissKeyboard.observe(self.dismissKeyboard.observer)
    self.vm.outputs.onePasswordButtonIsHidden.observe(self.onePasswordButtonHidden.observer)
    self.vm.outputs.onePasswordFindLoginForURLString.observe(self.onePasswordFindLoginForURLString.observer)
    self.vm.outputs.passwordText.observe(self.passwordText.observer)
    self.vm.outputs.saveButtonIsEnabled.observe(self.saveButtonIsEnabled.observer)
  }

  func testDidChangeEmailEmits_OnSuccess() {

    self.vm.inputs.passwordFieldDidTapGo(newEmail: "ksr@kickstarter.com", password: "123456")
    self.scheduler.advance()

    self.didChangeEmail.assertDidEmitValue()
  }

  func testDidFailToChangeEmailEmits_OnFailure() {

    let error = GraphError.emptyResponse(nil)

    withEnvironment(apiService: MockService(changeEmailError: error)) {

      self.vm.inputs.passwordFieldDidTapGo(newEmail: "ksr@kickstarter.com", password: "123456")
      self.scheduler.advance()

      self.didFailToChangeEmail.assertDidEmitValue()
    }
  }

  func testOnePasswordButtonHidesIfNotAvailable() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.onePassword(isAvailable: false)

    self.onePasswordButtonHidden.assertValues([true])
  }

  func testOnePasswordButtonVisibleIfAvailable() {

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.onePassword(isAvailable: true)

    self.onePasswordButtonHidden.assertValues([false])
  }

  func testTrackingEventsIfOnePassword_IsAvailable() {

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.onePassword(isAvailable: true)

    XCTAssertEqual([true, nil],
                   self.trackingClient.properties(forKey: "1password_extension_available", as: Bool.self))

    XCTAssertEqual([nil, true],
                   self.trackingClient.properties(forKey: "one_password_extension_available", as: Bool.self))
  }

  func testPasswordText_OnePassword() {

    self.vm.inputs.onePasswordFound(password: "123456")
    self.passwordText.assertValues(["123456"])
  }

  func testEmailText_AfterFetchingUsersEmail() {

    let response = GraphUser(email: "ksr@kickstarter.com")

    withEnvironment(apiService: MockService(fetchGraphUserEmailResponse: response)) {

      self.vm.inputs.passwordFieldDidTapGo(newEmail: "ksr@kickstarter.com", password: "123456")
      self.scheduler.advance()

      self.emailText.assertValues(["ksr@kickstarter.com"])
    }
  }

  func testOnePasswordFindLoginForURLString() {

    self.vm.inputs.onePasswordButtonTapped()

    self.onePasswordFindLoginForURLString.assertValues(
      [AppEnvironment.current.apiService.serverConfig.webBaseUrl.absoluteString]
    )
  }

  func testSaveButtonEnabledStatus() {

    let response = GraphUser(email: "ksr@kickstarter.com")

    withEnvironment(apiService: MockService(fetchGraphUserEmailResponse: response)) {

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.vm.inputs.emailFieldTextDidChange(text: "ksr@ksr.com")
      self.saveButtonIsEnabled.assertDidNotEmitValue()

      self.vm.inputs.passwordFieldTextDidChange(text: "123456")
      self.saveButtonIsEnabled.assertValues([true])

      // Disabled if new email is equal to the old one.
      self.vm.inputs.emailFieldTextDidChange(text: "ksr@kickstarter.com")
      self.saveButtonIsEnabled.assertValues([true, false])
    }
  }
}
