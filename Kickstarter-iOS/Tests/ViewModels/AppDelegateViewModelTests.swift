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

  override func setUp() {
    super.setUp()

    vm.outputs.updateCurrentUserInEnvironment.observe(updateCurrentUserInEnvironment.observer)
    vm.outputs.updateEnvironment.observe(updateEnvironment.observer)
    vm.outputs.postNotification.map { $0.name }.observe(postNotificationName.observer)
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
}
