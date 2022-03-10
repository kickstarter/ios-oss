@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import UserNotifications
import XCTest

final class AppDelegateViewModelTests: TestCase {
  var vm: AppDelegateViewModelType!

  private let applicationIconBadgeNumber = TestObserver<Int, Never>()
  private let configureAppCenterWithData = TestObserver<AppCenterConfigData, Never>()
  private let configureOptimizelySDKKey = TestObserver<String, Never>()
  private let configureOptimizelyLogLevel = TestObserver<OptimizelyLogLevelType, Never>()
  private let configureOptimizelyDispatchInterval = TestObserver<TimeInterval, Never>()
  private let configureFirebase = TestObserver<(), Never>()
  private let configurePerimeterX = TestObserver<(), Never>()
  private let configureSegment = TestObserver<String, Never>()
  private let didAcceptReceivingRemoteNotifications = TestObserver<(), Never>()
  private let emailVerificationCompletedMessage = TestObserver<String, Never>()
  private let emailVerificationCompletedSuccess = TestObserver<Bool, Never>()
  private let findRedirectUrl = TestObserver<URL, Never>()
  private let forceLogout = TestObserver<(), Never>()
  private let goToActivity = TestObserver<(), Never>()
  private let goToCategoriesPersonalizationOnboarding = TestObserver<(), Never>()
  private let goToDashboard = TestObserver<Param?, Never>()
  private let goToDiscovery = TestObserver<DiscoveryParams?, Never>()
  private let goToLandingPage = TestObserver<(), Never>()
  private let goToProjectActivities = TestObserver<Param, Never>()
  private let goToLoginWithIntent = TestObserver<LoginIntent, Never>()
  private let goToPerimeterXCaptcha = TestObserver<PerimeterXBlockResponseType, Never>()
  private let goToProfile = TestObserver<(), Never>()
  private let goToMobileSafari = TestObserver<URL, Never>()
  private let goToSearch = TestObserver<(), Never>()
  private let perimeterXManagerReady = TestObserver<[String: String]?, Never>()
  private let perimeterXRefreshedHeaders = TestObserver<[String: String]?, Never>()
  private let postNotificationName = TestObserver<Notification.Name, Never>()
  private let presentViewController = TestObserver<Int, Never>()
  private let pushRegistrationStarted = TestObserver<(), Never>()
  private let pushTokenSuccessfullyRegistered = TestObserver<String, Never>()
  private let registerPushTokenInSegment = TestObserver<Data, Never>()
  private let setApplicationShortcutItems = TestObserver<[ShortcutItem], Never>()
  private let segmentIsEnabled = TestObserver<Bool, Never>()
  private let showAlert = TestObserver<Notification, Never>()
  private let unregisterForRemoteNotifications = TestObserver<(), Never>()
  private let updateCurrentUserInEnvironment = TestObserver<User, Never>()
  private let updateConfigInEnvironment = TestObserver<Config, Never>()

  private var defaultRootCategoriesTemplate: RootCategoriesEnvelope {
    RootCategoriesEnvelope.template
      |> RootCategoriesEnvelope.lens.categories .~ [
        .art,
        .filmAndVideo,
        .illustration,
        .documentary
      ]
  }

  override func setUp() {
    super.setUp()

    self.vm = AppDelegateViewModel()

    self.vm.outputs.applicationIconBadgeNumber.observe(self.applicationIconBadgeNumber.observer)
    self.vm.outputs.configureAppCenterWithData.observe(self.configureAppCenterWithData.observer)
    self.vm.outputs.configureFirebase.observe(self.configureFirebase.observer)
    self.vm.outputs.configureOptimizely.map(first).observe(self.configureOptimizelySDKKey.observer)
    self.vm.outputs.configureOptimizely.map(second).observe(self.configureOptimizelyLogLevel.observer)
    self.vm.outputs.configureOptimizely.map(third).observe(self.configureOptimizelyDispatchInterval.observer)
    self.vm.outputs.configurePerimeterX.observe(self.configurePerimeterX.observer)
    self.vm.outputs.configureSegment.observe(self.configureSegment.observer)
    self.vm.outputs.emailVerificationCompleted.map(first)
      .observe(self.emailVerificationCompletedMessage.observer)
    self.vm.outputs.emailVerificationCompleted.map(second)
      .observe(self.emailVerificationCompletedSuccess.observer)
    self.vm.outputs.findRedirectUrl.observe(self.findRedirectUrl.observer)
    self.vm.outputs.forceLogout.observe(self.forceLogout.observer)
    self.vm.outputs.goToActivity.observe(self.goToActivity.observer)
    self.vm.outputs.goToCategoryPersonalizationOnboarding
      .observe(self.goToCategoriesPersonalizationOnboarding.observer)
    self.vm.outputs.goToDashboard.observe(self.goToDashboard.observer)
    self.vm.outputs.goToDiscovery.observe(self.goToDiscovery.observer)
    self.vm.outputs.goToLandingPage.observe(self.goToLandingPage.observer)
    self.vm.outputs.goToLoginWithIntent.observe(self.goToLoginWithIntent.observer)
    self.vm.outputs.goToPerimeterXCaptcha.observe(self.goToPerimeterXCaptcha.observer)
    self.vm.outputs.goToProfile.observe(self.goToProfile.observer)
    self.vm.outputs.goToMobileSafari.observe(self.goToMobileSafari.observer)
    self.vm.outputs.goToProjectActivities.observe(self.goToProjectActivities.observer)
    self.vm.outputs.goToSearch.observe(self.goToSearch.observer)
    self.vm.outputs.postNotification.map { $0.name }.observe(self.postNotificationName.observer)
    self.vm.outputs.presentViewController.map { ($0 as! UINavigationController).viewControllers.count }
      .observe(self.presentViewController.observer)
    self.vm.outputs.pushTokenRegistrationStarted.observe(self.pushRegistrationStarted.observer)
    self.vm.outputs.pushTokenSuccessfullyRegistered.observe(self.pushTokenSuccessfullyRegistered.observer)
    self.vm.outputs.registerPushTokenInSegment.observe(self.registerPushTokenInSegment.observer)
    self.vm.outputs.setApplicationShortcutItems.observe(self.setApplicationShortcutItems.observer)
    self.vm.outputs.showAlert.observe(self.showAlert.observer)
    self.vm.outputs.segmentIsEnabled.observe(self.segmentIsEnabled.observer)
    self.vm.outputs.unregisterForRemoteNotifications.observe(self.unregisterForRemoteNotifications.observer)
    self.vm.outputs.updateCurrentUserInEnvironment.observe(self.updateCurrentUserInEnvironment.observer)
    self.vm.outputs.updateConfigInEnvironment.observe(self.updateConfigInEnvironment.observer)
  }

  func testResetApplicationIconBadgeNumber_registeredForPushNotifications_WillEnterForeground() {
    MockPushRegistration.hasAuthorizedNotificationsProducer = .init(value: true)

    withEnvironment(pushRegistrationType: MockPushRegistration.self) {
      self.applicationIconBadgeNumber.assertValues([])

      self.vm.inputs.applicationWillEnterForeground()

      self.applicationIconBadgeNumber.assertValues([0])
    }
  }

  func testResetApplicationIconBadgeNumber_notRegisteredForPushNotifications_WillEnterForeground() {
    MockPushRegistration.hasAuthorizedNotificationsProducer = .init(value: false)

    withEnvironment(pushRegistrationType: MockPushRegistration.self) {
      self.applicationIconBadgeNumber.assertValues([])

      self.vm.inputs.applicationWillEnterForeground()

      self.applicationIconBadgeNumber.assertValues([])
    }
  }

