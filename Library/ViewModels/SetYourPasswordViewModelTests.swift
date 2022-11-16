import XCTest
@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers

final class SetYourPasswordViewModelTests: TestCase {
  private let viewModel = SetYourPasswordViewModel()
  private let saveButtonIsEnabled = TestObserver<Bool, Never>()
  private let contextLabelText = TestObserver<String, Never>()
  private let newPasswordLabel = TestObserver<String, Never>()
  private let confirmPasswordLabel = TestObserver<String, Never>()
  private var setPasswordFailure = TestObserver<String, Never>()
  private var setPasswordSuccess = TestObserver<Void, Never>()

  override func setUp() {
    super.setUp()

    self.viewModel.outputs.saveButtonIsEnabled.observe(self.saveButtonIsEnabled.observer)
    self.viewModel.outputs.contextLabelText.observe(self.contextLabelText.observer)
    self.viewModel.outputs.newPasswordLabel.observe(self.newPasswordLabel.observer)
    self.viewModel.outputs.confirmPasswordLabel.observe(self.confirmPasswordLabel.observer)
    self.viewModel.outputs.setPasswordSuccess.observe(self.setPasswordSuccess.observer)
    self.viewModel.outputs.setPasswordFailure.observe(self.setPasswordFailure.observer)

    self.viewModel.inputs.viewDidLoad()
  }

  func test_init() {
    let userEnvelope = UserEnvelope(me: GraphUser.template)
    
    withEnvironment(apiService: MockService(fetchGraphUserResult: .success(userEnvelope))) {
      self.contextLabelText
        .assertValue(Strings.We_will_be_discontinuing_the_ability_to_log_in_via_Facebook(email: userEnvelope.me.email ?? ""))
      self.newPasswordLabel.assertValue("Enter new password")
      self.confirmPasswordLabel.assertValue("Re-enter new password")
      
      XCTAssertNil(self.saveButtonIsEnabled.lastValue)
    }
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
