import Foundation
import XCTest
import ReactiveSwift
import Result
import Prelude
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class SettingsNewsletterCellViewModelTests: TestCase {
  let vm = SettingsNewsletterCellViewModel()

  let showOptInPrompt = TestObserver<String, NoError>()
  let subscribeToAllSwitchIsOn = TestObserver<Bool?, NoError>()
  let switchIsOn = TestObserver<Bool?, NoError>()
  let unableToSaveError = TestObserver<String, NoError>()
  let updateCurrentUser = TestObserver<User, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.showOptInPrompt.observe(self.showOptInPrompt.observer)
    self.vm.outputs.subscribeToAllSwitchIsOn.observe(self.subscribeToAllSwitchIsOn.observer)
    self.vm.outputs.switchIsOn.observe(self.switchIsOn.observer)
    self.vm.outputs.unableToSaveError.observe(self.unableToSaveError.observer)
    self.vm.outputs.updateCurrentUser.observe(self.updateCurrentUser.observer)
  }

  func test_SubscribeToAll_Toggled() {

    let user = User.template
      |> User.lens.newsletters .~ User.NewsletterSubscriptions.all(on: true)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))

    self.vm.inputs.configureWith(value: user)
    self.subscribeToAllSwitchIsOn.assertValue(true)
  }

  func test_SubscribeToAll_Untoggled_IfAtLeastOneNewsletterIsUntoggled() {

    let user = User.template
      |> User.lens.newsletters.arts .~ nil

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))

    self.vm.inputs.configureWith(value: user)
    self.subscribeToAllSwitchIsOn.assertValue(false)
  }

  func test_ArtsNewsletters_Toggled() {
    self.assertValue(for: .arts)
  }

  func test_ProjectsWeLoveNewsletters_Toggled() {
    self.assertValue(for: .weekly)
  }

  func test_NewsAndEventsNewsletters_Toggled() {
    self.assertValue(for: .promo)
  }

  func test_GamesNewsletters_Toggled() {
    self.assertValue(for: .games)
  }

  func test_HappeningNewsletters_Toggled() {
    self.assertValue(for: .happening)
  }

  func test_InventNewsletters_Toggled() {
    self.assertValue(for: .invent)
  }

  func test_FilmsNewsletters_Toggled() {
    self.assertValue(for: .films)
  }

  func test_PublishingNewsletters_Toggled() {
    self.assertValue(for: .publishing)
  }

  func test_AlumniNewsletters_Toggled() {
    self.assertValue(for: .alumni)
  }

  private func assertValue(for newsletter: Newsletter) {

    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))

    self.vm.inputs.configureWith(value: (newsletter, user))
    self.switchIsOn.assertValues([false])

    self.vm.inputs.newslettersSwitchTapped(on: true)
    let user1 = User.template |> UserAttribute.newsletter(newsletter).lens .~ true

    self.vm.inputs.configureWith(value: user1)

    self.switchIsOn.assertValues([false, true])
    XCTAssertEqual(["Subscribed To Newsletter"], self.trackingClient.events)

    self.vm.inputs.newslettersSwitchTapped(on: false)
    let user2 = User.template |> UserAttribute.newsletter(newsletter).lens .~ false

    self.vm.inputs.configureWith(value: user2)
    self.switchIsOn.assertValues([false, true, false])

    XCTAssertEqual(["Subscribed To Newsletter", "Unsubscribed From Newsletter"], self.trackingClient.events)
  }

  func testOptInPromptNotShown() {
    withEnvironment(countryCode: "US") {
      let user = User.template
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))

      self.vm.inputs.newslettersSwitchTapped(on: true)
      self.showOptInPrompt.assertDidNotEmitValue("Non-German locale does not require double opt-in.")
    }
  }

  func testShowOptInPrompt() {
    withEnvironment(config: Config.deConfig) {
      let user = User.template
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))

      self.vm.inputs.configureWith(value: (.arts, user))

      self.vm.inputs.newslettersSwitchTapped(on: true)
      self.showOptInPrompt.assertValueCount(1, "German locale requires double opt-in.")

      self.vm.inputs.newslettersSwitchTapped(on: false)
      self.showOptInPrompt.assertValueCount(1, "Prompt not shown again when newsletter toggled off.")
    }
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

      self.vm.inputs.configureWith(value: (.arts, user))

      self.switchIsOn.assertValues([false], "Newsletter notifications turned off as default.")

      self.vm.inputs.newslettersSwitchTapped(on: true)
      let user1 = User.template
        |> User.lens.newsletters.arts .~ true

      self.vm.inputs.configureWith(value: user1)
      self.switchIsOn.assertValues([false, true], "Newsletter immediately turned on on tap.")

      self.scheduler.advance()

      self.vm.inputs.allNewslettersSwitchTapped(on: false)
      self.unableToSaveError.assertValueCount(1, "Updating user errored.")

      self.switchIsOn.assertValues([false, true], "Did not successfully save preference.")
    }
  }

  func testUpdateUser() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))

    self.vm.inputs.configureWith(value: (.games, user))

    self.updateCurrentUser.assertValueCount(0, "Begin with environment's current user.")

    self.vm.inputs.newslettersSwitchTapped(on: true)

    self.scheduler.advance()

    self.updateCurrentUser.assertValueCount(1, "User should be updated.")

    self.vm.inputs.newslettersSwitchTapped(on: false)

    self.scheduler.advance()

    self.updateCurrentUser.assertValueCount(2, "User should be updated.")
  }
}
