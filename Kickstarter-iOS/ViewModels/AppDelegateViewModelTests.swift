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
  private let configureFabric = TestObserver<(), Never>()
  private let configureQualtrics = TestObserver<QualtricsConfigData, Never>()
  private let didAcceptReceivingRemoteNotifications = TestObserver<(), Never>()
  private let displayQualtricsSurvey = TestObserver<(), Never>()
  private let evaluateQualtricsTargetingLogic = TestObserver<(), Never>()
  private let findRedirectUrl = TestObserver<URL, Never>()
  private let forceLogout = TestObserver<(), Never>()
  private let goToActivity = TestObserver<(), Never>()
  private let goToCategoriesPersonalizationOnboarding = TestObserver<(), Never>()
  private let goToDashboard = TestObserver<Param?, Never>()
  private let goToDiscovery = TestObserver<DiscoveryParams?, Never>()
  private let goToLandingPage = TestObserver<(), Never>()
  private let goToProjectActivities = TestObserver<Param, Never>()
  private let goToLoginWithIntent = TestObserver<LoginIntent, Never>()
  private let goToProfile = TestObserver<(), Never>()
  private let goToMobileSafari = TestObserver<URL, Never>()
  private let goToSearch = TestObserver<(), Never>()
  private let postNotificationName = TestObserver<Notification.Name, Never>()
  private let presentViewController = TestObserver<Int, Never>()
  private let pushRegistrationStarted = TestObserver<(), Never>()
  private let pushTokenSuccessfullyRegistered = TestObserver<String, Never>()
  private let setApplicationShortcutItems = TestObserver<[ShortcutItem], Never>()
  private let showAlert = TestObserver<Notification, Never>()
  private let unregisterForRemoteNotifications = TestObserver<(), Never>()
  private let updateCurrentUserInEnvironment = TestObserver<User, Never>()
  private let updateConfigInEnvironment = TestObserver<Config, Never>()

  override func setUp() {
    super.setUp()

    self.vm = AppDelegateViewModel()

    self.vm.outputs.applicationIconBadgeNumber.observe(self.applicationIconBadgeNumber.observer)
    self.vm.outputs.configureAppCenterWithData.observe(self.configureAppCenterWithData.observer)
    self.vm.outputs.configureFabric.observe(self.configureFabric.observer)
    self.vm.outputs.configureOptimizely.map(first).observe(self.configureOptimizelySDKKey.observer)
    self.vm.outputs.configureOptimizely.map(second).observe(self.configureOptimizelyLogLevel.observer)
    self.vm.outputs.configureOptimizely.map(third).observe(self.configureOptimizelyDispatchInterval.observer)
    self.vm.outputs.configureQualtrics.observe(self.configureQualtrics.observer)
    self.vm.outputs.displayQualtricsSurvey.observe(self.displayQualtricsSurvey.observer)
    self.vm.outputs.evaluateQualtricsTargetingLogic.observe(self.evaluateQualtricsTargetingLogic.observer)
    self.vm.outputs.findRedirectUrl.observe(self.findRedirectUrl.observer)
    self.vm.outputs.forceLogout.observe(self.forceLogout.observer)
    self.vm.outputs.goToActivity.observe(self.goToActivity.observer)
    self.vm.outputs.goToCategoryPersonalizationOnboarding
      .observe(self.goToCategoriesPersonalizationOnboarding.observer)
    self.vm.outputs.goToDashboard.observe(self.goToDashboard.observer)
    self.vm.outputs.goToDiscovery.observe(self.goToDiscovery.observer)
    self.vm.outputs.goToLandingPage.observe(self.goToLandingPage.observer)
    self.vm.outputs.goToLoginWithIntent.observe(self.goToLoginWithIntent.observer)
    self.vm.outputs.goToProfile.observe(self.goToProfile.observer)
    self.vm.outputs.goToMobileSafari.observe(self.goToMobileSafari.observer)
    self.vm.outputs.goToProjectActivities.observe(self.goToProjectActivities.observer)
    self.vm.outputs.goToSearch.observe(self.goToSearch.observer)
    self.vm.outputs.postNotification.map { $0.name }.observe(self.postNotificationName.observer)
    self.vm.outputs.presentViewController.map { ($0 as! UINavigationController).viewControllers.count }
      .observe(self.presentViewController.observer)
    self.vm.outputs.pushTokenRegistrationStarted.observe(self.pushRegistrationStarted.observer)
    self.vm.outputs.pushTokenSuccessfullyRegistered.observe(self.pushTokenSuccessfullyRegistered.observer)
    self.vm.outputs.setApplicationShortcutItems.observe(self.setApplicationShortcutItems.observer)
    self.vm.outputs.showAlert.observe(self.showAlert.observer)
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

  func testConfigureFabric() {
    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)

    self.configureFabric.assertValueCount(1)
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

  func testKoala_AppLifecycle() {
    XCTAssertEqual([], trackingClient.events)

    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )
    XCTAssertEqual(["App Open", "Opened App"], trackingClient.events)

    self.vm.inputs.applicationDidEnterBackground()
    XCTAssertEqual(["App Open", "Opened App"], trackingClient.events)

    self.vm.inputs.applicationWillEnterForeground()
    XCTAssertEqual(
      ["App Open", "Opened App", "App Open", "Opened App"],
      trackingClient.events
    )
  }

  func testKoala_MemoryWarning() {
    XCTAssertEqual([], trackingClient.events)

    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )
    XCTAssertEqual(["App Open", "Opened App"], trackingClient.events)

    self.vm.inputs.applicationDidReceiveMemoryWarning()
    XCTAssertEqual(["App Open", "Opened App", "App Memory Warning"], trackingClient.events)
  }

  func testKoala_AppCrash() {
    XCTAssertEqual([], trackingClient.events)

    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )
    XCTAssertEqual(["App Open", "Opened App"], trackingClient.events)

    self.vm.inputs.crashManagerDidFinishSendingCrashReport()
    XCTAssertEqual(["App Open", "Opened App", "Crashed App"], trackingClient.events)
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

    self.vm.inputs.applicationDidEnterBackground()
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

  func testOpenAppBanner() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    XCTAssertEqual(["App Open", "Opened App"], self.trackingClient.events)

    let result = self.vm.inputs.applicationOpenUrl(
      application: UIApplication.shared,
      url: URL(string: "http://www.google.com/?app_banner=1&hello=world")!,
      options: [:]
    )
    XCTAssertTrue(result)

    XCTAssertEqual(
      ["App Open", "Opened App", "Smart App Banner Opened", "Opened App Banner"],
      self.trackingClient.events
    )
    XCTAssertEqual(
      [true, nil, true, nil],
      self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self)
    )
    XCTAssertEqual(
      [nil, nil, "world", "world"],
      self.trackingClient.properties(forKey: "hello", as: String.self)
    )
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
    let apiService = MockService(fetchProjectResponse: .template, fetchUpdateResponse: .template)
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
    }
  }

  func testPresentViewController_ProjectPreviewLink_PrelaunchActivated_True() {
    let project = Project.template
      |> Project.lens.prelaunchActivated .~ true

    let apiService = MockService(fetchProjectResponse: project)
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

  func testPresentViewController_ProjectPreviewLink_PrelaunchActivated_False() {
    let project = Project.template
      |> Project.lens.prelaunchActivated .~ false

    let apiService = MockService(fetchProjectResponse: project)
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

  func testPresentViewController_ProjectPreviewLink_PrelaunchActivated_Nil() {
    let project = Project.template
      |> Project.lens.prelaunchActivated .~ nil

    let apiService = MockService(fetchProjectResponse: project)
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

  func testGoToDiscoveryWithCategory() {
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
    let client = MockTrackingClient()

    MockPushRegistration.hasAuthorizedNotificationsProducer = .init(value: false)
    MockPushRegistration.registerProducer = .init(value: true)

    withEnvironment(
      apiService: MockService(),
      currentUser: .template,
      koala: Koala(client: client),
      pushRegistrationType: MockPushRegistration.self
    ) {
      XCTAssertEqual([], client.events)
      self.pushRegistrationStarted.assertValueCount(0)
      self.pushTokenSuccessfullyRegistered.assertValueCount(0)

      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: [:])
      self.vm.inputs.userSessionStarted()
      self.vm.inputs.didAcceptReceivingRemoteNotifications()

      self.pushRegistrationStarted.assertValueCount(1)

      self.vm.inputs.didRegisterForRemoteNotifications(withDeviceTokenData: "token".data(using: .utf8)!)

      self.scheduler.advance(by: .seconds(5))

      self.pushTokenSuccessfullyRegistered.assertValueCount(1)

      XCTAssertEqual(
        ["App Open", "Opened App", "Confirmed Push Opt-In"], client.events
      )
    }
  }

  func testRegisterPushNotifications_PreviouslyAccepted() {
    let client = MockTrackingClient()

    MockPushRegistration.hasAuthorizedNotificationsProducer = .init(value: true)
    MockPushRegistration.registerProducer = .init(value: true)

    withEnvironment(
      apiService: MockService(),
      currentUser: .template,
      koala: Koala(client: client),
      pushRegistrationType: MockPushRegistration.self
    ) {
      XCTAssertEqual([], client.events)
      self.pushRegistrationStarted.assertValueCount(0)
      self.pushTokenSuccessfullyRegistered.assertValueCount(0)

      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: [:])
      self.vm.inputs.userSessionStarted()

      self.pushRegistrationStarted.assertValueCount(1)

      self.vm.inputs.didRegisterForRemoteNotifications(withDeviceTokenData: "token".data(using: .utf8)!)

      self.scheduler.advance(by: .seconds(5))

      self.pushTokenSuccessfullyRegistered.assertValueCount(1)

      XCTAssertEqual(
        ["App Open", "Opened App"], client.events,
        "Re-registers for pushes but does not track as an opt-in"
      )
    }
  }

  func testTrackingPushAuthorizationOptIn() {
    let client = MockTrackingClient()

    MockPushRegistration.hasAuthorizedNotificationsProducer = .init(value: false)
    MockPushRegistration.registerProducer = .init(value: true)

    withEnvironment(
      currentUser: .template, koala: Koala(client: client), pushRegistrationType: MockPushRegistration.self
    ) {
      XCTAssertEqual([], client.events)

      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: [:])
      self.vm.inputs.userSessionStarted()

      self.vm.inputs.didAcceptReceivingRemoteNotifications()

      XCTAssertEqual(["App Open", "Opened App", "Confirmed Push Opt-In"], client.events)
    }
  }

  func testTrackingPushAuthorizationOptOut() {
    let client = MockTrackingClient()

    MockPushRegistration.hasAuthorizedNotificationsProducer = .init(value: false)
    MockPushRegistration.registerProducer = .init(value: false)

    withEnvironment(
      currentUser: .template, koala: Koala(client: client), pushRegistrationType: MockPushRegistration.self
    ) {
      XCTAssertEqual([], client.events)

      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: [:])
      self.vm.inputs.userSessionStarted()

      self.vm.inputs.didAcceptReceivingRemoteNotifications()

      XCTAssertEqual(["App Open", "Opened App", "Dismissed Push Opt-In"], client.events)
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

  func testOpenPushNotification_WhileInBackground() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    self.presentViewController.assertValueCount(0)

    self.vm.inputs.didReceive(remoteNotification: friendBackingPushData)

    self.presentViewController.assertValueCount(1)
    XCTAssertEqual(
      ["App Open", "Opened App", "Notification Opened", "Opened Notification"],
      self.trackingClient.events
    )
    XCTAssertEqual(
      [true, nil, true, nil],
      self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self)
    )
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
    self.vm.inputs.didReceive(remoteNotification: updatePushData)

    self.presentViewController.assertValueCount(1)
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
    self.vm.inputs.didReceive(remoteNotification: updateCommentPushData)

    self.presentViewController.assertValueCount(1)
  }

  func testOpenNotification_UpdateComment_BadData() {
    var badPushData = updatePushData
    badPushData["activity"]?["update_id"] = nil

    self.vm.inputs.didReceive(remoteNotification: badPushData)

    self.presentViewController.assertValueCount(0)
  }

  func testOpenNotification_ProjectComment() {
    self.vm.inputs.didReceive(remoteNotification: projectCommentPushData)

    self.presentViewController.assertValueCount(1)
  }

  func testOpenNotification_ProjectComment_WithBadData() {
    var badPushData = updatePushData
    badPushData["activity"]?["project_id"] = nil

    self.vm.inputs.didReceive(remoteNotification: badPushData)

    self.presentViewController.assertValueCount(0)
  }

  func testOpenNotification_GenericProject() {
    self.vm.inputs.didReceive(remoteNotification: genericProjectPushData)

    self.presentViewController.assertValueCount(1)
  }

  func testOpenNotification_ProjectStateChanges() {
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
    XCTAssertEqual(["App Open", "Opened App"], self.trackingClient.events)

    let result = self.vm.inputs.applicationContinueUserActivity(userActivity)
    XCTAssertTrue(result)

    self.goToActivity.assertValueCount(1)
    XCTAssertTrue(self.vm.outputs.continueUserActivityReturnValue.value)
    XCTAssertEqual(
      ["App Open", "Opened App", "Continue User Activity", "Opened Deep Link"],
      self.trackingClient.events
    )
    XCTAssertEqual(
      [true, nil, true, nil],
      self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self)
    )
  }

  func testContinueUserActivity_InvalidActivity() {
    let userActivity = NSUserActivity(activityType: "Other")

    self.vm.inputs.applicationDidFinishLaunching(application: .shared, launchOptions: [:])
    let result = self.vm.inputs.applicationContinueUserActivity(userActivity)
    XCTAssertFalse(result)

    XCTAssertFalse(self.vm.outputs.continueUserActivityReturnValue.value)
    XCTAssertEqual(["App Open", "Opened App"], self.trackingClient.events)
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

  func testPerformShortcutItem_KoalaTracking() {
    // Launch app and wait for shortcuts to be set
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )
    self.scheduler.advance(by: .seconds(5))

    // Perform a shortcut item
    self.vm.inputs.applicationPerformActionForShortcutItem(
      ShortcutItem.projectsWeLove.applicationShortcutItem
    )

    XCTAssertEqual(["App Open", "Opened App", "Performed Shortcut"], self.trackingClient.events)
    XCTAssertEqual(
      [nil, nil, "projects_we_love"],
      self.trackingClient.properties(forKey: "type", as: String.self)
    )
    XCTAssertEqual(
      [nil, nil, "projects_we_love,search"],
      self.trackingClient.properties(forKey: "context", as: String.self)
    )

    withEnvironment(currentUser: .template) {
      // Login with a user and wait for shortcuts to be set
      self.vm.inputs.userSessionStarted()
      self.scheduler.advance(by: .seconds(5))

      XCTAssertEqual(
        ["App Open", "Opened App", "Performed Shortcut"],
        self.trackingClient.events,
        "Nothing new is tracked."
      )

      // Perform shortcut item
      self.vm.inputs.applicationPerformActionForShortcutItem(
        ShortcutItem.recommendedForYou.applicationShortcutItem
      )

      XCTAssertEqual(
        ["App Open", "Opened App", "Performed Shortcut", "Performed Shortcut"],
        self.trackingClient.events
      )
      XCTAssertEqual(
        [nil, nil, "projects_we_love", "recommended_for_you"],
        self.trackingClient.properties(forKey: "type", as: String.self)
      )
      XCTAssertEqual(
        [
          nil, nil, "projects_we_love,search",
          "recommended_for_you,projects_we_love,search"
        ],
        self.trackingClient.properties(forKey: "context", as: String.self)
      )
    }
  }

  func testLaunchShortcutItem_KoalaTracking() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [
        UIApplication.LaunchOptionsKey.shortcutItem: ShortcutItem.projectsWeLove.applicationShortcutItem
      ]
    )

    XCTAssertEqual(["App Open", "Opened App"], self.trackingClient.events)

    self.scheduler.advance(by: .seconds(5))

    XCTAssertEqual(["App Open", "Opened App", "Performed Shortcut"], self.trackingClient.events)
    XCTAssertEqual(
      [nil, nil, "projects_we_love"],
      self.trackingClient.properties(forKey: "type", as: String.self)
    )
    XCTAssertEqual(
      [nil, nil, "projects_we_love,search"],
      self.trackingClient.properties(forKey: "context", as: String.self)
    )
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
    let service = MockService(fetchProjectResponse: project)

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
    withEnvironment(currentUser: nil) {
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
    let service = MockService(fetchProjectResponse: project)

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
    withEnvironment(currentUser: nil) {
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

  // MARK: - Qualtrics

  private let firstAppSessionKey = "first_app_session"

  func testQualtricsDisplaySurvey_FeatureFlagDisabled() {
    let config = Config.template
      |> \.features .~ [Feature.qualtrics.rawValue: false]

    withEnvironment(config: config) {
      self.configureQualtrics.assertDidNotEmitValue()
      self.displayQualtricsSurvey.assertDidNotEmitValue()
      self.evaluateQualtricsTargetingLogic.assertDidNotEmitValue()

      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)
      self.vm.inputs.didUpdateConfig(config)

      self.configureQualtrics.assertDidNotEmitValue()
      self.displayQualtricsSurvey.assertDidNotEmitValue()
      self.evaluateQualtricsTargetingLogic.assertDidNotEmitValue()
    }
  }

  func testQualtricsDisplaySurvey_Success_LoggedOut() {
    let config = Config.template
      |> \.features .~ [Feature.qualtrics.rawValue: true]

    let mockQualtricsPropertiesType = MockQualtricsPropertiesType()

    withEnvironment(config: config) {
      self.configureQualtrics.assertDidNotEmitValue()
      self.displayQualtricsSurvey.assertDidNotEmitValue()
      self.evaluateQualtricsTargetingLogic.assertDidNotEmitValue()
      XCTAssertEqual(mockQualtricsPropertiesType.values[firstAppSessionKey], nil)

      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)
      self.vm.inputs.didUpdateConfig(config)

      let expectedConfig = QualtricsConfigData(
        brandId: Secrets.Qualtrics.brandId,
        zoneId: Secrets.Qualtrics.zoneId,
        interceptId: QualtricsIntercept.survey.interceptId,
        stringProperties: qualtricsProps()
          .withAllValuesFrom([
            "logged_in": "false"
          ])
      )

      self.configureQualtrics.assertValues([expectedConfig])
      self.displayQualtricsSurvey.assertDidNotEmitValue()
      self.evaluateQualtricsTargetingLogic.assertDidNotEmitValue()
      XCTAssertEqual(mockQualtricsPropertiesType.values[firstAppSessionKey], nil)

      self.vm.inputs.qualtricsInitialized(with: MockQualtricsResultType(passedResult: true))

      self.configureQualtrics.assertValues([expectedConfig])
      self.displayQualtricsSurvey.assertDidNotEmitValue()
      self.evaluateQualtricsTargetingLogic.assertDidNotEmitValue()
      XCTAssertEqual(mockQualtricsPropertiesType.values[firstAppSessionKey], nil)

      self.scheduler.advance(by: .seconds(2))

      self.configureQualtrics.assertValues([expectedConfig])
      self.displayQualtricsSurvey.assertDidNotEmitValue()
      self.evaluateQualtricsTargetingLogic.assertValueCount(1)
      XCTAssertEqual(mockQualtricsPropertiesType.values[firstAppSessionKey], nil)

      self.vm.inputs.didEvaluateQualtricsTargetingLogic(
        with: MockQualtricsResultType(passedResult: true),
        properties: mockQualtricsPropertiesType
      )

      self.configureQualtrics.assertValues([expectedConfig])
      self.displayQualtricsSurvey.assertValueCount(1)
      self.evaluateQualtricsTargetingLogic.assertValueCount(1)
      XCTAssertEqual(mockQualtricsPropertiesType.values[firstAppSessionKey], 0)
    }
  }

  func testQualtricsDisplaySurvey_Success_LoggedIn() {
    let config = Config.template
      |> \.features .~ [Feature.qualtrics.rawValue: true]

    let mockQualtricsPropertiesType = MockQualtricsPropertiesType()

    withEnvironment(config: config, currentUser: .template) {
      self.configureQualtrics.assertDidNotEmitValue()
      self.displayQualtricsSurvey.assertDidNotEmitValue()
      self.evaluateQualtricsTargetingLogic.assertDidNotEmitValue()
      XCTAssertEqual(mockQualtricsPropertiesType.values[firstAppSessionKey], nil)

      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)
      self.vm.inputs.didUpdateConfig(config)

      let expectedConfig = QualtricsConfigData(
        brandId: Secrets.Qualtrics.brandId,
        zoneId: Secrets.Qualtrics.zoneId,
        interceptId: QualtricsIntercept.survey.interceptId,
        stringProperties: qualtricsProps()
          .withAllValuesFrom([
            "logged_in": "true",
            "user_uid": "1"
          ])
      )

      self.configureQualtrics.assertValues([expectedConfig])
      self.displayQualtricsSurvey.assertDidNotEmitValue()
      self.evaluateQualtricsTargetingLogic.assertDidNotEmitValue()
      XCTAssertEqual(mockQualtricsPropertiesType.values[firstAppSessionKey], nil)

      self.vm.inputs.qualtricsInitialized(with: MockQualtricsResultType(passedResult: true))

      self.configureQualtrics.assertValues([expectedConfig])
      self.displayQualtricsSurvey.assertDidNotEmitValue()
      self.evaluateQualtricsTargetingLogic.assertDidNotEmitValue()
      XCTAssertEqual(mockQualtricsPropertiesType.values[firstAppSessionKey], nil)

      self.scheduler.advance(by: .seconds(2))

      self.configureQualtrics.assertValues([expectedConfig])
      self.displayQualtricsSurvey.assertDidNotEmitValue()
      self.evaluateQualtricsTargetingLogic.assertValueCount(1)
      XCTAssertEqual(mockQualtricsPropertiesType.values[firstAppSessionKey], nil)

      self.vm.inputs.didEvaluateQualtricsTargetingLogic(
        with: MockQualtricsResultType(passedResult: true),
        properties: mockQualtricsPropertiesType
      )

      self.configureQualtrics.assertValues([expectedConfig])
      self.displayQualtricsSurvey.assertValueCount(1)
      self.evaluateQualtricsTargetingLogic.assertValueCount(1)
      XCTAssertEqual(mockQualtricsPropertiesType.values[firstAppSessionKey], 0)
    }
  }

  func testQualtricsDisplaySurvey_FailureToConfigure_LoggedIn() {
    let config = Config.template
      |> \.features .~ [Feature.qualtrics.rawValue: true]

    let mockQualtricsPropertiesType = MockQualtricsPropertiesType()

    withEnvironment(config: config, currentUser: .template) {
      self.configureQualtrics.assertDidNotEmitValue()
      self.displayQualtricsSurvey.assertDidNotEmitValue()
      self.evaluateQualtricsTargetingLogic.assertDidNotEmitValue()
      XCTAssertEqual(mockQualtricsPropertiesType.values[firstAppSessionKey], nil)

      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)
      self.vm.inputs.didUpdateConfig(config)

      let expectedConfig = QualtricsConfigData(
        brandId: Secrets.Qualtrics.brandId,
        zoneId: Secrets.Qualtrics.zoneId,
        interceptId: QualtricsIntercept.survey.interceptId,
        stringProperties: qualtricsProps()
      )

      self.configureQualtrics.assertValues([expectedConfig])
      self.displayQualtricsSurvey.assertDidNotEmitValue()
      self.evaluateQualtricsTargetingLogic.assertDidNotEmitValue()
      XCTAssertEqual(mockQualtricsPropertiesType.values[firstAppSessionKey], nil)

      self.vm.inputs.qualtricsInitialized(with: MockQualtricsResultType(passedResult: false))

      self.configureQualtrics.assertValues([expectedConfig])
      self.displayQualtricsSurvey.assertDidNotEmitValue()
      self.evaluateQualtricsTargetingLogic.assertDidNotEmitValue()
      XCTAssertEqual(mockQualtricsPropertiesType.values[firstAppSessionKey], nil)

      self.scheduler.advance(by: .seconds(2))

      self.configureQualtrics.assertValues([expectedConfig])
      self.displayQualtricsSurvey.assertDidNotEmitValue()
      self.evaluateQualtricsTargetingLogic.assertDidNotEmitValue()
      XCTAssertEqual(mockQualtricsPropertiesType.values[firstAppSessionKey], nil)
    }
  }

  func testQualtricsDisplaySurvey_DidNotPassTargetingLogic_LoggedIn() {
    let config = Config.template
      |> \.features .~ [Feature.qualtrics.rawValue: true]

    let mockQualtricsPropertiesType = MockQualtricsPropertiesType()

    withEnvironment(config: config, currentUser: .template) {
      self.configureQualtrics.assertDidNotEmitValue()
      self.displayQualtricsSurvey.assertDidNotEmitValue()
      self.evaluateQualtricsTargetingLogic.assertDidNotEmitValue()
      XCTAssertEqual(mockQualtricsPropertiesType.values[firstAppSessionKey], nil)

      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)
      self.vm.inputs.didUpdateConfig(config)

      let expectedConfig = QualtricsConfigData(
        brandId: Secrets.Qualtrics.brandId,
        zoneId: Secrets.Qualtrics.zoneId,
        interceptId: QualtricsIntercept.survey.interceptId,
        stringProperties: qualtricsProps()
      )

      self.configureQualtrics.assertValues([expectedConfig])
      self.displayQualtricsSurvey.assertDidNotEmitValue()
      self.evaluateQualtricsTargetingLogic.assertDidNotEmitValue()
      XCTAssertEqual(mockQualtricsPropertiesType.values[firstAppSessionKey], nil)

      self.vm.inputs.qualtricsInitialized(with: MockQualtricsResultType(passedResult: true))

      self.configureQualtrics.assertValues([expectedConfig])
      self.displayQualtricsSurvey.assertDidNotEmitValue()
      self.evaluateQualtricsTargetingLogic.assertDidNotEmitValue()
      XCTAssertEqual(mockQualtricsPropertiesType.values[firstAppSessionKey], nil)

      self.scheduler.advance(by: .seconds(2))

      self.configureQualtrics.assertValues([expectedConfig])
      self.displayQualtricsSurvey.assertDidNotEmitValue()
      self.evaluateQualtricsTargetingLogic.assertValueCount(1)
      XCTAssertEqual(mockQualtricsPropertiesType.values[firstAppSessionKey], nil)

      self.vm.inputs.didEvaluateQualtricsTargetingLogic(
        with: MockQualtricsResultType(passedResult: false),
        properties: mockQualtricsPropertiesType
      )

      self.configureQualtrics.assertValues([expectedConfig])
      self.displayQualtricsSurvey.assertDidNotEmitValue()
      self.evaluateQualtricsTargetingLogic.assertValueCount(1)
      XCTAssertEqual(mockQualtricsPropertiesType.values[firstAppSessionKey], 0)
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
}

private func qualtricsProps() -> [String: String] {
  return [
    "bundle_id": AppEnvironment.current.mainBundle.bundleIdentifier,
    "language": AppEnvironment.current.language.rawValue,
    "logged_in": "true",
    "distinct_id": AppEnvironment.current.device.identifierForVendor?.uuidString,
    "user_uid": AppEnvironment.current.currentUser.flatMap { $0.id }.map(String.init)
  ]
  .compact()
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
