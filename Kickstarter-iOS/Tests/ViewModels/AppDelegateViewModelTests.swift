import XCTest
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result
@testable import Library
@testable import Kickstarter_Framework
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers

final class AppDelegateViewModelTests: TestCase {
  let vm: AppDelegateViewModelType = AppDelegateViewModel()

  private let configureHockey = TestObserver<HockeyConfigData, NoError>()
  private let forceLogout = TestObserver<(), NoError>()
  private let goToActivity = TestObserver<(), NoError>()
  private let goToDashboard = TestObserver<Param?, NoError>()
  private let goToDiscovery = TestObserver<DiscoveryParams?, NoError>()
  private let goToLogin = TestObserver<(), NoError>()
  private let goToProfile = TestObserver<(), NoError>()
  private let goToSearch = TestObserver<(), NoError>()
  private let postNotificationName = TestObserver<String, NoError>()
  private let presentRemoteNotificationAlert = TestObserver<String, NoError>()
  private let presentViewController = TestObserver<Int, NoError>()
  private let pushTokenSuccessfullyRegistered = TestObserver<(), NoError>()
  private let registerUserNotificationSettings = TestObserver<(), NoError>()
  private let setApplicationShortcutItems = TestObserver<[ShortcutItem], NoError>()
  private let unregisterForRemoteNotifications = TestObserver<(), NoError>()
  private let updateCurrentUserInEnvironment = TestObserver<User, NoError>()
  private let updateConfigInEnvironment = TestObserver<Config, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.configureHockey.observe(self.configureHockey.observer)
    self.vm.outputs.forceLogout.observe(self.forceLogout.observer)
    self.vm.outputs.goToActivity.observe(self.goToActivity.observer)
    self.vm.outputs.goToDashboard.observe(self.goToDashboard.observer)
    self.vm.outputs.goToDiscovery.observe(self.goToDiscovery.observer)
    self.vm.outputs.goToLogin.observe(self.goToLogin.observer)
    self.vm.outputs.goToProfile.observe(self.goToProfile.observer)
    self.vm.outputs.goToSearch.observe(self.goToSearch.observer)
    self.vm.outputs.postNotification.map { $0.name }.observe(self.postNotificationName.observer)
    self.vm.outputs.presentRemoteNotificationAlert.observe(presentRemoteNotificationAlert.observer)
    self.vm.outputs.presentViewController.map { ($0 as! UINavigationController).viewControllers.count }
      .observe(self.presentViewController.observer)
    self.vm.outputs.pushTokenSuccessfullyRegistered.observe(self.pushTokenSuccessfullyRegistered.observer)
    self.vm.outputs.registerUserNotificationSettings.observe(self.registerUserNotificationSettings.observer)
    self.vm.outputs.setApplicationShortcutItems.observe(self.setApplicationShortcutItems.observer)
    self.vm.outputs.unregisterForRemoteNotifications.observe(self.unregisterForRemoteNotifications.observer)
    self.vm.outputs.updateCurrentUserInEnvironment.observe(self.updateCurrentUserInEnvironment.observer)
    self.vm.outputs.updateConfigInEnvironment.observe(self.updateConfigInEnvironment.observer)
  }

  func testConfigureHockey_BetaApp_LoggedOut() {
    let betaBundle = MockBundle(bundleIdentifier: KickstarterBundleIdentifier.beta.rawValue, lang: "en")

    withEnvironment(mainBundle: betaBundle) {
      vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                              launchOptions: [:])

      self.configureHockey.assertValues([
        HockeyConfigData(
          appIdentifier: HockeyConfigData.betaAppIdentifier,
          disableUpdates: false,
          userId: "0",
          userName: "anonymous"
        )
        ])
    }
  }

  func testConfigureHockey_BetaApp_LoggedIn() {
    let currentUser = User.template
    withEnvironment(
      mainBundle: MockBundle(bundleIdentifier: KickstarterBundleIdentifier.beta.rawValue, lang: "en"),
      currentUser: .template) {
        vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                launchOptions: [:])

        self.configureHockey.assertValues([
          HockeyConfigData(
            appIdentifier: HockeyConfigData.betaAppIdentifier,
            disableUpdates: false,
            userId: String(currentUser.id),
            userName: currentUser.name
          )
          ])
    }
  }

  func testConfigureHockey_ProductionApp_LoggedOut() {
    let bundle = MockBundle(bundleIdentifier: KickstarterBundleIdentifier.release.rawValue, lang: "en")
    withEnvironment(mainBundle: bundle) {
      vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                              launchOptions: [:])

      self.configureHockey.assertValues([
        HockeyConfigData(
          appIdentifier: HockeyConfigData.releaseAppIdentifier,
          disableUpdates: true,
          userId: "0",
          userName: "anonymous"
        )
        ])
    }
  }

  func testConfigureHockey_ProductionApp_LoggedIn() {
    let bundle = MockBundle(bundleIdentifier: KickstarterBundleIdentifier.release.rawValue, lang: "en")
    let currentUser = User.template

    withEnvironment(mainBundle: bundle, currentUser: .template) {
        vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                launchOptions: [:])

        self.configureHockey.assertValues([
          HockeyConfigData(
            appIdentifier: HockeyConfigData.releaseAppIdentifier,
            disableUpdates: true,
            userId: String(currentUser.id),
            userName: currentUser.name
          )
          ])
    }
  }

  func testConfigureHockey_SessionChanges() {
    let bundle = MockBundle(bundleIdentifier: KickstarterBundleIdentifier.release.rawValue, lang: "en")
    let currentUser = User.template

    withEnvironment(mainBundle: bundle) {
      vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                              launchOptions: [:])

      self.configureHockey.assertValues([
        HockeyConfigData(
          appIdentifier: HockeyConfigData.releaseAppIdentifier,
          disableUpdates: true,
          userId: "0",
          userName: "anonymous"
        )
        ])

      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))
      self.vm.inputs.userSessionStarted()

      self.configureHockey.assertValues([
        HockeyConfigData(
          appIdentifier: HockeyConfigData.releaseAppIdentifier,
          disableUpdates: true,
          userId: "0",
          userName: "anonymous"
        ),
        HockeyConfigData(
          appIdentifier: HockeyConfigData.releaseAppIdentifier,
          disableUpdates: true,
          userId: String(currentUser.id),
          userName: currentUser.name
        )
        ])

      AppEnvironment.logout()
      self.vm.inputs.userSessionStarted()

      self.configureHockey.assertValues([
        HockeyConfigData(
          appIdentifier: HockeyConfigData.releaseAppIdentifier,
          disableUpdates: true,
          userId: "0",
          userName: "anonymous"
        ),
        HockeyConfigData(
          appIdentifier: HockeyConfigData.releaseAppIdentifier,
          disableUpdates: true,
          userId: String(currentUser.id),
          userName: currentUser.name
        ),
        HockeyConfigData(
          appIdentifier: HockeyConfigData.releaseAppIdentifier,
          disableUpdates: true,
          userId: "0",
          userName: "anonymous"
        )
        ])
    }
  }

  func testKoala_AppLifecycle() {
    XCTAssertEqual([], trackingClient.events)

    vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                            launchOptions: [:])
    XCTAssertEqual(["App Open", "Opened App"], trackingClient.events)

    vm.inputs.applicationDidEnterBackground()
    XCTAssertEqual(["App Open", "Opened App", "App Close", "Closed App"], trackingClient.events)

    vm.inputs.applicationWillEnterForeground()
    XCTAssertEqual(["App Open", "Opened App", "App Close", "Closed App", "App Open", "Opened App"],
                   trackingClient.events)
  }

  func testKoala_MemoryWarning() {
    XCTAssertEqual([], trackingClient.events)

    vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                           launchOptions: [:])
    XCTAssertEqual(["App Open", "Opened App"], trackingClient.events)

    vm.inputs.applicationDidReceiveMemoryWarning()
    XCTAssertEqual(["App Open", "Opened App", "App Memory Warning"], trackingClient.events)
  }

  func testKoala_AppCrash() {
    XCTAssertEqual([], trackingClient.events)

    vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                            launchOptions: [:])
    XCTAssertEqual(["App Open", "Opened App"], trackingClient.events)

    vm.inputs.crashManagerDidFinishSendingCrashReport()
    XCTAssertEqual(["App Open", "Opened App", "Crashed App"], trackingClient.events)
  }

  func testCurrentUserUpdating_NothingHappensWhenLoggedOut() {
    vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                            launchOptions: [:])
    vm.inputs.applicationWillEnterForeground()
    vm.inputs.applicationDidEnterBackground()

    updateCurrentUserInEnvironment.assertDidNotEmitValue()
  }

  func testCurrentUserUpdating_WhenLoggedIn() {
    let env = AccessTokenEnvelope(accessToken: "deadbeef", user: User.template)
    AppEnvironment.login(env)

    vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                            launchOptions: [:])

    self.scheduler.advanceByInterval(5.0)

    updateCurrentUserInEnvironment.assertValues([env.user])
    postNotificationName.assertDidNotEmitValue()

    vm.inputs.currentUserUpdatedInEnvironment()

    updateCurrentUserInEnvironment.assertValues([env.user])
    postNotificationName.assertValues([CurrentUserNotifications.userUpdated])

    vm.inputs.applicationDidEnterBackground()
    vm.inputs.applicationWillEnterForeground()
    self.scheduler.advanceByInterval(5.0)

    updateCurrentUserInEnvironment.assertValues([env.user, env.user])
    postNotificationName.assertValues([CurrentUserNotifications.userUpdated])

    vm.inputs.currentUserUpdatedInEnvironment()

    updateCurrentUserInEnvironment.assertValues([env.user, env.user])
    postNotificationName.assertValues(
      [CurrentUserNotifications.userUpdated, CurrentUserNotifications.userUpdated]
    )
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

      vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                              launchOptions: [:])
      self.scheduler.advanceByInterval(5.0)

      updateCurrentUserInEnvironment.assertDidNotEmitValue()
      self.forceLogout.assertValueCount(1)
    }
  }

  func testFacebookAppDelegate() {
    XCTAssertFalse(self.facebookAppDelegate.didFinishLaunching)
    XCTAssertFalse(self.facebookAppDelegate.openedUrl)

    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])

    XCTAssertTrue(self.facebookAppDelegate.didFinishLaunching)
    XCTAssertFalse(self.facebookAppDelegate.openedUrl)

    self.vm.inputs.applicationOpenUrl(application: UIApplication.sharedApplication(),
                                      url: NSURL(string: "http://www.fb.com")!,
                                      sourceApplication: nil,
                                      annotation: 1)

    XCTAssertTrue(self.facebookAppDelegate.openedUrl)
  }

  func testOpenAppBanner() {
    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])

    XCTAssertEqual(["App Open", "Opened App"], self.trackingClient.events)

    self.vm.inputs.applicationOpenUrl(application: UIApplication.sharedApplication(),
                                      url: NSURL(string: "http://www.google.com/?app_banner=1&hello=world")!,
                                      sourceApplication: nil,
                                      annotation: 1)

    XCTAssertEqual(["App Open", "Opened App", "Smart App Banner Opened", "Opened App Banner"],
                   self.trackingClient.events)
    XCTAssertEqual([true, nil, true, nil],
                   self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self))
    XCTAssertEqual([nil, nil, "world", "world"],
                   self.trackingClient.properties(forKey: "hello", as: String.self))
  }

  func testConfig() {
    let config1 = Config.template |> Config.lens.countryCode .~ "US"
    withEnvironment(apiService: MockService(fetchConfigResponse: config1)) {
      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                   launchOptions: [:])
      self.updateConfigInEnvironment.assertValues([config1])
    }

    let config2 = Config.template |> Config.lens.countryCode .~ "GB"
    withEnvironment(apiService: MockService(fetchConfigResponse: config2)) {
      self.vm.inputs.applicationWillEnterForeground()
      self.updateConfigInEnvironment.assertValues([config1, config2])
    }
  }

  func testPresentViewController() {
    let apiService = MockService(fetchProjectResponse: .template, fetchUpdateResponse: .template)
    withEnvironment(apiService: apiService) {
      let rootUrl = "https://www.kickstarter.com/"

      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                   launchOptions: [:])

      self.presentViewController.assertValues([])

      let projectUrl =
        rootUrl + "projects/tequila/help-me-transform-this-pile-of-wood"
      self.vm.inputs.applicationOpenUrl(application: UIApplication.sharedApplication(),
                                        url: NSURL(string: projectUrl)!,
                                        sourceApplication: nil,
                                        annotation: 1)

      self.presentViewController.assertValues([1])

      let commentsUrl =
        projectUrl + "/comments"
      self.vm.inputs.applicationOpenUrl(application: UIApplication.sharedApplication(),
                                        url: NSURL(string: commentsUrl)!,
                                        sourceApplication: nil,
                                        annotation: 1)

      self.presentViewController.assertValues([1, 2])

      let updatesUrl =
        projectUrl + "/posts"
      self.vm.inputs.applicationOpenUrl(application: UIApplication.sharedApplication(),
                                        url: NSURL(string: updatesUrl)!,
                                        sourceApplication: nil,
                                        annotation: 1)

      self.presentViewController.assertValues([1, 2, 2])

      let updateUrl =
        projectUrl + "/posts/1399396"
      self.vm.inputs.applicationOpenUrl(application: UIApplication.sharedApplication(),
                                        url: NSURL(string: updateUrl)!,
                                        sourceApplication: nil,
                                        annotation: 1)

      self.presentViewController.assertValues([1, 2, 2, 2])

      let updateCommentsUrl =
        updateUrl + "/comments"
      self.vm.inputs.applicationOpenUrl(application: UIApplication.sharedApplication(),
                                        url: NSURL(string: updateCommentsUrl)!,
                                        sourceApplication: nil,
                                        annotation: 1)

      self.presentViewController.assertValues([1, 2, 2, 2, 3])
    }
  }

  func testGoToActivity() {
    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])

    self.goToActivity.assertValueCount(0)

    self.vm.inputs.applicationOpenUrl(application: UIApplication.sharedApplication(),
                                      url: NSURL(string: "https://www.kickstarter.com/activity")!,
                                      sourceApplication: nil,
                                      annotation: 1)

    self.goToActivity.assertValueCount(1)
  }

  func testGoToDashboard() {
    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])

    self.goToDashboard.assertValueCount(0)

    let url = "https://www.kickstarter.com/projects/tequila/help-me-transform-this-pile-of-wood/dashboard"
    self.vm.inputs.applicationOpenUrl(application: UIApplication.sharedApplication(),
                                      url: NSURL(string: url)!,
                                      sourceApplication: nil,
                                      annotation: 1)

    self.goToDashboard.assertValueCount(1)
  }

  func testGoToDiscovery() {
    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])

    self.goToDiscovery.assertValues([])

    self.vm.inputs.applicationOpenUrl(application: UIApplication.sharedApplication(),
                                      url: NSURL(string: "https://www.kickstarter.com/discover?sort=newest")!,
                                      sourceApplication: nil,
                                      annotation: 1)

    let params = .defaults
      |> DiscoveryParams.lens.sort .~ .newest
      |> DiscoveryParams.lens.staffPicks .~ true
    self.goToDiscovery.assertValues([params])
  }

  func testGoToDiscoveryWithCategory() {
    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])

    self.goToDiscovery.assertValues([])

    let url = NSURL(string: "https://www.kickstarter.com/discover/categories/art")!
    self.vm.inputs.applicationOpenUrl(application: UIApplication.sharedApplication(),
                                      url: url,
                                      sourceApplication: nil,
                                      annotation: 1)

    self.scheduler.advance()

    let params = .defaults |> DiscoveryParams.lens.category .~ .art
    self.goToDiscovery.assertValues([params])
  }

  func testGoToLogin() {
    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])

    self.goToLogin.assertValueCount(0)

    self.vm.inputs.applicationOpenUrl(application: UIApplication.sharedApplication(),
                                      url: NSURL(string: "https://www.kickstarter.com/authorize")!,
                                      sourceApplication: nil,
                                      annotation: 1)

    self.goToLogin.assertValueCount(1)
  }

  func testGoToProfile() {
    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])

    self.goToProfile.assertValueCount(0)

    self.vm.inputs.applicationOpenUrl(application: UIApplication.sharedApplication(),
                                      url: NSURL(string: "https://www.kickstarter.com/profile/me")!,
                                      sourceApplication: nil,
                                      annotation: 1)

    self.goToProfile.assertValueCount(1)
  }

  func testGoToSearch() {
    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])

    self.goToSearch.assertValueCount(0)

    self.vm.inputs.applicationOpenUrl(application: UIApplication.sharedApplication(),
                                      url: NSURL(string: "https://www.kickstarter.com/search")!,
                                      sourceApplication: nil,
                                      annotation: 1)

    self.goToSearch.assertValueCount(1)
  }

  func testRegisterUnregisterNotifications() {
    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])

    self.registerUserNotificationSettings.assertValueCount(0)
    self.unregisterForRemoteNotifications.assertValueCount(0)

    withEnvironment(currentUser: .template) {
      self.vm.inputs.userSessionStarted()

      self.registerUserNotificationSettings.assertValueCount(1)
      self.unregisterForRemoteNotifications.assertValueCount(0)

      self.vm.inputs.applicationDidEnterBackground()
      self.vm.inputs.applicationWillEnterForeground()

      self.registerUserNotificationSettings.assertValueCount(2)
      self.unregisterForRemoteNotifications.assertValueCount(0)

      self.vm.inputs.applicationDidEnterBackground()
      self.vm.inputs.applicationWillEnterForeground()

      self.registerUserNotificationSettings.assertValueCount(3)
      self.unregisterForRemoteNotifications.assertValueCount(0)
    }

    self.vm.inputs.userSessionEnded()

    self.registerUserNotificationSettings.assertValueCount(3)
    self.unregisterForRemoteNotifications.assertValueCount(1)
  }

  func testRegisterDeviceToken() {
    withEnvironment(currentUser: .template) {
      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                   launchOptions: [:])
      self.vm.inputs.didRegisterForRemoteNotifications(withDeviceTokenData: NSData())
      self.scheduler.advanceByInterval(5.0)

      self.pushTokenSuccessfullyRegistered.assertValueCount(1)
    }
  }

  func testOpenPushNotification_WhileInBackground() {
    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])

    self.presentViewController.assertValueCount(0)

    self.vm.inputs.didReceive(remoteNotification: friendBackingPushData, applicationIsActive: false)

    self.presentViewController.assertValueCount(1)
    XCTAssertEqual(["App Open", "Opened App", "Notification Opened", "Opened Notification"],
                   self.trackingClient.events)
    XCTAssertEqual([true, nil, true, nil],
                   self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self))

  }

  func testOpenPushNotification_WhileInForeground() {
    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])

    self.presentViewController.assertValueCount(0)

    self.vm.inputs.didReceive(remoteNotification: friendBackingPushData, applicationIsActive: true)

    self.presentViewController.assertValueCount(0)
    XCTAssertEqual(["App Open", "Opened App"], self.trackingClient.events)

    self.vm.inputs.openRemoteNotificationTappedOk()

    self.presentViewController.assertValueCount(1)
    XCTAssertEqual(["App Open", "Opened App", "Notification Opened", "Opened Notification"],
                   self.trackingClient.events)
  }

  func testOpenPushNotification_LaunchApp() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.sharedApplication(),
      launchOptions: [UIApplicationLaunchOptionsRemoteNotificationKey: friendBackingPushData]
    )

    self.presentViewController.assertValueCount(1)
    XCTAssertEqual(["Notification Opened", "Opened Notification", "App Open", "Opened App"],
                   self.trackingClient.events)
    XCTAssertEqual([true, nil, true, nil],
                   self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self))
  }

  func testOpenPushNotification_WhileAppIsActive() {
    let pushData = friendBackingPushData

    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])

    self.presentViewController.assertValueCount(0)
    self.presentRemoteNotificationAlert.assertValueCount(0)

    self.vm.inputs.didReceive(remoteNotification: pushData, applicationIsActive: true)

    self.presentViewController.assertValueCount(0)
    self.presentRemoteNotificationAlert.assertValueCount(1)

    self.vm.inputs.openRemoteNotificationTappedOk()

    self.presentViewController.assertValueCount(1)
    self.presentRemoteNotificationAlert.assertValueCount(1)
  }

  func testOpenNotification_NewBacking_ForCreator() {
    let projectId = (backingForCreatorPushData["activity"] as? [String:AnyObject])
      .flatMap { $0["project_id"] as? Int }
    let param = Param.id(projectId ?? -1)

    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.sharedApplication(),
      launchOptions: [UIApplicationLaunchOptionsRemoteNotificationKey: backingForCreatorPushData]
    )

    self.goToDashboard.assertValues([param])
  }

  func testOpenNotification_NewBacking_ForCreator_WithBadData() {
    var badPushData = backingForCreatorPushData
    var badActivityData = badPushData["activity"] as? [String:AnyObject]
    badActivityData?["project_id"] = nil
    badPushData["activity"] = badActivityData

    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.sharedApplication(),
      launchOptions: [UIApplicationLaunchOptionsRemoteNotificationKey: badPushData]
    )

    self.goToDashboard.assertValueCount(0)
  }

  func testOpenNotification_ProjectUpdate() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.sharedApplication(),
      launchOptions: [UIApplicationLaunchOptionsRemoteNotificationKey: updatePushData]
    )

    self.presentViewController.assertValueCount(1)
  }

  func testOpenNotification_ProjectUpdate_BadData() {
    var badPushData = updatePushData
    badPushData["activity"]?["update_id"] = nil

    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.sharedApplication(),
      launchOptions: [UIApplicationLaunchOptionsRemoteNotificationKey: badPushData]
    )

    self.presentViewController.assertValueCount(0)
  }

  func testOpenNotification_SurveyResponse() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.sharedApplication(),
      launchOptions: [UIApplicationLaunchOptionsRemoteNotificationKey: surveyResponsePushData]
    )

    self.presentViewController.assertValueCount(1)
  }

  func testOpenNotification_SurveyResponse_BadData() {
    var badPushData = surveyResponsePushData
    badPushData["survey"]?["id"] = nil

    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.sharedApplication(),
      launchOptions: [UIApplicationLaunchOptionsRemoteNotificationKey: badPushData]
    )

    self.presentViewController.assertValueCount(0)
  }

  func testOpenNotification_UpdateComment() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.sharedApplication(),
      launchOptions: [UIApplicationLaunchOptionsRemoteNotificationKey: updateCommentPushData]
    )

    self.presentViewController.assertValueCount(1)
  }

  func testOpenNotification_UpdateComment_BadData() {
    var badPushData = updatePushData
    badPushData["activity"]?["update_id"] = nil

    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.sharedApplication(),
      launchOptions: [UIApplicationLaunchOptionsRemoteNotificationKey: badPushData]
    )

    self.presentViewController.assertValueCount(0)
  }

  func testOpenNotification_ProjectComment() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.sharedApplication(),
      launchOptions: [UIApplicationLaunchOptionsRemoteNotificationKey: projectCommentPushData]
    )

    self.presentViewController.assertValueCount(1)
  }

  func testOpenNotification_ProjectComment_WithBadData() {
    var badPushData = updatePushData
    badPushData["activity"]?["project_id"] = nil

    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.sharedApplication(),
      launchOptions: [UIApplicationLaunchOptionsRemoteNotificationKey: badPushData]
    )

    self.presentViewController.assertValueCount(0)
  }

  func testOpenNotification_GenericProject() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.sharedApplication(),
      launchOptions: [UIApplicationLaunchOptionsRemoteNotificationKey: genericProjectPushData]
    )

    self.presentViewController.assertValueCount(1)
  }

  func testOpenNotification_ProjectStateChanges() {
    let states: [Activity.Category] = [.failure, .launch, .success, .cancellation, .suspension]

    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])

    states.enumerate().forEach { idx, state in
      var pushData = genericActivityPushData
      pushData["activity"]?["category"] = state.rawValue

      self.vm.inputs.didReceive(remoteNotification: pushData, applicationIsActive: false)

      self.presentViewController.assertValueCount(
        idx + 1, "Presents controller for \(state.rawValue) state change."
      )
    }
  }

  func testOpenNotification_CreatorActivity() {
    let categories: [Activity.Category] = [.backingAmount, .backingCanceled, .backingDropped, .backingReward]

    let projectId = (backingForCreatorPushData["activity"] as? [String:AnyObject])
      .flatMap { $0["project_id"] as? Int }
    let param = Param.id(projectId ?? -1)

    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])

    categories.enumerate().forEach { idx, state in
      var pushData = genericActivityPushData
      pushData["activity"]?["category"] = state.rawValue

      self.vm.inputs.didReceive(remoteNotification: pushData, applicationIsActive: false)

      self.goToDashboard.assertValueCount(idx + 1)
      self.goToDashboard.assertLastValue(param)
    }
  }

  func testOpenNotification_PostLike() {

    let pushData: [String:AnyObject] = [
      "aps": [
        "alert": "Blob liked your update: Important message..."
      ],
      "post": [
        "id": 1,
        "project_id": 2
      ]
    ]

    self.vm.inputs.didReceive(remoteNotification: pushData, applicationIsActive: false)

    self.presentViewController.assertValues([2])
  }

  func testOpenNotification_UnrecognizedActivityType() {
    let categories: [Activity.Category] = [.follow, .funding, .unknown, .watch]

    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])

    categories.enumerate().forEach { idx, state in
      var pushData = genericActivityPushData
      pushData["activity"]?["category"] = state.rawValue

      self.vm.inputs.didReceive(remoteNotification: pushData, applicationIsActive: false)

      self.goToDashboard.assertValueCount(0)
      self.presentViewController.assertValueCount(0)
    }
  }

  func testOpenNotification_LocalNotification_FromLaunch() {
    let localNotification = UILocalNotification()
    localNotification.userInfo = updatePushData

    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.sharedApplication(),
      launchOptions: [UIApplicationLaunchOptionsLocalNotificationKey: localNotification]
    )

    self.presentViewController.assertValueCount(1)
  }

  func testContinueUserActivity_ValidActivity() {
    let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
    userActivity.webpageURL = NSURL(string: "https://www.kickstarter.com/activity")

    self.vm.inputs.applicationDidFinishLaunching(application: .sharedApplication(), launchOptions: [:])

    self.goToActivity.assertValueCount(0)
    XCTAssertFalse(self.vm.outputs.continueUserActivityReturnValue.value)
    XCTAssertEqual(["App Open", "Opened App"], self.trackingClient.events)

    self.vm.inputs.applicationContinueUserActivity(userActivity)

    self.goToActivity.assertValueCount(1)
    XCTAssertTrue(self.vm.outputs.continueUserActivityReturnValue.value)
    XCTAssertEqual(["App Open", "Opened App", "Continue User Activity", "Opened Deep Link"],
                   self.trackingClient.events)
    XCTAssertEqual([true, nil, true, nil],
                   self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self))
  }

  func testContinueUserActivity_InvalidActivity() {
    let userActivity = NSUserActivity(activityType: "Other")

    self.vm.inputs.applicationDidFinishLaunching(application: .sharedApplication(), launchOptions: [:])
    self.vm.inputs.applicationContinueUserActivity(userActivity)

    XCTAssertFalse(self.vm.outputs.continueUserActivityReturnValue.value)
    XCTAssertEqual(["App Open", "Opened App"], self.trackingClient.events)
  }

  func testSetApplicationShortcutItems() {
    self.setApplicationShortcutItems.assertValues([])

    self.vm.inputs.applicationDidFinishLaunching(application: .sharedApplication(), launchOptions: [:])

    self.setApplicationShortcutItems.assertValues([])

    self.scheduler.advanceByInterval(5)

    self.setApplicationShortcutItems.assertValues([[.projectOfTheDay, .projectsWeLove, .search]])

    self.vm.inputs.applicationDidEnterBackground()
    self.vm.inputs.applicationWillEnterForeground()
    self.scheduler.advanceByInterval(5)

    self.setApplicationShortcutItems.assertValues(
      [
        [.projectOfTheDay, .projectsWeLove, .search],
        [.projectOfTheDay, .projectsWeLove, .search]
      ]
    )
  }

  func testSetApplicationShortcutItems_LoggedInUser_NonMember() {
    let currentUser = .template
      |> User.lens.stats.memberProjectsCount .~ 0

    withEnvironment(apiService: MockService(fetchUserSelfResponse: currentUser), currentUser: currentUser) {
      self.setApplicationShortcutItems.assertValues([])

      self.vm.inputs.applicationDidFinishLaunching(application: .sharedApplication(), launchOptions: [:])

      self.setApplicationShortcutItems.assertValues([])

      self.scheduler.advanceByInterval(5)

      self.setApplicationShortcutItems.assertValues([
        [.projectOfTheDay, .recommendedForYou, .projectsWeLove, .search]
      ])
    }
  }

  func testSetApplicationShortcutItems_LoggedInUser_Member() {
    let currentUser = .template
      |> User.lens.stats.memberProjectsCount .~ 2

    withEnvironment(apiService: MockService(fetchUserSelfResponse: currentUser), currentUser: currentUser) {
      self.setApplicationShortcutItems.assertValues([])

      self.vm.inputs.applicationDidFinishLaunching(application: .sharedApplication(), launchOptions: [:])

      self.setApplicationShortcutItems.assertValues([])

      self.scheduler.advanceByInterval(5)

      self.setApplicationShortcutItems.assertValues([
        [.creatorDashboard, .projectOfTheDay, .recommendedForYou, .projectsWeLove]
      ])
    }
  }

  func testPerformShortcutItem_CreatorDashboard() {
    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])

    self.goToDashboard.assertValueCount(0)

    self.vm.inputs.applicationPerformActionForShortcutItem(
      ShortcutItem.creatorDashboard.applicationShortcutItem
    )

    self.goToDashboard.assertValueCount(1)
  }

  func testLaunchShortcutItem_CreatorDashboard() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.sharedApplication(),
      launchOptions: [
        UIApplicationLaunchOptionsShortcutItemKey: ShortcutItem.creatorDashboard.applicationShortcutItem
      ]
    )

    self.goToDashboard.assertValueCount(1)
    XCTAssertFalse(self.vm.outputs.applicationDidFinishLaunchingReturnValue)
  }

  func testPerformShortcutItem_ProjectOfTheDay() {
    let potd = .template
      |> Project.lens.dates.potdAt .~ NSDate().timeIntervalSince1970
    let env = .template |> DiscoveryEnvelope.lens.projects .~ [potd]

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: env)) {
      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                   launchOptions: [:])

      self.presentViewController.assertValueCount(0)

      self.vm.inputs.applicationPerformActionForShortcutItem(
        ShortcutItem.projectOfTheDay.applicationShortcutItem
      )

      self.presentViewController.assertValueCount(1)
    }
  }

  func testLaunchShortcutItem_ProjectOfTheDay() {
    let potd = .template
      |> Project.lens.dates.potdAt .~ NSDate().timeIntervalSince1970
    let env = .template |> DiscoveryEnvelope.lens.projects .~ [potd]

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: env)) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.sharedApplication(),
        launchOptions: [
          UIApplicationLaunchOptionsShortcutItemKey: ShortcutItem.projectOfTheDay.applicationShortcutItem
        ]
      )

      self.presentViewController.assertValueCount(1)
      XCTAssertFalse(self.vm.outputs.applicationDidFinishLaunchingReturnValue)
    }
  }

  func testPerformShortcutItem_ProjectsWeLove() {
    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])

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
      application: UIApplication.sharedApplication(),
      launchOptions: [
        UIApplicationLaunchOptionsShortcutItemKey: ShortcutItem.projectsWeLove.applicationShortcutItem
      ]
    )

    let params = .defaults
      |> DiscoveryParams.lens.staffPicks .~ true
      |> DiscoveryParams.lens.sort .~ .magic
    self.goToDiscovery.assertValues([params])
    XCTAssertFalse(self.vm.outputs.applicationDidFinishLaunchingReturnValue)
  }

  func testPerformShortcutItem_RecommendedForYou() {
    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])

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
      application: UIApplication.sharedApplication(),
      launchOptions: [
        UIApplicationLaunchOptionsShortcutItemKey: ShortcutItem.recommendedForYou.applicationShortcutItem
      ]
    )

    let params = .defaults
      |> DiscoveryParams.lens.recommended .~ true
      |> DiscoveryParams.lens.sort .~ .magic
    self.goToDiscovery.assertValues([params])
    XCTAssertFalse(self.vm.outputs.applicationDidFinishLaunchingReturnValue)
  }

  func testPerformShortcutItem_Search() {
    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])

    self.goToSearch.assertValueCount(0)

    self.vm.inputs.applicationPerformActionForShortcutItem(ShortcutItem.search.applicationShortcutItem)

    self.goToSearch.assertValueCount(1)
  }

  func testLaunchShortcutItem_Search() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.sharedApplication(),
      launchOptions: [
        UIApplicationLaunchOptionsShortcutItemKey: ShortcutItem.search.applicationShortcutItem
      ]
    )

    self.goToSearch.assertValueCount(1)
    XCTAssertFalse(self.vm.outputs.applicationDidFinishLaunchingReturnValue)
  }

  func testPerformShortcutItem_KoalaTracking() {
    // Launch app and wait for shortcuts to be set
    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])
    self.scheduler.advanceByInterval(5)

    // Perform a shortcut item
    self.vm.inputs.applicationPerformActionForShortcutItem(
      ShortcutItem.projectsWeLove.applicationShortcutItem
    )

    XCTAssertEqual(["App Open", "Opened App", "Performed Shortcut"], self.trackingClient.events)
    XCTAssertEqual([nil, nil, "projects_we_love"],
                   self.trackingClient.properties(forKey: "type", as: String.self))
    XCTAssertEqual([nil, nil, "project_of_the_day,projects_we_love,search"],
                   self.trackingClient.properties(forKey: "context", as: String.self))

    withEnvironment(currentUser: .template) {
      // Login with a user and wait for shortcuts to be set
      self.vm.inputs.userSessionStarted()
      self.scheduler.advanceByInterval(5)

      XCTAssertEqual(["App Open", "Opened App", "Performed Shortcut"],
                     self.trackingClient.events,
                     "Nothing new is tracked.")

      // Perform shortcut item
      self.vm.inputs.applicationPerformActionForShortcutItem(
        ShortcutItem.recommendedForYou.applicationShortcutItem
      )

      XCTAssertEqual(["App Open", "Opened App", "Performed Shortcut", "Performed Shortcut"],
                     self.trackingClient.events)
      XCTAssertEqual(
        [nil, nil, "projects_we_love", "recommended_for_you"],
        self.trackingClient.properties(forKey: "type", as: String.self)
      )
      XCTAssertEqual(
        [nil, nil, "project_of_the_day,projects_we_love,search",
          "project_of_the_day,recommended_for_you,projects_we_love,search"],
        self.trackingClient.properties(forKey: "context", as: String.self)
      )
    }
  }

  func testLaunchShortcutItem_KoalaTracking() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.sharedApplication(),
      launchOptions: [
        UIApplicationLaunchOptionsShortcutItemKey: ShortcutItem.projectsWeLove.applicationShortcutItem
      ]
    )

    XCTAssertEqual(["App Open", "Opened App"], self.trackingClient.events)

    self.scheduler.advanceByInterval(5)

    XCTAssertEqual(["App Open", "Opened App", "Performed Shortcut"], self.trackingClient.events)
    XCTAssertEqual([nil, nil, "projects_we_love"],
                   self.trackingClient.properties(forKey: "type", as: String.self))
    XCTAssertEqual([nil, nil, "project_of_the_day,projects_we_love,search"],
                   self.trackingClient.properties(forKey: "context", as: String.self))
  }
}

private let backingForCreatorPushData = [
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
