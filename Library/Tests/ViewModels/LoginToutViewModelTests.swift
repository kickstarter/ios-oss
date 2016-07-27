import XCTest
@testable import KsApi
@testable import ReactiveCocoa
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import Result
@testable import Library
@testable import FBSDKLoginKit
@testable import FBSDKCoreKit

final class LoginToutViewModelTests: TestCase {
  private let vm: LoginToutViewModelType = LoginToutViewModel()
  private let startLogin = TestObserver<(), NoError>()
  private let startSignup = TestObserver<(), NoError>()
  private let startFacebookConfirmation = TestObserver<String, NoError>()
  private let startTwoFactorChallenge = TestObserver<String, NoError>()
  private let logIntoEnvironment = TestObserver<AccessTokenEnvelope, NoError>()
  private let postNotification = TestObserver<String, NoError>()
  private let attemptFacebookLogin = TestObserver<(), NoError>()
  private let isLoading = TestObserver<Bool, NoError>()
  private let showFacebookErrorAlert = TestObserver<AlertError, NoError>()
  private let dismissViewController = TestObserver<(), NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.startLogin.observe(self.startLogin.observer)
    self.vm.outputs.startSignup.observe(self.startSignup.observer)
    self.vm.outputs.startFacebookConfirmation.map { _, token in token }
      .observe(self.startFacebookConfirmation.observer)
    self.vm.outputs.startTwoFactorChallenge.observe(self.startTwoFactorChallenge.observer)
    self.vm.outputs.logIntoEnvironment.observe(self.logIntoEnvironment.observer)
    self.vm.outputs.postNotification.map { note in note.name }.observe(self.postNotification.observer)
    self.vm.outputs.attemptFacebookLogin.observe(self.attemptFacebookLogin.observer)
    self.vm.outputs.isLoading.observe(self.isLoading.observer)
    self.vm.outputs.showFacebookErrorAlert.observe(self.showFacebookErrorAlert.observer)
    self.vm.outputs.dismissViewController.observe(self.dismissViewController.observer)
  }

  func testLoginIntentTracking_Default() {
    XCTAssertEqual([], trackingClient.events, "Login tout did not track")

    vm.inputs.viewWillAppear()

    XCTAssertEqual(["Application Login or Signup"], trackingClient.events)
    XCTAssertEqual("login_tab", trackingClient.properties.last!["intent"] as? String)
  }

  func testKoala_whenLoginIntentBeforeViewAppears() {
    vm.inputs.loginIntent(.activity)
    vm.inputs.viewWillAppear()

    XCTAssertEqual(["Application Login or Signup"], trackingClient.events)
    XCTAssertEqual("activity", trackingClient.properties.last!["intent"] as? String)

    vm.inputs.viewWillAppear()

    XCTAssertEqual(["Application Login or Signup"], trackingClient.events)
    XCTAssertEqual("activity", trackingClient.properties.last!["intent"] as? String)
  }

  func testStartLogin() {
    vm.inputs.viewWillAppear()
    vm.inputs.loginButtonPressed()

    startLogin.assertValueCount(1, "Start login emitted")
  }

  func testStartSignup() {
    vm.inputs.viewWillAppear()
    vm.inputs.signupButtonPressed()

    startSignup.assertValueCount(1, "Start sign up emitted")
  }

  func testFacebookLoginFlow_Success() {
    let token = FBSDKAccessToken(
      tokenString: "12344566",
      permissions: nil,
      declinedPermissions: nil,
      appID: "834987809",
      userID: "0000000001",
      expirationDate: NSDate(),
      refreshDate: NSDate()
    )

    let result = FBSDKLoginManagerLoginResult(
      token: token,
      isCancelled: false,
      grantedPermissions: nil,
      declinedPermissions: nil
    )

    vm.inputs.viewWillAppear()

    attemptFacebookLogin.assertValueCount(0, "Attempt Facebook login did not emit")

    vm.inputs.facebookLoginButtonPressed()

    attemptFacebookLogin.assertValueCount(1, "Attempt Facebook login emitted")

    vm.inputs.facebookLoginSuccess(result: result)

    // Wait enough time for API request to be made.
    scheduler.advance()

    logIntoEnvironment.assertValueCount(1, "Log into environment.")
    XCTAssertEqual(["Application Login or Signup", "Logged In With Facebook", "Facebook Login"],
                   trackingClient.events, "Koala login is tracked")

    vm.inputs.environmentLoggedIn()
    postNotification.assertValues([CurrentUserNotifications.sessionStarted],
                                  "Login notification posted.")

    showFacebookErrorAlert.assertValueCount(0, "Facebook login error did not emit")
    startFacebookConfirmation.assertValueCount(0, "Facebook confirmation did not emit")
  }

  func testLoginFacebookFlow_AttemptFail() {
    let error = NSError(domain: "facebook.com",
                        code: 404,
                        userInfo: [
                          FBSDKErrorLocalizedTitleKey: "Facebook Login Fail",
                          FBSDKErrorLocalizedDescriptionKey: "Something went wrong yo."
      ])

    vm.inputs.viewWillAppear()

    attemptFacebookLogin.assertValueCount(0, "Attempt Facebook login did not emit")
    showFacebookErrorAlert.assertValueCount(0, "Facebook login error did not emit")

    vm.inputs.facebookLoginButtonPressed()

    attemptFacebookLogin.assertValueCount(1, "Attempt Facebook login emitted")
    showFacebookErrorAlert.assertValueCount(0, "Facebook login fail does not emit")

    vm.inputs.facebookLoginFail(error: error)

    showFacebookErrorAlert.assertValues([AlertError.facebookLoginAttemptFail(error: error)],
                                     "Show Facebook Attempt Login error")
    XCTAssertEqual(["Application Login or Signup", "Errored Facebook Login"], trackingClient.events)
  }

  func testLoginFacebookFlow_AttemptFail_WithDefaultMessage() {
    let error = NSError(domain: "facebook.com",
                        code: 404,
                        userInfo: [:])

    vm.inputs.viewWillAppear()

    attemptFacebookLogin.assertValueCount(0, "Attempt Facebook login did not emit")
    showFacebookErrorAlert.assertValueCount(0, "Facebook login error did not emit")

    vm.inputs.facebookLoginButtonPressed()

    attemptFacebookLogin.assertValueCount(1, "Attempt Facebook login emitted")
    showFacebookErrorAlert.assertValueCount(0, "Facebook login fail does not emit")

    vm.inputs.facebookLoginFail(error: error)

    showFacebookErrorAlert.assertValues([AlertError.facebookLoginAttemptFail(error: error)],
                                     "Show Facebook Attempt Login error")
    XCTAssertEqual(["Application Login or Signup", "Errored Facebook Login"], trackingClient.events)
  }

  func testLoginFacebookFlow_InvalidTokenFail() {
    let token = FBSDKAccessToken(
      tokenString: "spaghetti",
      permissions: nil,
      declinedPermissions: nil,
      appID: "834987809",
      userID: "0000000001",
      expirationDate: NSDate(),
      refreshDate: NSDate()
    )

    let result = FBSDKLoginManagerLoginResult(
      token: token,
      isCancelled: false,
      grantedPermissions: nil,
      declinedPermissions: nil
    )

    let error = ErrorEnvelope(
      errorMessages: ["Couldn't log into Facebook."],
      ksrCode: .FacebookInvalidAccessToken,
      httpCode: 403,
      exception: nil
    )

    withEnvironment(apiService: MockService(loginError: error)) {
      vm.inputs.viewWillAppear()

      showFacebookErrorAlert.assertValueCount(0, "Facebook login fail does not emit")

      vm.inputs.facebookLoginSuccess(result: result)

      // Wait enough time for API request to be made.
      scheduler.advance()

      showFacebookErrorAlert.assertValues([AlertError.facebookTokenFail],
                                       "Show Facebook token fail error")
      XCTAssertEqual(["Application Login or Signup", "Errored Facebook Login"], trackingClient.events)
    }
  }

  func testLoginFacebookFlow_GenericFail() {
    let token = FBSDKAccessToken(
      tokenString: "12344566",
      permissions: nil,
      declinedPermissions: nil,
      appID: "834987809",
      userID: "0000000001",
      expirationDate: NSDate(),
      refreshDate: NSDate()
    )

    let result = FBSDKLoginManagerLoginResult(
      token: token,
      isCancelled: false,
      grantedPermissions: nil,
      declinedPermissions: nil
    )

    let error = ErrorEnvelope(
      errorMessages: ["Something went wrong."],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    withEnvironment(apiService: MockService(loginError: error)) {
      vm.inputs.viewWillAppear()
      vm.inputs.facebookLoginSuccess(result: result)

      // Wait enough time for API request to be made.
      scheduler.advance()

      showFacebookErrorAlert.assertValues([AlertError.genericFacebookError(envelope: error)],
                                       "Show Facebook account taken error")
      XCTAssertEqual(["Application Login or Signup", "Errored Facebook Login"], trackingClient.events)
    }
  }

  func testLoginFacebookFlow_GenericFail_WithDefaultMessage() {
    let token = FBSDKAccessToken(
      tokenString: "12344566",
      permissions: nil,
      declinedPermissions: nil,
      appID: "834987809",
      userID: "0000000001",
      expirationDate: NSDate(),
      refreshDate: NSDate()
    )

    let result = FBSDKLoginManagerLoginResult(
      token: token,
      isCancelled: false,
      grantedPermissions: nil,
      declinedPermissions: nil
    )

    let error = ErrorEnvelope(
      errorMessages: [],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    withEnvironment(apiService: MockService(loginError: error)) {
      vm.inputs.viewWillAppear()
      vm.inputs.facebookLoginSuccess(result: result)

      // Wait enough time for API request to be made.
      scheduler.advance()

      showFacebookErrorAlert.assertValues([AlertError.genericFacebookError(envelope: error)],
                                       "Show Facebook account taken error")
      XCTAssertEqual(["Application Login or Signup", "Errored Facebook Login"], trackingClient.events)
    }
  }

  func testStartTwoFactorChallenge() {
    let token = FBSDKAccessToken(
      tokenString: "12344566",
      permissions: nil,
      declinedPermissions: nil,
      appID: "834987809",
      userID: "0000000001",
      expirationDate: NSDate(),
      refreshDate: NSDate()
    )

    let result = FBSDKLoginManagerLoginResult(
      token: token,
      isCancelled: false,
      grantedPermissions: nil,
      declinedPermissions: nil
    )

    let error = ErrorEnvelope(
      errorMessages: ["Two Factor Authenticaion is required."],
      ksrCode: .TfaRequired,
      httpCode: 403,
      exception: nil
    )

    withEnvironment(apiService: MockService(loginError: error)) {
      vm.inputs.viewWillAppear()
      vm.inputs.facebookLoginSuccess(result: result)

      startTwoFactorChallenge.assertDidNotEmitValue()

      // Wait enough time for API request to be made.
      scheduler.advance()

      startTwoFactorChallenge.assertValues(["12344566"], "TFA challenge emitted with token")
      logIntoEnvironment.assertValueCount(0, "Did not log into environment.")
      showFacebookErrorAlert.assertValueCount(0, "Facebook login fail does not emit")
      startFacebookConfirmation.assertValueCount(0, "Facebook confirmation did not emit")
      XCTAssertEqual(["Application Login or Signup"], trackingClient.events, "Login error was not tracked")
    }
  }

  func testStartFacebookConfirmation() {
    let token = FBSDKAccessToken(
      tokenString: "12344566",
      permissions: nil,
      declinedPermissions: nil,
      appID: "834987809",
      userID: "0000000001",
      expirationDate: NSDate(),
      refreshDate: NSDate()
    )

    let result = FBSDKLoginManagerLoginResult(
      token: token,
      isCancelled: false,
      grantedPermissions: nil,
      declinedPermissions: nil
    )

    let error = ErrorEnvelope(
      errorMessages: ["Confirm Facebook Signup"],
      ksrCode: .ConfirmFacebookSignup,
      httpCode: 403,
      exception: nil
    )

    withEnvironment(apiService: MockService(loginError: error)) {
      vm.inputs.viewWillAppear()
      vm.inputs.facebookLoginSuccess(result: result)

      // Wait enough time for API request to be made.
      scheduler.advance()

      startFacebookConfirmation.assertValues(["12344566"], "Start Facebook confirmation emitted with token")

      logIntoEnvironment.assertValueCount(0, "Did not log into environment.")
      showFacebookErrorAlert.assertValueCount(0, "Facebook login fail does not emit")
      XCTAssertEqual(["Application Login or Signup"], trackingClient.events, "Login error was not tracked")

      self.vm.inputs.viewWillAppear()

      startFacebookConfirmation.assertValues(["12344566"], "Facebook confirmation didn't start again.")

      vm.inputs.facebookLoginSuccess(result: result)
      scheduler.advance()

      startFacebookConfirmation.assertValues(["12344566", "12344566"],
                                             "Start Facebook confirmation emitted with token")
    }
  }

  func testDismissalWhenNotPresented() {
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.view(isPresented: false)
    self.vm.inputs.userSessionStarted()

    self.dismissViewController.assertValueCount(0)
  }

  func testDismissalWhenPresented() {
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.view(isPresented: true)
    self.vm.inputs.userSessionStarted()

    self.dismissViewController.assertValueCount(1)
  }
}
