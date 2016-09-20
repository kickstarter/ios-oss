import Prelude
import XCTest
@testable import Library
@testable import KsApi
@testable import ReactiveCocoa
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import Result

final class LoginViewModelTests: TestCase {
  private let vm: LoginViewModelType = LoginViewModel()
  private let emailTextFieldBecomeFirstResponder = TestObserver<(), NoError>()
  private let passwordTextFieldBecomeFirstResponder = TestObserver<(), NoError>()
  private let isFormValid = TestObserver<Bool, NoError>()
  private let dismissKeyboard = TestObserver<(), NoError>()
  private let postNotificationName = TestObserver<String, NoError>()
  private let logIntoEnvironment = TestObserver<AccessTokenEnvelope, NoError>()
  private let showError = TestObserver<String, NoError>()
  private let tfaChallenge = TestObserver<String, NoError>()
  private let emailText = TestObserver<String, NoError>()
  private let tfaChallengePasswordText = TestObserver<String, NoError>()
  private let onePasswordButtonHidden = TestObserver<Bool, NoError>()
  private let onePasswordFindLoginForURLString = TestObserver<String, NoError>()
  private let passwordText = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.emailTextFieldBecomeFirstResponder
      .observe(self.emailTextFieldBecomeFirstResponder.observer)
    self.vm.outputs.passwordTextFieldBecomeFirstResponder
      .observe(self.passwordTextFieldBecomeFirstResponder.observer)
    self.vm.outputs.isFormValid.observe(self.isFormValid.observer)
    self.vm.outputs.dismissKeyboard.observe(self.dismissKeyboard.observer)
    self.vm.outputs.postNotification.map { $0.name }.observe(self.postNotificationName.observer)
    self.vm.outputs.logIntoEnvironment.observe(self.logIntoEnvironment.observer)
    self.vm.outputs.showError.observe(self.showError.observer)
    self.vm.outputs.tfaChallenge.map { $0.email }.observe(self.tfaChallenge.observer)
    self.vm.outputs.tfaChallenge.map { $0.password }.observe(self.tfaChallengePasswordText.observer)
    self.vm.outputs.emailText.observe(self.emailText.observer)
    self.vm.outputs.onePasswordButtonHidden.observe(self.onePasswordButtonHidden.observer)
    self.vm.outputs.onePasswordFindLoginForURLString.observe(self.onePasswordFindLoginForURLString.observer)
    self.vm.outputs.passwordText.observe(self.passwordText.observer)
  }

  func testLoginFlow() {
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.onePassword(isAvailable: false)

    self.emailTextFieldBecomeFirstResponder
      .assertValueCount(1, "Email field is first responder when view loads.")

    XCTAssertEqual(["User Login", "Viewed Login"], trackingClient.events, "Koala login is tracked")
    XCTAssertEqual([false, false],
                   self.trackingClient.properties(forKey: "1password_extension_available", as: Bool.self))
    XCTAssertEqual([true, nil],
                   self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self))
    self.isFormValid.assertValues([false], "Form is not valid")

    self.vm.inputs.emailChanged("Gina@rules.com")
    self.isFormValid.assertValues([false], "Form is not valid")

    self.vm.inputs.emailTextFieldDoneEditing()
    self.passwordTextFieldBecomeFirstResponder
      .assertValueCount(1, "Password textfield becomes first responder when done editing email.")
    self.emailTextFieldBecomeFirstResponder
      .assertValueCount(1, "Does not emit again.")

    self.vm.inputs.passwordChanged("hello")
    self.isFormValid.assertValues([false, true], "Form is valid")

    self.vm.inputs.passwordTextFieldDoneEditing()
    self.dismissKeyboard.assertValueCount(1, "Keyboard is dismissed")

    self.vm.inputs.loginButtonPressed()
    self.logIntoEnvironment.assertValueCount(1, "Log into environment.")
    XCTAssertEqual(["User Login", "Viewed Login", "Logged In", "Login"], trackingClient.events,
                   "Koala login is tracked")

    self.vm.inputs.environmentLoggedIn()
    self.postNotificationName.assertValues([CurrentUserNotifications.sessionStarted],
                                           "Login notification posted.")

    self.showError.assertValueCount(0, "Error did not happen")
    self.tfaChallenge.assertValueCount(0, "TFA challenge did not happen")
  }

  func testLoginError() {
    let error = ErrorEnvelope(
      errorMessages: ["Unable to log in."],
      ksrCode: .InvalidXauthLogin,
      httpCode: 400,
      exception: nil
    )

    withEnvironment(apiService: MockService(loginError: error)) {
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.onePassword(isAvailable: false)
      self.vm.inputs.emailChanged("nativesquad@kickstarter.com")
      self.vm.inputs.passwordChanged("helloooooo")
      self.vm.inputs.loginButtonPressed()

      self.logIntoEnvironment.assertValueCount(0, "Did not log into environment.")
      XCTAssertEqual(["User Login", "Viewed Login", "Errored User Login"], trackingClient.events)
      self.showError.assertValues(["Unable to log in."], "Login errored")
      self.tfaChallenge.assertValueCount(0, "TFA challenge did not happen")
    }
  }

  func testLoginError_WithNoErrorMessage() {
    let error = ErrorEnvelope(
      errorMessages: [],
      ksrCode: .InvalidXauthLogin,
      httpCode: 400,
      exception: nil
    )

    withEnvironment(apiService: MockService(loginError: error)) {
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.onePassword(isAvailable: false)
      self.vm.inputs.emailChanged("nativesquad@kickstarter.com")
      self.vm.inputs.passwordChanged("helloooooo")
      self.vm.inputs.loginButtonPressed()

      self.logIntoEnvironment.assertValueCount(0, "Did not log into environment.")
      XCTAssertEqual(["User Login", "Viewed Login", "Errored User Login"], trackingClient.events)
      self.showError.assertValues([Strings.login_errors_unable_to_log_in()], "Login errored")
      self.tfaChallenge.assertValueCount(0, "TFA challenge did not happen")
    }
  }

  func testTfaChallenge() {
    let error = ErrorEnvelope(
      errorMessages: ["Two Factor Authenticaion is required."],
      ksrCode: .TfaRequired,
      httpCode: 403,
      exception: nil
    )

    withEnvironment(apiService: MockService(loginError: error)) {
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.onePassword(isAvailable: false)
      self.vm.inputs.emailChanged("nativesquad@kickstarter.com")
      self.vm.inputs.passwordChanged("helloooooo")
      self.vm.inputs.loginButtonPressed()

      self.logIntoEnvironment.assertValueCount(0, "Did not log into environment.")
      XCTAssertEqual(["User Login", "Viewed Login"],
                     self.trackingClient.events, "Tfa Challenge error was not tracked")
      self.showError.assertValueCount(0, "Login error did not happen")
      self.tfaChallenge.assertValues(["nativesquad@kickstarter.com"],
                                     "Two factor challenge emitted with email and password")
      self.tfaChallengePasswordText.assertValues(["helloooooo"], "Two factor challenge emitted with password")
    }
  }

  func testOnePasswordButtonHidesWhenNotAvailable() {
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.onePassword(isAvailable: false)

    self.onePasswordButtonHidden.assertValues([true])
  }

  func testOnePasswordFlow() {
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.onePassword(isAvailable: true)

    XCTAssertEqual([true, true],
                   self.trackingClient.properties(forKey: "1password_extension_available", as: Bool.self))
    self.onePasswordButtonHidden.assertValues([false])

    self.vm.inputs.onePasswordButtonTapped()

    self.onePasswordFindLoginForURLString.assertValues(
      [optionalize(AppEnvironment.current.apiService.serverConfig.webBaseUrl.absoluteString)].compact()
    )

    self.vm.inputs.onePasswordFoundLogin(email: "nativesquad@gmail.com", password: "hello")

    self.emailText.assertValues(["nativesquad@gmail.com"])
    self.passwordText.assertValues(["hello"])
    self.logIntoEnvironment.assertValueCount(1, "Log into environment.")
    XCTAssertEqual(["User Login", "Viewed Login", "Logged In", "Login", "Attempting 1password Login"],
                   self.trackingClient.events,
                   "Koala login is tracked")

    self.vm.inputs.environmentLoggedIn()
    self.postNotificationName.assertValues([CurrentUserNotifications.sessionStarted],
                                      "Login notification posted.")

    self.showError.assertValueCount(0, "Error did not happen")
    self.tfaChallenge.assertValueCount(0, "TFA challenge did not happen")
  }

  func testOnePasswordWithTfaFlow() {
    let error = ErrorEnvelope(
      errorMessages: ["Two Factor Authenticaion is required."],
      ksrCode: .TfaRequired,
      httpCode: 403,
      exception: nil
    )

    withEnvironment(apiService: MockService(loginError: error)) {
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.onePassword(isAvailable: true)
      self.vm.inputs.onePasswordButtonTapped()
      self.vm.inputs.onePasswordFoundLogin(email: "nativesquad@gmail.com", password: "hello")

      self.logIntoEnvironment.assertValueCount(0, "Did not log into environment.")
      XCTAssertEqual(["User Login", "Viewed Login", "Attempting 1password Login"], self.trackingClient.events,
                     "Tfa Challenge error was not tracked")
      self.showError.assertValueCount(0, "Login error did not happen")
      self.tfaChallenge.assertValues(["nativesquad@gmail.com"],
                                     "Two factor challenge emitted with email and password")
    }
  }
}