  func testResetApplicationIconBadgeNumber_registeredForPushNotifications_AppLaunch() {
    MockPushRegistration.hasAuthorizedNotificationsProducer = .init(value: true)

    withEnvironment(pushRegistrationType: MockPushRegistration.self) {
      self.applicationIconBadgeNumber.assertValues([])

      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)

      self.applicationIconBadgeNumber.assertValues([0])
    }
  }

  func testResetApplicationIconBadgeNumber_notRegisteredForPushNotifications_AppLaunch() {
    MockPushRegistration.hasAuthorizedNotificationsProducer = .init(value: false)

    withEnvironment(pushRegistrationType: MockPushRegistration.self) {
      self.applicationIconBadgeNumber.assertValues([])

      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)

      self.applicationIconBadgeNumber.assertValues([])
    }
  }

  func testConfigureFirebase() {
    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)

    self.configureFirebase.assertValueCount(1)
  }

  func testConfigurePerimeterX() {
    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)

    self.configurePerimeterX.assertValueCount(1)
  }

  // MARK: - Optimizely

  func testConfigureOptimizely_Production() {
    let mockService = MockService(serverConfig: ServerConfig.production)

    withEnvironment(apiService: mockService) {
      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)

      self.configureOptimizelySDKKey
        .assertValues([Secrets.OptimizelySDKKey.production])
    }
  }

  func testConfigureOptimizely_Staging() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService) {
      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)

      self.configureOptimizelySDKKey
        .assertValues([Secrets.OptimizelySDKKey.staging])
    }
  }

  func testConfigureOptimizely_Release() {
    let mockBundle = MockBundle(
      bundleIdentifier: KickstarterBundleIdentifier.release.rawValue,
      lang: Language.en.rawValue
    )

    withEnvironment(mainBundle: mockBundle) {
      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)

      self.configureOptimizelyLogLevel
        .assertValues([OptimizelyLogLevelType.error])
    }
  }

  func testConfigureOptimizely_Alpha() {
    let mockBundle = MockBundle(
      bundleIdentifier: KickstarterBundleIdentifier.alpha.rawValue,
      lang: Language.en.rawValue
    )

    withEnvironment(mainBundle: mockBundle) {
      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)

      self.configureOptimizelyLogLevel
        .assertValues([OptimizelyLogLevelType.error])
    }
  }

  func testConfigureOptimizely_Beta() {
    let mockBundle = MockBundle(
      bundleIdentifier: KickstarterBundleIdentifier.beta.rawValue,
      lang: Language.en.rawValue
    )

    withEnvironment(mainBundle: mockBundle) {
      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)

      self.configureOptimizelyLogLevel
        .assertValues([OptimizelyLogLevelType.error])
    }
  }

  func testConfigureOptimizely_Debug() {
    let mockBundle = MockBundle(
      bundleIdentifier: KickstarterBundleIdentifier.debug.rawValue,
      lang: Language.en.rawValue
    )

    withEnvironment(mainBundle: mockBundle) {
      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)

      self.configureOptimizelyLogLevel
        .assertValues([OptimizelyLogLevelType.debug])
    }
  }

  func testConfigureOptimizelyDispatchInterval() {
    self.configureOptimizelyDispatchInterval.assertDidNotEmitValue()
    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)

    self.configureOptimizelyDispatchInterval.assertValues([5])
  }

  func testOptimizelyConfiguration_IsSuccess() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService) {
      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)

      self.configureOptimizelySDKKey
        .assertValues([Secrets.OptimizelySDKKey.staging])

      let error = self.vm.inputs.optimizelyConfigured(with: MockOptimizelyResult())

      XCTAssertNil(error)

      self.vm.inputs.didUpdateOptimizelyClient(MockOptimizelyClient())

      self.postNotificationName.assertValues([.ksr_optimizelyClientConfigured])
    }
  }

  func testOptimizelyConfiguration_IsFailure() {
    let mockService = MockService(serverConfig: ServerConfig.staging)
    let mockResult = MockOptimizelyResult() |> \.shouldSucceed .~ false

    withEnvironment(apiService: mockService) {
      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)

      self.configureOptimizelySDKKey
        .assertValues([Secrets.OptimizelySDKKey.staging])

      let error = self.vm.inputs.optimizelyConfigured(with: mockResult) as? MockOptimizelyError

      XCTAssertEqual("Optimizely Error", error?.localizedDescription)

      self.vm.inputs.optimizelyClientConfigurationFailed()

      self.postNotificationName.assertValues([.ksr_optimizelyClientConfigurationFailed])
    }
  }

  // MARK: - AppCenter

  func testConfigureAppCenter_AlphaApp_LoggedOut() {
    let alphaBundle = MockBundle(bundleIdentifier: KickstarterBundleIdentifier.alpha.rawValue, lang: "en")

    withEnvironment(mainBundle: alphaBundle) {
      vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.configureAppCenterWithData.assertValues([
        AppCenterConfigData(
          appSecret: KsApi.Secrets.AppCenter.alpha,
          userId: "0",
          userName: "anonymous"
        )
      ])
    }
  }

  func testConfigureAppCenter_AlphaApp_LoggedIn() {
    let alphaBundle = MockBundle(bundleIdentifier: KickstarterBundleIdentifier.alpha.rawValue, lang: "en")
    let currentUser = User.template

    withEnvironment(
      currentUser: .template,
      mainBundle: alphaBundle
    ) {
      vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.configureAppCenterWithData.assertValues([
        AppCenterConfigData(
          appSecret: KsApi.Secrets.AppCenter.alpha,
          userId: String(currentUser.id),
          userName: currentUser.name
        )
      ])
    }
  }

  func testConfigureAppCenter_DebugApp() {
    let debugBundle = MockBundle(bundleIdentifier: KickstarterBundleIdentifier.debug.rawValue, lang: "en")

    withEnvironment(mainBundle: debugBundle) {
      vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.configureAppCenterWithData.assertDidNotEmitValue()
    }
  }

  func testConfigureAppCenter_BetaApp_LoggedOut() {
    let betaBundle = MockBundle(bundleIdentifier: KickstarterBundleIdentifier.beta.rawValue, lang: "en")

    withEnvironment(mainBundle: betaBundle) {
      vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.configureAppCenterWithData.assertValues([
        AppCenterConfigData(
          appSecret: KsApi.Secrets.AppCenter.beta,
          userId: "0",
          userName: "anonymous"
        )
      ])
    }
  }

  func testConfigureAppCenter_BetaApp_LoggedIn() {
    let currentUser = User.template
    withEnvironment(
      currentUser: .template,
      mainBundle: MockBundle(bundleIdentifier: KickstarterBundleIdentifier.beta.rawValue, lang: "en")
    ) {
      vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.configureAppCenterWithData.assertValues([
        AppCenterConfigData(
          appSecret: KsApi.Secrets.AppCenter.beta,
          userId: String(currentUser.id),
          userName: currentUser.name
        )
      ])
    }
  }

  func testConfigureAppCenter_ProductionApp_LoggedOut() {
    let bundle = MockBundle(bundleIdentifier: KickstarterBundleIdentifier.release.rawValue, lang: "en")
    withEnvironment(mainBundle: bundle) {
      vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.configureAppCenterWithData.assertValues([])
    }
  }

  func testConfigureAppCenter_ProductionApp_LoggedIn() {
    let bundle = MockBundle(bundleIdentifier: KickstarterBundleIdentifier.release.rawValue, lang: "en")

    withEnvironment(currentUser: .template, mainBundle: bundle) {
      vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.configureAppCenterWithData.assertValues([])
    }
  }

  func testConfigureAppCenter_SessionChanges() {
    let bundle = MockBundle(bundleIdentifier: KickstarterBundleIdentifier.release.rawValue, lang: "en")

    withEnvironment(mainBundle: bundle) {
      vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.configureAppCenterWithData.assertValues([])

      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))
      self.vm.inputs.userSessionStarted()

      self.configureAppCenterWithData.assertValues([])

      AppEnvironment.logout()
      self.vm.inputs.userSessionStarted()

      self.configureAppCenterWithData.assertValues([])
    }
  }

  func testCurrentUserUpdating_NothingHappensWhenLoggedOut() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )
    self.vm.inputs.applicationWillEnterForeground()
    self.vm.inputs.applicationDidEnterBackground()

    self.updateCurrentUserInEnvironment.assertDidNotEmitValue()
  }

  func testCurrentUserUpdating_WhenLoggedIn() {
    let env = AccessTokenEnvelope(accessToken: "deadbeef", user: User.template)
    AppEnvironment.login(env)

    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    self.scheduler.advance(by: .seconds(5))

    self.updateCurrentUserInEnvironment.assertValues([env.user])
    self.postNotificationName.assertDidNotEmitValue()

    self.vm.inputs.currentUserUpdatedInEnvironment()

    self.updateCurrentUserInEnvironment.assertValues([env.user])
    self.postNotificationName.assertValues([.ksr_userUpdated])

    self.vm.inputs.applicationWillEnterForeground()
    self.scheduler.advance(by: .seconds(5))

    self.updateCurrentUserInEnvironment.assertValues([env.user, env.user])
    self.postNotificationName.assertValues([.ksr_userUpdated])

    self.vm.inputs.currentUserUpdatedInEnvironment()

    self.updateCurrentUserInEnvironment.assertValues([env.user, env.user])
    self.postNotificationName.assertValues(
      [.ksr_userUpdated, .ksr_userUpdated]
    )
  }

  func testAppStateEnteringBackground_SendNotification_Success() {
    let env = AccessTokenEnvelope(accessToken: "deadbeef", user: User.template)
    AppEnvironment.login(env)

    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    self.scheduler.advance(by: .seconds(5))

    self.postNotificationName.assertDidNotEmitValue()

    self.vm.inputs.applicationDidEnterBackground()
    self.scheduler.advance(by: .seconds(5))

    self.postNotificationName.assertValues([.ksr_applicationDidEnterBackground]
    )
  }

  func testCurrentUserUpdating_WithLegacyUserDefaultsUser() {
    // No current user in the environment, but the api has an oauth token. This can happen when an oauth
    // token is resurrected from the legacy user defaults.
    withEnvironment(apiService: MockService(oauthToken: OauthToken(token: "deadbeef"))) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.scheduler.advance(by: .seconds(5))

      self.updateCurrentUserInEnvironment.assertValues([.template])
      self.postNotificationName.assertDidNotEmitValue()

      self.vm.inputs.currentUserUpdatedInEnvironment()

      self.updateCurrentUserInEnvironment.assertValues([.template])
      self.postNotificationName.assertValues([.ksr_userUpdated])
    }
  }

  func testInvalidAccessToken() {
    let error = ErrorEnvelope(
      errorMessages: ["invalid deadbeef"],
      ksrCode: .AccessTokenInvalid,
      httpCode: 401,
      exception: nil
    )

    withEnvironment(apiService: MockService(fetchUserSelfError: error), currentUser: .template) {
      self.forceLogout.assertValueCount(0)

      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )
      self.scheduler.advance(by: .seconds(5))

      updateCurrentUserInEnvironment.assertDidNotEmitValue()
      self.forceLogout.assertValueCount(1)
    }
  }

  func testConfig() {
    let config1 = Config.template |> Config.lens.countryCode .~ "US"
    withEnvironment(apiService: MockService(fetchConfigResponse: config1)) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )
      self.updateConfigInEnvironment.assertValues([config1])

      self.vm.inputs.didUpdateConfig(config1)
      self.postNotificationName.assertValues([.ksr_configUpdated])
    }

    let config2 = Config.template |> Config.lens.countryCode .~ "GB"
    withEnvironment(apiService: MockService(fetchConfigResponse: config2)) {
      self.vm.inputs.applicationWillEnterForeground()
      self.updateConfigInEnvironment.assertValues([config1, config2])

      self.vm.inputs.didUpdateConfig(config2)
      self.postNotificationName.assertValues([.ksr_configUpdated, .ksr_configUpdated])
    }

    let config3 = Config.template |> Config.lens.countryCode .~ "CZ"
    withEnvironment(apiService: MockService(fetchConfigResponse: config3)) {
      self.vm.inputs.userSessionEnded()
      self.updateConfigInEnvironment.assertValues([config1, config2, config3])

      self.vm.inputs.didUpdateConfig(config3)
      self.postNotificationName.assertValues([.ksr_configUpdated, .ksr_configUpdated, .ksr_configUpdated])
    }

    let config4 = Config.template |> Config.lens.countryCode .~ "CA"
    withEnvironment(apiService: MockService(fetchConfigResponse: config4)) {
      self.vm.inputs.userSessionStarted()
      self.updateConfigInEnvironment.assertValues([config1, config2, config3, config4])

      self.vm.inputs.didUpdateConfig(config4)
      self.postNotificationName.assertValues([
        .ksr_configUpdated,
        .ksr_configUpdated,
        .ksr_configUpdated,
        .ksr_configUpdated
      ])
    }
  }

  func testPresentViewController() {
    let apiService = MockService(
      fetchProjectResult: .success(.template),
      fetchUpdateResponse: .template
    )
    withEnvironment(apiService: apiService) {
      let rootUrl = "https://www.kickstarter.com/"

      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.presentViewController.assertValues([])

      let projectUrl = rootUrl + "projects/tequila/help-me-transform-this-pile-of-wood"
      var result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: projectUrl)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([1])

      let commentsUrl = projectUrl + "/comments"
      result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: commentsUrl)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([1, 2])

      let updatesUrl = projectUrl + "/posts"
      result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: updatesUrl)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([1, 2, 2])

      let updateUrl = projectUrl + "/posts/1399396"
      result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: updateUrl)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([1, 2, 2, 2])

      let updateCommentsUrl = updateUrl + "/comments"
      result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: updateCommentsUrl)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([1, 2, 2, 2, 3])

      let faqUrl = projectUrl + "/faqs"
      result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: faqUrl)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([1, 2, 2, 2, 3, 2])
    }
  }

  func testPresentViewController_ProjectPreviewLink_DisplayPrelaunch_True() {
    let project = Project.template
      |> Project.lens.displayPrelaunch .~ true

    let apiService = MockService(fetchProjectResult: .success(project))
    withEnvironment(apiService: apiService) {
      let rootUrl = "https://www.kickstarter.com/"

      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.presentViewController.assertValues([])

      let projectUrl = rootUrl + "projects/tequila/help-me-transform-this-pile-of-wood"
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: projectUrl)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([])
      XCTAssertEqual(self.goToMobileSafari.values.map { $0.absoluteString }, [projectUrl])
    }
  }

  func testPresentViewController_ProjectPreviewLink_DisplayPrelaunch_False() {
    let project = Project.template
      |> Project.lens.displayPrelaunch .~ false

    let apiService = MockService(fetchProjectResult: .success(project))
    withEnvironment(apiService: apiService) {
      let rootUrl = "https://www.kickstarter.com/"

      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.presentViewController.assertValues([])

      let projectUrl = rootUrl + "projects/tequila/help-me-transform-this-pile-of-wood"
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: projectUrl)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([1])
      self.goToMobileSafari.assertValues([])
    }
  }

  func testPresentViewController_ProjectPreviewLink_DisplayPrelaunch_Nil() {
    let project = Project.template
      |> Project.lens.displayPrelaunch .~ nil

    let apiService = MockService(fetchProjectResult: .success(project))
    withEnvironment(apiService: apiService) {
      let rootUrl = "https://www.kickstarter.com/"

      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.presentViewController.assertValues([])

      let projectUrl = rootUrl + "projects/tequila/help-me-transform-this-pile-of-wood"
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: projectUrl)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([1])
      self.goToMobileSafari.assertValues([])
    }
  }

  func testPresentViewController_ProjectCommentThread_Success() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    withEnvironment(apiService: MockService(fetchCommentRepliesEnvelopeResult: .success(CommentRepliesEnvelope
        .successfulRepliesTemplate), fetchProjectResult: .success(.template))) {
      let url =
        "https://\(AppEnvironment.current.apiService.serverConfig.webBaseUrl.host ?? "")/projects/fjorden/fjorden-iphone-photography-reinvented/comments?comment=Q29tbWVudC0zMzY0OTg0MQ%3D%3D"

      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: url)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([3])
    }
  }

  func testPresentViewController_ProjectCommentThread_Reply_Success() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    withEnvironment(apiService: MockService(fetchCommentRepliesEnvelopeResult: .success(CommentRepliesEnvelope
        .successfulRepliesTemplate), fetchProjectResult: .success(.template))) {
      let url =
        "https://\(AppEnvironment.current.apiService.serverConfig.webBaseUrl.host ?? "")/projects/fjorden/fjorden-iphone-photography-reinvented/comments?comment=Q29tbWVudC0zMzY0OTg0MQ%3D%3D&reply=deadbeef"

      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: url)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([3])
    }
  }

  func testPresentViewController_UpdateCommentThread_Success() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    withEnvironment(apiService: MockService(fetchCommentRepliesEnvelopeResult: .success(CommentRepliesEnvelope
        .successfulRepliesTemplate), fetchProjectResult: .success(.template))) {
      let url =
        "https://\(AppEnvironment.current.apiService.serverConfig.webBaseUrl.host ?? "")/projects/fjorden/fjorden-iphone-photography-reinvented/posts/3254626/comments?comment=Q29tbWVudC0zMzY0OTg0MQ%3D%3D"

      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: url)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([4])
    }
  }

  func testPresentViewController_UpdateCommentThread_Reply_Success() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    withEnvironment(apiService: MockService(fetchCommentRepliesEnvelopeResult: .success(CommentRepliesEnvelope
        .successfulRepliesTemplate), fetchProjectResult: .success(.template))) {
      let url =
        "https://\(AppEnvironment.current.apiService.serverConfig.webBaseUrl.host ?? "")/projects/fjorden/fjorden-iphone-photography-reinvented/posts/3254626/comments?comment=Q29tbWVudC0zMzY0OTg0MQ%3D%3D&reply=deadbeef"

      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: url)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.presentViewController.assertValues([4])
    }
  }

  func testGoToActivity() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    self.goToActivity.assertValueCount(0)

    let result = self.vm.inputs.applicationOpenUrl(
      application: UIApplication.shared,
      url: URL(string: "https://www.kickstarter.com/activity")!,
      options: [:]
    )
    XCTAssertTrue(result)

    self.goToActivity.assertValueCount(1)
  }

  func testGoToDashboard() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    self.goToDashboard.assertValueCount(0)

    let url = "https://www.kickstarter.com/projects/tequila/help-me-transform-this-pile-of-wood/dashboard"
    let result = self.vm.inputs.applicationOpenUrl(
      application: UIApplication.shared,
      url: URL(string: url)!,
      options: [:]
    )
    XCTAssertTrue(result)

    self.goToDashboard.assertValueCount(1)
  }

  func testGoToDiscovery() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    self.goToDiscovery.assertValues([])

    let result = self.vm.inputs.applicationOpenUrl(
      application: UIApplication.shared,
      url: URL(string: "https://www.kickstarter.com/discover?sort=newest")!,
      options: [:]
    )
    XCTAssertTrue(result)

    let params = .defaults
      |> DiscoveryParams.lens.sort .~ .newest
    self.goToDiscovery.assertValues([params])
  }

  func testGoToDiscovery_NoParams() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    self.goToDiscovery.assertValues([])

    let result = self.vm.inputs.applicationOpenUrl(
      application: UIApplication.shared,
      url: URL(string: "https://www.kickstarter.com/discover")!,
      options: [:]
    )
    XCTAssertTrue(result)

    self.goToDiscovery.assertValues([nil])
  }

  func testGoToDiscoveryWithCategoryName_ValidCategoryName_RoutesToCategory() {
    let mockService = MockService(fetchGraphCategoriesResult: .success(defaultRootCategoriesTemplate))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.goToDiscovery.assertValues([])

      let url = URL(string: "https://www.kickstarter.com/discover/categories/art")!
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: url,
        options: [:]
      )
      XCTAssertTrue(result)

      self.scheduler.advance()

      let params = .defaults |> DiscoveryParams.lens.category .~ .art
      self.goToDiscovery.assertValues([params])
    }
  }

  func testGoToDiscoveryWithCategoryName_InvalidCategoryName_DoesNotRouteToAnyCategory() {
    let mockService = MockService(fetchGraphCategoriesResult: .success(defaultRootCategoriesTemplate))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.goToDiscovery.assertValues([])

      let url = URL(string: "https://www.kickstarter.com/discover/categories/random")!
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: url,
        options: [:]
      )
      XCTAssertTrue(result)

      self.scheduler.advance()

      let params = .defaults |> DiscoveryParams.lens.category .~ .none
      self.goToDiscovery.assertValues([params])
    }
  }

  func testGoToDiscoveryWithSubcategoryName_ValidSubcategoryName_RoutesToSubcategory() {
    let gamesTemplate = RootCategoriesEnvelope.template
      |> RootCategoriesEnvelope.lens.categories .~ [
        .art,
        .filmAndVideo,
        .illustration,
        .documentary,
        .games
      ]

    let mockService = MockService(fetchGraphCategoriesResult: .success(gamesTemplate))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.goToDiscovery.assertValues([])

      let url = URL(string: "https://www.kickstarter.com/discover/categories/games/tabletop%20games")!
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: url,
        options: [:]
      )
      XCTAssertTrue(result)

      self.scheduler.advance()

      let params = .defaults |> DiscoveryParams.lens.category .~ .tabletopGames
      self.goToDiscovery.assertValues([params])
    }
  }

  func testGoToDiscoveryWithSubcategoryName_InvalidSubcategoryName_RoutesToCategory() {
    let gamesTemplate = RootCategoriesEnvelope.template
      |> RootCategoriesEnvelope.lens.categories .~ [
        .art,
        .filmAndVideo,
        .illustration,
        .documentary,
        .games
      ]

    let mockService = MockService(fetchGraphCategoriesResult: .success(gamesTemplate))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.goToDiscovery.assertValues([])

      let url = URL(string: "https://www.kickstarter.com/discover/categories/games/tabletopgames")!
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: url,
        options: [:]
      )
      XCTAssertTrue(result)

      self.scheduler.advance()

      let params = .defaults |> DiscoveryParams.lens.category .~ .games
      self.goToDiscovery.assertValues([params])
    }
  }

  func testGoToDiscoveryWithCategoryId_ValidCategoryId_RoutesToCategory() {
    let mockService = MockService(fetchGraphCategoriesResult: .success(defaultRootCategoriesTemplate))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.goToDiscovery.assertValues([])

      let url =
        URL(string: "https://www.kickstarter.com/discover/advanced?category_id=1&sort=magic&seed=2714369&page=1")!
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: url,
        options: [:]
      )
      XCTAssertTrue(result)

      self.scheduler.advance()

      let params = .defaults |> DiscoveryParams.lens.category .~ .art
        |> DiscoveryParams.lens.sort .~ .magic
        |> DiscoveryParams.lens.seed .~ 2_714_369
        |> DiscoveryParams.lens.page .~ 1
      self.goToDiscovery.assertValues([params])
    }
  }

  func testGoToDiscoveryWithCategoryId_InvalidCategoryOrSubcategoryId_DoesNotRouteToAnyCategory() {
    let mockService = MockService(fetchGraphCategoriesResult: .success(defaultRootCategoriesTemplate))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.goToDiscovery.assertValues([])

      let url =
        URL(string: "https://www.kickstarter.com/discover/advanced?category_id=9999&sort=magic&seed=2714369&page=1")!
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: url,
        options: [:]
      )
      XCTAssertTrue(result)

      self.scheduler.advance()

      let params = .defaults |> DiscoveryParams.lens.category .~ .none
        |> DiscoveryParams.lens.sort .~ .magic
        |> DiscoveryParams.lens.seed .~ 2_714_369
        |> DiscoveryParams.lens.page .~ 1
      self.goToDiscovery.assertValues([params])
    }
  }

  func testGoToDiscoveryWithSubcategoryId_ValidSubcategoryId_RoutesToSubcategory() {
    let gamesTemplate = RootCategoriesEnvelope.template
      |> RootCategoriesEnvelope.lens.categories .~ [
        .art,
        .filmAndVideo,
        .illustration,
        .documentary,
        .games
      ]

    let mockService = MockService(fetchGraphCategoriesResult: .success(gamesTemplate))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.goToDiscovery.assertValues([])

      let url =
        URL(string: "https://www.kickstarter.com/discover/advanced?category_id=34&sort=magic&seed=2714369&page=1")!
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: url,
        options: [:]
      )
      XCTAssertTrue(result)

      self.scheduler.advance()

      let params = .defaults |> DiscoveryParams.lens.category .~ .tabletopGames
        |> DiscoveryParams.lens.sort .~ .magic
        |> DiscoveryParams.lens.seed .~ 2_714_369
        |> DiscoveryParams.lens.page .~ 1
      self.goToDiscovery.assertValues([params])
    }
  }

  func testGoToLogin() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    self.goToLoginWithIntent.assertValueCount(0)

    let result = self.vm.inputs.applicationOpenUrl(
      application: UIApplication.shared,
      url: URL(string: "https://www.kickstarter.com/authorize")!,
      options: [:]
    )
    XCTAssertTrue(result)

    self.goToLoginWithIntent.assertValueCount(1)
  }

  func testGoToProfile() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    self.goToProfile.assertValueCount(0)

    let result = self.vm.inputs.applicationOpenUrl(
      application: UIApplication.shared,
      url: URL(string: "https://www.kickstarter.com/profile/me")!,
      options: [:]
    )
    XCTAssertTrue(result)

    self.goToProfile.assertValueCount(1)
  }

  func testGoToSearch() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    self.goToSearch.assertValueCount(0)

    let result = self.vm.inputs.applicationOpenUrl(
      application: UIApplication.shared,
      url: URL(string: "https://www.kickstarter.com/search")!,
      options: [:]
    )
    XCTAssertTrue(result)

    self.goToSearch.assertValueCount(1)
  }

  func testDeeplink_WhenOnboardingFlowIsActive() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.onboardingCategoryPersonalizationFlow.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    withEnvironment(currentUser: nil, optimizelyClient: optimizelyClient) {
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: "https://www.kickstarter.com/search")!,
        options: [:]
      )

      XCTAssertTrue(result)

      self.goToSearch.assertValueCount(0)
    }
  }

  func testRegisterPushNotifications_Prompted() {
    let segmentClient = MockTrackingClient()

    MockPushRegistration.hasAuthorizedNotificationsProducer = .init(value: false)
    MockPushRegistration.registerProducer = .init(value: true)

    withEnvironment(
      apiService: MockService(),
      currentUser: .template,
      ksrAnalytics: KSRAnalytics(segmentClient: segmentClient),
      pushRegistrationType: MockPushRegistration.self
    ) {
      self.pushRegistrationStarted.assertValueCount(0)
      self.pushTokenSuccessfullyRegistered.assertValueCount(0)

      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: [:])
      self.vm.inputs.userSessionStarted()
      self.vm.inputs.didAcceptReceivingRemoteNotifications()

      self.pushRegistrationStarted.assertValueCount(1)

      self.vm.inputs.didRegisterForRemoteNotifications(withDeviceTokenData: "token".data(using: .utf8)!)

      self.scheduler.advance(by: .seconds(5))

      self.pushTokenSuccessfullyRegistered.assertValueCount(1)

      XCTAssertEqual([], segmentClient.events)
    }
  }

  func testRegisterPushNotifications_PreviouslyAccepted() {
    let segmentClient = MockTrackingClient()

    MockPushRegistration.hasAuthorizedNotificationsProducer = .init(value: true)
    MockPushRegistration.registerProducer = .init(value: true)

    withEnvironment(
      apiService: MockService(),
      currentUser: .template,
      ksrAnalytics: KSRAnalytics(segmentClient: segmentClient),
      pushRegistrationType: MockPushRegistration.self
    ) {
      self.pushRegistrationStarted.assertValueCount(0)
      self.pushTokenSuccessfullyRegistered.assertValueCount(0)

      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: [:])
      self.vm.inputs.userSessionStarted()

      self.pushRegistrationStarted.assertValueCount(1)

      self.vm.inputs.didRegisterForRemoteNotifications(withDeviceTokenData: "token".data(using: .utf8)!)

      self.scheduler.advance(by: .seconds(5))

      self.pushTokenSuccessfullyRegistered.assertValueCount(1)

      XCTAssertEqual([], segmentClient.events)
    }
  }

  func testTrackingPushAuthorizationOptIn() {
    let segmentClient = MockTrackingClient()

    MockPushRegistration.hasAuthorizedNotificationsProducer = .init(value: false)
    MockPushRegistration.registerProducer = .init(value: true)

    withEnvironment(
      currentUser: .template,
      ksrAnalytics: KSRAnalytics(segmentClient: segmentClient),
      pushRegistrationType: MockPushRegistration.self
    ) {
      XCTAssertEqual([], segmentClient.events)

      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: [:])
      self.vm.inputs.userSessionStarted()

      self.vm.inputs.didAcceptReceivingRemoteNotifications()
    }
  }

  func testRegisterDeviceToken() {
    withEnvironment(currentUser: .template) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )
      self.vm.inputs.didRegisterForRemoteNotifications(withDeviceTokenData: "deadbeef".data(using: .utf8)!)
      self.scheduler.advance(by: .seconds(5))

      self.pushTokenSuccessfullyRegistered.assertValueCount(1)
    }
  }

  func testRegisterPushTokenInSegment() {
    let data = Data("deadbeef".utf8)

    self.registerPushTokenInSegment.assertDidNotEmitValue()

    withEnvironment(currentUser: .template) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )
      self.vm.inputs.didRegisterForRemoteNotifications(withDeviceTokenData: data)

      self.registerPushTokenInSegment.assertValueCount(1)
    }
  }

  func testOpenPushNotification_WhileInBackground() {
    withEnvironment(apiService: MockService(fetchProjectResult: .success(.template))) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.presentViewController.assertValueCount(0)

      self.vm.inputs.didReceive(remoteNotification: friendBackingPushData)

      self.presentViewController.assertValueCount(1)
    }
  }

  func testOpenNotification_NewBacking_ForCreator() {
    let projectId = (backingForCreatorPushData["activity"] as? [String: AnyObject])
      .flatMap { $0["project_id"] as? Int }
    let param = Param.id(projectId ?? -1)

    self.vm.inputs.didReceive(remoteNotification: backingForCreatorPushData)

    self.goToProjectActivities.assertValues([param])
  }

  func testOpenNotification_NewBacking_ForCreator_WithBadData() {
    var badPushData = backingForCreatorPushData
    var badActivityData = badPushData["activity"] as? [String: AnyObject]
    badActivityData?["project_id"] = nil
    badPushData["activity"] = badActivityData

    self.vm.inputs.didReceive(remoteNotification: badPushData)

    self.goToDashboard.assertValueCount(0)
  }

  func testOpenNotification_ProjectUpdate() {
    withEnvironment(apiService: MockService(fetchProjectResult: .success(.template))) {
      self.vm.inputs.didReceive(remoteNotification: updatePushData)

      self.presentViewController.assertValueCount(1)
    }
  }

  func testOpenNotification_ProjectUpdate_BadData() {
    var badPushData = updatePushData
    badPushData["activity"]?["update_id"] = nil

    self.vm.inputs.didReceive(remoteNotification: badPushData)

    self.presentViewController.assertValueCount(0)
  }

  func testOpenNotification_SurveyResponse() {
    self.vm.inputs.didReceive(remoteNotification: surveyResponsePushData)

    self.presentViewController.assertValueCount(1)
  }

  func testOpenNotification_SurveyResponse_BadData() {
    var badPushData = surveyResponsePushData
    badPushData["survey"]?["id"] = nil

    self.vm.inputs.didReceive(remoteNotification: badPushData)

    self.presentViewController.assertValueCount(0)
  }

  func testOpenNotification_UpdateComment() {
    withEnvironment(apiService: MockService(fetchProjectResult: .success(.template))) {
      self.vm.inputs.didReceive(remoteNotification: updateCommentPushData)

      self.presentViewController.assertValueCount(1)
    }
  }

  func testOpenNotification_UpdateComment_BadData() {
    var badPushData = updatePushData
    badPushData["activity"]?["update_id"] = nil

    self.vm.inputs.didReceive(remoteNotification: badPushData)

    self.presentViewController.assertValueCount(0)
  }

  func testOpenNotification_ProjectComment() {
    withEnvironment(apiService: MockService(fetchProjectResult: .success(.template))) {
      self.vm.inputs.didReceive(remoteNotification: projectCommentPushData)

      self.presentViewController.assertValueCount(1)
    }
  }

  func testOpenNotification_ProjectComment_WithBadData() {
    withEnvironment(apiService: MockService(fetchProjectResult: .success(.template))) {
      var badPushData = updatePushData
      badPushData["activity"]?["project_id"] = nil

      self.vm.inputs.didReceive(remoteNotification: badPushData)

      self.presentViewController.assertValueCount(0)
    }
  }

  func testOpenNotification_GenericProject() {
    withEnvironment(apiService: MockService(fetchProjectResult: .success(.template))) {
      self.vm.inputs.didReceive(remoteNotification: genericProjectPushData)

      self.presentViewController.assertValueCount(1)
    }
  }

  func testOpenNotification_ProjectStateChanges() {
    withEnvironment(apiService: MockService(fetchProjectResult: .success(.template))) {
      let states: [Activity.Category] = [.failure, .launch, .success, .cancellation, .suspension]

      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      states.enumerated().forEach { idx, state in
        var pushData = genericActivityPushData
        pushData["activity"]?["category"] = state.rawValue

        self.vm.inputs.didReceive(remoteNotification: pushData)

        self.presentViewController.assertValueCount(
          idx + 1, "Presents controller for \(state.rawValue) state change."
        )
      }
    }
  }

  func testOpenNotification_CreatorActivity() {
    let categories: [Activity.Category] = [.backingAmount, .backingCanceled, .backingDropped, .backingReward]

    let projectId = (backingForCreatorPushData["activity"] as? [String: AnyObject])
      .flatMap { $0["project_id"] as? Int }
    let param = Param.id(projectId ?? -1)

    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    categories.enumerated().forEach { idx, state in
      var pushData = genericActivityPushData
      pushData["activity"]?["category"] = state.rawValue

      self.vm.inputs.didReceive(remoteNotification: pushData)

      self.goToDashboard.assertValueCount(idx + 1)
      self.goToDashboard.assertLastValue(param)
    }
  }

  func testOpenNotification_PostLike() {
    withEnvironment(apiService: MockService(fetchProjectResult: .success(.template))) {
      let pushData: [String: Any] = [
        "aps": [
          "alert": "Blob liked your update: Important message..."
        ],
        "post": [
          "id": 1,
          "project_id": 2
        ]
      ]

      self.vm.inputs.didReceive(remoteNotification: pushData)

      self.presentViewController.assertValues([2])
    }
  }

  func testOpenNotification_UnrecognizedActivityType() {
    let categories: [Activity.Category] = [.follow, .funding, .unknown, .watch]

    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    categories.enumerated().forEach { _, state in
      var pushData = genericActivityPushData
      pushData["activity"]?["category"] = state.rawValue

      self.vm.inputs.didReceive(remoteNotification: pushData)

      self.goToDashboard.assertValueCount(0)
      self.goToDiscovery.assertValueCount(0)
      self.presentViewController.assertValueCount(0)
    }
  }

  func testOpenPushNotification_WhenOnboardingFlowIsActive() {
    let pushData: [String: Any] = [
      "aps": [
        "alert": "Blob liked your update: Important message..."
      ],
      "post": [
        "id": 1,
        "project_id": 2
      ]
    ]

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.onboardingCategoryPersonalizationFlow.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    withEnvironment(currentUser: nil, optimizelyClient: optimizelyClient) {
      self.vm.inputs.didReceive(remoteNotification: pushData)

      self.presentViewController.assertValueCount(0)
    }
  }

  func testContinueUserActivity_ValidActivity() {
    let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
    userActivity.webpageURL = URL(string: "https://www.kickstarter.com/activity")

    self.vm.inputs.applicationDidFinishLaunching(application: .shared, launchOptions: [:])

    self.goToActivity.assertValueCount(0)
    XCTAssertFalse(self.vm.outputs.continueUserActivityReturnValue.value)

    let result = self.vm.inputs.applicationContinueUserActivity(userActivity)
    XCTAssertTrue(result)

    self.goToActivity.assertValueCount(1)
    XCTAssertTrue(self.vm.outputs.continueUserActivityReturnValue.value)
  }

  func testContinueUserActivity_InvalidActivity() {
    let userActivity = NSUserActivity(activityType: "Other")

    self.vm.inputs.applicationDidFinishLaunching(application: .shared, launchOptions: [:])
    let result = self.vm.inputs.applicationContinueUserActivity(userActivity)
    XCTAssertFalse(result)

    XCTAssertFalse(self.vm.outputs.continueUserActivityReturnValue.value)
  }

  func testContinueUserActivity_WhenOnboardingFlowIsActive() {
    let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
    userActivity.webpageURL = URL(string: "https://www.kickstarter.com/activity")

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.onboardingCategoryPersonalizationFlow.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    withEnvironment(currentUser: nil, optimizelyClient: optimizelyClient) {
      self.vm.inputs.applicationDidFinishLaunching(application: .shared, launchOptions: [:])

      self.goToActivity.assertValueCount(0)
      XCTAssertFalse(self.vm.outputs.continueUserActivityReturnValue.value)

      let result = self.vm.inputs.applicationContinueUserActivity(userActivity)
      XCTAssertTrue(result)

      XCTAssertTrue(self.vm.outputs.continueUserActivityReturnValue.value)
      self.goToActivity.assertValueCount(0)
    }
  }

  func testSetApplicationShortcutItems() {
    self.setApplicationShortcutItems.assertValues([])

    self.vm.inputs.applicationDidFinishLaunching(application: .shared, launchOptions: [:])

    self.setApplicationShortcutItems.assertValues([])

    self.scheduler.advance(by: .seconds(5))

    self.setApplicationShortcutItems.assertValues([[.projectsWeLove, .search]])

    self.vm.inputs.applicationDidEnterBackground()
    self.vm.inputs.applicationWillEnterForeground()
    self.scheduler.advance(by: .seconds(5))

    self.setApplicationShortcutItems.assertValues(
      [
        [.projectsWeLove, .search],
        [.projectsWeLove, .search]
      ]
    )
  }

  func testSetApplicationShortcutItems_LoggedInUser_NonMember() {
    let currentUser = User.template
      |> \.stats.memberProjectsCount .~ 0

    withEnvironment(apiService: MockService(fetchUserSelfResponse: currentUser), currentUser: currentUser) {
      self.setApplicationShortcutItems.assertValues([])

      self.vm.inputs.applicationDidFinishLaunching(application: .shared, launchOptions: [:])

      self.setApplicationShortcutItems.assertValues([])

      self.scheduler.advance(by: .seconds(5))

      self.setApplicationShortcutItems.assertValues([
        [.recommendedForYou, .projectsWeLove, .search]
      ])
    }
  }

  func testSetApplicationShortcutItems_LoggedInUser_Member() {
    let currentUser = User.template
      |> \.stats.memberProjectsCount .~ 2

    withEnvironment(apiService: MockService(fetchUserSelfResponse: currentUser), currentUser: currentUser) {
      self.setApplicationShortcutItems.assertValues([])

      self.vm.inputs.applicationDidFinishLaunching(application: .shared, launchOptions: [:])

      self.setApplicationShortcutItems.assertValues([])

      self.scheduler.advance(by: .seconds(5))

      self.setApplicationShortcutItems.assertValues([
        [.creatorDashboard, .recommendedForYou, .projectsWeLove, .search]
      ])
    }
  }

  func testPerformShortcutItem_CreatorDashboard() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    self.goToDashboard.assertValueCount(0)

    self.vm.inputs.applicationPerformActionForShortcutItem(
      ShortcutItem.creatorDashboard.applicationShortcutItem
    )

    self.goToDashboard.assertValueCount(1)
  }

  func testLaunchShortcutItem_CreatorDashboard() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [
        UIApplication.LaunchOptionsKey.shortcutItem: ShortcutItem.creatorDashboard.applicationShortcutItem
      ]
    )

    self.goToDashboard.assertValueCount(1)
    XCTAssertFalse(self.vm.outputs.applicationDidFinishLaunchingReturnValue)
  }

  func testPerformShortcutItem_ProjectsWeLove() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    self.goToDiscovery.assertValueCount(0)

    self.vm.inputs.applicationPerformActionForShortcutItem(
      ShortcutItem.projectsWeLove.applicationShortcutItem
    )

    let params = .defaults
      |> DiscoveryParams.lens.staffPicks .~ true
      |> DiscoveryParams.lens.sort .~ .magic
    self.goToDiscovery.assertValues([params])
  }

  func testLaunchShortcutItem_ProjectsWeLove() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [
        UIApplication.LaunchOptionsKey.shortcutItem: ShortcutItem.projectsWeLove.applicationShortcutItem
      ]
    )

    let params = .defaults
      |> DiscoveryParams.lens.staffPicks .~ true
      |> DiscoveryParams.lens.sort .~ .magic
    self.goToDiscovery.assertValues([params])
    XCTAssertFalse(self.vm.outputs.applicationDidFinishLaunchingReturnValue)
  }

  func testPerformShortcutItem_RecommendedForYou() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    self.goToDiscovery.assertValueCount(0)

    self.vm.inputs.applicationPerformActionForShortcutItem(
      ShortcutItem.recommendedForYou.applicationShortcutItem
    )

    let params = .defaults
      |> DiscoveryParams.lens.recommended .~ true
      |> DiscoveryParams.lens.sort .~ .magic
    self.goToDiscovery.assertValues([params])
  }

  func testLaunchShortcutItem_RecommendedForYou() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [
        UIApplication.LaunchOptionsKey.shortcutItem: ShortcutItem.recommendedForYou.applicationShortcutItem
      ]
    )

    let params = .defaults
      |> DiscoveryParams.lens.recommended .~ true
      |> DiscoveryParams.lens.sort .~ .magic
    self.goToDiscovery.assertValues([params])
    XCTAssertFalse(self.vm.outputs.applicationDidFinishLaunchingReturnValue)
  }

  func testPerformShortcutItem_Search() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    self.goToSearch.assertValueCount(0)

    self.vm.inputs.applicationPerformActionForShortcutItem(ShortcutItem.search.applicationShortcutItem)

    self.goToSearch.assertValueCount(1)
  }

  func testPerformShortcutItem_WhenOnboardingFlowIsActive() {
    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.onboardingCategoryPersonalizationFlow.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    withEnvironment(currentUser: nil, optimizelyClient: optimizelyClient) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )
      self.vm.inputs.applicationPerformActionForShortcutItem(ShortcutItem.search.applicationShortcutItem)

      self.goToSearch.assertValueCount(0)
    }
  }

  func testLaunchShortcutItem_Search() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [
        UIApplication.LaunchOptionsKey.shortcutItem: ShortcutItem.search.applicationShortcutItem
      ]
    )

    self.goToSearch.assertValueCount(1)
    XCTAssertFalse(self.vm.outputs.applicationDidFinishLaunchingReturnValue)
  }

  func testLaunchShortcutItem_WhenOnboardingFlowIsActive() {
    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.onboardingCategoryPersonalizationFlow.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    withEnvironment(currentUser: nil, optimizelyClient: optimizelyClient) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [
          UIApplication.LaunchOptionsKey.shortcutItem: ShortcutItem.search.applicationShortcutItem
        ]
      )

      self.goToSearch.assertValueCount(0)
      XCTAssertFalse(self.vm.outputs.applicationDidFinishLaunchingReturnValue)
    }
  }

  func testVisitorCookies_ApplicationDidFinishLaunching() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    XCTAssertEqual(["vis", "vis"], AppEnvironment.current.cookieStorage.cookies!.map { $0.name })
    XCTAssertEqual(
      ["DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF", "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF"],
      AppEnvironment.current.cookieStorage.cookies!.map { $0.value }
    )
    XCTAssertEqual(
      [
        AppEnvironment.current.apiService.serverConfig.apiBaseUrl.host,
        AppEnvironment.current.apiService.serverConfig.webBaseUrl.host
      ]
      .compact(),
      AppEnvironment.current.cookieStorage.cookies!.map { $0.domain }.sorted()
    )
  }

  func testVisitorCookies_ApplicationWillEnterForeground() {
    let existingCookie = HTTPCookie(
      properties: [
        .name: "existing-cookie",
        .value: "existing-cookie-value",
        .domain: AppEnvironment.current.apiService.serverConfig.apiBaseUrl.host as Any,
        .path: "/",
        .version: 0,
        .expires: Date.distantFuture,
        .secure: true
      ]
    )

    AppEnvironment.current.cookieStorage.setCookie(existingCookie!)

    self.vm.inputs.applicationWillEnterForeground()

    XCTAssertEqual(
      ["existing-cookie", "vis", "vis"],
      AppEnvironment.current.cookieStorage.cookies!.map { $0.name }.sorted()
    )
    XCTAssertEqual(
      [
        "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF",
        "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF",
        "existing-cookie-value"
      ],
      AppEnvironment.current.cookieStorage.cookies!.map { $0.value }.sorted()
    )
    XCTAssertEqual(
      [
        AppEnvironment.current.apiService.serverConfig.apiBaseUrl.host,
        AppEnvironment.current.apiService.serverConfig.apiBaseUrl.host,
        AppEnvironment.current.apiService.serverConfig.webBaseUrl.host
      ]
      .compact(),
      AppEnvironment.current.cookieStorage.cookies!.map { $0.domain }.sorted()
    )
  }

  func testVisitorCookies_UserSessionStarted() {
    let existingCookie = HTTPCookie(
      properties: [
        .name: "existing-cookie",
        .value: "existing-cookie-value",
        .domain: AppEnvironment.current.apiService.serverConfig.apiBaseUrl.host as Any,
        .path: "/",
        .version: 0,
        .expires: Date.distantFuture,
        .secure: true
      ]
    )

    AppEnvironment.current.cookieStorage.setCookie(existingCookie!)

    self.vm.inputs.userSessionStarted()

    XCTAssertEqual(
      ["existing-cookie", "vis", "vis"],
      AppEnvironment.current.cookieStorage.cookies!.map { $0.name }.sorted()
    )
    XCTAssertEqual(
      [
        "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF",
        "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF",
        "existing-cookie-value"
      ],
      AppEnvironment.current.cookieStorage.cookies!.map { $0.value }.sorted()
    )
    XCTAssertEqual(
      [
        AppEnvironment.current.apiService.serverConfig.apiBaseUrl.host,
        AppEnvironment.current.apiService.serverConfig.apiBaseUrl.host,
        AppEnvironment.current.apiService.serverConfig.webBaseUrl.host
      ]
      .compact(),
      AppEnvironment.current.cookieStorage.cookies!.map { $0.domain }.sorted()
    )
  }

  func testVisitorCookies_UserSessionEnded() {
    let existingCookie = HTTPCookie(
      properties: [
        .name: "existing-cookie",
        .value: "existing-cookie-value",
        .domain: AppEnvironment.current.apiService.serverConfig.apiBaseUrl.host as Any,
        .path: "/",
        .version: 0,
        .expires: Date.distantFuture,
        .secure: true
      ]
    )

    AppEnvironment.current.cookieStorage.setCookie(existingCookie!)

    self.vm.inputs.userSessionEnded()

    XCTAssertEqual(
      ["existing-cookie", "vis", "vis"],
      AppEnvironment.current.cookieStorage.cookies!.map { $0.name }.sorted()
    )
    XCTAssertEqual(
      [
        "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF",
        "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF",
        "existing-cookie-value"
      ],
      AppEnvironment.current.cookieStorage.cookies!.map { $0.value }.sorted()
    )
    XCTAssertEqual(
      [
        AppEnvironment.current.apiService.serverConfig.apiBaseUrl.host,
        AppEnvironment.current.apiService.serverConfig.apiBaseUrl.host,
        AppEnvironment.current.apiService.serverConfig.webBaseUrl.host
      ]
      .compact(),
      AppEnvironment.current.cookieStorage.cookies!.map { $0.domain }.sorted()
    )
  }

  func testEmailDeepLinking() {
    withEnvironment(apiService: MockService(fetchProjectResult: .success(.template))) {
      let emailUrl = URL(string: "https://click.e.kickstarter.com/?qs=deadbeef")!

      // The application launches.
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.findRedirectUrl.assertValues([])
      self.presentViewController.assertValues([])
      self.goToMobileSafari.assertValues([])

      // We deep-link to an email url.
      self.vm.inputs.applicationDidEnterBackground()
      self.vm.inputs.applicationWillEnterForeground()
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: emailUrl,
        options: [:]
      )
      XCTAssertTrue(result)

      self.findRedirectUrl.assertValues([emailUrl], "Ask to find the redirect after open the email url.")
      self.presentViewController.assertValues([], "No view controller is presented yet.")
      self.goToMobileSafari.assertValues([])

      // We find the redirect to be a project url.
      self.vm.inputs.foundRedirectUrl(URL(string: "https://www.kickstarter.com/projects/creator/project")!)

      self.findRedirectUrl.assertValues([emailUrl], "Nothing new is emitted.")
      self.presentViewController.assertValueCount(1, "Present the project view controller.")
      self.goToMobileSafari.assertValues([])
    }
  }

  func testEmailDeepLinking_WhenOnboardingFlowIsActive() {
    let emailUrl = URL(string: "https://click.e.kickstarter.com/?qs=deadbeef")!
    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.onboardingCategoryPersonalizationFlow.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    withEnvironment(currentUser: nil, optimizelyClient: optimizelyClient) {
      // The application launches.
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      // We deep-link to an email url.
      self.vm.inputs.applicationDidEnterBackground()
      self.vm.inputs.applicationWillEnterForeground()
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: emailUrl,
        options: [:]
      )
      XCTAssertTrue(result)

      self.findRedirectUrl.assertValues([emailUrl], "Ask to find the redirect after open the email url.")
      self.presentViewController.assertValues([], "No view controller is presented yet.")
      self.goToMobileSafari.assertValues([])

      // We find the redirect to be a project url.
      self.vm.inputs.foundRedirectUrl(URL(string: "https://www.kickstarter.com/projects/creator/project")!)

      self.findRedirectUrl.assertValues([emailUrl], "Nothing new is emitted.")
      self.presentViewController.assertValueCount(0, "Nothing is presented")
      self.goToMobileSafari.assertValues([])
    }
  }

  func testEmailDeepLinking_ContinuedUserActivity() {
    withEnvironment(apiService: MockService(fetchProjectResult: .success(.template))) {
      let emailUrl = URL(string: "https://click.e.kickstarter.com/?qs=deadbeef")!
      let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
      userActivity.webpageURL = emailUrl

      // The application launches.
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.findRedirectUrl.assertValues([])
      self.presentViewController.assertValues([])
      self.goToMobileSafari.assertValues([])

      // We deep-link to an email url.
      self.vm.inputs.applicationDidEnterBackground()
      self.vm.inputs.applicationWillEnterForeground()
      let result = self.vm.inputs.applicationContinueUserActivity(userActivity)
      XCTAssertTrue(result)

      self.findRedirectUrl.assertValues([emailUrl], "Ask to find the redirect after open the email url.")
      self.presentViewController.assertValues([], "No view controller is presented yet.")
      self.goToMobileSafari.assertValues([])

      // We find the redirect to be a project url.
      self.vm.inputs.foundRedirectUrl(URL(string: "https://www.kickstarter.com/projects/creator/project")!)

      self.findRedirectUrl.assertValues([emailUrl], "Nothing new is emitted.")
      self.presentViewController.assertValueCount(1, "Present the project view controller.")
      self.goToMobileSafari.assertValues([])
    }
  }

  func testEmailDeepLinking_UnrecognizedUrl() {
    let emailUrl = URL(string: "https://click.e.kickstarter.com/?qs=deadbeef")!

    // The application launches.
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    self.findRedirectUrl.assertValues([])
    self.presentViewController.assertValueCount(0)
    self.goToMobileSafari.assertValues([])

    // We deep-link to an email url.
    self.vm.inputs.applicationDidEnterBackground()
    self.vm.inputs.applicationWillEnterForeground()
    let result = self.vm.inputs.applicationOpenUrl(
      application: UIApplication.shared,
      url: emailUrl,
      options: [:]
    )
    XCTAssertTrue(result)

    self.findRedirectUrl.assertValues([emailUrl], "Ask to find the redirect after open the email url.")
    self.presentViewController.assertValues([], "No view controller is presented.")
    self.goToMobileSafari.assertValues([], "Do not go to mobile safari")

    // We find the redirect to be an unrecognized url.
    let unrecognizedUrl = URL(string: "https://www.kickstarter.com/unreconizable")!
    self.vm.inputs.foundRedirectUrl(unrecognizedUrl)

    self.findRedirectUrl.assertValues([emailUrl], "Nothing new is emitted.")
    self.presentViewController.assertValues([], "Do not present controller since the url was unrecognizable.")
    self.goToMobileSafari.assertValues([unrecognizedUrl], "Go to mobile safari for the unrecognized url.")
  }

  func testEmailDeepLinking_UnrecognizedUrl_ProjectPreview() {
    let emailUrl = URL(string: "https://click.e.kickstarter.com/?qs=deadbeef")!

    // The application launches.
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    self.findRedirectUrl.assertValues([])
    self.presentViewController.assertValueCount(0)
    self.goToMobileSafari.assertValues([])

    // We deep-link to an email url.
    self.vm.inputs.applicationDidEnterBackground()
    self.vm.inputs.applicationWillEnterForeground()
    let result = self.vm.inputs.applicationOpenUrl(
      application: UIApplication.shared,
      url: emailUrl,
      options: [:]
    )
    XCTAssertTrue(result)

    self.findRedirectUrl.assertValues([emailUrl], "Ask to find the redirect after open the email url.")
    self.presentViewController.assertValues([], "No view controller is presented.")
    self.goToMobileSafari.assertValues([], "Do not go to mobile safari")

    // We find the redirect to be an unrecognized url (project preview).
    let unrecognizedUrl = URL(string: "https://www.kickstarter.com/projects/creator/project?token=4")!
    self.vm.inputs.foundRedirectUrl(unrecognizedUrl)

    self.findRedirectUrl.assertValues([emailUrl], "Nothing new is emitted.")
    self.presentViewController.assertValues([], "Do not present controller since the url was unrecognizable.")
    self.goToMobileSafari.assertValues([unrecognizedUrl], "Go to mobile safari for the unrecognized url.")
  }

  func testOtherEmailDeepLink() {
    withEnvironment(apiService: MockService(fetchProjectResult: .success(.template))) {
      let emailUrl = URL(string: "https://email.kickstarter.com/mpss/a/b/c/d/e/f/g")!

      // The application launches.
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.findRedirectUrl.assertValues([])
      self.presentViewController.assertValues([])
      self.goToMobileSafari.assertValues([])

      // We deep-link to an email url.
      self.vm.inputs.applicationDidEnterBackground()
      self.vm.inputs.applicationWillEnterForeground()
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: emailUrl,
        options: [:]
      )
      XCTAssertTrue(result)

      self.findRedirectUrl.assertValues([emailUrl], "Ask to find the redirect after open the email url.")
      self.presentViewController.assertValues([], "No view controller is presented yet.")
      self.goToMobileSafari.assertValues([])

      // We find the redirect to be a project url.
      self.vm.inputs.foundRedirectUrl(URL(string: "https://www.kickstarter.com/projects/creator/project")!)

      self.findRedirectUrl.assertValues([emailUrl], "Nothing new is emitted.")
      self.presentViewController.assertValueCount(1, "Present the project view controller.")
      self.goToMobileSafari.assertValues([])
    }
  }

  func testProjectSurveyDeepLink() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    self.presentViewController.assertValues([])

    let projectUrl = "https://www.kickstarter.com"
      + "/projects/tequila/help-me-transform-this-pile-of-wood/surveys/123"
    let result = self.vm.inputs.applicationOpenUrl(
      application: UIApplication.shared,
      url: URL(string: projectUrl)!,
      options: [:]
    )
    XCTAssertTrue(result)

    self.presentViewController.assertValues([1])
  }

  func testErroredPledgeDeepLink_LoggedIn() {
    let project = Project.template
      |> \.personalization.backing .~ .template
    let service = MockService(fetchProjectResult: .success(project))

    withEnvironment(apiService: service, currentUser: .template) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.goToLoginWithIntent.assertDidNotEmitValue()
      self.presentViewController.assertValues([])

      let projectUrl = "https://www.kickstarter.com"
        + "/projects/sshults/greensens-the-easy-way-to-take-care-of-your-houseplants-0"
        + "/pledge?at=4f7d35e7c9d2bb57&ref=ksr_email_backer_failed_transaction"

      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: projectUrl)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.goToLoginWithIntent.assertDidNotEmitValue()
      self.presentViewController.assertValues([2])
    }
  }

  func testErroredPledgeDeepLink_LoggedOut() {
    withEnvironment(apiService: MockService(fetchProjectResult: .success(.template)), currentUser: nil) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.goToLoginWithIntent.assertDidNotEmitValue()
      self.presentViewController.assertValues([])

      let projectUrl = "https://www.kickstarter.com"
        + "/projects/sshults/greensens-the-easy-way-to-take-care-of-your-houseplants-0"
        + "/pledge?at=4f7d35e7c9d2bb57&ref=ksr_email_backer_failed_transaction"

      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: projectUrl)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.goToLoginWithIntent.assertValues([.erroredPledge])
      self.presentViewController.assertDidNotEmitValue()
    }
  }

  func testErroredPledgePushDeepLink_LoggedIn() {
    let project = Project.template
      |> \.personalization.backing .~ .template
    let service = MockService(fetchProjectResult: .success(project))

    withEnvironment(apiService: service, currentUser: .template) {
      self.goToLoginWithIntent.assertDidNotEmitValue()
      self.presentViewController.assertDidNotEmitValue()

      let pushData: [String: Any] = [
        "aps": [
          "alert": "You have an errored pledge."
        ],
        "errored_pledge": [
          "project_id": 2
        ]
      ]

      self.vm.inputs.didReceive(remoteNotification: pushData)

      self.goToLoginWithIntent.assertDidNotEmitValue()
      self.presentViewController.assertValues([2])
    }
  }

  func testErroredPledgePushDeepLink_LoggedOut() {
    withEnvironment(apiService: MockService(fetchProjectResult: .success(.template)), currentUser: nil) {
      self.goToLoginWithIntent.assertDidNotEmitValue()
      self.presentViewController.assertDidNotEmitValue()

      let pushData: [String: Any] = [
        "aps": [
          "alert": "You have an errored pledge."
        ],
        "errored_pledge": [
          "project_id": 2
        ]
      ]

      self.vm.inputs.didReceive(remoteNotification: pushData)

      self.goToLoginWithIntent.assertValues([.erroredPledge])
      self.presentViewController.assertDidNotEmitValue()
    }
  }

  func testUserSurveyDeepLink() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    self.presentViewController.assertValues([])

    let projectUrl = "https://www.kickstarter.com/users/tequila/surveys/123"
    let result = self.vm.inputs.applicationOpenUrl(
      application: UIApplication.shared,
      url: URL(string: projectUrl)!,
      options: [:]
    )
    XCTAssertTrue(result)

    self.presentViewController.assertValues([1])
  }

  func testDeeplink_WhenLandingPageExperiment_IsActive() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeOnboarding.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    withEnvironment(currentUser: nil, optimizelyClient: optimizelyClient) {
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: "https://www.kickstarter.com/search")!,
        options: [:]
      )

      XCTAssertTrue(result)

      self.goToSearch.assertValueCount(0)
    }
  }

  func testOpenPushNotification_WhenLandingPageExperiment_IsActive() {
    let pushData: [String: Any] = [
      "aps": [
        "alert": "Blob liked your update: Important message..."
      ],
      "post": [
        "id": 1,
        "project_id": 2
      ]
    ]

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeOnboarding.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    withEnvironment(currentUser: nil, optimizelyClient: optimizelyClient) {
      self.vm.inputs.didReceive(remoteNotification: pushData)

      self.presentViewController.assertValueCount(0)
    }
  }

  func testContinueUserActivity_WhenLandingPageExperiment_IsActive() {
    let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
    userActivity.webpageURL = URL(string: "https://www.kickstarter.com/activity")

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeOnboarding.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    withEnvironment(currentUser: nil, optimizelyClient: optimizelyClient) {
      self.vm.inputs.applicationDidFinishLaunching(application: .shared, launchOptions: [:])

      self.goToActivity.assertValueCount(0)
      XCTAssertFalse(self.vm.outputs.continueUserActivityReturnValue.value)

      let result = self.vm.inputs.applicationContinueUserActivity(userActivity)
      XCTAssertTrue(result)

      XCTAssertTrue(self.vm.outputs.continueUserActivityReturnValue.value)
      self.goToActivity.assertValueCount(0)
    }
  }

  func testPerformShortcutItem_WhenLandingPageExperiment_IsActive() {
    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeOnboarding.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    withEnvironment(currentUser: nil, optimizelyClient: optimizelyClient) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )
      self.vm.inputs.applicationPerformActionForShortcutItem(ShortcutItem.search.applicationShortcutItem)

      self.goToSearch.assertValueCount(0)
    }
  }

  func testLaunchShortcutItem_WhenLandingPageExperiment_IsActive() {
    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeOnboarding.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    withEnvironment(currentUser: nil, optimizelyClient: optimizelyClient) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [
          UIApplication.LaunchOptionsKey.shortcutItem: ShortcutItem.search.applicationShortcutItem
        ]
      )

      self.goToSearch.assertValueCount(0)
      XCTAssertFalse(self.vm.outputs.applicationDidFinishLaunchingReturnValue)
    }
  }

  func testEmailDeepLinking_WhenLandingPageExperiment_IsActive() {
    let emailUrl = URL(string: "https://click.e.kickstarter.com/?qs=deadbeef")!
    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeOnboarding.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    withEnvironment(currentUser: nil, optimizelyClient: optimizelyClient) {
      // The application launches.
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      // We deep-link to an email url.
      self.vm.inputs.applicationDidEnterBackground()
      self.vm.inputs.applicationWillEnterForeground()
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: emailUrl,
        options: [:]
      )
      XCTAssertTrue(result)

      self.findRedirectUrl.assertValues([emailUrl], "Ask to find the redirect after open the email url.")
      self.presentViewController.assertValues([], "No view controller is presented yet.")
      self.goToMobileSafari.assertValues([])

      // We find the redirect to be a project url.
      self.vm.inputs.foundRedirectUrl(URL(string: "https://www.kickstarter.com/projects/creator/project")!)

      self.findRedirectUrl.assertValues([emailUrl], "Nothing new is emitted.")
      self.presentViewController.assertValueCount(0, "Nothing is presented")
      self.goToMobileSafari.assertValues([])
    }
  }

  func testShowAlertEmitsIf_CanShowDialog() {
    let notification = Notification(
      name: Notification.Name(rawValue: "deadbeef"),
      userInfo: ["context": PushNotificationDialog.Context.login]
    )

    userDefaults.set(["message"], forKey: "com.kickstarter.KeyValueStoreType.deniedNotificationContexts")

    withEnvironment(currentUser: .template, userDefaults: userDefaults) {
      self.vm.inputs.applicationWillEnterForeground()
      self.vm.inputs.didReceive(remoteNotification: updatePushData)
      self.vm.inputs.showNotificationDialog(notification: notification)

      self.showAlert.assertValue(notification)
    }
  }

  func testShowAlertDoesNotEmitIf_CanNotShowDialog() {
    let notification = Notification(
      name: Notification.Name(rawValue: "deadbeef"),
      userInfo: ["context": PushNotificationDialog.Context.login]
    )

    userDefaults.set(["login"], forKey: "com.kickstarter.KeyValueStoreType.deniedNotificationContexts")

    withEnvironment(currentUser: .template, userDefaults: userDefaults) {
      self.vm.inputs.applicationWillEnterForeground()
      self.vm.inputs.didReceive(remoteNotification: updatePushData)
      self.vm.inputs.showNotificationDialog(notification: notification)

      self.showAlert.assertDidNotEmitValue()
    }
  }

  func testGoToCategoriesPersonalizationOnboarding_WhenLoggedIn() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments
      .~ [
        OptimizelyExperiment.Key.onboardingCategoryPersonalizationFlow.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    self.goToCategoriesPersonalizationOnboarding.assertDidNotEmitValue()

    self.vm.inputs.applicationDidFinishLaunching(application: nil, launchOptions: nil)
    _ = self.vm.inputs.optimizelyConfigured(with: MockOptimizelyResult())

    withEnvironment(
      currentUser: .template,
      optimizelyClient: mockOptimizelyClient,
      userDefaults: MockKeyValueStore()
    ) {
      self.vm.inputs.didUpdateOptimizelyClient(mockOptimizelyClient)

      self.goToCategoriesPersonalizationOnboarding.assertDidNotEmitValue()
    }
  }

  func testGoToCategoriesPersonalizationOnboarding_WhenPreviouslySeen() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments
      .~ [
        OptimizelyExperiment.Key.onboardingCategoryPersonalizationFlow.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]
    let mockValueStore = MockKeyValueStore()
    mockValueStore.hasSeenCategoryPersonalizationFlow = true

    self.goToCategoriesPersonalizationOnboarding.assertDidNotEmitValue()

    self.vm.inputs.applicationDidFinishLaunching(application: nil, launchOptions: nil)
    _ = self.vm.inputs.optimizelyConfigured(with: MockOptimizelyResult())

    withEnvironment(
      currentUser: nil,
      optimizelyClient: mockOptimizelyClient,
      userDefaults: mockValueStore
    ) {
      self.vm.inputs.didUpdateOptimizelyClient(mockOptimizelyClient)

      self.goToCategoriesPersonalizationOnboarding.assertDidNotEmitValue()
    }
  }

  func testGoToCategoriesPersonalizationOnboarding_Variant1() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments
      .~ [
        OptimizelyExperiment.Key.onboardingCategoryPersonalizationFlow.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]
    let mockValueStore = MockKeyValueStore()

    self.goToCategoriesPersonalizationOnboarding.assertDidNotEmitValue()

    self.vm.inputs.applicationDidFinishLaunching(application: nil, launchOptions: nil)
    _ = self.vm.inputs.optimizelyConfigured(with: MockOptimizelyResult())

    withEnvironment(
      currentUser: nil,
      optimizelyClient: mockOptimizelyClient,
      userDefaults: mockValueStore
    ) {
      self.vm.inputs.didUpdateOptimizelyClient(mockOptimizelyClient)

      self.goToCategoriesPersonalizationOnboarding.assertValueCount(1)
    }
  }

  func testGoToCategoriesPersonalizationOnboarding_Control() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments
      .~ [
        OptimizelyExperiment.Key.onboardingCategoryPersonalizationFlow.rawValue:
          OptimizelyExperiment.Variant.control.rawValue
      ]
    let mockValueStore = MockKeyValueStore()

    self.goToCategoriesPersonalizationOnboarding.assertDidNotEmitValue()

    self.vm.inputs.applicationDidFinishLaunching(application: nil, launchOptions: nil)
    _ = self.vm.inputs.optimizelyConfigured(with: MockOptimizelyResult())

    withEnvironment(
      currentUser: nil,
      optimizelyClient: mockOptimizelyClient,
      userDefaults: mockValueStore
    ) {
      self.vm.inputs.didUpdateOptimizelyClient(mockOptimizelyClient)

      self.goToCategoriesPersonalizationOnboarding.assertDidNotEmitValue()
    }
  }

  func testGoToCategoriesPersonalizationOnboarding_Variant2() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments
      .~ [
        OptimizelyExperiment.Key.onboardingCategoryPersonalizationFlow.rawValue:
          OptimizelyExperiment.Variant.variant2.rawValue
      ]
    let mockValueStore = MockKeyValueStore()

    self.goToCategoriesPersonalizationOnboarding.assertDidNotEmitValue()

    self.vm.inputs.applicationDidFinishLaunching(application: nil, launchOptions: nil)
    _ = self.vm.inputs.optimizelyConfigured(with: MockOptimizelyResult())

    withEnvironment(
      currentUser: nil,
      optimizelyClient: mockOptimizelyClient,
      userDefaults: mockValueStore
    ) {
      self.vm.inputs.didUpdateOptimizelyClient(mockOptimizelyClient)

      self.goToCategoriesPersonalizationOnboarding.assertDidNotEmitValue()
    }
  }

  func testGoToLandingPage_EmitsIf_OptimizelyIsNotControl_HasNotSeenLandingPage() {
    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.nativeOnboarding.rawValue: OptimizelyExperiment.Variant.variant1.rawValue]

    withEnvironment(currentUser: nil, optimizelyClient: optimizelyClient) {
      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)

      self.goToLandingPage.assertDidNotEmitValue()

      self.vm.inputs.didUpdateOptimizelyClient(MockOptimizelyClient())

      self.goToLandingPage.assertValueCount(1)
    }
  }

  func testGoToLandingPage_DoesNotEmitIf_OptimizelyIsControl_UserHasNotSeenLandingPage() {
    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.nativeOnboarding.rawValue: OptimizelyExperiment.Variant.control.rawValue]

    withEnvironment(currentUser: nil, optimizelyClient: optimizelyClient) {
      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)

      self.vm.inputs.didUpdateOptimizelyClient(MockOptimizelyClient())

      self.goToLandingPage.assertDidNotEmitValue()
    }
  }

  func testGoToLandingPage_DoesNotEmitIf_OptimizelyIsNotControl_UserHasSeenLandingPage() {
    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.nativeOnboarding.rawValue: OptimizelyExperiment.Variant.variant2.rawValue]

    let userDefaults = MockKeyValueStore()
      |> \.hasSeenLandingPage .~ true

    withEnvironment(currentUser: nil, optimizelyClient: optimizelyClient, userDefaults: userDefaults) {
      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)

      self.vm.inputs.didUpdateOptimizelyClient(MockOptimizelyClient())

      self.goToLandingPage.assertDidNotEmitValue()
    }
  }

  func testGoToLandingPage_DoesNotEmitIf_UserIsLoggedIn() {
    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.nativeOnboarding.rawValue: OptimizelyExperiment.Variant.variant1.rawValue]

    let userDefaults = MockKeyValueStore()
      |> \.hasSeenLandingPage .~ false

    withEnvironment(currentUser: .template, optimizelyClient: optimizelyClient, userDefaults: userDefaults) {
      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)

      self.vm.inputs.didUpdateOptimizelyClient(MockOptimizelyClient())

      self.goToLandingPage.assertDidNotEmitValue()
    }
  }

  func testDeeplink_DoesNotActivateIf_GoToLandingPageEmits() {
    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.nativeOnboarding.rawValue: OptimizelyExperiment.Variant.variant1.rawValue]

    let userDefaults = MockKeyValueStore()
      |> \.hasSeenLandingPage .~ false

    withEnvironment(currentUser: nil, optimizelyClient: optimizelyClient, userDefaults: userDefaults) {
      self.goToLandingPage.assertDidNotEmitValue()

      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)
      self.vm.inputs.didUpdateOptimizelyClient(MockOptimizelyClient())

      _ = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(
          string: "https://www.kickstarter.com/projects/chelsea-punk/chelsea-punk-band-the-final-album"
        )!,
        options: [:]
      )

      self.presentViewController.assertDidNotEmitValue()
      self.goToLandingPage.assertValueCount(1)
    }
  }

  func testVerifyEmail_Success() {
    self.emailVerificationCompletedMessage.assertDidNotEmitValue()
    self.emailVerificationCompletedSuccess.assertDidNotEmitValue()

    guard let url = URL(string: "https://www.kickstarter.com/profile/verify_email?at=12345") else {
      XCTFail("Should have a url")
      return
    }

    let env = EmailVerificationResponseEnvelope(
      message: "Thanks—you’ve successfully verified your email address."
    )

    let mockService = MockService(verifyEmailResult: .success(env))

    withEnvironment(apiService: mockService) {
      _ = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: url,
        options: [:]
      )

      self.scheduler.advance()

      self.emailVerificationCompletedSuccess.assertValues([true])
      self.emailVerificationCompletedMessage.assertValues(
        ["Thanks—you’ve successfully verified your email address."]
      )
    }
  }

  func testVerifyEmail_Failure() {
    self.emailVerificationCompletedMessage.assertDidNotEmitValue()
    self.emailVerificationCompletedSuccess.assertDidNotEmitValue()

    guard let url = URL(string: "https://www.kickstarter.com/profile/verify_email?at=12345") else {
      XCTFail("Should have a url")
      return
    }

    let errorEnvelope = ErrorEnvelope(
      errorMessages: ["Error Message"],
      ksrCode: .UnknownCode,
      httpCode: 403,
      exception: nil
    )

    let mockService = MockService(verifyEmailResult: .failure(errorEnvelope))

    withEnvironment(apiService: mockService) {
      _ = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: url,
        options: [:]
      )

      self.scheduler.advance()

      self.emailVerificationCompletedSuccess.assertValues([false])
      self.emailVerificationCompletedMessage.assertValues(
        ["Error Message"]
      )
    }
  }

  func testVerifyEmail_Failure_UnknownError() {
    self.emailVerificationCompletedMessage.assertDidNotEmitValue()
    self.emailVerificationCompletedSuccess.assertDidNotEmitValue()

    guard let url = URL(string: "https://www.kickstarter.com/profile/verify_email?at=12345") else {
      XCTFail("Should have a url")
      return
    }

    let errorEnvelope = ErrorEnvelope(
      errorMessages: [],
      ksrCode: .UnknownCode,
      httpCode: 500,
      exception: nil
    )

    let mockService = MockService(verifyEmailResult: .failure(errorEnvelope))

    withEnvironment(apiService: mockService) {
      _ = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: url,
        options: [:]
      )

      self.scheduler.advance()

      self.emailVerificationCompletedSuccess.assertValues([false])
      self.emailVerificationCompletedMessage.assertValues(
        ["Something went wrong, please try again."]
      )
    }
  }

  func testGoToPerimeterXCaptcha_Captcha() {
    self.goToPerimeterXCaptcha.assertDidNotEmitValue()

    let response = MockPerimeterXBlockResponse(blockType: .Captcha)

    self.vm.inputs.perimeterXCaptchaTriggeredWithUserInfo(["response": response])

    self.goToPerimeterXCaptcha.assertValueCount(1)
    XCTAssertEqual(self.goToPerimeterXCaptcha.values.last?.type, .Captcha)
  }

  func testGoToPerimeterXCaptcha_Blocked() {
    self.goToPerimeterXCaptcha.assertDidNotEmitValue()

    let response = MockPerimeterXBlockResponse(blockType: .Block)

    self.vm.inputs.perimeterXCaptchaTriggeredWithUserInfo(["response": response])

    self.goToPerimeterXCaptcha.assertValueCount(1)
    XCTAssertEqual(self.goToPerimeterXCaptcha.values.last?.type, .Block)
  }

  func testFeatureFlagsRetainedInConfig_NotRelease() {
    let mockBundle = MockBundle(
      bundleIdentifier: KickstarterBundleIdentifier.beta.rawValue
    )

    let config = Config.template
      |> Config.lens.features .~ [
        "my_enabled_feature": true,
        "my_disabled_feature": false
      ]

    let incomingConfig = Config.template
      |> Config.lens.features .~ [
        "my_enabled_feature": false,
        "my_disabled_feature": true,
        "my_new_feature": true
      ]

    let service = MockService(fetchConfigResponse: incomingConfig)

    self.updateConfigInEnvironment.assertDidNotEmitValue()

    withEnvironment(apiService: service, config: config, mainBundle: mockBundle) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: .shared,
        launchOptions: [:]
      )

      self.updateConfigInEnvironment.assertValueCount(1)

      let updatedFeatures = self.updateConfigInEnvironment.lastValue?.features

      XCTAssertEqual(updatedFeatures?["my_enabled_feature"], true, "Retains stored value")
      XCTAssertEqual(updatedFeatures?["my_disabled_feature"], false, "Retains stored value")
      XCTAssertEqual(updatedFeatures?["my_new_feature"], true, "Uses incoming value")
    }
  }

  func testFeatureFlagsRetainedInConfig_Release() {
    let mockBundle = MockBundle(
      bundleIdentifier: KickstarterBundleIdentifier.release.rawValue
    )

    let config = Config.template
      |> Config.lens.features .~ [
        "my_enabled_feature": true,
        "my_disabled_feature": false
      ]

    let incomingConfig = Config.template
      |> Config.lens.features .~ [
        "my_enabled_feature": false,
        "my_disabled_feature": true,
        "my_new_feature": true
      ]

    let service = MockService(fetchConfigResponse: incomingConfig)

    self.updateConfigInEnvironment.assertDidNotEmitValue()

    withEnvironment(apiService: service, config: config, mainBundle: mockBundle) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: .shared,
        launchOptions: [:]
      )

      self.updateConfigInEnvironment.assertValueCount(1)

      let updatedFeatures = self.updateConfigInEnvironment.lastValue?.features

      XCTAssertEqual(updatedFeatures?["my_enabled_feature"], false, "Uses incoming value")
      XCTAssertEqual(updatedFeatures?["my_disabled_feature"], true, "Uses incoming value")
      XCTAssertEqual(updatedFeatures?["my_new_feature"], true, "Uses incoming value")
    }
  }

  func testConfigureSegment_Release() {
    let mockBundle = MockBundle(
      bundleIdentifier: KickstarterBundleIdentifier.release.rawValue
    )

    self.configureSegment.assertDidNotEmitValue()

    withEnvironment(mainBundle: mockBundle) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: .shared,
        launchOptions: [:]
      )

      self.configureSegment.assertValues([Secrets.Segment.production])
    }
  }

  func testConfigureSegment_NotRelease() {
    let mockBundle = MockBundle(
      bundleIdentifier: KickstarterBundleIdentifier.beta.rawValue
    )

    self.configureSegment.assertDidNotEmitValue()

    withEnvironment(mainBundle: mockBundle) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: .shared,
        launchOptions: [:]
      )

      self.configureSegment.assertValues([Secrets.Segment.staging])
    }
  }

  func testSegmentIsEnabled_IsEnabled_DidUpdateConfig() {
    self.segmentIsEnabled.assertDidNotEmitValue()

    let config = Config.template
      |> Config.lens.features .~ [Feature.segment.rawValue: true]

    withEnvironment(config: config) {
      self.vm.inputs.didUpdateConfig(config)

      self.segmentIsEnabled.assertValues([true])
    }
  }

  func testSegmentIsEnabled_IsDisabled_ConfigUpdatedNotificationObserved() {
    self.segmentIsEnabled.assertDidNotEmitValue()

    let config = Config.template
      |> Config.lens.features .~ [Feature.segment.rawValue: false]

    withEnvironment(config: config) {
      self.vm.inputs.configUpdatedNotificationObserved()

      self.segmentIsEnabled.assertValues([false])
    }
  }

  func testDeepLink_UserDidUpdateNotificationSettings() {
    self.updateCurrentUserInEnvironment.assertDidNotEmitValue()

    withEnvironment(apiService: MockService()) {
      let user = User.template
        |> User.lens.notifications.mobileMessages .~ false

      let env = AccessTokenEnvelope(accessToken: "deadbeef", user: user)
      AppEnvironment.login(env)

      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )

      self.scheduler.advance(by: .seconds(5))

      self.updateCurrentUserInEnvironment.assertValues([user])

      let updatedUser = user
        |> User.lens.notifications.mobileMessages .~ true

      let url =
        "https://\(AppEnvironment.current.apiService.serverConfig.webBaseUrl.host ?? "")/settings/notify_mobile_of_messages/true"

      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: url)!,
        options: [:]
      )
      XCTAssertTrue(result)

      self.updateCurrentUserInEnvironment.assertValues([user])

      self.scheduler.advance()

      self.updateCurrentUserInEnvironment.assertValues([user, updatedUser])
    }
  }
}

