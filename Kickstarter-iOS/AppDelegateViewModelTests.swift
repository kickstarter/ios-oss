import GraphAPI
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
  private let configureFirebase = TestObserver<(), Never>()
  private let configureSegmentWithBraze = TestObserver<String, Never>()
  private let didAcceptReceivingRemoteNotifications = TestObserver<(), Never>()
  private let emailVerificationCompletedMessage = TestObserver<String, Never>()
  private let emailVerificationCompletedSuccess = TestObserver<Bool, Never>()
  private let findRedirectUrl = TestObserver<URL, Never>()
  private let forceLogout = TestObserver<(), Never>()
  private let goToActivity = TestObserver<(), Never>()
  private let goToDiscovery = TestObserver<DiscoveryParams?, Never>()
  private let goToLoginWithIntent = TestObserver<LoginIntent, Never>()
  private let goToProfile = TestObserver<(), Never>()
  private let goToMobileSafari = TestObserver<URL, Never>()
  private let goToSearch = TestObserver<(), Never>()
  private let postNotificationName = TestObserver<Notification.Name, Never>()
  private let presentViewController = TestObserver<Int, Never>()
  private let pushRegistrationStarted = TestObserver<(), Never>()
  private let pushTokenSuccessfullyRegistered = TestObserver<String, Never>()
  private let registerPushTokenInSegment = TestObserver<Data, Never>()
  private let requestATTrackingAuthorizationStatus = TestObserver<Void, Never>()
  private let setApplicationShortcutItems = TestObserver<[ShortcutItem], Never>()
  private let segmentIsEnabled = TestObserver<Bool, Never>()
  private let showAlert = TestObserver<Notification, Never>()
  private let trackingAuthorizationStatus = TestObserver<AppTrackingAuthorization, Never>()
  private let unregisterForRemoteNotifications = TestObserver<(), Never>()
  private let updateCurrentUserInEnvironment = TestObserver<User, Never>()
  private let updateConfigInEnvironment = TestObserver<Config, Never>()
  private let darkModeEnabled = TestObserver<Bool, Never>()
  private var disposables: [any Disposable] = []

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
    self.vm.outputs.configureFirebase.observe(self.configureFirebase.observer)
    self.vm.outputs.configureSegmentWithBraze.observe(self.configureSegmentWithBraze.observer)
    self.vm.outputs.emailVerificationCompleted.map(first)
      .observe(self.emailVerificationCompletedMessage.observer)
    self.vm.outputs.emailVerificationCompleted.map(second)
      .observe(self.emailVerificationCompletedSuccess.observer)
    self.vm.outputs.findRedirectUrl.observe(self.findRedirectUrl.observer)
    self.vm.outputs.forceLogout.observe(self.forceLogout.observer)
    self.vm.outputs.goToActivity.observe(self.goToActivity.observer)
    self.vm.outputs.goToDiscovery.observe(self.goToDiscovery.observer)
    self.vm.outputs.goToLoginWithIntent.observe(self.goToLoginWithIntent.observer)
    self.vm.outputs.goToProfile.observe(self.goToProfile.observer)
    self.vm.outputs.goToMobileSafari.observe(self.goToMobileSafari.observer)
    self.vm.outputs.goToSearch.observe(self.goToSearch.observer)
    self.vm.outputs.postNotification.map { $0.name }.observe(self.postNotificationName.observer)
    self.vm.outputs.presentViewController.map { ($0 as! UINavigationController).viewControllers.count }
      .observe(self.presentViewController.observer)
    self.vm.outputs.pushTokenRegistrationStarted.observe(self.pushRegistrationStarted.observer)
    self.vm.outputs.pushTokenSuccessfullyRegistered.observe(self.pushTokenSuccessfullyRegistered.observer)
    self.vm.outputs.registerPushTokenInSegment.observe(self.registerPushTokenInSegment.observer)
    self.vm.outputs.requestATTrackingAuthorizationStatus
      .observe(self.requestATTrackingAuthorizationStatus.observer)
    self.vm.outputs.setApplicationShortcutItems.observe(self.setApplicationShortcutItems.observer)
    self.vm.outputs.showAlert.observe(self.showAlert.observer)
    self.vm.outputs.segmentIsEnabled.observe(self.segmentIsEnabled.observer)
    self.disposables
      .append(self.vm.outputs.trackingAuthorizationStatus.start(self.trackingAuthorizationStatus.observer))
    self.vm.outputs.unregisterForRemoteNotifications.observe(self.unregisterForRemoteNotifications.observer)
    self.vm.outputs.updateCurrentUserInEnvironment.observe(self.updateCurrentUserInEnvironment.observer)
    self.vm.outputs.updateConfigInEnvironment.observe(self.updateConfigInEnvironment.observer)
    self.vm.outputs.darkModeEnabled.observe(self.darkModeEnabled.observer)
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

    self.postNotificationName.assertValues(
      [.ksr_applicationDidEnterBackground]
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

      self.updateCurrentUserInEnvironment.assertDidNotEmitValue()
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

      self.presentViewController.assertValues([1, 2, 2, 2, 3, 1])
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

      self.presentViewController.assertValues([1])
      self.goToMobileSafari.assertValues([])
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

    withEnvironment(apiService: MockService(fetchCommentRepliesEnvelopeResult: .success(
      CommentRepliesEnvelope
        .successfulRepliesTemplate
    ), fetchProjectResult: .success(.template))) {
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

    withEnvironment(apiService: MockService(fetchCommentRepliesEnvelopeResult: .success(
      CommentRepliesEnvelope
        .successfulRepliesTemplate
    ), fetchProjectResult: .success(.template))) {
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

    withEnvironment(apiService: MockService(fetchCommentRepliesEnvelopeResult: .success(
      CommentRepliesEnvelope
        .successfulRepliesTemplate
    ), fetchProjectResult: .success(.template))) {
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

    withEnvironment(apiService: MockService(fetchCommentRepliesEnvelopeResult: .success(
      CommentRepliesEnvelope
        .successfulRepliesTemplate
    ), fetchProjectResult: .success(.template))) {
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
        URL(
          string: "https://www.kickstarter.com/discover/advanced?category_id=1&sort=magic&seed=2714369&page=1"
        )!
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
        URL(
          string: "https://www.kickstarter.com/discover/advanced?category_id=9999&sort=magic&seed=2714369&page=1"
        )!
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
        URL(
          string: "https://www.kickstarter.com/discover/advanced?category_id=34&sort=magic&seed=2714369&page=1"
        )!
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

  func testDeeplink_IsActivated_Success() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    withEnvironment(currentUser: nil) {
      let result = self.vm.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: URL(string: "https://www.kickstarter.com/search")!,
        options: [:]
      )

      XCTAssertTrue(result)

      self.goToSearch.assertValueCount(1)
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

  func testOpenNotification_NewBacking_ForCreator_WithBadData() {
    var badPushData = backingForCreatorPushData
    var badActivityData = badPushData["activity"] as? [String: AnyObject]
    badActivityData?["project_id"] = nil
    badPushData["activity"] = badActivityData

    self.vm.inputs.didReceive(remoteNotification: badPushData)
  }

  func testOpenNotification_PledgeRedemption() {
    self.vm.inputs.didReceive(remoteNotification: pledgeRedemptionPushData)

    self.presentViewController.assertValueCount(1)
  }

  func testOpenNotification_PledgeRedemption_BadData() {
    var badPushData = pledgeRedemptionPushData
    badPushData["pledgeRedemption"]?["id"] = nil

    self.vm.inputs.didReceive(remoteNotification: badPushData)

    self.presentViewController.assertValueCount(0)
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

      self.goToDiscovery.assertValueCount(0)
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

  func testContinueUserActivity_Success() {
    let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
    userActivity.webpageURL = URL(string: "https://www.kickstarter.com/activity")

    withEnvironment(currentUser: nil) {
      self.vm.inputs.applicationDidFinishLaunching(application: .shared, launchOptions: [:])

      self.goToActivity.assertValueCount(0)
      XCTAssertFalse(self.vm.outputs.continueUserActivityReturnValue.value)

      let result = self.vm.inputs.applicationContinueUserActivity(userActivity)
      XCTAssertTrue(result)

      XCTAssertTrue(self.vm.outputs.continueUserActivityReturnValue.value)
      self.goToActivity.assertValueCount(1)
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
        [.recommendedForYou, .projectsWeLove, .search]
      ])
    }
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

  func testPerformShortcutItem_Success() {
    withEnvironment(currentUser: nil) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [:]
      )
      self.vm.inputs.applicationPerformActionForShortcutItem(ShortcutItem.search.applicationShortcutItem)

      self.goToSearch.assertValueCount(1)
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

  func testLaunchShortcutItem_Failure() {
    withEnvironment(currentUser: nil) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: UIApplication.shared,
        launchOptions: [
          UIApplication.LaunchOptionsKey.shortcutItem: ShortcutItem.search.applicationShortcutItem
        ]
      )

      self.goToSearch.assertValueCount(1)
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
      let emailUrl = URL(string: "https://clicks.kickstarter.com/?qs=deadbeef")!

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

  func testEmailDeepLinking_ContinuedUserActivity() {
    withEnvironment(apiService: MockService(fetchProjectResult: .success(.template))) {
      let emailUrl = URL(string: "https://emails.kickstarter.com/?qs=deadbeef")!
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
    let emailUrl = URL(string: "https://clicks.kickstarter.com/?qs=deadbeef")!

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
    let emailUrl = URL(string: "https://emails.kickstarter.com/?qs=deadbeef")!

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

    self.configureSegmentWithBraze.assertDidNotEmitValue()

    withEnvironment(mainBundle: mockBundle) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: .shared,
        launchOptions: [:]
      )

      self.configureSegmentWithBraze.assertValues([Secrets.Segment.production])
    }
  }

  func testConfigureSegment_NotRelease() {
    let mockBundle = MockBundle(
      bundleIdentifier: KickstarterBundleIdentifier.beta.rawValue
    )

    self.configureSegmentWithBraze.assertDidNotEmitValue()

    withEnvironment(mainBundle: mockBundle) {
      self.vm.inputs.applicationDidFinishLaunching(
        application: .shared,
        launchOptions: [:]
      )

      self.configureSegmentWithBraze.assertValues([Secrets.Segment.staging])
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

  func testRequestATTrackingAuthorizationStatus_WhenAppBecomesActive_WhenAdvertisingIdentifierNil_WhenConsentManagementFeatureFlagOn_WhenShouldRequestAuthorizationStatusTrue_RequestAllowed_ShowsConsentDialogAndUpdatesAdId(
  ) {
    let appTrackingTransparency = MockAppTrackingTransparency()
    appTrackingTransparency.requestAndSetAuthorizationStatusFlag = true
    appTrackingTransparency.shouldRequestAuthStatus = true

    withEnvironment(
      appTrackingTransparency: appTrackingTransparency
    ) {
      self.requestATTrackingAuthorizationStatus.assertValueCount(0)

      XCTAssertNil(appTrackingTransparency.advertisingIdentifier)

      self.vm.inputs.applicationActive(state: false)
      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)
      self.vm.inputs.applicationActive(state: true)

      self.scheduler.advance(by: .seconds(1))

      XCTAssertEqual(appTrackingTransparency.advertisingIdentifier, "advertisingIdentifier")
      self.requestATTrackingAuthorizationStatus.assertValueCount(1)
    }
  }

  func testRequestATTrackingAuthorizationStatus_WhenAppBecomesActive_WhenAdvertisingIdentifierNil_WhenConsentManagementFeatureFlagOn_WhenShouldRequestAuthorizationStatusFalse_RequestAllowed_DoesNotShowConsentDialogAndDoesNotUpdateAdId(
  ) {
    let appTrackingTransparency = MockAppTrackingTransparency()
    appTrackingTransparency.requestAndSetAuthorizationStatusFlag = true
    appTrackingTransparency.shouldRequestAuthStatus = false

    withEnvironment(
      appTrackingTransparency: appTrackingTransparency
    ) {
      self.requestATTrackingAuthorizationStatus.assertValueCount(0)

      XCTAssertNil(appTrackingTransparency.advertisingIdentifier)

      self.vm.inputs.applicationActive(state: false)
      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)
      self.vm.inputs.applicationActive(state: true)

      self.scheduler.advance(by: .seconds(1))

      XCTAssertNil(appTrackingTransparency.advertisingIdentifier)
      self.requestATTrackingAuthorizationStatus.assertValueCount(1)
    }
  }

  func testRequestATTrackingAuthorizationStatus_WhenAppBecomesActive_WhenAdvertisingIdentifierNil_WhenConsentManagementFeatureFlagOn_WhenShouldRequestAuthorizationStatusTrue_RequestDenied_DoesNotShowConsentDialogAndDoesNotUpdateAdId(
  ) {
    let appTrackingTransparency = MockAppTrackingTransparency()
    appTrackingTransparency.requestAndSetAuthorizationStatusFlag = false
    appTrackingTransparency.shouldRequestAuthStatus = true

    withEnvironment(
      appTrackingTransparency: appTrackingTransparency
    ) {
      self.requestATTrackingAuthorizationStatus.assertValueCount(0)

      XCTAssertNil(appTrackingTransparency.advertisingIdentifier)

      self.vm.inputs.applicationActive(state: false)
      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)
      self.vm.inputs.applicationActive(state: true)

      self.scheduler.advance(by: .seconds(1))

      XCTAssertNil(appTrackingTransparency.advertisingIdentifier)
      self.requestATTrackingAuthorizationStatus.assertValueCount(1)
    }
  }

  func testRequestAppTrackingSignalAuthorize() {
    let appTrackingTransparency = MockAppTrackingTransparency()
    withEnvironment(
      appTrackingTransparency: appTrackingTransparency
    ) {
      self.vm.inputs.applicationActive(state: false)
      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)

      appTrackingTransparency.authorizationStatusValue = .notDetermined
      XCTAssertEqual(self.trackingAuthorizationStatus.values, [.notDetermined])
      XCTAssertTrue(appTrackingTransparency.shouldRequestAuthStatus)

      appTrackingTransparency.requestAndSetAuthorizationStatus()
      XCTAssertEqual(self.trackingAuthorizationStatus.values, [.notDetermined, .authorized])
      XCTAssertFalse(appTrackingTransparency.shouldRequestAuthStatus)
    }
  }

  func testRequestAppTrackingSignalDeny() {
    let appTrackingTransparency = MockAppTrackingTransparency()
    withEnvironment(
      appTrackingTransparency: appTrackingTransparency
    ) {
      self.vm.inputs.applicationActive(state: false)
      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)

      appTrackingTransparency.authorizationStatusValue = .notDetermined
      XCTAssertEqual(self.trackingAuthorizationStatus.values, [.notDetermined])
      XCTAssertTrue(appTrackingTransparency.shouldRequestAuthStatus)

      appTrackingTransparency.authorizationStatusValue = .denied
      XCTAssertEqual(self.trackingAuthorizationStatus.values, [.notDetermined, .denied])
      XCTAssertFalse(appTrackingTransparency.shouldRequestAuthStatus)
    }
  }

  func testPresentViewController_BrazeInAppNotificationDeeplink_ProjectCommentThread_Success() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    withEnvironment(apiService: MockService(fetchCommentRepliesEnvelopeResult: .success(
      CommentRepliesEnvelope
        .successfulRepliesTemplate
    ), fetchProjectResult: .success(.template))) {
      let url =
        "https://\(AppEnvironment.current.apiService.serverConfig.webBaseUrl.host ?? "")/projects/fjorden/fjorden-iphone-photography-reinvented/"

      self.presentViewController.assertValues([])

      self.vm.inputs.urlFromBrazeInAppNotification(URL(string: url)!)

      self.presentViewController.assertValues([1])
    }
  }

  func testGoToMobileSafari_BrazeInAppNotificaton() {
    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    let url = URL(string: "https://fake-url.com")!
    self.vm.inputs.urlFromBrazeInAppNotification(url)

    self.goToMobileSafari.assertValues([url])
    self.presentViewController.assertValues([])
  }

  func testRemoteConfigClientConfiguredNotification_Success() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService) {
      self.postNotificationName.assertDidNotEmitValue()

      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)

      self.vm.inputs.didUpdateRemoteConfigClient()

      self.postNotificationName.assertValues([.ksr_remoteConfigClientConfigured])
    }
  }

  func testRemoteConfigClientConfigurationFailedNotification() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService) {
      self.postNotificationName.assertDidNotEmitValue()

      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)

      self.vm.inputs.remoteConfigClientConfigurationFailed()

      self.postNotificationName.assertValues([.ksr_remoteConfigClientConfigurationFailed])
    }
  }

  func testUserSessionStarted_fetchesUserEmail_andClearsOnLogout() {
    let fetchUserSetupQueryData = GraphAPI.FetchUserSetupQuery.Data(
      me: GraphAPI.FetchUserSetupQuery.Data.Me(
        email: "user@example.com",
        enabledFeatures: []
      )
    )

    guard let envelope = UserEnvelope<GraphUserSetup>.userEnvelope(from: fetchUserSetupQueryData) else {
      XCTFail()
      return
    }

    let mockService = MockService(
      fetchGraphUserSetupResult: .success(envelope)
    )

    withEnvironment(apiService: mockService) {
      XCTAssertNil(AppEnvironment.current.currentUserEmail)

      self.vm.inputs.userSessionStarted()

      XCTAssertEqual(AppEnvironment.current.currentUserEmail, "user@example.com")

      AppEnvironment.logout()

      XCTAssertNil(AppEnvironment.current.currentUserEmail)
    }
  }

  func test_darkModeEnabled_startsOff_andIsTurnedOnRemotely() {
    let darkModeOn = MockRemoteConfigClient()
    darkModeOn.features = [
      RemoteConfigFeature.darkModeEnabled.rawValue: true
    ]

    let darkModeOff = MockRemoteConfigClient()
    darkModeOff.features = [
      RemoteConfigFeature.darkModeEnabled.rawValue: false
    ]

    withEnvironment(remoteConfigClient: darkModeOff) {
      self.darkModeEnabled.assertDidNotEmitValue()
      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)
      self.darkModeEnabled.assertLastValue(false)
    }

    withEnvironment(remoteConfigClient: darkModeOn) {
      self.vm.inputs.didUpdateRemoteConfigClient()
      self.darkModeEnabled.assertLastValue(true)
    }
  }

  func test_darkModeEnabled_startsOn_andIsTurnedOffOnForeground() {
    let darkModeOn = MockRemoteConfigClient()
    darkModeOn.features = [
      RemoteConfigFeature.darkModeEnabled.rawValue: true
    ]

    let darkModeOff = MockRemoteConfigClient()
    darkModeOff.features = [
      RemoteConfigFeature.darkModeEnabled.rawValue: false
    ]

    withEnvironment(remoteConfigClient: darkModeOn) {
      self.darkModeEnabled.assertDidNotEmitValue()
      self.vm.inputs.applicationDidFinishLaunching(application: UIApplication.shared, launchOptions: nil)
      self.darkModeEnabled.assertLastValue(true)
    }

    withEnvironment(remoteConfigClient: darkModeOff) {
      self.vm.inputs.applicationWillEnterForeground()
      self.darkModeEnabled.assertLastValue(false)
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

private let pledgeRedemptionPushData = [
  "aps": [
    "alert": "Response needed! Get your reward for backing some project."
  ],
  "pledgeRedemption": [
    "id": 1,
    "project_id": 1,
    "pledge_manager_path": "/projects/fakeCreatorId/1/backing/redeem"
  ]
]

private let surveyResponsePushData = [
  "aps": [
    "alert": "Response needed! Get your reward for backing some project."
  ],
  "survey": [
    "id": 1,
    "project_id": 1,
    "urls": [
      "web": [
        "survey": "/projects/fakeCreatorId/1/surveys/0"
      ]
    ]
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
