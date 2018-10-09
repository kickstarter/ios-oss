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
  fileprivate let dismissKeyboard = TestObserver<(), NoError>()
  fileprivate let onePasswordButtonHidden = TestObserver<Bool, NoError>()
  fileprivate let onePasswordFindLoginForURLString = TestObserver<String, NoError>()
  fileprivate let passwordText = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.dismissKeyboard.observe(self.dismissKeyboard.observer)
    self.vm.outputs.onePasswordButtonIsHidden.observe(self.onePasswordButtonHidden.observer)
    self.vm.outputs.onePasswordFindLoginForURLString.observe(self.onePasswordFindLoginForURLString.observer)
    self.vm.outputs.passwordText.observe(self.passwordText.observer)
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

  func testPasswordText() {

    self.vm.inputs.onePasswordFound(password: "123456")
    self.passwordText.assertValues(["123456"])
  }

  func testOnePasswordFindLoginForURLString() {

    self.vm.inputs.onePasswordButtonTapped()

    self.onePasswordFindLoginForURLString.assertValues(
      [AppEnvironment.current.apiService.serverConfig.webBaseUrl.absoluteString]
    )
  }
}