private let backingForCreatorPushData: [String: Any] = [
  "aps": [
    "alert": "HEYYYY"
  ],
  "activity": [
    "category": "backing",
    "id": 1,
    "project_id": 1
  ],
  "for_creator": true
]

private let friendBackingPushData = [
  "aps": [
    "alert": "HEYYYY"
  ],
  "activity": [
    "category": "backing",
    "id": 1,
    "project_id": 1
  ]
]

private let genericActivityPushData = [
  "aps": [
    "alert": "HEYYYY"
  ],
  "activity": [
    "category": "success",
    "id": 1,
    "project_id": 1
  ]
]

private let genericProjectPushData = [
  "aps": [
    "alert": "HEYYYY"
  ],
  "project": [
    "id": 1
  ]
]
private let projectCommentPushData = [
  "aps": [
    "alert": "HEYYYY"
  ],
  "activity": [
    "category": "comment-project",
    "id": 1,
    "project_id": 1
  ]
]

private let surveyResponsePushData = [
  "aps": [
    "alert": "Response needed! Get your reward for backing some project."
  ],
  "survey": [
    "id": 1,
    "project_id": 1
  ]
]

private let updateCommentPushData = [
  "aps": [
    "alert": "HEYYYY"
  ],
  "activity": [
    "category": "comment-post",
    "id": 1,
    "project_id": 1,
    "update_id": 1
  ]
]

private let updatePushData = [
  "aps": [
    "alert": "HEYYYY"
  ],
  "activity": [
    "category": "update",
    "id": 1,
    "project_id": 1,
    "update_id": 1
  ]
]
