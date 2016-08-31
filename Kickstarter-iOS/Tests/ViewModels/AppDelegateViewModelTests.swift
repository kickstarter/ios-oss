import XCTest
import ReactiveCocoa
import Result
@testable import Library
@testable import Kickstarter_Framework
@testable import KsApi
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers

final class AppDelegateViewModelTests: TestCase {
  let vm: AppDelegateViewModelType = AppDelegateViewModel()

  let configureHockey = TestObserver<HockeyConfigData, NoError>()
  let updateCurrentUserInEnvironment = TestObserver<User, NoError>()
  let updateEnvironment = TestObserver<(Config, Koala), NoError>()
  let postNotificationName = TestObserver<String, NoError>()
  let presentRemoteNotificationAlert = TestObserver<String, NoError>()
  let presentViewController = TestObserver<Int, NoError>()
  let pushTokenSuccessfullyRegistered = TestObserver<(), NoError>()
  let goToActivity = TestObserver<(), NoError>()
  let goToDashboard = TestObserver<Param, NoError>()
  let goToLogin = TestObserver<(), NoError>()
  let goToProfile = TestObserver<(), NoError>()
  let goToSearch = TestObserver<(), NoError>()
  let registerUserNotificationSettings = TestObserver<(), NoError>()
  let unregisterForRemoteNotifications = TestObserver<(), NoError>()

  override func setUp() {
    super.setUp()

    vm.outputs.configureHockey.observe(self.configureHockey.observer)
    vm.outputs.updateCurrentUserInEnvironment.observe(self.updateCurrentUserInEnvironment.observer)
    vm.outputs.updateEnvironment.observe(self.updateEnvironment.observer)
    vm.outputs.postNotification.map { $0.name }.observe(self.postNotificationName.observer)
    vm.outputs.presentRemoteNotificationAlert.observe(presentRemoteNotificationAlert.observer)
    vm.outputs.presentViewController.map { ($0 as! UINavigationController).viewControllers.count }
      .observe(self.presentViewController.observer)
    vm.outputs.pushTokenSuccessfullyRegistered.observe(self.pushTokenSuccessfullyRegistered.observer)
    vm.outputs.goToActivity.observe(self.goToActivity.observer)
    vm.outputs.goToDashboard.observe(self.goToDashboard.observer)
    vm.outputs.goToLogin.observe(self.goToLogin.observer)
    vm.outputs.goToProfile.observe(self.goToProfile.observer)
    vm.outputs.goToSearch.observe(self.goToSearch.observer)
    vm.outputs.registerUserNotificationSettings.observe(self.registerUserNotificationSettings.observer)
    vm.outputs.unregisterForRemoteNotifications.observe(self.unregisterForRemoteNotifications.observer)
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
    XCTAssertEqual(["App Open"], trackingClient.events)

    vm.inputs.applicationDidEnterBackground()
    XCTAssertEqual(["App Open", "App Close"], trackingClient.events)

    vm.inputs.applicationWillEnterForeground()
    XCTAssertEqual(["App Open", "App Close", "App Open"], trackingClient.events)
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

    updateCurrentUserInEnvironment.assertValues([env.user])
    postNotificationName.assertDidNotEmitValue()

    vm.inputs.currentUserUpdatedInEnvironment()

    updateCurrentUserInEnvironment.assertValues([env.user])
    postNotificationName.assertValues([CurrentUserNotifications.userUpdated])

    vm.inputs.applicationDidEnterBackground()
    vm.inputs.applicationWillEnterForeground()

    updateCurrentUserInEnvironment.assertValues([env.user, env.user])
    postNotificationName.assertValues([CurrentUserNotifications.userUpdated])

    vm.inputs.currentUserUpdatedInEnvironment()

    updateCurrentUserInEnvironment.assertValues([env.user, env.user])
    postNotificationName.assertValues(
      [CurrentUserNotifications.userUpdated, CurrentUserNotifications.userUpdated]
    )
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

  func testConfig() {
    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])
    self.updateEnvironment.assertValueCount(1)

    self.vm.inputs.applicationWillEnterForeground()
    self.updateEnvironment.assertValueCount(2)
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

      self.presentViewController.assertValues([1, 2, 2, 3])

      let updateCommentsUrl =
        updateUrl + "/comments"
      self.vm.inputs.applicationOpenUrl(application: UIApplication.sharedApplication(),
                                        url: NSURL(string: updateCommentsUrl)!,
                                        sourceApplication: nil,
                                        annotation: 1)

      self.presentViewController.assertValues([1, 2, 2, 3, 4])
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
      self.pushTokenSuccessfullyRegistered.assertValueCount(1)
    }
  }

  func testOpenPushNotification_WhileInBackground() {
    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])

    self.presentViewController.assertValueCount(0)

    self.vm.inputs.didReceive(remoteNotification: friendBackingPushData, applicationIsActive: false)

    self.presentViewController.assertValueCount(1)
    XCTAssertEqual(["App Open", "Notification Opened", "Opened Notification"], self.trackingClient.events)
    XCTAssertEqual([nil, true, nil],
                   self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self))

  }

  func testOpenPushNotification_WhileInForeground() {
    self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                                 launchOptions: [:])

    self.presentViewController.assertValueCount(0)

    self.vm.inputs.didReceive(remoteNotification: friendBackingPushData, applicationIsActive: true)

    self.presentViewController.assertValueCount(0)
    XCTAssertEqual(["App Open"], self.trackingClient.events)

    self.vm.inputs.openRemoteNotificationTappedOk()

    self.presentViewController.assertValueCount(1)
    XCTAssertEqual(["App Open", "Notification Opened", "Opened Notification"], self.trackingClient.events)
  }

  func testOpenPushNotification_LaunchApp() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.sharedApplication(),
      launchOptions: [UIApplicationLaunchOptionsRemoteNotificationKey: friendBackingPushData]
    )

    self.presentViewController.assertValueCount(1)
    XCTAssertEqual(["Notification Opened", "Opened Notification", "App Open"], self.trackingClient.events)
    XCTAssertEqual([true, nil, nil],
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
