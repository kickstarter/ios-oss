@testable import FBSDKLoginKit
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class LoginToutViewModelTests: TestCase {
  fileprivate var vm: LoginToutViewModelType!

  fileprivate let attemptAppleLogin = TestObserver<(), Never>()
  fileprivate let attemptFacebookLogin = TestObserver<(), Never>()
  fileprivate let didSignInWithApple = TestObserver<SignInWithAppleEnvelope, Never>()
  fileprivate let dismissViewController = TestObserver<(), Never>()
  fileprivate let headlineLabelHidden = TestObserver<Bool, Never>()
  fileprivate let isLoading = TestObserver<Bool, Never>()
  fileprivate let logInContextText = TestObserver<String, Never>()
  fileprivate let logIntoEnvironmentWithApple = TestObserver<AccessTokenEnvelope, Never>()
  fileprivate let logIntoEnvironmentWithFacebook = TestObserver<AccessTokenEnvelope, Never>()
  fileprivate let postNotification = TestObserver<(Notification.Name, Notification.Name), Never>()
  fileprivate let showAppleErrorAlert = TestObserver<String, Never>()
  fileprivate let showFacebookErrorAlert = TestObserver<AlertError, Never>()
  fileprivate let startFacebookConfirmation = TestObserver<String, Never>()
  fileprivate let startLogin = TestObserver<(), Never>()
  fileprivate let startSignup = TestObserver<(), Never>()
  fileprivate let startTwoFactorChallenge = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm = LoginToutViewModel()

    self.vm.outputs.attemptAppleLogin.observe(self.attemptAppleLogin.observer)
    self.vm.outputs.attemptFacebookLogin.observe(self.attemptFacebookLogin.observer)
    self.vm.outputs.dismissViewController.observe(self.dismissViewController.observer)
    self.vm.outputs.headlineLabelHidden.observe(self.headlineLabelHidden.observer)
    self.vm.outputs.isLoading.observe(self.isLoading.observer)
    self.vm.outputs.logInContextText.observe(self.logInContextText.observer)
    self.vm.outputs.logIntoEnvironmentWithApple.observe(self.logIntoEnvironmentWithApple.observer)
    self.vm.outputs.logIntoEnvironmentWithFacebook.observe(self.logIntoEnvironmentWithFacebook.observer)
    self.vm.outputs.postNotification.map { ($0.0.name, $0.1.name) }.observe(self.postNotification.observer)
    self.vm.outputs.showAppleErrorAlert.observe(self.showAppleErrorAlert.observer)
    self.vm.outputs.showFacebookErrorAlert.observe(self.showFacebookErrorAlert.observer)
    self.vm.outputs.startFacebookConfirmation.map { _, token in token }
      .observe(self.startFacebookConfirmation.observer)
    self.vm.outputs.startLogin.observe(self.startLogin.observer)
    self.vm.outputs.startSignup.observe(self.startSignup.observer)
    self.vm.outputs.startTwoFactorChallenge.observe(self.startTwoFactorChallenge.observer)
  }

  func testLoginIntent_Pledge() {
    let reward = Reward.template
      |> Reward.lens.id .~ 10
    let project = Project.template
      |> Project.lens.id .~ 2

    self.vm.inputs.configureWith(.backProject, project: project, reward: reward)
    self.vm.inputs.viewWillAppear()

    self.logInContextText.assertValues(
      ["Please log in or sign up to back this project."],
      "Emits login Context Text"
    )
  }

  func testStartLogin() {
    self.vm.inputs.configureWith(.activity, project: nil, reward: nil)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.loginButtonPressed()

    self.startLogin.assertValueCount(1, "Start login emitted")

    self.logInContextText.assertValues(
      ["Pledge to projects and view all your saved and backed projects in one place."],
      "Emits login Context Text"
    )
  }

  func testStartLogin_PledgeIntent() {
    self.vm.inputs.configureWith(.backProject, project: .template, reward: .template)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.loginButtonPressed()

    self.startLogin.assertValueCount(1)

    self.logInContextText.assertValues(
      ["Please log in or sign up to back this project."],
      "Emits login with pledge intent Context Text"
    )
  }

  func testStartSignup() {
    self.vm.inputs.configureWith(.activity, project: nil, reward: nil)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.signupButtonPressed()

    self.startSignup.assertValueCount(1, "Start sign up emitted")

    self.logInContextText.assertValues(
      ["Pledge to projects and view all your saved and backed projects in one place."],
      "Emits Signup Context Text"
    )
  }

  func testStartSignup_PledgeIntent() {
    self.vm.inputs.configureWith(.backProject, project: .template, reward: .template)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.signupButtonPressed()

    self.startSignup.assertValueCount(1)

    self.logInContextText.assertValues(
      ["Please log in or sign up to back this project."],
      "Emits Signup with pledge login Context Text"
    )
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

  func testFacebookLoginFlow_Success_WhenFBLoginDeprecationFlagEnabled() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.facebookLoginDeprecationEnabled.rawValue: true]

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
      authenticationToken: nil,
      isCancelled: false,
      grantedPermissions: [],
      declinedPermissions: []
    )

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      vm.inputs.configureWith(.generic, project: nil, reward: nil)
      self.vm.inputs.viewWillAppear()

      self.attemptFacebookLogin.assertValueCount(0, "Attempt Facebook login did not emit")

      self.vm.inputs.facebookLoginButtonPressed()

      self.attemptFacebookLogin.assertValueCount(1, "Attempt Facebook login emitted")

      self.vm.inputs.facebookLoginSuccess(result: result)

      self.isLoading.assertValues([true])

      // Wait enough time for API request to be made.
      scheduler.advance()

      self.isLoading.assertValues([true, false])
      self.logIntoEnvironmentWithFacebook.assertValueCount(1, "Log into environment.")

      self.postNotification.assertDidNotEmitValue()

      self.scheduler.advance()

      // Notifications are not posted on the next run loop
      XCTAssert(self.postNotification.values.isEmpty)

      self.showFacebookErrorAlert.assertValueCount(0, "Facebook login error did not emit")
      self.startFacebookConfirmation.assertValueCount(0, "Facebook confirmation did not emit")
    }
  }

  func testFacebookLoginFlow_Success_WhenFBLoginDeprecationFlagDisabled() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.facebookLoginDeprecationEnabled.rawValue: true]

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
      authenticationToken: nil,
      isCancelled: false,
      grantedPermissions: [],
      declinedPermissions: []
    )

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      vm.inputs.configureWith(.generic, project: nil, reward: nil)
      self.vm.inputs.viewWillAppear()

      self.attemptFacebookLogin.assertValueCount(0, "Attempt Facebook login did not emit")

      self.vm.inputs.facebookLoginButtonPressed()

      self.attemptFacebookLogin.assertValueCount(1, "Attempt Facebook login emitted")

      self.vm.inputs.facebookLoginSuccess(result: result)

      self.isLoading.assertValues([true])

      // Wait enough time for API request to be made.
      scheduler.advance()

      self.isLoading.assertValues([true, false])
      self.logIntoEnvironmentWithFacebook.assertValueCount(1, "Log into environment.")

      self.vm.inputs.environmentLoggedIn()

      self.postNotification.assertDidNotEmitValue()

      self.scheduler.advance()

      // Notifications are posted on the next run loop
      XCTAssertEqual(self.postNotification.values.first?.0, .ksr_sessionStarted, "Login notification posted.")
      XCTAssertEqual(
        self.postNotification.values.first?.1, .ksr_showNotificationsDialog,
        "Contextual Dialog notification posted."
      )

      self.showFacebookErrorAlert.assertValueCount(0, "Facebook login error did not emit")
      self.startFacebookConfirmation.assertValueCount(0, "Facebook confirmation did not emit")
    }
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

    self.isLoading.assertDidNotEmitValue()
    self.attemptFacebookLogin.assertValueCount(1, "Attempt Facebook login emitted")
    self.showFacebookErrorAlert.assertValueCount(0, "Facebook login fail does not emit")

    self.vm.inputs.facebookLoginFail(error: error)

    self.isLoading.assertDidNotEmitValue()
    self.showFacebookErrorAlert.assertValues(
      [AlertError.facebookLoginAttemptFail(error: error)],
      "Show Facebook Attempt Login error"
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

    self.isLoading.assertDidNotEmitValue()
    self.attemptFacebookLogin.assertValueCount(1, "Attempt Facebook login emitted")
    self.showFacebookErrorAlert.assertValueCount(0, "Facebook login fail does not emit")

    self.vm.inputs.facebookLoginFail(error: error)

    self.isLoading.assertDidNotEmitValue()
    self.showFacebookErrorAlert.assertValues(
      [AlertError.facebookLoginAttemptFail(error: error)],
      "Show Facebook Attempt Login error"
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
      authenticationToken: nil,
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

      self.isLoading.assertValues([true])
      // Wait enough time for API request to be made.
      scheduler.advance()

      self.isLoading.assertValues([true, false])
      showFacebookErrorAlert.assertValues([AlertError.facebookTokenFail], "Show Facebook token fail error")
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
      authenticationToken: nil,
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

      self.isLoading.assertValues([true])
      // Wait enough time for API request to be made.
      scheduler.advance()

      self.isLoading.assertValues([true, false])
      showFacebookErrorAlert.assertValues(
        [AlertError.genericFacebookError(envelope: error)],
        "Show Facebook account taken error"
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
      authenticationToken: nil,
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

      self.isLoading.assertValues([true])
      // Wait enough time for API request to be made.
      scheduler.advance()

      self.isLoading.assertValues([true, false])
      showFacebookErrorAlert.assertValues(
        [AlertError.genericFacebookError(envelope: error)],
        "Show Facebook account taken error"
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
      authenticationToken: nil,
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

      self.isLoading.assertValues([true])
      // Wait enough time for API request to be made.
      scheduler.advance()

      self.isLoading.assertValues([true, false])
      self.startTwoFactorChallenge.assertValues(["12344566"], "TFA challenge emitted with token")
      self.logIntoEnvironmentWithApple.assertValueCount(0, "Did not log into environment.")
      self.logIntoEnvironmentWithFacebook.assertValueCount(0, "Did not log into environment.")
      self.showFacebookErrorAlert.assertValueCount(0, "Facebook login fail does not emit")
      self.startFacebookConfirmation.assertValueCount(0, "Facebook confirmation did not emit")
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
      authenticationToken: nil,
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

      self.isLoading.assertValues([true])
      // Wait enough time for API request to be made.
      scheduler.advance()

      self.isLoading.assertValues([true, false])
      self.startFacebookConfirmation.assertValues(
        ["12344566"],
        "Start Facebook confirmation emitted with token"
      )
      self.logIntoEnvironmentWithFacebook.assertValueCount(0, "Did not log into environment.")
      self.showFacebookErrorAlert.assertValueCount(0, "Facebook login fail does not emit")

      self.vm.inputs.viewWillAppear()

      self.startFacebookConfirmation.assertValues(["12344566"], "Facebook confirmation didn't start again.")

      self.vm.inputs.facebookLoginButtonPressed()
      self.vm.inputs.facebookLoginSuccess(result: result)

      self.isLoading.assertValues([true, false, true])
      scheduler.advance()

      self.isLoading.assertValues([true, false, true, false])
      startFacebookConfirmation.assertValues(
        ["12344566", "12344566"],
        "Start Facebook confirmation emitted with token"
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

  func testShowAppleErrorAlert_DoesNotEmitWhen_CancellingSignInWithAppleModal() {
    self.vm.inputs.configureWith(.generic, project: nil, reward: nil)
    self.vm.inputs.viewWillAppear()

    self.vm.inputs.appleAuthorizationDidFail(with: .canceled)

    self.showAppleErrorAlert.assertDidNotEmitValue()
  }

  func testShowAppleErrorAlert_AppleAuthorizationError() {
    let error = NSError(
      domain: "notonlinesorry", code: -1_234, userInfo: [NSLocalizedDescriptionKey: "Not online sorry"]
    )

    self.vm.inputs.configureWith(.generic, project: nil, reward: nil)
    self.vm.inputs.viewWillAppear()

    self.vm.inputs.appleAuthorizationDidFail(with: .other(error))

    self.showAppleErrorAlert.assertValue("Not online sorry")
  }

  func testShowAppleErrorAlert_SignInWithAppleMutationError() {
    withEnvironment(apiService: MockService(signInWithAppleResult: .failure(.couldNotParseJSON))) {
      self.vm.inputs.configureWith(.generic, project: nil, reward: nil)
      self.vm.inputs.viewWillAppear()

      let data = SignInWithAppleData(
        appId: "com.kickstarter.test",
        firstName: "Nino",
        lastName: "Teixeira",
        token: "apple_auth_token"
      )

      self.isLoading.assertDidNotEmitValue()
      self.showAppleErrorAlert.assertDidNotEmitValue()

      self.vm.inputs.appleAuthorizationDidSucceed(with: data)

      self.isLoading.assertValues([true])
      scheduler.advance()

      self.isLoading.assertValues([true, false])
      self.showAppleErrorAlert.assertValue("Something went wrong.")
    }
  }

  func testShowAppleErrorAlert_FetchUserEventError() {
    let envelope = SignInWithAppleEnvelope.template
      |> \.signInWithApple.apiAccessToken .~ "some_token"

    withEnvironment(apiService: MockService(
      fetchUserResult: .failure(.couldNotParseJSON),
      signInWithAppleResult: .success(envelope)
    )) {
      self.vm.inputs.configureWith(.generic, project: nil, reward: nil)
      self.vm.inputs.viewWillAppear()

      let data = SignInWithAppleData(
        appId: "com.kickstarter.test",
        firstName: "Nino",
        lastName: "Teixeira",
        token: "apple_auth_token"
      )

      self.isLoading.assertDidNotEmitValue()
      self.showAppleErrorAlert.assertDidNotEmitValue()

      self.vm.inputs.appleAuthorizationDidSucceed(with: data)

      self.isLoading.assertValues([true])
      self.scheduler.advance()

      self.isLoading.assertValues([true, false])
      self.showAppleErrorAlert.assertValue(
        "Something went wrong."
      )
    }
  }

  func testLogIntoEnvironment_SignInWithApple_WhenFBLoginDeprecationFlagDisabled() {
    let user = User.template

    let envelope = SignInWithAppleEnvelope.template
      |> \.signInWithApple.apiAccessToken .~ "some_token"

    let service = MockService(fetchUserResult: .success(user), signInWithAppleResult: .success(envelope))

    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.facebookLoginDeprecationEnabled.rawValue: false]

    withEnvironment(apiService: service, optimizelyClient: mockOptimizelyClient) {
      self.vm.inputs.configureWith(.generic, project: nil, reward: nil)
      self.vm.inputs.viewWillAppear()

      let data = SignInWithAppleData(
        appId: "com.kickstarter.test",
        firstName: "Nino",
        lastName: "Teixeira",
        token: "apple_auth_token"
      )

      self.isLoading.assertDidNotEmitValue()
      self.logIntoEnvironmentWithApple.assertDidNotEmitValue()

      self.vm.inputs.appleAuthorizationDidSucceed(with: data)

      self.isLoading.assertValues([true])
      self.scheduler.run()

      self.isLoading.assertValues([true, false])
      self.logIntoEnvironmentWithApple.assertValueCount(1)

      let value = self.logIntoEnvironmentWithApple.values.first

      XCTAssertEqual(user, value?.user)
      XCTAssertEqual("some_token", value?.accessToken)
    }
  }

  func testLogIntoEnvironment_SignInWithApple_WhenFBLoginDeprecationFlagEnabled() {
    let user = User.template

    let envelope = SignInWithAppleEnvelope.template
      |> \.signInWithApple.apiAccessToken .~ "some_token"

    let service = MockService(fetchUserResult: .success(user), signInWithAppleResult: .success(envelope))

    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.facebookLoginDeprecationEnabled.rawValue: true]

    withEnvironment(apiService: service, optimizelyClient: mockOptimizelyClient) {
      self.vm.inputs.configureWith(.generic, project: nil, reward: nil)
      self.vm.inputs.viewWillAppear()

      let data = SignInWithAppleData(
        appId: "com.kickstarter.test",
        firstName: "Nino",
        lastName: "Teixeira",
        token: "apple_auth_token"
      )

      self.isLoading.assertDidNotEmitValue()
      self.logIntoEnvironmentWithApple.assertDidNotEmitValue()

      self.vm.inputs.appleAuthorizationDidSucceed(with: data)

      self.isLoading.assertValues([true])
      self.scheduler.run()

      self.isLoading.assertValues([true, false])
      self.logIntoEnvironmentWithApple.assertValueCount(1)

      let value = self.logIntoEnvironmentWithApple.values.first

      XCTAssertEqual(user, value?.user)
      XCTAssertEqual("some_token", value?.accessToken)
    }
  }

  func testAttemptAppleLogin_Tracking() {
    self.vm.inputs.configureWith(.generic, project: nil, reward: nil)
    self.vm.inputs.viewWillAppear()

    self.attemptAppleLogin.assertDidNotEmitValue()

    self.vm.inputs.appleLoginButtonPressed()

    self.attemptAppleLogin.assertValueCount(1)
  }
}
