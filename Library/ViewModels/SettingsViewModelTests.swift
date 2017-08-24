import Foundation
import XCTest
import ReactiveSwift
import Result
import Prelude
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class SettingsViewModelTests: TestCase {
  let vm = SettingsViewModel()

  let artsAndCultureNewsletterOn = TestObserver<Bool, NoError>()
  let backingsSelected = TestObserver<Bool, NoError>()
  let betaToolsHidden = TestObserver<Bool, NoError>()
  let commentsSelected = TestObserver<Bool, NoError>()
  let creatorNotificationsHidden = TestObserver<Bool, NoError>()
  let followerSelected = TestObserver<Bool, NoError>()
  let friendActivitySelected = TestObserver<Bool, NoError>()
  let gamesNewsletterOn = TestObserver<Bool, NoError>()
  let goToAppStoreRating = TestObserver<String, NoError>()
  let goToBetaFeedback = TestObserver<(), NoError>()
  let goToFindFriends = TestObserver<Void, NoError>()
  let goToManageProjectNotifications = TestObserver<Void, NoError>()
  let happeningNewsletterOn = TestObserver<Bool, NoError>()
  let inventNewsletterOn = TestObserver<Bool, NoError>()
  let logoutWithParams = TestObserver<DiscoveryParams, NoError>()
  let mobileBackingsSelected = TestObserver<Bool, NoError>()
  let mobileCommentsSelected = TestObserver<Bool, NoError>()
  let mobileFollowerSelected = TestObserver<Bool, NoError>()
  let mobileFriendActivitySelected = TestObserver<Bool, NoError>()
  let mobilePostLikesSelected = TestObserver<Bool, NoError>()
  let mobileUpdatesSelected = TestObserver<Bool, NoError>()
  let postLikesSelected = TestObserver<Bool, NoError>()
  let projectNotificationsCount = TestObserver<String, NoError>()
  let promoNewsletterOn = TestObserver<Bool, NoError>()
  let showConfirmLogoutPrompt = TestObserver<(message: String, cancel: String, confirm: String), NoError>()
  let showOptInPrompt = TestObserver<String, NoError>()
  let unableToSaveError = TestObserver<String, NoError>()
  let updatesSelected = TestObserver<Bool, NoError>()
  let updateCurrentUser = TestObserver<User, NoError>()
  let weeklyNewsletterOn = TestObserver<Bool, NoError>()
  let versionText = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.artsAndCultureNewsletterOn.observe(self.artsAndCultureNewsletterOn.observer)
    self.vm.outputs.backingsSelected.observe(self.backingsSelected.observer)
    self.vm.outputs.betaToolsHidden.observe(self.betaToolsHidden.observer)
    self.vm.outputs.commentsSelected.observe(self.commentsSelected.observer)
    self.vm.outputs.creatorNotificationsHidden.observe(self.creatorNotificationsHidden.observer)
    self.vm.outputs.followerSelected.observe(self.followerSelected.observer)
    self.vm.outputs.friendActivitySelected.observe(self.friendActivitySelected.observer)
    self.vm.outputs.gamesNewsletterOn.observe(self.gamesNewsletterOn.observer)
    self.vm.outputs.goToAppStoreRating.observe(self.goToAppStoreRating.observer)
    self.vm.outputs.goToBetaFeedback.observe(self.goToBetaFeedback.observer)
    self.vm.outputs.goToFindFriends.observe(self.goToFindFriends.observer)
    self.vm.outputs.goToManageProjectNotifications.observe(self.goToManageProjectNotifications.observer)
    self.vm.outputs.happeningNewsletterOn.observe(self.happeningNewsletterOn.observer)
    self.vm.outputs.inventNewsletterOn.observe(self.inventNewsletterOn.observer)
    self.vm.outputs.logoutWithParams.observe(self.logoutWithParams.observer)
    self.vm.outputs.mobileBackingsSelected.observe(self.mobileBackingsSelected.observer)
    self.vm.outputs.mobileCommentsSelected.observe(self.mobileCommentsSelected.observer)
    self.vm.outputs.mobileFollowerSelected.observe(self.mobileFollowerSelected.observer)
    self.vm.outputs.mobileFriendActivitySelected.observe(self.mobileFriendActivitySelected.observer)
    self.vm.outputs.mobilePostLikesSelected.observe(self.mobilePostLikesSelected.observer)
    self.vm.outputs.mobileUpdatesSelected.observe(self.mobileUpdatesSelected.observer)
    self.vm.outputs.postLikesSelected.observe(self.postLikesSelected.observer)
    self.vm.outputs.projectNotificationsCount.observe(self.projectNotificationsCount.observer)
    self.vm.outputs.promoNewsletterOn.observe(self.promoNewsletterOn.observer)
    self.vm.outputs.showConfirmLogoutPrompt.observe(self.showConfirmLogoutPrompt.observer)
    self.vm.outputs.showOptInPrompt.observe(self.showOptInPrompt.observer)
    self.vm.outputs.unableToSaveError.observe(self.unableToSaveError.observer)
    self.vm.outputs.updatesSelected.observe(self.updatesSelected.observer)
    self.vm.outputs.updateCurrentUser.observe(self.updateCurrentUser.observer)
    self.vm.outputs.weeklyNewsletterOn.observe(self.weeklyNewsletterOn.observer)
    self.vm.outputs.versionText.observe(self.versionText.observer)
  }

  func testbetaToolsHidden_Alpha() {
    withEnvironment(mainBundle: MockBundle(bundleIdentifier: KickstarterBundleIdentifier.alpha.rawValue)) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))

      self.vm.inputs.viewDidLoad()

      self.betaToolsHidden.assertValues([false])
    }
  }

  func testbetaToolsHidden_Beta() {
    withEnvironment(mainBundle: MockBundle(bundleIdentifier: KickstarterBundleIdentifier.beta.rawValue)) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))

      self.vm.inputs.viewDidLoad()

      self.betaToolsHidden.assertValues([false])
    }
  }

  func testbetaToolsHidden_Release() {
    withEnvironment(mainBundle: MockBundle(bundleIdentifier: KickstarterBundleIdentifier.release.rawValue)) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))

      self.vm.inputs.viewDidLoad()

      self.betaToolsHidden.assertValues([true])
    }
  }

  func testbetaToolsHidden_Unknown() {
    withEnvironment(mainBundle: MockBundle(bundleIdentifier: "com.unknown")) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))

      self.vm.inputs.viewDidLoad()

      self.betaToolsHidden.assertValues([true])
    }
  }

  func testCreatorNotificationsHidden() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()
    self.creatorNotificationsHidden.assertValues([true], "Creator notifications hidden from non-creator.")
  }

  func testCreatorNotificationsShown() {
    let creator = User.template |> User.lens.stats.createdProjectsCount .~ 2

    withEnvironment(apiService: MockService(fetchUserSelfResponse: creator)) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: creator))

      self.vm.inputs.viewDidLoad()
      self.creatorNotificationsHidden.assertValues([false], "Creator notifications shown for creator.")
    }
  }

  func testCreatorNotificationsTapped() {
    let user = User.template |> User.lens.stats.createdProjectsCount .~ 2
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()

    self.backingsSelected.assertValues([false], "All creator notifications turned off as test default.")
    self.commentsSelected.assertValues([false])
    self.mobileBackingsSelected.assertValues([false])
    self.mobileCommentsSelected.assertValues([false])
    self.mobilePostLikesSelected.assertValues([false])
    self.postLikesSelected.assertValues([false])

    self.vm.inputs.mobileBackingsTapped(selected: true)
    self.mobileBackingsSelected.assertValues([false, true], "Mobile backings notifications on.")
    self.backingsSelected.assertValues([false], "Backings notifications remain unchanged.")

    self.vm.inputs.mobileBackingsTapped(selected: false)
    self.mobileBackingsSelected.assertValues([false, true, false], "Mobile backings notifications off.")
    self.mobileCommentsSelected.assertValues([false], "Mobile comments notifications remain unchanged.")

    self.vm.inputs.mobileBackingsTapped(selected: false)
    self.mobileBackingsSelected.assertValues([false, true, false],
                                             "Mobile backings notifications remain off.")

    self.vm.inputs.backingsTapped(selected: true)
    self.vm.inputs.commentsTapped(selected: true)
    self.vm.inputs.mobileBackingsTapped(selected: true)
    self.vm.inputs.mobileCommentsTapped(selected: true)
    self.vm.inputs.mobilePostLikesTapped(selected: true)
    self.vm.inputs.postLikesTapped(selected: true)

    self.backingsSelected.assertValues([false, true], "All creator notifications toggled on.")
    self.commentsSelected.assertValues([false, true])
    self.mobileBackingsSelected.assertValues([false, true, false, true])
    self.mobileCommentsSelected.assertValues([false, true])
    self.mobilePostLikesSelected.assertValues([false, true])
    self.postLikesSelected.assertValues([false, true])
    self.unableToSaveError.assertValueCount(0, "Error did not happen.")
  }

  func testGoToAppStoreRating() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.rateUsTapped()

    XCTAssertEqual(["Settings View", "Viewed Settings", "App Store Rating Open", "Opened App Store Listing"],
                   self.trackingClient.events)
    self.goToAppStoreRating.assertValueCount(1, "Go to App Store.")
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

  func testNewslettersToggled() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()

    self.artsAndCultureNewsletterOn.assertValues([false])
    self.gamesNewsletterOn.assertValues([false])
    self.happeningNewsletterOn.assertValues([false])
    self.inventNewsletterOn.assertValues([false])
    self.promoNewsletterOn.assertValues([false])
    self.weeklyNewsletterOn.assertValues([false])
    XCTAssertEqual(["Settings View", "Viewed Settings"], self.trackingClient.events)

    self.vm.inputs.artsAndCultureNewsletterTapped(on: true)
    self.artsAndCultureNewsletterOn.assertValues([false, true], "Arts newwsletter toggled on.")

    self.vm.inputs.gamesNewsletterTapped(on: true)
    self.gamesNewsletterOn.assertValues([false, true], "Games newsletter toggled on.")
    XCTAssertEqual(["Settings View", "Viewed Settings", "Subscribed To Newsletter", "Subscribed To Newsletter"],
                   self.trackingClient.events)

    self.vm.inputs.happeningNewsletterTapped(on: true)
    self.happeningNewsletterOn.assertValues([false, true], "Happening newsletter toggled on.")

    self.vm.inputs.inventNewsletterTapped(on: true)
    self.inventNewsletterOn.assertValues([false, true], "Invent newsletter toggled on.")

    self.vm.inputs.promoNewsletterTapped(on: true)
    self.promoNewsletterOn.assertValues([false, true], "Promo newsletter toggled on.")

    self.vm.inputs.weeklyNewsletterTapped(on: true)
    self.weeklyNewsletterOn.assertValues([false, true], "Weekly newsletter toggled on.")

    self.vm.inputs.artsAndCultureNewsletterTapped(on: false)
    self.artsAndCultureNewsletterOn.assertValues([false, true, false], "Arts newsletter toggled off.")

    self.vm.inputs.gamesNewsletterTapped(on: false)
    self.gamesNewsletterOn.assertValues([false, true, false], "Games newsletter toggled off.")

    self.vm.inputs.happeningNewsletterTapped(on: false)
    self.happeningNewsletterOn.assertValues([false, true, false], "Happening newsletter toggled off.")

    self.vm.inputs.inventNewsletterTapped(on: false)
    self.inventNewsletterOn.assertValues([false, true, false])

    self.vm.inputs.promoNewsletterTapped(on: false)
    self.promoNewsletterOn.assertValues([false, true, false], "Promo newsletter toggled off.")

    self.vm.inputs.weeklyNewsletterTapped(on: false)
    self.weeklyNewsletterOn.assertValues([false, true, false], "Weekly newsletter toggled off.")
    XCTAssertEqual(["Settings View", "Viewed Settings", "Subscribed To Newsletter", "Subscribed To Newsletter",
      "Subscribed To Newsletter", "Subscribed To Newsletter", "Subscribed To Newsletter", "Subscribed To Newsletter",
      "Unsubscribed From Newsletter", "Unsubscribed From Newsletter", "Unsubscribed From Newsletter", "Unsubscribed From Newsletter", "Unsubscribed From Newsletter",
      "Unsubscribed From Newsletter"], self.trackingClient.events)
  }

  func testOptInPromptNotShown() {
    withEnvironment(countryCode: "US") {
      let user = User.template
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.happeningNewsletterTapped(on: true)
      self.showOptInPrompt.assertDidNotEmitValue("Non-German locale does not require double opt-in.")
    }
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

    self.updatesSelected.assertValues([false], "Project update notifications turned off as test default.")
    self.mobileUpdatesSelected.assertValues([false])

    self.vm.inputs.updatesTapped(selected: true)
    self.vm.inputs.mobileUpdatesTapped(selected: true)

    self.updatesSelected.assertValues([false, true], "Project update notifications toggled on.")
    self.mobileUpdatesSelected.assertValues([false, true])

    XCTAssertEqual(["Settings View", "Viewed Settings", "Enabled Email Notifications",
      "Enabled Push Notifications"], self.trackingClient.events)
  }

  func testLogoutFlow() {
    let params = .defaults
      |> DiscoveryParams.lens.includePOTD .~ true
      |> DiscoveryParams.lens.sort .~ .magic

    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.logoutTapped()
    self.showConfirmLogoutPrompt.assertValueCount(1, "Show confirm logout prompt.")

    self.vm.inputs.logoutCanceled()

    self.vm.inputs.logoutTapped()
    self.showConfirmLogoutPrompt.assertValueCount(2, "Show prompt again.")
    self.logoutWithParams.assertValueCount(0, "Logout did not emit.")

    self.vm.inputs.logoutConfirmed()
    self.logoutWithParams.assertValues([params], "User logged out.")

    XCTAssertEqual(["Settings View", "Viewed Settings", "Triggered Logout Modal", "Canceled Logout",
      "Triggered Logout Modal", "Confirmed Logout"], self.trackingClient.events)
  }

  func testShowOptInPrompt() {
    withEnvironment(config: Config.deConfig) {
      let user = User.template
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.gamesNewsletterTapped(on: true)
      self.showOptInPrompt.assertValueCount(1, "German locale requires double opt-in.")

      self.vm.inputs.gamesNewsletterTapped(on: false)
      self.showOptInPrompt.assertValueCount(1, "Prompt not shown again when newsletter toggled off.")
    }
  }

  func testSocialNotificationsToggled() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()

    self.followerSelected.assertValues([false], "All social notifications turned off as test default.")
    self.friendActivitySelected.assertValues([false])
    self.mobileFollowerSelected.assertValues([false])
    self.mobileFriendActivitySelected.assertValues([false])

    self.vm.inputs.followerTapped(selected: true)
    self.vm.inputs.friendActivityTapped(selected: true)
    self.vm.inputs.mobileFollowerTapped(selected: true)
    self.vm.inputs.mobileFriendActivityTapped(selected: true)

    self.followerSelected.assertValues([false, true], "All social notifications toggled on.")
    self.friendActivitySelected.assertValues([false, true])
    self.mobileFollowerSelected.assertValues([false, true])
    self.mobileFriendActivitySelected.assertValues([false, true])

    XCTAssertEqual(["Settings View", "Viewed Settings", "Enabled Email Notifications",
      "Enabled Email Notifications", "Enabled Push Notifications", "Enabled Push Notifications"],
      self.trackingClient.events)

    self.vm.inputs.mobileFollowerTapped(selected: false)
    self.vm.inputs.mobileFriendActivityTapped(selected: false)

    self.mobileFollowerSelected.assertValues([false, true, false], "Mobile social notifications toggled off.")
    self.mobileFriendActivitySelected.assertValues([false, true, false])

    XCTAssertEqual(["Settings View", "Viewed Settings", "Enabled Email Notifications",
      "Enabled Email Notifications", "Enabled Push Notifications", "Enabled Push Notifications",
      "Disabled Push Notifications", "Disabled Push Notifications"], self.trackingClient.events)
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

      self.updatesSelected.assertValues([false], "Updates notifications turned off as default.")

      self.vm.inputs.updatesTapped(selected: true)

      self.updatesSelected.assertValues([false, true], "Updates immediately flipped to true on tap.")

      self.scheduler.advance()

      self.unableToSaveError.assertValueCount(1, "Updating user errored.")
      self.updatesSelected.assertValues([false, true, false], "Did not successfully save preference.")
    }
  }

  func testUpdateUser() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()
    self.updateCurrentUser.assertValueCount(2, "Begin with environment's current user and refresh.")

    self.vm.inputs.gamesNewsletterTapped(on: true)
    self.updateCurrentUser.assertValueCount(3, "User should be updated.")

    self.vm.inputs.commentsTapped(selected: true)
    self.updateCurrentUser.assertValueCount(4, "User should be updated.")
  }

  func testVersionText_Alpha() {
    withEnvironment(mainBundle: MockBundle(bundleIdentifier: KickstarterBundleIdentifier.alpha.rawValue)) {
      self.vm.inputs.viewDidLoad()

      XCTAssertEqual(["Settings View", "Viewed Settings"], self.trackingClient.events)
      self.versionText.assertValues(
        ["Version \(self.mainBundle.shortVersionString) #\(self.mainBundle.version)"],
        "Build version string emitted with build number.")
    }
  }

  func testVersionText_Beta() {
    withEnvironment(mainBundle: MockBundle(bundleIdentifier: KickstarterBundleIdentifier.beta.rawValue)) {
      self.vm.inputs.viewDidLoad()

      XCTAssertEqual(["Settings View", "Viewed Settings"], self.trackingClient.events)
      self.versionText.assertValues(
        ["Version \(self.mainBundle.shortVersionString) #\(self.mainBundle.version)"],
        "Build version string emitted with build number.")
    }
  }

  func testVersionText_Release() {
    withEnvironment(mainBundle: MockBundle(bundleIdentifier: KickstarterBundleIdentifier.release.rawValue)) {
      self.vm.inputs.viewDidLoad()

      XCTAssertEqual(["Settings View", "Viewed Settings"], self.trackingClient.events)
      self.versionText.assertValues(
        ["Version \(self.mainBundle.shortVersionString)"],
        "Build version string emitted without build number.")
    }
  }
}
