import XCTest

@testable import Library
import ReactiveExtensions_TestHelpers

final class SetYourPasswordViewModelTests: TestCase {
  private let viewModel = SetYourPasswordViewModel()
  private let saveButtonIsEnabled = TestObserver<Bool, Never>()
  private let contextLabelText = TestObserver<String, Never>()
  private let newPasswordLabel = TestObserver<String, Never>()
  private let confirmPasswordLabel = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.viewModel.outputs.saveButtonIsEnabled.observe(self.saveButtonIsEnabled.observer)
    self.viewModel.outputs.contextLabelText.observe(self.contextLabelText.observer)
    self.viewModel.outputs.newPasswordLabel.observe(self.newPasswordLabel.observer)
    self.viewModel.outputs.confirmPasswordLabel.observe(self.confirmPasswordLabel.observer)

    self.viewModel.inputs.configureWith("test@email.com")
    self.viewModel.inputs.viewDidLoad()
  }

  func test_init() {
    self.contextLabelText
      .assertValue("We will be discontinuing the ability to log in via Facebook. To log in to your account using the email test@email.com, please set a password that’s at least 6 characters long.")
    self.newPasswordLabel.assertValue("Enter new password")
    self.confirmPasswordLabel.assertValue("Re-enter new password")
    XCTAssertNil(self.saveButtonIsEnabled.lastValue)
  }

  func test_saveButtonIsEnabledWhenFormIsValid() {
    self.viewModel.inputs.newPasswordFieldDidChange("")
    self.viewModel.inputs.confirmPasswordFieldDidChange("")

    self.saveButtonIsEnabled.assertLastValue(false)

    self.viewModel.inputs.newPasswordFieldDidChange("somepassword")

    self.saveButtonIsEnabled.assertLastValue(false)

    self.viewModel.inputs.confirmPasswordFieldDidChange("somepass")

    self.saveButtonIsEnabled.assertLastValue(false)

    self.viewModel.inputs.newPasswordFieldDidChange("asdfasdf")
    self.viewModel.inputs.confirmPasswordFieldDidChange("asdfasdf")

    self.saveButtonIsEnabled.assertLastValue(true)
  }
}
