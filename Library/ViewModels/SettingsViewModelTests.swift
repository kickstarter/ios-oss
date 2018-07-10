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
  let exportDataButtonEnabled = TestObserver<Bool, NoError>()
  let exportDataExpirationDate = TestObserver<String, NoError>()
  let exportdDataLoadingIndicator = TestObserver<Bool, NoError>()
  let exportDataText = TestObserver<String, NoError>()
  let followingPrivacyOn = TestObserver<Bool, NoError>()
  let gamesNewsletterOn = TestObserver<Bool, NoError>()
  let goToAppStoreRating = TestObserver<String, NoError>()
  let goToDeleteAccountBrowser = TestObserver<URL, NoError>()
  let happeningNewsletterOn = TestObserver<Bool, NoError>()
  let inventNewsletterOn = TestObserver<Bool, NoError>()
  let logoutWithParams = TestObserver<DiscoveryParams, NoError>()
  let privateProfileEnabled = TestObserver<Bool, NoError>()
  let promoNewsletterOn = TestObserver<Bool, NoError>()
  let requestExportData = TestObserver<(), NoError>()
  let recommendationsOn = TestObserver<Bool, NoError>()
  let showConfirmLogoutPrompt = TestObserver<(message: String, cancel: String, confirm: String), NoError>()
  let showDataExpirationAndChevron = TestObserver<Bool, NoError>()
  let showOptInPrompt = TestObserver<String, NoError>()
  let showPrivacyFollowingPrompt = TestObserver<(), NoError>()
  let unableToSaveError = TestObserver<String, NoError>()
  let updateCurrentUser = TestObserver<User, NoError>()
  let weeklyNewsletterOn = TestObserver<Bool, NoError>()
  let versionText = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.artsAndCultureNewsletterOn.observe(self.artsAndCultureNewsletterOn.observer)
    self.vm.outputs.exportDataButtonEnabled.observe(self.exportDataButtonEnabled.observer)
    self.vm.outputs.exportDataExpirationDate.observe(self.exportDataExpirationDate.observer)
    self.vm.outputs.exportDataLoadingIndicator.observe(self.exportdDataLoadingIndicator.observer)
    self.vm.outputs.exportDataText.observe(self.exportDataText.observer)
    self.vm.outputs.followingPrivacyOn.observe(self.followingPrivacyOn.observer)
    self.vm.outputs.gamesNewsletterOn.observe(self.gamesNewsletterOn.observer)
    self.vm.outputs.goToAppStoreRating.observe(self.goToAppStoreRating.observer)
    self.vm.outputs.goToDeleteAccountBrowser.observe(self.goToDeleteAccountBrowser.observer)
    self.vm.outputs.happeningNewsletterOn.observe(self.happeningNewsletterOn.observer)
    self.vm.outputs.inventNewsletterOn.observe(self.inventNewsletterOn.observer)
    self.vm.outputs.logoutWithParams.observe(self.logoutWithParams.observer)
    self.vm.outputs.privateProfileEnabled.observe(self.privateProfileEnabled.observer)
    self.vm.outputs.promoNewsletterOn.observe(self.promoNewsletterOn.observer)
    self.vm.outputs.requestExportData.observe(self.requestExportData.observer)
    self.vm.outputs.recommendationsOn.observe(self.recommendationsOn.observer)
    self.vm.outputs.showConfirmLogoutPrompt.observe(self.showConfirmLogoutPrompt.observer)
    self.vm.outputs.showDataExpirationAndChevron.observe(self.showDataExpirationAndChevron.observer)
    self.vm.outputs.showOptInPrompt.observe(self.showOptInPrompt.observer)
    self.vm.outputs.showPrivacyFollowingPrompt.observe(self.showPrivacyFollowingPrompt.observer)
    self.vm.outputs.unableToSaveError.observe(self.unableToSaveError.observer)
    self.vm.outputs.updateCurrentUser.observe(self.updateCurrentUser.observer)
    self.vm.outputs.weeklyNewsletterOn.observe(self.weeklyNewsletterOn.observer)
    self.vm.outputs.versionText.observe(self.versionText.observer)
  }

  func testExportDataButtonIsEnabled() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()

    self.exportDataButtonEnabled.assertValues([true], "Export data button is enabled")

    self.vm.inputs.exportDataTapped()

    self.exportDataButtonEnabled.assertValues([true, false], "Export data button is disabled")

    self.scheduler.advance()

    self.exportDataButtonEnabled.assertValues([true, false, true], "Export data button is enabled")
  }

  func testExportDataExpirationDateText_Hidden() {
    let user = User.template
    let export = ExportDataEnvelope.template
    withEnvironment(apiService: MockService(fetchExportStateResponse: export)) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
      self.vm.inputs.viewDidLoad()

      self.showDataExpirationAndChevron.assertValues([false])

      self.vm.inputs.exportDataTapped()
      self.showDataExpirationAndChevron.assertValues([false, true])

      self.scheduler.advance()

      self.showDataExpirationAndChevron.assertValues([false, true, false])
      self.exportDataExpirationDate.assertValues(["Expires Jun 19, 2018 at 1:12 PM"])
    }
  }

  func testFollowingPrivacyToggleStatus_OnViewDidLoad() {

    let socialUser = .template
      |> User.lens.social .~ true

    withEnvironment(currentUser: socialUser) {
      self.vm.inputs.viewDidLoad()
      self.followingPrivacyOn.assertValues([true])
    }
  }

  func testFollowingPrivacyAlertEmits_beforeTurnFollowingOff() {
    self.vm.inputs.followingSwitchTapped(on: false, didShowPrompt: false)
    self.showPrivacyFollowingPrompt.assertDidEmitValue()
  }

  func testFollowingPrivacyDoesNotAlertEmit_TurningFollowingOn() {
    self.vm.inputs.followingSwitchTapped(on: true, didShowPrompt: false)
    self.showPrivacyFollowingPrompt.assertDidNotEmitValue()
  }

  func testUpdateUserEmits_When_TurnFollowingOn() {

    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))

    self.vm.inputs.viewDidLoad()
    self.updateCurrentUser.assertValueCount(2, "Begin with environment's current user and refresh.")

    self.vm.inputs.followingSwitchTapped(on: true, didShowPrompt: false)
    self.updateCurrentUser.assertValueCount(3, "User should be updated.")

    self.vm.inputs.followingSwitchTapped(on: true, didShowPrompt: true)
    self.updateCurrentUser.assertValueCount(4, "User should be updated.")
  }

  func testUpdateUserDoesNotEmit_TurningFollowingOff_BeforeShowingPrompt() {

    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))

    self.vm.inputs.viewDidLoad()
    self.updateCurrentUser.assertValueCount(2, "Begin with environment's current user and refresh.")

    self.vm.inputs.followingSwitchTapped(on: false, didShowPrompt: false)
    self.updateCurrentUser.assertValueCount(2, "User should not be updated.")
  }

  func testUpdateUserEmits_TurningFollowingOff_AfterShowingPrompt() {

    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))

    self.vm.inputs.viewDidLoad()
    self.updateCurrentUser.assertValueCount(2, "Begin with environment's current user and refresh.")

    self.vm.inputs.followingSwitchTapped(on: false, didShowPrompt: true)
    self.updateCurrentUser.assertValueCount(3, "User should be updated.")
  }

  func testRequestExportData() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.exportDataTapped()

    self.scheduler.advance()

    self.requestExportData.assertValueCount(1, "Request Data")
  }

  func testOptOutOfRecommendations() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()
    self.recommendationsOn.assertValues([true])
    self.vm.inputs.recommendationsTapped(on: false)
    self.recommendationsOn.assertValues([true, false])
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

  func testGoToDeleteAccount() {
    let user = User.template
    let url =
      AppEnvironment.current.apiService.serverConfig.webBaseUrl.appendingPathComponent("/profile/destroy")
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.deleteAccountTapped()
    self.goToDeleteAccountBrowser.assertValues([url])
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
    XCTAssertEqual(["Settings View", "Viewed Settings", "Subscribed To Newsletter",
                "Subscribed To Newsletter"], self.trackingClient.events)

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
    XCTAssertEqual(["Settings View", "Viewed Settings", "Subscribed To Newsletter",
      "Subscribed To Newsletter", "Subscribed To Newsletter", "Subscribed To Newsletter",
      "Subscribed To Newsletter", "Subscribed To Newsletter", "Unsubscribed From Newsletter",
      "Unsubscribed From Newsletter", "Unsubscribed From Newsletter", "Unsubscribed From Newsletter",
      "Unsubscribed From Newsletter", "Unsubscribed From Newsletter"], self.trackingClient.events)
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

  func testPrivateProfileToggled() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))

    self.vm.inputs.viewDidLoad()

    self.privateProfileEnabled.assertValues([true])

    self.vm.inputs.privateProfileSwitchDidChange(isOn: false)

    self.privateProfileEnabled.assertValues([true, false])
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

      self.gamesNewsletterOn.assertValues([false], "Newsletter notifications turned off as default.")

      self.vm.inputs.gamesNewsletterTapped(on: true)

      self.gamesNewsletterOn.assertValues([false, true], "Newsletter immediately turned on on tap.")

      self.scheduler.advance()

      self.unableToSaveError.assertValueCount(1, "Updating user errored.")
      self.gamesNewsletterOn.assertValues([false, true, false], "Did not successfully save preference.")
    }
  }

  func testUpdateUser() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()
    self.updateCurrentUser.assertValueCount(2, "Begin with environment's current user and refresh.")

    self.vm.inputs.gamesNewsletterTapped(on: true)
    self.updateCurrentUser.assertValueCount(3, "User should be updated.")

    self.vm.inputs.gamesNewsletterTapped(on: true)
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
