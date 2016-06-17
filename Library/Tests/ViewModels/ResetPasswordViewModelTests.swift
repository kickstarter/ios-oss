import XCTest
@testable import ReactiveCocoa
@testable import ReactiveExtensions_TestHelpers
@testable import KsApi
@testable import KsApi_TestHelpers
@testable import Result
@testable import Library

final class ResetPasswordViewModelTests: TestCase {
  var vm: ResetPasswordViewModelType = ResetPasswordViewModel()

  let formIsValid = TestObserver<Bool, NoError>()
  let showResetSuccess = TestObserver<String, NoError>()
  let returnToLogin = TestObserver<(), NoError>()
  let showError = TestObserver<String, NoError>()
  let setEmailInitial = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    vm.outputs.formIsValid.observe(formIsValid.observer)
    vm.outputs.showResetSuccess.observe(showResetSuccess.observer)
    vm.outputs.returnToLogin.observe(returnToLogin.observer)
    vm.outputs.setEmailInitial.observe(setEmailInitial.observer)
    vm.errors.showError.observe(showError.observer)
  }

  func testViewDidLoadTracking() {
    vm.inputs.viewDidLoad()

    XCTAssertEqual(["Forgot Password View"], trackingClient.events)
  }

  func testFormIsValid() {
    formIsValid.assertDidNotEmitValue("Form is valid did not emit any values")

    vm.inputs.viewDidLoad()

    formIsValid.assertValues([false], "Emits form is valid after view loads")

    vm.inputs.emailChanged("bad")

    formIsValid.assertValues([false])

    vm.inputs.emailChanged("gina@kickstarter.com")

    formIsValid.assertValues([false, true])
  }

  func testFormIsValid_WithInitialValue() {
    formIsValid.assertDidNotEmitValue("Form is valid did not emit any values")

    vm.inputs.emailChanged("hello@goodemail.biz")

    formIsValid.assertDidNotEmitValue("Form is valid did not emit any values")

    vm.inputs.viewDidLoad()

    formIsValid.assertValues([true])

    vm.inputs.emailChanged("")

    formIsValid.assertValues([true, false])
  }

  func testEmailSetOnce_WithInitialValue() {
    vm.inputs.emailChanged("nativesquad@kickstarter.com")

    setEmailInitial.assertValueCount(0, "Initial email does not emit")

    vm.inputs.viewDidLoad()

    setEmailInitial.assertValues(["nativesquad@kickstarter.com"])

    vm.inputs.viewDidLoad()

    setEmailInitial.assertValues(["nativesquad@kickstarter.com"])
  }

  func testEmailNotSet_WithoutInitialValue() {
    setEmailInitial.assertValueCount(0, "Initial email does not emit")

    vm.inputs.viewDidLoad()

    setEmailInitial.assertValueCount(0, "Initial email does not emit")

    vm.inputs.emailChanged("nativesquad@kickstarter.com")

    setEmailInitial.assertValueCount(0, "Initial email does not emit")
  }

  func testResetSuccess() {
    vm.inputs.viewDidLoad()
    vm.inputs.emailChanged("lisa@kickstarter.com")
    vm.inputs.resetButtonPressed()

    showResetSuccess.assertValues(
      [Strings.forgot_password_we_sent_an_email_to_email_address_with_instructions_to_reset_your_password(
        email: "lisa@kickstarter.com")
      ]
    )
    XCTAssertEqual(["Forgot Password View", "Forgot Password Requested"], trackingClient.events)
  }

  func testResetConfirmation() {
    vm.inputs.viewDidLoad()
    vm.inputs.confirmResetButtonPressed()

    returnToLogin.assertValueCount(1, "Shows login after confirming message receipt")
  }

  func testResetFail_WithUnknownEmail() {
    let error = ErrorEnvelope(
      errorMessages: ["The resource you are looking for does not exist."],
      ksrCode: nil,
      httpCode: 404,
      exception: nil
    )

    withEnvironment(apiService: MockService(resetPasswordError: error)) {
      vm.inputs.viewDidLoad()
      vm.inputs.emailChanged("bad@email")
      vm.inputs.resetButtonPressed()

      showError.assertValues([Strings.forgot_password_error()],
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
      vm.inputs.viewDidLoad()
      vm.inputs.emailChanged("unicorns@sparkles.tv")
      vm.inputs.resetButtonPressed()

      showError.assertValues(["Something went wrong."], "Error alert is shown on bad request")
    }
  }
}
