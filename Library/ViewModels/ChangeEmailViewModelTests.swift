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

  private let activityIndicatorShouldShow = TestObserver<Bool, NoError>()
  private let didChangeEmail = TestObserver<Void, NoError>()
  private let didFailToChangeEmail = TestObserver<String, NoError>()
  private let didFailToSendVerificationEmail = TestObserver<String, NoError>()
  private let didSendVerificationEmail = TestObserver<Void, NoError>()
  private let dismissKeyboard = TestObserver<(), NoError>()
  private let emailText = TestObserver<String, NoError>()
  private let onePasswordButtonHidden = TestObserver<Bool, NoError>()
  private let onePasswordFindLoginForURLString = TestObserver<String, NoError>()

  private let passwordFieldBecomeFirstResponder = TestObserver<Void, NoError>()
  private let resetFields = TestObserver<String, NoError>()
  private let shouldSubmitForm = TestObserver<Void, NoError>()
  private let messageLabelViewHiddenObserver = TestObserver<Bool, NoError>()
  private let passwordText = TestObserver<String, NoError>()
  private let resendVerificationEmailViewIsHiddenObserver = TestObserver<Bool, NoError>()
  private let saveButtonIsEnabled = TestObserver<Bool, NoError>()
  private let unverifiedEmailLabelHiddenObserver = TestObserver<Bool, NoError>()
  private let warningMessageLabelHiddenObserver = TestObserver<Bool, NoError>()
  private let verificationEmailButtonTitle = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.activityIndicatorShouldShow.observe(self.activityIndicatorShouldShow.observer)
    self.vm.outputs.didChangeEmail.observe(self.didChangeEmail.observer)
    self.vm.outputs.didFailToChangeEmail.observe(self.didFailToChangeEmail.observer)
    self.vm.outputs.emailText.observe(self.emailText.observer)

    self.vm.outputs.dismissKeyboard.observe(self.dismissKeyboard.observer)
    self.vm.outputs.messageLabelViewHidden.observe(self.messageLabelViewHiddenObserver.observer)
    self.vm.outputs.onePasswordButtonIsHidden.observe(self.onePasswordButtonHidden.observer)
    self.vm.outputs.onePasswordFindLoginForURLString.observe(self.onePasswordFindLoginForURLString.observer)
    self.vm.outputs.passwordFieldBecomeFirstResponder.observe(self.passwordFieldBecomeFirstResponder.observer)
    self.vm.outputs.passwordText.observe(self.passwordText.observer)
    self.vm.outputs.resendVerificationEmailViewIsHidden.observe(
      self.resendVerificationEmailViewIsHiddenObserver.observer
    )
    self.vm.outputs.didSendVerificationEmail.observe(
      self.didSendVerificationEmail.observer
    )
    self.vm.outputs.didFailToSendVerificationEmail.observe(
      self.didFailToSendVerificationEmail.observer
    )
    self.vm.outputs.resetFields.observe(self.resetFields.observer)
    self.vm.outputs.saveButtonIsEnabled.observe(self.saveButtonIsEnabled.observer)
    self.vm.outputs.shouldSubmitForm.observe(self.shouldSubmitForm.observer)
    self.vm.outputs.unverifiedEmailLabelHidden.observe(self.unverifiedEmailLabelHiddenObserver.observer)
    self.vm.outputs.warningMessageLabelHidden.observe(self.warningMessageLabelHiddenObserver.observer)
    self.vm.outputs.verificationEmailButtonTitle.observe(self.verificationEmailButtonTitle.observer)
  }

  func testDidChangeEmailEmits_OnSuccess() {

    self.vm.inputs.submitForm(newEmail: "ksr@kickstarter.com", password: "123456")
    self.scheduler.advance()

    self.didChangeEmail.assertDidEmitValue()
  }

  func testDidFailToChangeEmailEmits_OnFailure() {

    let error = GraphError.emptyResponse(nil)

    withEnvironment(apiService: MockService(changeEmailError: error)) {

      self.vm.inputs.saveButtonTapped(newEmail: "ksr@kickstarter.com", password: "123456")

      self.activityIndicatorShouldShow.assertValues([true])

      self.scheduler.advance()

      self.didFailToChangeEmail.assertDidEmitValue()

      self.activityIndicatorShouldShow.assertValues([true, false])
    }
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

  func testPasswordText_OnePassword() {

    self.vm.inputs.onePasswordFound(password: "123456")
    self.passwordText.assertValues(["123456"])
  }

  func testEmailText_AfterFetchingUsersEmail() {

    let response = UserEnvelope<UserEmailFields>(me: .template)

    withEnvironment(apiService: MockService(changeEmailResponse: response)) {

      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.emailText.assertValues(["ksr@kickstarter.com"])
    }
  }

  func testOnePasswordFindLoginForURLString() {

    self.vm.inputs.onePasswordButtonTapped()

    self.onePasswordFindLoginForURLString.assertValues(
      [AppEnvironment.current.apiService.serverConfig.webBaseUrl.absoluteString]
    )
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

  func testSaveButtonEnablesAfter_OnePasswordPrefillsField() {

    let response = UserEnvelope<UserEmailFields>(me: .template)

    withEnvironment(apiService: MockService(changeEmailResponse: response)) {

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.vm.inputs.emailFieldTextDidChange(text: "ksr@ksr.com")
      self.saveButtonIsEnabled.assertDidNotEmitValue()

      self.vm.inputs.onePasswordFound(password: "123456")
      self.saveButtonIsEnabled.assertValues([true])
    }
  }

  func testResendVerificationViewIsHidden_IfEmailIsVerified() {
    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    self.resendVerificationEmailViewIsHiddenObserver
      .assertValues([true], "Email is deliverable and verified")
  }

  func testResendVerificationViewIsNotHidden_IfEmailIsNotVerified() {
    let userEmailFields = UserEmailFields.template
      |> \.isEmailVerified .~ false

    let mockService = MockService(changeEmailResponse: UserEnvelope(me: userEmailFields))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.resendVerificationEmailViewIsHiddenObserver.assertValues([false], "Email is unverified")
    }
  }

  func testResendVerificationViewIsNotHidden_IfEmailIsUndeliverable() {
    let userEmailFields = UserEmailFields.template
      |> \.isDeliverable .~ false

    let mockService = MockService(changeEmailResponse: UserEnvelope(me: userEmailFields))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.resendVerificationEmailViewIsHiddenObserver
        .assertValues([false], "Email is undeliverable")
    }
  }

  func testWarningMessageLabel_isHidden() {
    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    self.warningMessageLabelHiddenObserver.assertValues([true], "Email is deliverable")
  }

  func testWarningMessageLabel_isNotHidden_whenEmailIsNotDeliverable() {
    let userEmailFields = UserEmailFields.template
      |> \.isDeliverable .~ false

    withEnvironment(apiService: MockService(changeEmailResponse: UserEnvelope(me: userEmailFields))) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.warningMessageLabelHiddenObserver
        .assertValues([false], "Email is not deliverable")
    }
  }

  func testUnverifiedEmailLabel_isHidden_whenEmailIsVerified() {
    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    self.unverifiedEmailLabelHiddenObserver.assertValues([true], "Email is verified & deliverable")
  }

  func testUnverifiedEmailLabel_isNotHidden_whenEmailIsUnverified() {
    let userEmailFields = UserEmailFields.template
      |> \.isEmailVerified .~ false

    withEnvironment(apiService: MockService(changeEmailResponse: UserEnvelope(me: userEmailFields))) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.unverifiedEmailLabelHiddenObserver
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

      self.unverifiedEmailLabelHiddenObserver
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

  func testDismissKeyboard() {

    self.dismissKeyboard.assertDidNotEmitValue()

    self.vm.inputs.submitForm(newEmail: "new@email.com", password: "123456")
    self.dismissKeyboard.assertValueCount(1)

    self.vm.inputs.submitForm(newEmail: "new@test.com", password: "123456")
    self.dismissKeyboard.assertValueCount(2)
  }

  func testPasswordFieldBecomeFirstResponder_WhenTappingNext() {

    self.vm.inputs.viewDidLoad()
    self.passwordFieldBecomeFirstResponder.assertValueCount(0)

    self.vm.inputs.textFieldShouldReturn(with: .go)
    self.passwordFieldBecomeFirstResponder.assertValueCount(0)

    self.vm.inputs.textFieldShouldReturn(with: .next)
    self.passwordFieldBecomeFirstResponder.assertValueCount(1)
  }

  func testFieldsResetWithEmptyString_AfterChangingEmail() {
    self.vm.inputs.submitForm(newEmail: "ksr@kickstarter.com", password: "123456")
    self.scheduler.advance()

    self.resetFields.assertValue("")
  }

  func testShouldSubmitFormEmits_WhenTappingSaveOrGo() {
    self.vm.inputs.viewDidLoad()
    self.shouldSubmitForm.assertValueCount(0)

    self.vm.inputs.textFieldShouldReturn(with: .go)
    self.shouldSubmitForm.assertValueCount(1)

    self.vm.inputs.saveButtonTapped(newEmail: "", password: "")
    self.shouldSubmitForm.assertValueCount(2)
  }
}
