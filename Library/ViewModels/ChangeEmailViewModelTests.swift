@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class ChangeEmailViewModelTests: TestCase {
  fileprivate let vm: ChangeEmailViewModelType = ChangeEmailViewModel()

  private let activityIndicatorShouldShow = TestObserver<Bool, Never>()
  private let didChangeEmail = TestObserver<Void, Never>()
  private let didFailToChangeEmail = TestObserver<String, Never>()
  private let didFailToSendVerificationEmail = TestObserver<String, Never>()
  private let didSendVerificationEmail = TestObserver<Void, Never>()
  private let dismissKeyboard = TestObserver<(), Never>()
  private let emailText = TestObserver<String, Never>()
  private let messageLabelViewHidden = TestObserver<Bool, Never>()
  private let passwordFieldBecomeFirstResponder = TestObserver<Void, Never>()
  private let passwordText = TestObserver<String, Never>()
  private let resendVerificationEmailViewIsHidden = TestObserver<Bool, Never>()
  private let resetFields = TestObserver<String, Never>()
  private let saveButtonIsEnabled = TestObserver<Bool, Never>()
  private let textFieldsAreEnabled = TestObserver<Bool, Never>()
  private let unverifiedEmailLabelHidden = TestObserver<Bool, Never>()
  private let warningMessageLabelHidden = TestObserver<Bool, Never>()
  private let verificationEmailButtonTitle = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.activityIndicatorShouldShow.observe(self.activityIndicatorShouldShow.observer)
    self.vm.outputs.didChangeEmail.observe(self.didChangeEmail.observer)
    self.vm.outputs.didFailToChangeEmail.observe(self.didFailToChangeEmail.observer)
    self.vm.outputs.emailText.observe(self.emailText.observer)
    self.vm.outputs.dismissKeyboard.observe(self.dismissKeyboard.observer)
    self.vm.outputs.messageLabelViewHidden.observe(self.messageLabelViewHidden.observer)
    self.vm.outputs.passwordFieldBecomeFirstResponder.observe(self.passwordFieldBecomeFirstResponder.observer)
    self.vm.outputs.resendVerificationEmailViewIsHidden.observe(
      self.resendVerificationEmailViewIsHidden.observer
    )
    self.vm.outputs.didSendVerificationEmail.observe(
      self.didSendVerificationEmail.observer
    )
    self.vm.outputs.didFailToSendVerificationEmail.observe(
      self.didFailToSendVerificationEmail.observer
    )
    self.vm.outputs.resetFields.observe(self.resetFields.observer)
    self.vm.outputs.saveButtonIsEnabled.observe(self.saveButtonIsEnabled.observer)
    self.vm.outputs.textFieldsAreEnabled.observe(self.textFieldsAreEnabled.observer)
    self.vm.outputs.unverifiedEmailLabelHidden.observe(self.unverifiedEmailLabelHidden.observer)
    self.vm.outputs.warningMessageLabelHidden.observe(self.warningMessageLabelHidden.observer)
    self.vm.outputs.verificationEmailButtonTitle.observe(self.verificationEmailButtonTitle.observer)
  }

  func testChangeEmail_OnSuccess() {
    let updatedEmail = UserEmailFields.template |> \.email .~ "apple@kickstarter.com"
    let response = UserEnvelope<UserEmailFields>(me: updatedEmail)
    let mockService = MockService(changeEmailResponse: response)

    withEnvironment(apiService: mockService) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.resendVerificationEmailViewIsHidden.assertValues([true])
      self.unverifiedEmailLabelHidden.assertValues([true])
      self.emailText.assertValues(["ksr@kickstarter.com"])

      self.vm.inputs.emailFieldTextDidChange(text: "apple@kickstarter.com")
      self.vm.inputs.passwordFieldTextDidChange(text: "123456")

      self.vm.inputs.saveButtonIsEnabled(true)
      self.vm.inputs.saveButtonTapped()

      self.scheduler.advance()

      self.didChangeEmail.assertDidEmitValue()
      self.emailText.assertValues(["ksr@kickstarter.com", "apple@kickstarter.com"])
      self.resendVerificationEmailViewIsHidden.assertValues(
        [true],
        "Resend verification email button does not show"
      )
      self.unverifiedEmailLabelHidden.assertValues([true])
    }
  }

  func testDidFailToChangeEmailEmits_OnFailure() {
    let error = GraphError.emptyResponse(nil)

    withEnvironment(apiService: MockService(changeEmailError: error)) {
      self.vm.inputs.emailFieldTextDidChange(text: "ksr@ksr.com")
      self.vm.inputs.passwordFieldTextDidChange(text: "123456")

      self.vm.inputs.saveButtonIsEnabled(true)
      self.vm.inputs.saveButtonTapped()

      self.activityIndicatorShouldShow.assertValues([true])

      self.scheduler.advance()

      self.didFailToChangeEmail.assertDidEmitValue()

      self.activityIndicatorShouldShow.assertValues([true, false])
    }
  }

  func testEmailText_AfterFetchingUsersEmail() {
    let response = UserEnvelope<UserEmailFields>(me: .template)

    withEnvironment(apiService: MockService(changeEmailResponse: response)) {
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.emailText.assertValues(["ksr@kickstarter.com"])
    }
  }

  func testSaveButtonEnabledStatus() {
    let response = UserEnvelope<UserEmailFields>(me: .template)

    withEnvironment(apiService: MockService(changeEmailResponse: response)) {
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

  func testResendVerificationViewIsHidden_onViewDidLoad_andIfEmailIsVerified() {
    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    self.resendVerificationEmailViewIsHidden
      .assertValues([true], "Email is deliverable and verified")
  }

  func testResendVerificationViewIsNotHidden_IfEmailIsNotVerified() {
    let userEmailFields = UserEmailFields.template
      |> \.isEmailVerified .~ false

    let mockService = MockService(fetchGraphUserEmailFieldsResponse: userEmailFields)

    withEnvironment(apiService: mockService) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.resendVerificationEmailViewIsHidden.assertValues([true, false], "Email is unverified")
    }
  }

  func testResendVerificationViewIsNotHidden_IfEmailIsUndeliverable() {
    let userEmailFields = UserEmailFields.template
      |> \.isDeliverable .~ false

    let mockService = MockService(fetchGraphUserEmailFieldsResponse: userEmailFields)

    withEnvironment(apiService: mockService) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.resendVerificationEmailViewIsHidden
        .assertValues([true, false], "Email is undeliverable")
    }
  }

  func testWarningMessageLabel_isHidden() {
    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    self.warningMessageLabelHidden.assertValues([true], "Email is deliverable")
  }

  func testWarningMessageLabel_isNotHidden_whenEmailIsNotDeliverable() {
    let userEmailFields = UserEmailFields.template
      |> \.isDeliverable .~ false

    withEnvironment(apiService: MockService(fetchGraphUserEmailFieldsResponse: userEmailFields)) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.warningMessageLabelHidden
        .assertValues([false], "Email is not deliverable")
    }
  }

  func testUnverifiedEmailLabel_isHidden_whenEmailIsVerified() {
    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    self.unverifiedEmailLabelHidden.assertValues([true], "Email is verified & deliverable")
  }

  func testUnverifiedEmailLabel_isNotHidden_whenEmailIsUnverified() {
    let userEmailFields = UserEmailFields.template
      |> \.isEmailVerified .~ false

    withEnvironment(apiService: MockService(fetchGraphUserEmailFieldsResponse: userEmailFields)) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.unverifiedEmailLabelHidden
        .assertValues([false], "Email is not verified, but deliverable")
    }
  }

  func testUnverifiedEmailLabel_isHidden_whenEmailIsUnverifiedAndUndeliverable() {
    let userEmailFields = UserEmailFields.template
      |> \.isDeliverable .~ false
      |> \.isEmailVerified .~ false

    withEnvironment(apiService: MockService(changeEmailResponse: UserEnvelope(me: userEmailFields))) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.unverifiedEmailLabelHidden
        .assertValues([true], "Email is not verified, but deliverable message takes precendent")
    }
  }

  func testDidFailToSendVerificationEmailEmits_OnFailure() {
    let error = GraphError.invalidInput

    withEnvironment(apiService: MockService(sendEmailVerificationError: error)) {
      self.vm.inputs.resendVerificationEmailButtonTapped()
      self.scheduler.advance()

      self.didFailToSendVerificationEmail.assertValue(GraphError.invalidInput.localizedDescription)
    }
  }

  func testDidSendVerificationEmailEmits_OnSuccess() {
    self.vm.inputs.resendVerificationEmailButtonTapped()
    self.scheduler.advance()

    self.didSendVerificationEmail.assertDidEmitValue()
  }

  func testVerificationEmailButtonTitle_Backer() {
    let user = User.template
      |> \.stats.createdProjectsCount .~ 0

    withEnvironment(currentUser: user) {
      self.vm.inputs.viewDidLoad()

      self.verificationEmailButtonTitle.assertValue(Strings.Send_verfication_email())
    }
  }

  func testVerificationEmailButtonTitle_Creator() {
    let user = User.template
      |> \.stats.createdProjectsCount .~ 1

    withEnvironment(currentUser: user) {
      self.vm.inputs.viewDidLoad()

      self.verificationEmailButtonTitle.assertValue(Strings.Resend_verification_email())
    }
  }

  func testDismissKeyboard_OnSuccess() {
    self.dismissKeyboard.assertDidNotEmitValue()

    self.vm.inputs.emailFieldTextDidChange(text: "new@email.com")
    self.vm.inputs.passwordFieldTextDidChange(text: "123456")

    self.vm.inputs.saveButtonTapped()

    self.dismissKeyboard.assertValueCount(1)

    self.vm.inputs.textFieldShouldReturn(with: .done)
    self.dismissKeyboard.assertValueCount(2)
  }

  func testDismissKeyboard_InvalidEmail() {
    self.dismissKeyboard.assertDidNotEmitValue()

    self.vm.inputs.emailFieldTextDidChange(text: "new@email.com.")
    self.vm.inputs.passwordFieldTextDidChange(text: "123456")

    self.vm.inputs.saveButtonIsEnabled(false)
    self.vm.inputs.textFieldShouldReturn(with: .done)

    self.dismissKeyboard.assertValueCount(1)
    self.didChangeEmail.assertDidNotEmitValue()
  }

  func testPasswordFieldBecomeFirstResponder_WhenTappingNext() {
    self.vm.inputs.viewDidLoad()
    self.passwordFieldBecomeFirstResponder.assertValueCount(0)

    self.vm.inputs.textFieldShouldReturn(with: .done)
    self.passwordFieldBecomeFirstResponder.assertValueCount(0)

    self.vm.inputs.textFieldShouldReturn(with: .next)
    self.passwordFieldBecomeFirstResponder.assertValueCount(1)
  }

  func testFieldsResetWithEmptyString_AfterChangingEmail() {
    self.vm.inputs.emailFieldTextDidChange(text: "ksr@kickstarter.com")
    self.vm.inputs.passwordFieldTextDidChange(text: "123456")
    self.vm.inputs.saveButtonIsEnabled(true)

    self.scheduler.advance()

    self.vm.inputs.emailFieldTextDidChange(text: "ksr@kickstarter.com")
    self.vm.inputs.passwordFieldTextDidChange(text: "123456")
    self.vm.inputs.saveButtonIsEnabled(true)

    self.vm.inputs.saveButtonTapped()

    self.scheduler.advance()

    self.resetFields.assertValue("")
  }

  func testTextFieldsAreEnabled() {
    self.vm.inputs.emailFieldTextDidChange(text: "ksr@kickstarter.com")
    self.vm.inputs.passwordFieldTextDidChange(text: "123456")

    self.vm.inputs.saveButtonIsEnabled(true)
    self.vm.inputs.saveButtonTapped()

    self.textFieldsAreEnabled.assertValues([false])

    self.scheduler.advance()

    self.textFieldsAreEnabled.assertValues([false, true])
  }

  func testTrackViewedChangeEmail() {
    let client = MockTrackingClient()

    withEnvironment(koala: Koala(client: client)) {
      XCTAssertEqual([], client.events)

      self.vm.inputs.viewDidAppear()

      XCTAssertEqual(["Viewed Change Email"], client.events)

      self.vm.inputs.viewDidAppear()

      XCTAssertEqual(["Viewed Change Email", "Viewed Change Email"], client.events)
    }
  }

  func testTrackChangeEmail() {
    let client = MockTrackingClient()

    withEnvironment(koala: Koala(client: client)) {
      XCTAssertEqual([], client.events)

      self.vm.inputs.emailFieldTextDidChange(text: "new@email.com")
      self.vm.inputs.passwordFieldTextDidChange(text: "123456")
      self.vm.inputs.saveButtonIsEnabled(true)
      self.vm.inputs.saveButtonTapped()

      self.scheduler.advance()

      XCTAssertEqual(["Changed Email"], client.events)

      self.vm.inputs.saveButtonIsEnabled(true)
      self.vm.inputs.saveButtonTapped()
      self.scheduler.advance()

      XCTAssertEqual(["Changed Email", "Changed Email"], client.events)
    }
  }

  func testTrackResendVerificationEmail() {
    let client = MockTrackingClient()

    withEnvironment(koala: Koala(client: client)) {
      XCTAssertEqual([], client.events)

      self.vm.inputs.resendVerificationEmailButtonTapped()
      self.scheduler.advance()

      XCTAssertEqual(["Resent Verification Email"], client.events)

      self.vm.inputs.resendVerificationEmailButtonTapped()
      self.scheduler.advance()

      XCTAssertEqual(["Resent Verification Email", "Resent Verification Email"], client.events)
    }
  }
}
