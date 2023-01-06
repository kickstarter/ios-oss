@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class FacebookResetPasswordViewModelTests: TestCase {
  internal let vm: FacebookResetPasswordViewModelType = FacebookResetPasswordViewModel()

  internal let emailLabel = TestObserver<String, Never>()
  internal let contextLabelText = TestObserver<String, Never>()
  internal let setPasswordButtonIsEnabled = TestObserver<Bool, Never>()
  internal let setPasswordSuccess = TestObserver<String, Never>()
  internal let setPasswordFailure = TestObserver<String, Never>()
  internal let shouldShowActivityIndicator = TestObserver<Bool, Never>()
  internal let textFieldAndSetPasswordButtonAreEnabled = TestObserver<Bool, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.contextLabelText.observe(self.contextLabelText.observer)
    self.vm.outputs.emailLabel.observe(self.emailLabel.observer)
    self.vm.outputs.setPasswordButtonIsEnabled.observe(self.setPasswordButtonIsEnabled.observer)
    self.vm.outputs.setPasswordSuccess.observe(self.setPasswordSuccess.observer)
    self.vm.outputs.setPasswordFailure.observe(self.setPasswordFailure.observer)
    self.vm.outputs.shouldShowActivityIndicator.observe(self.shouldShowActivityIndicator.observer)
    self.vm.outputs.textFieldAndSetPasswordButtonAreEnabled
      .observe(self.textFieldAndSetPasswordButtonAreEnabled.observer)
  }

  func testtextLabelsSet_onSetUp() {
    self.vm.inputs.viewWillAppear()

    self.contextLabelText.assertValue(Strings.We_re_simplifying_our_login_process_To_log_in())
    self.emailLabel.assertValue(Strings.forgot_password_placeholder_email())
  }

  func testsetPasswordButtonIsEnabled() {
    self.setPasswordButtonIsEnabled.assertDidNotEmitValue("Form is valid did not emit any values")

    self.vm.inputs.viewDidLoad()

    self.setPasswordButtonIsEnabled.assertValues([false], "Emits form is valid after view loads")

    self.vm.inputs.emailTextFieldFieldDidChange("bad")

    self.setPasswordButtonIsEnabled.assertValues([false])

    self.vm.inputs.emailTextFieldFieldDidChange("gina@kickstarter.com")

    self.setPasswordButtonIsEnabled.assertValues([false, true])
  }

  func testsetPasswordButtonIsEnabled_WithInitialValue() {
    self.setPasswordButtonIsEnabled.assertDidNotEmitValue("Form is valid did not emit any values")

    self.vm.inputs.emailTextFieldFieldDidChange("hello@goodemail.biz")

    self.setPasswordButtonIsEnabled.assertDidNotEmitValue("Form is valid did not emit any values")

    self.vm.inputs.viewDidLoad()

    self.setPasswordButtonIsEnabled.assertValues([true])

    self.vm.inputs.emailTextFieldFieldDidChange("")

    self.setPasswordButtonIsEnabled.assertValues([true, false])
  }

  func testResetSuccess() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.emailTextFieldFieldDidChange("lisa@kickstarter.com")

    self.shouldShowActivityIndicator.assertValues([])

    self.vm.inputs.setPasswordButtonPressed()

    self.setPasswordSuccess.assertValues(
      [
        Strings.forgot_password_we_sent_an_email_to_email_address_with_instructions_to_reset_your_password(
          email: "lisa@kickstarter.com"
        )
      ]
    )

    self.shouldShowActivityIndicator.assertValues([true, false])
  }

  func testResetFail_WithUnknownEmail() {
    let error = ErrorEnvelope(
      errorMessages: ["The resource you are looking for does not exist."],
      ksrCode: nil,
      httpCode: 404,
      exception: nil
    )

    withEnvironment(apiService: MockService(resetPasswordError: error)) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.emailTextFieldFieldDidChange("bad@email")
      self.shouldShowActivityIndicator.assertValues([])

      self.vm.inputs.setPasswordButtonPressed()

      self.setPasswordFailure.assertValues(
        [Strings.forgot_password_error()],
        "Error alert is shown on bad request"
      )
    }
  }

  func testResetFail_WithNon404Error() {
    let error = ErrorEnvelope(
      errorMessages: ["Zoinks!"],
      ksrCode: nil,
      httpCode: 400,
      exception: nil
    )

    withEnvironment(apiService: MockService(resetPasswordError: error)) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.emailTextFieldFieldDidChange("unicorns@sparkles.tv")

      self.shouldShowActivityIndicator.assertValues([])

      self.vm.inputs.setPasswordButtonPressed()

      self.setPasswordFailure.assertValues(["Something went wrong."], "Error alert is shown on bad request")

      self.shouldShowActivityIndicator.assertValues([true, false])
    }
  }
}
