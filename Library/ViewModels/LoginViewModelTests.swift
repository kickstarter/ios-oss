// swiftlint:disable force_unwrapping
import Prelude
import XCTest
@testable import Library
@testable import KsApi
@testable import ReactiveSwift
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import Result

final class LoginViewModelTests: TestCase {
  fileprivate let vm: LoginViewModelType = LoginViewModel()
  fileprivate let emailTextFieldBecomeFirstResponder = TestObserver<(), NoError>()
  fileprivate let passwordTextFieldBecomeFirstResponder = TestObserver<(), NoError>()
  fileprivate let isFormValid = TestObserver<Bool, NoError>()
  fileprivate let dismissKeyboard = TestObserver<(), NoError>()
  fileprivate let postNotificationName = TestObserver<Notification.Name, NoError>()
  fileprivate let logIntoEnvironment = TestObserver<AccessTokenEnvelope, NoError>()
  fileprivate let showError = TestObserver<String, NoError>()
  fileprivate let tfaChallenge = TestObserver<String, NoError>()
  fileprivate let emailText = TestObserver<String, NoError>()
  fileprivate let tfaChallengePasswordText = TestObserver<String, NoError>()
  fileprivate let onePasswordButtonHidden = TestObserver<Bool, NoError>()
  fileprivate let onePasswordFindLoginForURLString = TestObserver<String, NoError>()
  fileprivate let passwordText = TestObserver<String, NoError>()

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
    
    XCTAssertEqual([false, nil],
                   self.trackingClient.properties(forKey: "1password_extension_available", as: Bool.self))
    
    XCTAssertEqual([nil, false],
                   self.trackingClient.properties(forKey: "one_password_extension_available", as: Bool.self))
    
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
    self.logIntoEnvironment.assertValueCount(1, "Log into environment.")
    XCTAssertEqual(["User Login", "Viewed Login", "Login", "Logged In"], trackingClient.events,
                   "Koala login is tracked")
    XCTAssertEqual("Email", trackingClient.properties.last!["auth_type"] as? String)

    self.vm.inputs.environmentLoggedIn()
    self.postNotificationName.assertValues([.ksr_sessionStarted],
                                           "Login notification posted.")

    self.showError.assertValueCount(0, "Error did not happen")
    self.tfaChallenge.assertValueCount(0, "TFA challenge did not happen")
  }

  func testBecomefirstResponder() {
    self.vm.inputs.viewDidLoad()
    self.emailTextFieldBecomeFirstResponder.assertValueCount(1, "Email starts as first responder.")
    self.passwordTextFieldBecomeFirstResponder.assertDidNotEmitValue("Not first responder yet.")

    self.vm.inputs.emailTextFieldDoneEditing()
    self.emailTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit another value.")
    self.passwordTextFieldBecomeFirstResponder.assertValueCount(1, "Password becomes first responder.")

    self.vm.inputs.passwordTextFieldDoneEditing()
    self.emailTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit another value.")
    self.passwordTextFieldBecomeFirstResponder.assertValueCount(1, "Does not emit another value.")
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
      XCTAssertEqual(["User Login", "Viewed Login", "Errored User Login", "Errored Login"],
                     trackingClient.events)
      XCTAssertEqual("Email", trackingClient.properties.last!["auth_type"] as? String)
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
      XCTAssertEqual(["User Login", "Viewed Login", "Errored User Login", "Errored Login"],
                     trackingClient.events)
      XCTAssertEqual("Email", trackingClient.properties.last!["auth_type"] as? String)
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

    XCTAssertEqual([true, nil],
                   self.trackingClient.properties(forKey: "1password_extension_available", as: Bool.self))
    
    XCTAssertEqual([nil, true],
                   self.trackingClient.properties(forKey: "one_password_extension_available", as: Bool.self))
    
    self.onePasswordButtonHidden.assertValues([false])

    self.vm.inputs.onePasswordButtonTapped()

    self.onePasswordFindLoginForURLString.assertValues(
      [AppEnvironment.current.apiService.serverConfig.webBaseUrl.absoluteString]
    )

    self.vm.inputs.onePasswordFoundLogin(email: "nativesquad@gmail.com", password: "hello")

    self.emailText.assertValues(["nativesquad@gmail.com"])
    self.passwordText.assertValues(["hello"])
    self.logIntoEnvironment.assertValueCount(1, "Log into environment.")
    XCTAssertEqual(["User Login", "Viewed Login", "Login", "Logged In", "Attempting 1password Login",
      "Triggered 1Password"], self.trackingClient.events, "Koala login is tracked")

    self.vm.inputs.environmentLoggedIn()
    self.postNotificationName.assertValues([.ksr_sessionStarted],
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
      XCTAssertEqual(["User Login", "Viewed Login", "Attempting 1password Login", "Triggered 1Password"],
                     self.trackingClient.events,
                     "Tfa Challenge error was not tracked")
      self.showError.assertValueCount(0, "Login error did not happen")
      self.tfaChallenge.assertValues(["nativesquad@gmail.com"],
                                     "Two factor challenge emitted with email and password")
    }
  }
}
