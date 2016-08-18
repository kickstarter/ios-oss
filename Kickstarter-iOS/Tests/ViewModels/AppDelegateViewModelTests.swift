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

  let updateCurrentUserInEnvironment = TestObserver<User, NoError>()
  let updateEnvironment = TestObserver<(Config, Koala), NoError>()
  let postNotificationName = TestObserver<String, NoError>()
  let presentViewController = TestObserver<Int, NoError>()
  let goToActivity = TestObserver<(), NoError>()
  let goToLogin = TestObserver<(), NoError>()
  let goToProfile = TestObserver<(), NoError>()
  let goToSearch = TestObserver<(), NoError>()

  override func setUp() {
    super.setUp()

    vm.outputs.updateCurrentUserInEnvironment.observe(self.updateCurrentUserInEnvironment.observer)
    vm.outputs.updateEnvironment.observe(self.updateEnvironment.observer)
    vm.outputs.postNotification.map { $0.name }.observe(self.postNotificationName.observer)
    vm.outputs.presentViewController.map { ($0 as! UINavigationController).viewControllers.count }
      .observe(self.presentViewController.observer)
    vm.outputs.goToActivity.observe(self.goToActivity.observer)
    vm.outputs.goToLogin.observe(self.goToLogin.observer)
    vm.outputs.goToProfile.observe(self.goToProfile.observer)
    vm.outputs.goToSearch.observe(self.goToSearch.observer)
  }

  func testHockeyManager_StartsWhenAppLaunches() {
    XCTAssertFalse(hockeyManager.managerStarted, "Manager should not start right away.")

    vm.inputs.applicationDidFinishLaunching(application: UIApplication.sharedApplication(),
                                            launchOptions: [:])
    XCTAssertTrue(hockeyManager.managerStarted, "Manager should start when the app launches.")
    XCTAssertTrue(hockeyManager.isAutoSendingReports, "Manager sends crash reports automatically.")
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

      let updateUrl =
        projectUrl + "/posts/1399396"
      self.vm.inputs.applicationOpenUrl(application: UIApplication.sharedApplication(),
                                        url: NSURL(string: updateUrl)!,
                                        sourceApplication: nil,
                                        annotation: 1)

      self.presentViewController.assertValues([1, 2, 2])

      let updateCommentsUrl =
        updateUrl + "/comments"
      self.vm.inputs.applicationOpenUrl(application: UIApplication.sharedApplication(),
                                        url: NSURL(string: updateCommentsUrl)!,
                                        sourceApplication: nil,
                                        annotation: 1)

      self.presentViewController.assertValues([1, 2, 2, 3])
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
}
