import XCTest

@testable import Library
import ReactiveExtensions_TestHelpers

final class SetYourPasswordViewModelTests: TestCase {
  private let saveButtonIsEnabled = TestObserver<Bool, Never>()
  private let contextLabelText = TestObserver<String, Never>()
  private let newPasswordLabel = TestObserver<String, Never>()
  private let confirmPasswordLabel = TestObserver<String, Never>()

  func test_init() {
    _ = self.makeSUT(with: "test@email.com")
    
    XCTAssertNil(self.saveButtonIsEnabled.lastValue)
  }

  func test_saveButtonIsEnabledWhenFormIsValid() {
    let sut = self.makeSUT()

    sut.inputs.newPasswordFieldDidChange("")
    sut.inputs.confirmPasswordFieldDidChange("")

    self.saveButtonIsEnabled.assertLastValue(false)

    sut.inputs.newPasswordFieldDidChange("somepassword")

    self.saveButtonIsEnabled.assertLastValue(false)

    sut.inputs.confirmPasswordFieldDidChange("somepass")

    self.saveButtonIsEnabled.assertLastValue  (false)

    sut.inputs.newPasswordFieldDidChange("asdfasdf")
    sut.inputs.confirmPasswordFieldDidChange("asdfasdf")

    self.saveButtonIsEnabled.assertLastValue(true)
  }

  // MARK: - Helpers

  private func makeSUT(with email: String = "", file: StaticString = #filePath,
                       line: UInt = #line) -> SetYourPasswordViewModel {
    let sut = SetYourPasswordViewModel()

    sut.inputs.configureWith(email)
    sut.inputs.viewDidLoad()

    sut.outputs.saveButtonIsEnabled.observe(self.saveButtonIsEnabled.observer)
    sut.outputs.contextLabelText.observe(self.contextLabelText.observer)
    sut.outputs.newPasswordLabel.observe(self.newPasswordLabel.observer)
    sut.outputs.confirmPasswordLabel.observe(self.confirmPasswordLabel.observer)

    return sut
  }
}
