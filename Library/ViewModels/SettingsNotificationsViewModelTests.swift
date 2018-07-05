import Foundation
import XCTest
import ReactiveSwift
import Result
import Prelude
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class SettingsNotificationsViewModelTests: TestCase {
  let vm = SettingsNotificationsViewModel()

  let emailFriendsActivitySelected = TestObserver<Bool, NoError>()
  let emailMessagesSelected = TestObserver<Bool, NoError>()
  let emailNewFollowersSelected = TestObserver<Bool, NoError>()
  let emailProjectUpdatesSelected = TestObserver<Bool, NoError>()
  let goToFindFriends = TestObserver<Void, NoError>()
  let goToManageProjectNotifications = TestObserver<Void, NoError>()
  let mobileNewFollowersSelected = TestObserver<Bool, NoError>()
  let mobileFriendsActivitySelected = TestObserver<Bool, NoError>()
  let mobileMessagesSelected = TestObserver<Bool, NoError>()
  let mobileProjectUpdatesSelected = TestObserver<Bool, NoError>()
  let projectNotificationsCount = TestObserver<String, NoError>()
  let unableToSaveError = TestObserver<String, NoError>()
  let updateCurrentUser = TestObserver<User, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.emailFriendsActivitySelected.observe(self.emailFriendsActivitySelected.observer)
    self.vm.outputs.emailNewFollowersSelected.observe(self.emailNewFollowersSelected.observer)
    self.vm.outputs.emailProjectUpdatesSelected.observe(self.emailProjectUpdatesSelected.observer)
    self.vm.outputs.goToFindFriends.observe(self.goToFindFriends.observer)
    self.vm.outputs.goToManageProjectNotifications.observe(self.goToManageProjectNotifications.observer)
    self.vm.outputs.emailMessagesSelected.observe(self.emailMessagesSelected.observer)
    self.vm.outputs.mobileFriendsActivitySelected.observe(self.mobileFriendsActivitySelected.observer)
    self.vm.outputs.mobileMessagesSelected.observe(self.mobileMessagesSelected.observer)
    self.vm.outputs.mobileNewFollowersSelected.observe(self.mobileNewFollowersSelected.observer)
    self.vm.outputs.mobileProjectUpdatesSelected.observe(self.mobileProjectUpdatesSelected.observer)
    self.vm.outputs.projectNotificationsCount.observe(self.projectNotificationsCount.observer)
    self.vm.outputs.unableToSaveError.observe(self.unableToSaveError.observer)
    self.vm.outputs.updateCurrentUser.observe(self.updateCurrentUser.observer)
  }

  func testGoToFindFriends() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.findFriendsTapped()
    self.goToFindFriends.assertValueCount(1, "Go to Find Friends screen.")
  }

  func testGoToManageProjectNotifications() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.manageProjectNotificationsTapped()
    self.goToManageProjectNotifications.assertValueCount(1, "Go to manage project notifications screen.")
  }

  func testProjectUpdatesToggled() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()

    self.emailProjectUpdatesSelected.assertValues(
      [false], "All project updates notifications turned off as test default."
    )
    self.mobileProjectUpdatesSelected.assertValues([false])

    self.vm.inputs.emailProjectUpdatesTapped(selected: true)
    self.vm.inputs.mobileProjectUpdatesTapped(selected: true)

    self.emailProjectUpdatesSelected.assertValues([false, true], "All social notifications toggled on.")
    self.mobileProjectUpdatesSelected.assertValues([false, true])

    XCTAssertEqual(["Settings View", "Viewed Settings", "Enabled Email Notifications",
                    "Enabled Push Notifications"],
                   self.trackingClient.events)

    self.vm.inputs.emailProjectUpdatesTapped(selected: false)
    self.vm.inputs.mobileProjectUpdatesTapped(selected: false)

    self.emailProjectUpdatesSelected.assertValues([false, true, false],
                                                  "Mobile social notifications toggled off.")
    self.mobileProjectUpdatesSelected.assertValues([false, true, false])

    XCTAssertEqual(["Settings View", "Viewed Settings", "Enabled Email Notifications",
                    "Enabled Push Notifications",
                    "Disabled Email Notifications", "Disabled Push Notifications"],
                   self.trackingClient.events)
  }

  func testSocialNotificationsToggled() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()

    self.emailNewFollowersSelected.assertValues([false],
                                                "All social notifications turned off as test default.")
    self.emailFriendsActivitySelected.assertValues([false])
    self.emailMessagesSelected.assertValues([false])
    self.mobileNewFollowersSelected.assertValues([false])
    self.mobileFriendsActivitySelected.assertValues([false])
    self.mobileMessagesSelected.assertValues([false])

    self.vm.inputs.emailNewFollowersTapped(selected: true)
    self.vm.inputs.emailFriendActivityTapped(selected: true)
    self.vm.inputs.emailMessagesTapped(selected: true)
    self.vm.inputs.mobileNewFollowersTapped(selected: true)
    self.vm.inputs.mobileFriendsActivityTapped(selected: true)
    self.vm.inputs.mobileMessagesTapped(selected: true)

    self.emailNewFollowersSelected.assertValues([false, true], "All social notifications toggled on.")
    self.emailFriendsActivitySelected.assertValues([false, true])
    self.emailMessagesSelected.assertValues([false, true])
    self.mobileNewFollowersSelected.assertValues([false, true])
    self.mobileFriendsActivitySelected.assertValues([false, true])
    self.mobileMessagesSelected.assertValues([false, true])

    XCTAssertEqual(["Settings View", "Viewed Settings", "Enabled Email Notifications",
                    "Enabled Email Notifications", "Enabled Email Notifications",
                    "Enabled Push Notifications", "Enabled Push Notifications", "Enabled Push Notifications"],
                   self.trackingClient.events)

    self.vm.inputs.mobileNewFollowersTapped(selected: false)
    self.vm.inputs.mobileFriendsActivityTapped(selected: false)

    self.mobileNewFollowersSelected.assertValues([false, true, false],
                                                 "Mobile social notifications toggled off.")
    self.mobileFriendsActivitySelected.assertValues([false, true, false])

    XCTAssertEqual(["Settings View", "Viewed Settings", "Enabled Email Notifications",
                    "Enabled Email Notifications", "Enabled Email Notifications",
                    "Enabled Push Notifications", "Enabled Push Notifications", "Enabled Push Notifications",
                    "Disabled Push Notifications", "Disabled Push Notifications"], self.trackingClient.events)
  }

  func testProjectNotificationsCount() {
    let user = User.template |> User.lens.stats.backedProjectsCount .~ 42
    withEnvironment(apiService: MockService(fetchUserSelfResponse: user)) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "dabbadoo", user: user))
      self.vm.inputs.viewDidLoad()
      self.projectNotificationsCount.assertValues(["42"], "Project notifications count emits.")
    }
  }

  func testProjectUpdateNotifications() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()

    self.emailProjectUpdatesSelected.assertValues([false],
                                                  "Project update notifications turned off as test default.")
    self.mobileProjectUpdatesSelected.assertValues([false])

    self.vm.inputs.emailProjectUpdatesTapped(selected: true)
    self.vm.inputs.mobileProjectUpdatesTapped(selected: true)

    self.emailProjectUpdatesSelected.assertValues([false, true], "Project update notifications toggled on.")
    self.mobileProjectUpdatesSelected.assertValues([false, true])

    XCTAssertEqual(["Settings View", "Viewed Settings", "Enabled Email Notifications",
                    "Enabled Push Notifications"], self.trackingClient.events)
  }

  func testUpdateError() {
    let error = ErrorEnvelope(
      errorMessages: ["Unable to save."],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    withEnvironment(apiService: MockService(updateUserSelfError: error)) {
      let user = User.template
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
      self.vm.inputs.viewDidLoad()

      self.emailProjectUpdatesSelected.assertValues([false], "Updates notifications turned off as default.")

      self.vm.inputs.emailProjectUpdatesTapped(selected: true)

      self.emailProjectUpdatesSelected.assertValues([false, true],
                                                    "Updates immediately flipped to true on tap.")

      self.scheduler.advance()

      self.unableToSaveError.assertValueCount(1, "Updating user errored.")
      self.emailProjectUpdatesSelected.assertValues([false, true, false],
                                                    "Did not successfully save preference.")
    }
  }

  func testUpdateUser() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()
    self.updateCurrentUser.assertValueCount(2, "Begin with environment's current user and refresh.")

    self.vm.inputs.emailProjectUpdatesTapped(selected: true)
    self.updateCurrentUser.assertValueCount(3, "User should be updated.")

    self.vm.inputs.mobileNewFollowersTapped(selected: true)
    self.updateCurrentUser.assertValueCount(4, "User should be updated.")
  }
}
