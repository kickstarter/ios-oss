import XCTest
@testable import KsApi
@testable import ReactiveCocoa
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import Result
@testable import Library

final class LoginViewModelTests: TestCase {
  private let vm: LoginViewModelType = LoginViewModel()
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
    vm.inputs.viewWillAppear()
    vm.inputs.onePassword(isAvailable: false)

    XCTAssertEqual(["User Login", "Viewed Login"], trackingClient.events, "Koala login is tracked")
    XCTAssertEqual([false, false],
                   self.trackingClient.properties(forKey: "1password_extension_available", as: Bool.self))
    XCTAssertEqual([true, nil],
                   self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self))
    isFormValid.assertValues([false], "Form is not valid")

    vm.inputs.emailChanged("Gina@rules.com")
    isFormValid.assertValues([false], "Form is not valid")

    vm.inputs.emailTextFieldDoneEditing()
    passwordTextFieldBecomeFirstResponder.assertValueCount(1, "Password textfield becomes first responder")

    vm.inputs.passwordChanged("hello")
    isFormValid.assertValues([false, true], "Form is valid")

    vm.inputs.passwordTextFieldDoneEditing()
    dismissKeyboard.assertValueCount(1, "Keyboard is dismissed")

    vm.inputs.loginButtonPressed()
    logIntoEnvironment.assertValueCount(1, "Log into environment.")
    XCTAssertEqual(["User Login", "Viewed Login", "Login"], trackingClient.events, "Koala login is tracked")

    vm.inputs.environmentLoggedIn()
    postNotificationName.assertValues([CurrentUserNotifications.sessionStarted],
                                      "Login notification posted.")

    showError.assertValueCount(0, "Error did not happen")
    tfaChallenge.assertValueCount(0, "TFA challenge did not happen")
  }

  func testLoginError() {
    let error = ErrorEnvelope(
      errorMessages: ["Unable to log in."],
      ksrCode: .InvalidXauthLogin,
      httpCode: 400,
      exception: nil
    )

    withEnvironment(apiService: MockService(loginError: error)) {
      vm.inputs.viewWillAppear()
      vm.inputs.onePassword(isAvailable: false)
      vm.inputs.emailChanged("nativesquad@kickstarter.com")
      vm.inputs.passwordChanged("helloooooo")
      vm.inputs.loginButtonPressed()

      logIntoEnvironment.assertValueCount(0, "Did not log into environment.")
      XCTAssertEqual(["User Login", "Viewed Login", "Errored User Login"], trackingClient.events)
      showError.assertValues(["Unable to log in."], "Login errored")
      tfaChallenge.assertValueCount(0, "TFA challenge did not happen")
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
      vm.inputs.viewWillAppear()
      vm.inputs.onePassword(isAvailable: false)
      vm.inputs.emailChanged("nativesquad@kickstarter.com")
      vm.inputs.passwordChanged("helloooooo")
      vm.inputs.loginButtonPressed()

      logIntoEnvironment.assertValueCount(0, "Did not log into environment.")
      XCTAssertEqual(["User Login", "Viewed Login", "Errored User Login"], trackingClient.events)
      self.showError.assertValues([Strings.login_errors_unable_to_log_in()], "Login errored")
      tfaChallenge.assertValueCount(0, "TFA challenge did not happen")
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
      vm.inputs.viewWillAppear()
      vm.inputs.onePassword(isAvailable: false)
      vm.inputs.emailChanged("nativesquad@kickstarter.com")
      vm.inputs.passwordChanged("helloooooo")
      vm.inputs.loginButtonPressed()

      logIntoEnvironment.assertValueCount(0, "Did not log into environment.")
      XCTAssertEqual(["User Login", "Viewed Login"],
                     self.trackingClient.events, "Tfa Challenge error was not tracked")
      showError.assertValueCount(0, "Login error did not happen")
      tfaChallenge.assertValues(["nativesquad@kickstarter.com"],
                                "Two factor challenge emitted with email and password")
      tfaChallengePasswordText.assertValues(["helloooooo"], "Two factor challenge emitted with password")
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
      [AppEnvironment.current.apiService.serverConfig.webBaseUrl.absoluteString]
    )

    self.vm.inputs.onePasswordFoundLogin(email: "nativesquad@gmail.com", password: "hello")

    self.emailText.assertValues(["nativesquad@gmail.com"])
    self.passwordText.assertValues(["hello"])
    self.logIntoEnvironment.assertValueCount(1, "Log into environment.")
    XCTAssertEqual(["User Login", "Viewed Login", "Login", "Attempting 1password Login"],
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

      logIntoEnvironment.assertValueCount(0, "Did not log into environment.")
      XCTAssertEqual(["User Login", "Viewed Login", "Attempting 1password Login"], self.trackingClient.events,
                     "Tfa Challenge error was not tracked")
      showError.assertValueCount(0, "Login error did not happen")
      tfaChallenge.assertValues(["nativesquad@gmail.com"],
                                "Two factor challenge emitted with email and password")
    }
  }
}
