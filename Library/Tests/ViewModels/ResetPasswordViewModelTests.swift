import XCTest
@testable import ReactiveCocoa
@testable import ReactiveExtensions_TestHelpers
@testable import KsApi
@testable import Result
@testable import Library

final class ResetPasswordViewModelTests: TestCase {
  internal let vm: ResetPasswordViewModelType = ResetPasswordViewModel()
  internal let emailTextFieldBecomeFirstResponder = TestObserver<(), NoError>()
  internal let formIsValid = TestObserver<Bool, NoError>()
  internal let showResetSuccess = TestObserver<String, NoError>()
  internal let returnToLogin = TestObserver<(), NoError>()
  internal let showError = TestObserver<String, NoError>()
  internal let setEmailInitial = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.emailTextFieldBecomeFirstResponder
      .observe(self.emailTextFieldBecomeFirstResponder.observer)
    self.vm.outputs.formIsValid.observe(self.formIsValid.observer)
    self.vm.outputs.showResetSuccess.observe(self.showResetSuccess.observer)
    self.vm.outputs.returnToLogin.observe(self.returnToLogin.observer)
    self.vm.outputs.setEmailInitial.observe(self.setEmailInitial.observer)
    self.vm.outputs.showError.observe(self.showError.observer)
  }

  func testEmailFieldBecomesFirstResponder() {
    self.vm.inputs.viewDidLoad()
    self.emailTextFieldBecomeFirstResponder.assertValueCount(1)
  }

  func testViewDidLoadTracking() {
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Forgot Password View"], trackingClient.events)
  }

  func testFormIsValid() {
    self.formIsValid.assertDidNotEmitValue("Form is valid did not emit any values")

    self.vm.inputs.viewDidLoad()

    self.formIsValid.assertValues([false], "Emits form is valid after view loads")

    self.vm.inputs.emailChanged("bad")

    self.formIsValid.assertValues([false])

    self.vm.inputs.emailChanged("gina@kickstarter.com")

    self.formIsValid.assertValues([false, true])
  }

  func testFormIsValid_WithInitialValue() {
    self.formIsValid.assertDidNotEmitValue("Form is valid did not emit any values")

    self.vm.inputs.emailChanged("hello@goodemail.biz")

    self.formIsValid.assertDidNotEmitValue("Form is valid did not emit any values")

    self.vm.inputs.viewDidLoad()

    self.formIsValid.assertValues([true])

    self.vm.inputs.emailChanged("")

    self.formIsValid.assertValues([true, false])
  }

  func testEmailSetOnce_WithInitialValue() {
    self.vm.inputs.emailChanged("nativesquad@kickstarter.com")

    self.setEmailInitial.assertValueCount(0, "Initial email does not emit")

    self.vm.inputs.viewDidLoad()

    self.setEmailInitial.assertValues(["nativesquad@kickstarter.com"])

    self.vm.inputs.viewDidLoad()

    self.setEmailInitial.assertValues(["nativesquad@kickstarter.com"])
  }

  func testEmailNotSet_WithoutInitialValue() {
    self.setEmailInitial.assertValueCount(0, "Initial email does not emit")

    self.vm.inputs.viewDidLoad()

    self.setEmailInitial.assertValueCount(0, "Initial email does not emit")

    self.vm.inputs.emailChanged("nativesquad@kickstarter.com")

    self.setEmailInitial.assertValueCount(0, "Initial email does not emit")
  }

  func testResetSuccess() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.emailChanged("lisa@kickstarter.com")
    self.vm.inputs.resetButtonPressed()

    self.showResetSuccess.assertValues(
      [Strings.forgot_password_we_sent_an_email_to_email_address_with_instructions_to_reset_your_password(
        email: "lisa@kickstarter.com")
      ]
    )
    XCTAssertEqual(["Forgot Password View", "Forgot Password Requested"], trackingClient.events)
  }

  func testResetConfirmation() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.confirmResetButtonPressed()

    self.returnToLogin.assertValueCount(1, "Shows login after confirming message receipt")
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
      self.vm.inputs.emailChanged("bad@email")
      self.vm.inputs.resetButtonPressed()

      self.showError.assertValues([Strings.forgot_password_error()],
                                  "Error alert is shown on bad request")
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
      self.vm.inputs.emailChanged("unicorns@sparkles.tv")
      self.vm.inputs.resetButtonPressed()

      self.showError.assertValues(["Something went wrong."], "Error alert is shown on bad request")
    }
  }
}
