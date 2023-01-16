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

  func testTextLabelsSet_onSetUp() {
    self.vm.inputs.viewWillAppear()

    self.contextLabelText.assertValue(Strings.We_re_simplifying_our_login_process_To_log_in())
    self.emailLabel.assertValue(Strings.forgot_password_placeholder_email())
  }

  func testSetPasswordButtonIsEnabled() {
    self.setPasswordButtonIsEnabled.assertDidNotEmitValue("Button is valid did not emit any values")

    self.vm.inputs.viewDidLoad()

    self.setPasswordButtonIsEnabled.assertValues([], "Button is valid did not emit any values")

    self.vm.inputs.emailTextFieldFieldDidChange("bad")

    self.setPasswordButtonIsEnabled.assertValues([false])

    self.vm.inputs.emailTextFieldFieldDidChange("scott@kickstarter.com")

    self.setPasswordButtonIsEnabled.assertValues([false, true])
  }

  func testResetSuccessValues_EnabledTextFieldsAndLoadingIndicator() {
    withEnvironment(apiService: MockService(resetPasswordResponse: .template)) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.emailTextFieldFieldDidChange("lisa@kickstarter.com")

      self.shouldShowActivityIndicator.assertValues([])
      self.textFieldAndSetPasswordButtonAreEnabled.assertValues([])
      
      self.vm.inputs.setPasswordButtonPressed()

      self.setPasswordSuccess.assertValues(
        [
          Strings.forgot_password_we_sent_an_email_to_email_address_with_instructions_to_reset_your_password(
            email: "lisa@kickstarter.com"
          )
        ]
      )
      
      self.textFieldAndSetPasswordButtonAreEnabled.assertValues([true, false])
      self.shouldShowActivityIndicator.assertValues([false, true])
    }
  }

  func testResetSuccessWhenTextFieldReturnsAndFormIsValid() {
    let testEmail = "test@email.com"
    
    withEnvironment(apiService: MockService(resetPasswordResponse: .template)) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.emailTextFieldFieldDidChange(testEmail)
      
      self.shouldShowActivityIndicator.assertValues([])
      
      self.vm.inputs.emailTextFieldFieldDidReturn()
      
      self.shouldShowActivityIndicator.assertValues([false, true])
      
      self.setPasswordSuccess.assertValues(
        [Strings.forgot_password_we_sent_an_email_to_email_address_with_instructions_to_reset_your_password(
          email: testEmail
        )]
      )
    }
  }

  func testResetDoesNotEmitWhenTextFieldReturnsAndFormIsNotValid() {
    let testEmail = "bad@email"
    
    withEnvironment(apiService: MockService(resetPasswordError: ErrorEnvelope.couldNotParseJSON)) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.emailTextFieldFieldDidChange(testEmail)
      
      self.shouldShowActivityIndicator.assertValues([])
      
      self.vm.inputs.emailTextFieldFieldDidReturn()
      
      self.shouldShowActivityIndicator.assertValues([])
      
      self.setPasswordSuccess.assertValues([])
      self.setPasswordFailure.assertValues([])
    }
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
      self.vm.inputs.emailTextFieldFieldDidChange("test@email.com")
      self.shouldShowActivityIndicator.assertValues([])

      self.vm.inputs.setPasswordButtonPressed()

      self.setPasswordFailure.assertValues(
        [error.errorMessages.last ?? Strings.general_error_something_wrong()],
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
      self.vm.inputs.emailTextFieldFieldDidChange("test@email.com")

      self.shouldShowActivityIndicator.assertValues([])

      self.vm.inputs.setPasswordButtonPressed()

      self.setPasswordFailure
        .assertValues(
          [error.errorMessages.last ?? Strings.general_error_something_wrong()],
          "Error alert is shown on bad request"
        )

      self.shouldShowActivityIndicator.assertValues([false, true])
    }
  }
}
