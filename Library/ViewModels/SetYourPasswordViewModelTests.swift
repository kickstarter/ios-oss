@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers
import XCTest

final class SetYourPasswordViewModelTests: TestCase {
  private let viewModel = SetYourPasswordViewModel()

  private let shouldShowActivityIndicator = TestObserver<Bool, Never>()
  private let saveButtonIsEnabled = TestObserver<Bool, Never>()
  private let contextLabelText = TestObserver<String, Never>()
  private let newPasswordLabel = TestObserver<String, Never>()
  private let confirmPasswordLabel = TestObserver<String, Never>()
  private let textFieldsAndSaveButtonAreEnabled = TestObserver<Bool, Never>()
  private let setPasswordFailure = TestObserver<String, Never>()
  private let setPasswordSuccess = TestObserver<Void, Never>()

  private let setPasswordFailureService =
    MockService(createPasswordResult: .failure(ErrorEnvelope(
      errorMessages: ["Error creating password"],
      ksrCode: nil,
      httpCode: 1,
      exception: nil
    )))
  private let setPasswordSuccessService =
    MockService(createPasswordResult: .success(EmptyResponseEnvelope()))

  override func setUp() {
    super.setUp()

    self.viewModel.outputs.shouldShowActivityIndicator.observe(self.shouldShowActivityIndicator.observer)
    self.viewModel.outputs.saveButtonIsEnabled.observe(self.saveButtonIsEnabled.observer)
    self.viewModel.outputs.contextLabelText.observe(self.contextLabelText.observer)
    self.viewModel.outputs.newPasswordLabel.observe(self.newPasswordLabel.observer)
    self.viewModel.outputs.confirmPasswordLabel.observe(self.confirmPasswordLabel.observer)
    self.viewModel.outputs.textFieldsAndSaveButtonAreEnabled
      .observe(self.textFieldsAndSaveButtonAreEnabled.observer)
    self.viewModel.outputs.setPasswordSuccess.observe(self.setPasswordSuccess.observer)
    self.viewModel.outputs.setPasswordFailure.observe(self.setPasswordFailure.observer)
  }

  func test_init_setsInitialTextLabelAndSaveButtonStates() {
    let userEnvelope = UserEnvelope(me: GraphUser.template)

    withEnvironment(apiService: MockService(fetchGraphUserResult: .success(userEnvelope))) {
      self.viewModel.inputs.viewDidLoad()
      self.viewModel.inputs.viewWillAppear()

      self.scheduler.advance()

      self.contextLabelText
        .assertValue(Strings
          .We_will_be_discontinuing_the_ability_to_log_in_via_Facebook(email: userEnvelope.me.email ?? ""))
      self.newPasswordLabel.assertValue(Strings.New_password())
      self.confirmPasswordLabel.assertValue(Strings.Confirm_password())

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

  func testChangePassword_Success() {
    withEnvironment(apiService: self.setPasswordSuccessService) {
      self.viewModel.inputs.viewDidLoad()

      self.viewModel.inputs.newPasswordFieldDidChange("password")
      self.viewModel.inputs.confirmPasswordFieldDidChange("password")

      self.saveButtonIsEnabled.assertValues([true])
      self.shouldShowActivityIndicator.assertValues([])
      self.textFieldsAndSaveButtonAreEnabled.assertValues([])

      self.viewModel.inputs.saveButtonPressed()
      self.shouldShowActivityIndicator.assertValues([true])
      self.textFieldsAndSaveButtonAreEnabled.assertValues([false])

      self.scheduler.advance()

      self.setPasswordSuccess.assertValueCount(1)
      self.setPasswordFailure.assertValueCount(0)

      self.shouldShowActivityIndicator.assertValues([true, false])
      self.textFieldsAndSaveButtonAreEnabled.assertValues([false, true])
    }
  }

  func testChangePassword_Failure() {
    withEnvironment(apiService: self.setPasswordFailureService) {
      self.viewModel.inputs.viewDidLoad()

      self.viewModel.inputs.newPasswordFieldDidChange("password")
      self.viewModel.inputs.confirmPasswordFieldDidChange("password")

      self.saveButtonIsEnabled.assertValues([true])
      self.shouldShowActivityIndicator.assertValues([])
      self.textFieldsAndSaveButtonAreEnabled.assertValues([])

      self.viewModel.inputs.saveButtonPressed()
      self.shouldShowActivityIndicator.assertValues([true])
      self.textFieldsAndSaveButtonAreEnabled.assertValues([false])

      self.scheduler.advance()

      self.setPasswordSuccess.assertValueCount(0)
      self.setPasswordFailure.assertValueCount(1)

      self.shouldShowActivityIndicator.assertValues([true, false])
      self.textFieldsAndSaveButtonAreEnabled.assertValues([false, true])
    }
  }
}
