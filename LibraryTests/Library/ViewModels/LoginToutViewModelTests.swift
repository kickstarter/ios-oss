@testable import KsApi
@testable import KsApiTestHelpers
@testable import Library
@testable import LibraryTestHelpers
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class LoginToutViewModelTests: TestCase {
  fileprivate var vm: LoginToutViewModelType!

  fileprivate let attemptAppleLogin = TestObserver<(), Never>()
  fileprivate let didSignInWithApple = TestObserver<SignInWithAppleEnvelope, Never>()
  fileprivate let dismissViewController = TestObserver<(), Never>()
  fileprivate let headlineLabelHidden = TestObserver<Bool, Never>()
  fileprivate let isLoading = TestObserver<Bool, Never>()
  fileprivate let logInContextText = TestObserver<String, Never>()
  fileprivate let logIntoEnvironmentWithApple = TestObserver<AccessTokenEnvelope, Never>()
  fileprivate let postNotification = TestObserver<(Notification.Name, Notification.Name), Never>()
  fileprivate let showAppleErrorAlert = TestObserver<String, Never>()
  fileprivate let startOAuthSignupOrLogin = TestObserver<(), Never>()

  override func setUp() {
    super.setUp()

    self.vm = LoginToutViewModel()

    self.vm.outputs.attemptAppleLogin.observe(self.attemptAppleLogin.observer)
    self.vm.outputs.dismissViewController.observe(self.dismissViewController.observer)
    self.vm.outputs.headlineLabelHidden.observe(self.headlineLabelHidden.observer)
    self.vm.outputs.isLoading.observe(self.isLoading.observer)
    self.vm.outputs.logInContextText.observe(self.logInContextText.observer)
    self.vm.outputs.logIntoEnvironmentWithApple.observe(self.logIntoEnvironmentWithApple.observer)
    self.vm.outputs.postNotification.map { ($0.0.name, $0.1.name) }.observe(self.postNotification.observer)
    self.vm.outputs.showAppleErrorAlert.observe(self.showAppleErrorAlert.observer)
    self.vm.outputs.startOAuthSignupOrLogin.observe(self.startOAuthSignupOrLogin.observer)
  }

  func testLoginIntent_Pledge() {
    self.vm.inputs.configureWith(.backProject)
    self.vm.inputs.viewWillAppear()

    self.logInContextText.assertValues(
      ["Please log in or sign up to back this project."],
      "Emits login Context Text"
    )
  }

  func testStartSignupOrLoginWithOAuth() {
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.signupOrLoginWithOAuthButtonPressed()
    self.startOAuthSignupOrLogin.assertValueCount(1, "OAuth signup/loginlogin emitted")
  }

  func testHeadlineLabelHidden() {
    self.vm.inputs.configureWith(.starProject)
    self.vm.inputs.viewWillAppear()

    self.headlineLabelHidden.assertValues([true])
  }

  func testHeadlineLabelShown() {
    self.vm.inputs.configureWith(.generic)
    self.vm.inputs.viewWillAppear()

    self.headlineLabelHidden.assertValues([false])
  }

  func testLoginContextText() {
    self.vm.inputs.configureWith(.starProject)
    self.vm.inputs.viewWillAppear()

    self.logInContextText.assertValues(
      ["Log in or sign up to save this project. We’ll remind you 48 hours before it ends."],
      "Emits login Context Text"
    )
  }

  func testDismissalWhenNotPresented() {
    self.vm.inputs.configureWith(.generic)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.view(isPresented: false)
    self.vm.inputs.userSessionStarted()

    self.dismissViewController.assertValueCount(0)
  }

  func testDismissalWhenPresented() {
    self.vm.inputs.configureWith(.generic)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.view(isPresented: true)
    self.vm.inputs.userSessionStarted()

    self.dismissViewController.assertValueCount(1)
  }

  func testShowAppleErrorAlert_DoesNotEmitWhen_CancellingSignInWithAppleModal() {
    self.vm.inputs.configureWith(.generic)
    self.vm.inputs.viewWillAppear()

    self.vm.inputs.appleAuthorizationDidFail(with: .canceled)

    self.showAppleErrorAlert.assertDidNotEmitValue()
  }

  func testShowAppleErrorAlert_AppleAuthorizationError() {
    let error = NSError(
      domain: "notonlinesorry", code: -1_234, userInfo: [NSLocalizedDescriptionKey: "Not online sorry"]
    )

    self.vm.inputs.configureWith(.generic)
    self.vm.inputs.viewWillAppear()

    self.vm.inputs.appleAuthorizationDidFail(with: .other(error))

    self.showAppleErrorAlert.assertValue("Not online sorry")
  }

  func testShowAppleErrorAlert_SignInWithAppleMutationError() {
    withEnvironment(apiService: MockService(signInWithAppleResult: .failure(.couldNotParseJSON))) {
      self.vm.inputs.configureWith(.generic)
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
      self.vm.inputs.configureWith(.generic)
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

  func testLogIntoEnvironment_SignInWithApple() {
    let user = User.template

    let envelope = SignInWithAppleEnvelope.template
      |> \.signInWithApple.apiAccessToken .~ "some_token"

    let service = MockService(fetchUserResult: .success(user), signInWithAppleResult: .success(envelope))

    withEnvironment(apiService: service) {
      self.vm.inputs.configureWith(.generic)
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
    self.vm.inputs.configureWith(.generic)
    self.vm.inputs.viewWillAppear()

    self.attemptAppleLogin.assertDidNotEmitValue()

    self.vm.inputs.appleLoginButtonPressed()

    self.attemptAppleLogin.assertValueCount(1)
  }
}
