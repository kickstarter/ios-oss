@testable import FBSDKCoreKit
@testable import FBSDKLoginKit
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class LoginToutViewModelTests: TestCase {
  fileprivate let vm: LoginToutViewModelType = LoginToutViewModel()

  fileprivate let attemptFacebookLogin = TestObserver<(), Never>()
  fileprivate let dismissViewController = TestObserver<(), Never>()
  fileprivate let facebookButtonTitleText = TestObserver<String, Never>()
  fileprivate let headlineLabelHidden = TestObserver<Bool, Never>()
  fileprivate let isLoading = TestObserver<Bool, Never>()
  fileprivate let logInContextText = TestObserver<String, Never>()
  fileprivate let logIntoEnvironment = TestObserver<AccessTokenEnvelope, Never>()
  fileprivate let postNotification = TestObserver<(Notification.Name, Notification.Name), Never>()
  fileprivate let showFacebookErrorAlert = TestObserver<AlertError, Never>()
  fileprivate let startFacebookConfirmation = TestObserver<String, Never>()
  fileprivate let startLogin = TestObserver<(), Never>()
  fileprivate let startSignup = TestObserver<(), Never>()
  fileprivate let startTwoFactorChallenge = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.attemptFacebookLogin.observe(self.attemptFacebookLogin.observer)
    self.vm.outputs.dismissViewController.observe(self.dismissViewController.observer)
    self.vm.outputs.facebookButtonTitleText.observe(self.facebookButtonTitleText.observer)
    self.vm.outputs.headlineLabelHidden.observe(self.headlineLabelHidden.observer)
    self.vm.outputs.isLoading.observe(self.isLoading.observer)
    self.vm.outputs.logInContextText.observe(self.logInContextText.observer)
    self.vm.outputs.logIntoEnvironment.observe(self.logIntoEnvironment.observer)
    self.vm.outputs.postNotification.map { ($0.0.name, $0.1.name) }.observe(self.postNotification.observer)
    self.vm.outputs.showFacebookErrorAlert.observe(self.showFacebookErrorAlert.observer)
    self.vm.outputs.startFacebookConfirmation.map { _, token in token }
      .observe(self.startFacebookConfirmation.observer)
    self.vm.outputs.startLogin.observe(self.startLogin.observer)
    self.vm.outputs.startSignup.observe(self.startSignup.observer)
    self.vm.outputs.startTwoFactorChallenge.observe(self.startTwoFactorChallenge.observer)
  }

  func testLoginIntentTracking_Default() {
    self.vm.inputs.configureWith(.loginTab, project: nil, reward: nil)

    XCTAssertEqual([], trackingClient.events, "Login tout did not track")

    self.vm.inputs.viewWillAppear()

    XCTAssertEqual(["Log In or Signup Page Viewed"], trackingClient.events)
    XCTAssertEqual("login_tab", trackingClient.properties.last?["login_intent"] as? String)
  }

  func testLoginIntent_Pledge() {
    let reward = Reward.template
      |> Reward.lens.id .~ 10
    let project = Project.template
      |> Project.lens.id .~ 2

    self.vm.inputs.configureWith(.backProject, project: project, reward: reward)
    self.vm.inputs.viewWillAppear()

    XCTAssertEqual(["Log In or Signup Page Viewed"], self.trackingClient.events)
    XCTAssertEqual(["pledge"], self.trackingClient.properties(forKey: "login_intent"))
    XCTAssertEqual(
      [2], self.trackingClient.properties(forKey: "project_pid", as: Int.self),
      "Tracking properties contain project properties"
    )
    XCTAssertEqual(
      [10], self.trackingClient.properties(forKey: "pledge_backer_reward_id", as: Int.self),
      "Tracking properties contain pledge properties"
    )
  }

  func testKoala_whenLoginIntentBeforeViewAppears() {
    self.vm.inputs.configureWith(.activity, project: nil, reward: nil)
    self.vm.inputs.viewWillAppear()

    XCTAssertEqual(["Log In or Signup Page Viewed"], trackingClient.events)
    XCTAssertEqual("activity", trackingClient.properties.last!["login_intent"] as? String)

    self.vm.inputs.viewWillAppear()

    XCTAssertEqual(
      ["Log In or Signup Page Viewed"],
      trackingClient.events,
      "Only tracks the first time the view appears"
    )
    XCTAssertEqual("activity", trackingClient.properties.last!["login_intent"] as? String)
  }

  func testStartLogin() {
    self.vm.inputs.configureWith(.activity, project: nil, reward: nil)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.loginButtonPressed()

    self.startLogin.assertValueCount(1, "Start login emitted")

    XCTAssertEqual(["Log In or Signup Page Viewed", "Log In Button Clicked"], self.trackingClient.events)
    XCTAssertEqual(["activity", "activity"], self.trackingClient.properties(forKey: "login_intent"))
    XCTAssertEqual([nil, nil], self.trackingClient.properties(forKey: "project_pid"))
    XCTAssertEqual([nil, nil], self.trackingClient.properties(forKey: "pledge_backer_reward_id"))
  }

  func testStartLogin_PledgeIntent() {
    self.vm.inputs.configureWith(.backProject, project: .template, reward: .template)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.loginButtonPressed()

    self.startLogin.assertValueCount(1)

    XCTAssertEqual(["Log In or Signup Page Viewed", "Log In Button Clicked"], self.trackingClient.events)
    XCTAssertEqual(["pledge", "pledge"], self.trackingClient.properties(forKey: "login_intent"))
    XCTAssertEqual([1, 1], self.trackingClient.properties(forKey: "project_pid", as: Int.self))
    XCTAssertEqual([1, 1], self.trackingClient.properties(forKey: "pledge_backer_reward_id", as: Int.self))
  }

  func testStartSignup() {
    self.vm.inputs.configureWith(.activity, project: nil, reward: nil)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.signupButtonPressed()

    self.startSignup.assertValueCount(1, "Start sign up emitted")

    XCTAssertEqual(["Log In or Signup Page Viewed", "Signup Button Clicked"], self.trackingClient.events)
    XCTAssertEqual(["activity", "activity"], self.trackingClient.properties(forKey: "login_intent"))
    XCTAssertEqual([nil, nil], self.trackingClient.properties(forKey: "project_pid"))
    XCTAssertEqual([nil, nil], self.trackingClient.properties(forKey: "pledge_backer_reward_id"))
  }

  func testStartSignup_PledgeIntent() {
    self.vm.inputs.configureWith(.backProject, project: .template, reward: .template)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.signupButtonPressed()

    self.startSignup.assertValueCount(1)

    XCTAssertEqual(["Log In or Signup Page Viewed", "Signup Button Clicked"], self.trackingClient.events)
    XCTAssertEqual(["pledge", "pledge"], self.trackingClient.properties(forKey: "login_intent"))
    XCTAssertEqual([1, 1], self.trackingClient.properties(forKey: "project_pid", as: Int.self))
    XCTAssertEqual([1, 1], self.trackingClient.properties(forKey: "pledge_backer_reward_id", as: Int.self))
  }

  func testHeadlineLabelHidden() {
    self.vm.inputs.configureWith(.starProject, project: nil, reward: nil)
    self.vm.inputs.viewWillAppear()

    self.headlineLabelHidden.assertValues([true])
  }

  func testHeadlineLabelShown() {
    self.vm.inputs.configureWith(.generic, project: nil, reward: nil)
    self.vm.inputs.viewWillAppear()

    self.headlineLabelHidden.assertValues([false])
  }

  func testLoginContextText() {
    self.vm.inputs.configureWith(.starProject, project: nil, reward: nil)
    self.vm.inputs.viewWillAppear()

    self.logInContextText.assertValues(
      ["Log in or sign up to save this project. We’ll remind you 48 hours before it ends."],
      "Emits login Context Text"
    )
  }

  func testFacebookLoginFlow_Success() {
    let token = AccessToken(
      tokenString: "12344566",
      permissions: [],
      declinedPermissions: [],
      expiredPermissions: [],
      appID: "834987809",
      userID: "0000000001",
      expirationDate: Date(),
      refreshDate: Date(),
      dataAccessExpirationDate: Date()
    )

    let result = LoginManagerLoginResult(
      token: token,
      isCancelled: false,
      grantedPermissions: [],
      declinedPermissions: []
    )

    vm.inputs.configureWith(.generic, project: nil, reward: nil)
    self.vm.inputs.viewWillAppear()

    self.attemptFacebookLogin.assertValueCount(0, "Attempt Facebook login did not emit")

    self.vm.inputs.facebookLoginButtonPressed()

    self.attemptFacebookLogin.assertValueCount(1, "Attempt Facebook login emitted")

    self.vm.inputs.facebookLoginSuccess(result: result)

    // Wait enough time for API request to be made.
    scheduler.advance()

    self.logIntoEnvironment.assertValueCount(1, "Log into environment.")
    XCTAssertEqual(
      [
        "Log In or Signup Page Viewed",
        "Facebook Log In or Signup Button Clicked"
      ],
      trackingClient.events
    )

    self.vm.inputs.environmentLoggedIn()
    XCTAssertEqual(self.postNotification.values.first?.0, .ksr_sessionStarted, "Login notification posted.")
    XCTAssertEqual(
      self.postNotification.values.first?.1, .ksr_showNotificationsDialog,
      "Contextual Dialog notification posted."
    )

    self.showFacebookErrorAlert.assertValueCount(0, "Facebook login error did not emit")
    self.startFacebookConfirmation.assertValueCount(0, "Facebook confirmation did not emit")
  }

  func testLoginFacebookFlow_AttemptFail() {
    let error = NSError(
      domain: "facebook.com",
      code: 404,
      userInfo: [
        ErrorLocalizedTitleKey: "Facebook Login Fail",
        ErrorLocalizedDescriptionKey: "Something went wrong yo."
      ]
    )

    vm.inputs.configureWith(.generic, project: nil, reward: nil)
    self.vm.inputs.viewWillAppear()

    self.attemptFacebookLogin.assertValueCount(0, "Attempt Facebook login did not emit")
    self.showFacebookErrorAlert.assertValueCount(0, "Facebook login error did not emit")

    self.vm.inputs.facebookLoginButtonPressed()

    self.attemptFacebookLogin.assertValueCount(1, "Attempt Facebook login emitted")
    self.showFacebookErrorAlert.assertValueCount(0, "Facebook login fail does not emit")

    self.vm.inputs.facebookLoginFail(error: error)

    self.showFacebookErrorAlert.assertValues(
      [AlertError.facebookLoginAttemptFail(error: error)],
      "Show Facebook Attempt Login error"
    )
    XCTAssertEqual(
      [
        "Log In or Signup Page Viewed",
        "Facebook Log In or Signup Button Clicked"
      ],
      trackingClient.events
    )
  }

  func testLoginFacebookFlow_AttemptFail_WithDefaultMessage() {
    let error = NSError(
      domain: "facebook.com",
      code: 404,
      userInfo: [:]
    )

    vm.inputs.configureWith(.generic, project: nil, reward: nil)
    self.vm.inputs.viewWillAppear()

    self.attemptFacebookLogin.assertValueCount(0, "Attempt Facebook login did not emit")
    self.showFacebookErrorAlert.assertValueCount(0, "Facebook login error did not emit")

    self.vm.inputs.facebookLoginButtonPressed()

    self.attemptFacebookLogin.assertValueCount(1, "Attempt Facebook login emitted")
    self.showFacebookErrorAlert.assertValueCount(0, "Facebook login fail does not emit")

    self.vm.inputs.facebookLoginFail(error: error)

    self.showFacebookErrorAlert.assertValues(
      [AlertError.facebookLoginAttemptFail(error: error)],
      "Show Facebook Attempt Login error"
    )
    XCTAssertEqual(
      [
        "Log In or Signup Page Viewed",
        "Facebook Log In or Signup Button Clicked"
      ],
      trackingClient.events
    )
  }

  func testLoginFacebookFlow_InvalidTokenFail() {
    let token = AccessToken(
      tokenString: "spaghetti",
      permissions: [],
      declinedPermissions: [],
      expiredPermissions: [],
      appID: "834987809",
      userID: "0000000001",
      expirationDate: Date(),
      refreshDate: Date(),
      dataAccessExpirationDate: Date()
    )

    let result = LoginManagerLoginResult(
      token: token,
      isCancelled: false,
      grantedPermissions: [],
      declinedPermissions: []
    )

    let error = ErrorEnvelope(
      errorMessages: ["Couldn't log into Facebook."],
      ksrCode: .FacebookInvalidAccessToken,
      httpCode: 403,
      exception: nil
    )

    withEnvironment(apiService: MockService(loginError: error)) {
      vm.inputs.configureWith(.generic, project: nil, reward: nil)
      vm.inputs.viewWillAppear()

      showFacebookErrorAlert.assertValueCount(0, "Facebook login fail does not emit")

      vm.inputs.facebookLoginButtonPressed()
      vm.inputs.facebookLoginSuccess(result: result)

      // Wait enough time for API request to be made.
      scheduler.advance()

      showFacebookErrorAlert.assertValues([AlertError.facebookTokenFail], "Show Facebook token fail error")
      XCTAssertEqual(
        [
          "Log In or Signup Page Viewed",
          "Facebook Log In or Signup Button Clicked"
        ],
        trackingClient.events
      )
    }
  }

  func testLoginFacebookFlow_GenericFail() {
    let token = AccessToken(
      tokenString: "12344566",
      permissions: [],
      declinedPermissions: [],
      expiredPermissions: [],
      appID: "834987809",
      userID: "0000000001",
      expirationDate: Date(),
      refreshDate: Date(),
      dataAccessExpirationDate: Date()
    )

    let result = LoginManagerLoginResult(
      token: token,
      isCancelled: false,
      grantedPermissions: [],
      declinedPermissions: []
    )

    let error = ErrorEnvelope(
      errorMessages: ["Something went wrong."],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    withEnvironment(apiService: MockService(loginError: error)) {
      vm.inputs.configureWith(.generic, project: nil, reward: nil)
      vm.inputs.viewWillAppear()

      vm.inputs.facebookLoginButtonPressed()
      vm.inputs.facebookLoginSuccess(result: result)

      // Wait enough time for API request to be made.
      scheduler.advance()

      showFacebookErrorAlert.assertValues(
        [AlertError.genericFacebookError(envelope: error)],
        "Show Facebook account taken error"
      )
      XCTAssertEqual(
        [
          "Log In or Signup Page Viewed",
          "Facebook Log In or Signup Button Clicked"
        ],
        trackingClient.events
      )
    }
  }

  func testLoginFacebookFlow_GenericFail_WithDefaultMessage() {
    let token = AccessToken(
      tokenString: "12344566",
      permissions: [],
      declinedPermissions: [],
      expiredPermissions: [],
      appID: "834987809",
      userID: "0000000001",
      expirationDate: Date(),
      refreshDate: Date(),
      dataAccessExpirationDate: Date()
    )

    let result = LoginManagerLoginResult(
      token: token,
      isCancelled: false,
      grantedPermissions: [],
      declinedPermissions: []
    )

    let error = ErrorEnvelope(
      errorMessages: [],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    withEnvironment(apiService: MockService(loginError: error)) {
      vm.inputs.configureWith(.generic, project: nil, reward: nil)
      vm.inputs.viewWillAppear()

      vm.inputs.facebookLoginButtonPressed()
      vm.inputs.facebookLoginSuccess(result: result)

      // Wait enough time for API request to be made.
      scheduler.advance()

      showFacebookErrorAlert.assertValues(
        [AlertError.genericFacebookError(envelope: error)],
        "Show Facebook account taken error"
      )
      XCTAssertEqual(
        [
          "Log In or Signup Page Viewed",
          "Facebook Log In or Signup Button Clicked"
        ],
        trackingClient.events
      )
    }
  }

  func testStartTwoFactorChallenge() {
    let token = AccessToken(
      tokenString: "12344566",
      permissions: [],
      declinedPermissions: [],
      expiredPermissions: [],
      appID: "834987809",
      userID: "0000000001",
      expirationDate: Date(),
      refreshDate: Date(),
      dataAccessExpirationDate: Date()
    )

    let result = LoginManagerLoginResult(
      token: token,
      isCancelled: false,
      grantedPermissions: [],
      declinedPermissions: []
    )

    let error = ErrorEnvelope(
      errorMessages: ["Two Factor Authenticaion is required."],
      ksrCode: .TfaRequired,
      httpCode: 403,
      exception: nil
    )

    withEnvironment(apiService: MockService(loginError: error)) {
      vm.inputs.configureWith(.generic, project: nil, reward: nil)
      vm.inputs.viewWillAppear()

      vm.inputs.facebookLoginButtonPressed()
      vm.inputs.facebookLoginSuccess(result: result)

      startTwoFactorChallenge.assertDidNotEmitValue()

      // Wait enough time for API request to be made.
      scheduler.advance()

      startTwoFactorChallenge.assertValues(["12344566"], "TFA challenge emitted with token")
      logIntoEnvironment.assertValueCount(0, "Did not log into environment.")
      showFacebookErrorAlert.assertValueCount(0, "Facebook login fail does not emit")
      startFacebookConfirmation.assertValueCount(0, "Facebook confirmation did not emit")
      XCTAssertEqual(
        [
          "Log In or Signup Page Viewed",
          "Facebook Log In or Signup Button Clicked"
        ],
        trackingClient.events
      )
    }
  }

  func testStartFacebookConfirmation() {
    let token = AccessToken(
      tokenString: "12344566",
      permissions: [],
      declinedPermissions: [],
      expiredPermissions: [],
      appID: "834987809",
      userID: "0000000001",
      expirationDate: Date(),
      refreshDate: Date(),
      dataAccessExpirationDate: Date()
    )

    let result = LoginManagerLoginResult(
      token: token,
      isCancelled: false,
      grantedPermissions: [],
      declinedPermissions: []
    )

    let error = ErrorEnvelope(
      errorMessages: ["Confirm Facebook Signup"],
      ksrCode: .ConfirmFacebookSignup,
      httpCode: 403,
      exception: nil
    )

    withEnvironment(apiService: MockService(loginError: error)) {
      vm.inputs.configureWith(.generic, project: nil, reward: nil)
      vm.inputs.viewWillAppear()

      vm.inputs.facebookLoginButtonPressed()
      vm.inputs.facebookLoginSuccess(result: result)

      // Wait enough time for API request to be made.
      scheduler.advance()

      startFacebookConfirmation.assertValues(["12344566"], "Start Facebook confirmation emitted with token")

      logIntoEnvironment.assertValueCount(0, "Did not log into environment.")
      showFacebookErrorAlert.assertValueCount(0, "Facebook login fail does not emit")
      XCTAssertEqual(
        [
          "Log In or Signup Page Viewed",
          "Facebook Log In or Signup Button Clicked"
        ],
        trackingClient.events
      )

      self.vm.inputs.viewWillAppear()

      startFacebookConfirmation.assertValues(["12344566"], "Facebook confirmation didn't start again.")

      vm.inputs.facebookLoginButtonPressed()
      vm.inputs.facebookLoginSuccess(result: result)
      scheduler.advance()

      startFacebookConfirmation.assertValues(
        ["12344566", "12344566"],
        "Start Facebook confirmation emitted with token"
      )

      XCTAssertEqual(
        [
          "Log In or Signup Page Viewed",
          "Facebook Log In or Signup Button Clicked",
          "Facebook Log In or Signup Button Clicked"
        ],
        trackingClient.events
      )
    }
  }

  func testDismissalWhenNotPresented() {
    self.vm.inputs.configureWith(.generic, project: nil, reward: nil)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.view(isPresented: false)
    self.vm.inputs.userSessionStarted()

    self.dismissViewController.assertValueCount(0)
  }

  func testDismissalWhenPresented() {
    self.vm.inputs.configureWith(.generic, project: nil, reward: nil)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.view(isPresented: true)
    self.vm.inputs.userSessionStarted()

    self.dismissViewController.assertValueCount(1)
  }

  func testFacebookButtonTitle() {
    self.vm.inputs.configureWith(.backProject, project: nil, reward: nil)
    self.vm.inputs.viewWillAppear()

    self.facebookButtonTitleText.assertValues(["Continue with Facebook"])

    self.vm.inputs.configureWith(.loginTab, project: nil, reward: nil)
    self.vm.inputs.viewWillAppear()
    self.facebookButtonTitleText.assertValues(["Continue with Facebook", "Log in with Facebook"])
  }
}
