import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class PledgeCTAContainerViewViewModelTests: TestCase {
  let vm: PledgeCTAContainerViewViewModelType = PledgeCTAContainerViewViewModel()

  let activityIndicatorIsHidden = TestObserver<Bool, Never>()
  let buttonStyleType = TestObserver<ButtonStyleType, Never>()
  let buttonTitleText = TestObserver<String, Never>()
  let notifyDelegateCTATapped = TestObserver<PledgeStateCTAType, Never>()
  let pledgeCTAButtonIsHidden = TestObserver<Bool, Never>()
  let pledgeRetryButtonIsHidden = TestObserver<Bool, Never>()
  let spacerIsHidden = TestObserver<Bool, Never>()
  let stackViewIsHidden = TestObserver<Bool, Never>()
  let subtitleText = TestObserver<String, Never>()
  let titleText = TestObserver<String, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.activityIndicatorIsHidden.observe(self.activityIndicatorIsHidden.observer)
    self.vm.outputs.buttonStyleType.observe(self.buttonStyleType.observer)
    self.vm.outputs.buttonTitleText.observe(self.buttonTitleText.observer)
    self.vm.outputs.notifyDelegateCTATapped.observe(self.notifyDelegateCTATapped.observer)
    self.vm.outputs.pledgeCTAButtonIsHidden.observe(self.pledgeCTAButtonIsHidden.observer)
    self.vm.outputs.retryStackViewIsHidden.observe(self.pledgeRetryButtonIsHidden.observer)
    self.vm.outputs.spacerIsHidden.observe(self.spacerIsHidden.observer)
    self.vm.outputs.stackViewIsHidden.observe(self.stackViewIsHidden.observer)
    self.vm.outputs.subtitleText.observe(self.subtitleText.observer)
    self.vm.outputs.titleText.observe(self.titleText.observer)
  }

  func testPledgeCTA_Backer_LiveProject() {
    let reward = .template
      |> Reward.lens.title .~ "Magic Lamp"
    let backing = .template
      |> Backing.lens.reward .~ reward
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.stats.currentCurrency .~ "USD"

    self.vm.inputs.configureWith(value: (.left((project, nil)), false, .projectPamphlet))
    self.buttonStyleType.assertValues([ButtonStyleType.blue])
    self.buttonTitleText.assertValues([Strings.Manage()])
    self.titleText.assertValues([Strings.Youre_a_backer()])
    self.subtitleText.assertValues(["$10 • Magic Lamp"])
    self.spacerIsHidden.assertValues([false])
    self.stackViewIsHidden.assertValues([false])
  }

  func testPledgeCTA_BackerWithDecimalAmount_LiveProject() {
    let reward = .template
      |> Reward.lens.title .~ "Magic Lamp"
    let backing = .template
      |> Backing.lens.reward .~ reward
      |> Backing.lens.amount .~ 10.50
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.stats.currentCurrency .~ "USD"

    self.vm.inputs.configureWith(value: (.left((project, nil)), false, .projectPamphlet))
    self.buttonStyleType.assertValues([ButtonStyleType.blue])
    self.buttonTitleText.assertValues([Strings.Manage()])
    self.titleText.assertValues([Strings.Youre_a_backer()])
    self.subtitleText.assertValues(["$10.50 • Magic Lamp"])
    self.spacerIsHidden.assertValues([false])
    self.stackViewIsHidden.assertValues([false])
  }

  func testPledgeCTA_Backer_NonLiveProject() {
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ Backing.template
      |> Project.lens.state .~ .successful

    self.vm.inputs.configureWith(value: (.left((project, nil)), false, .projectPamphlet))
    self.buttonStyleType.assertValues([ButtonStyleType.black])
    self.buttonTitleText.assertValues([Strings.View_your_pledge()])
    self.spacerIsHidden.assertValues([true])
    self.stackViewIsHidden.assertValues([true])
  }

  func testPledgeCTA_NonBacker_LiveProject_loggedOut() {
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ nil
      |> Project.lens.state .~ .live

    self.vm.inputs.configureWith(value: (.left((project, nil)), false, .projectPamphlet))
    self.buttonStyleType.assertValues([ButtonStyleType.green])
    self.buttonTitleText.assertValues([Strings.Back_this_project()])
    self.spacerIsHidden.assertValues([true])
    self.stackViewIsHidden.assertValues([true])
  }

  func testPledgeCTA_NonBacker_NonLiveProject_loggedOut() {
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ nil
      |> Project.lens.state .~ .successful

    self.vm.inputs.configureWith(value: (.left((project, nil)), false, .projectPamphlet))
    self.buttonStyleType.assertValues([ButtonStyleType.black])
    self.buttonTitleText.assertValues([Strings.View_rewards()])
    self.spacerIsHidden.assertValues([true])
    self.stackViewIsHidden.assertValues([true])
  }

  func testPledgeCTA_Backer_LiveProject_Error() {
    let backing = Backing.template
      |> Backing.lens.status .~ .errored
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.backing .~ backing

    self.vm.inputs.configureWith(value: (.left((project, nil)), false, .projectPamphlet))
    self.buttonStyleType.assertValues([ButtonStyleType.blue])
    self.buttonTitleText.assertValues([Strings.Manage()])
    self.titleText.assertValues([Strings.Youre_a_backer()])
    self.subtitleText.assertValues(["$10"])
    self.spacerIsHidden.assertValues([false])
    self.stackViewIsHidden.assertValues([false])
  }

  func testPledgeCTA_Backer_NonLiveProject_Error() {
    let backing = Backing.template
      |> Backing.lens.status .~ .errored
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.state .~ .successful
      |> Project.lens.personalization.backing .~ backing

    self.vm.inputs.configureWith(value: (.left((project, nil)), false, .projectPamphlet))
    self.buttonStyleType.assertValues([ButtonStyleType.red])
    self.buttonTitleText.assertValues([Strings.Manage()])
    self.titleText.assertValues(["Payment failure"])
    self.subtitleText.assertValues(["We can't process your pledge."])
    self.spacerIsHidden.assertValues([false])
    self.stackViewIsHidden.assertValues([false])
  }

  func testPledgeCTA_NonBacker_LiveProject_loggedIn() {
    let project = Project.template
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.personalization.isBacking .~ false

    self.vm.inputs.configureWith(value: (.left((project, nil)), false, .projectPamphlet))
    self.buttonStyleType.assertValues([ButtonStyleType.green])
    self.buttonTitleText.assertValues([Strings.Back_this_project()])
    self.spacerIsHidden.assertValues([true])
    self.stackViewIsHidden.assertValues([true])
  }

  func testPledgeCTA_LiveProject_LoggedOut_OptimizelyExperimental_Variant1() {
    let project = Project.template
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.personalization.isBacking .~ false

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.pledgeCTACopy.rawValue: OptimizelyExperiment.Variant.variant1.rawValue]

    withEnvironment(currentUser: nil, optimizelyClient: optimizelyClient) {
      self.vm.inputs.configureWith(value: (.left((project, .discovery)), false, .projectPamphlet))
      self.buttonStyleType.assertValues([ButtonStyleType.green])
      self.buttonTitleText.assertValues(["See the rewards"])
      self.spacerIsHidden.assertValues([true])
      self.stackViewIsHidden.assertValues([true])
      XCTAssertTrue(optimizelyClient.activatePathCalled)
      XCTAssertFalse(optimizelyClient.getVariantPathCalled)

      XCTAssertNil(optimizelyClient.userAttributes?["user_backed_projects_count"] as? Int)
      XCTAssertNil(optimizelyClient.userAttributes?["user_launched_projects_count"] as? Int)
      XCTAssertNil(optimizelyClient.userAttributes?["user_facebook_account"] as? Bool)
      XCTAssertEqual(
        optimizelyClient.userAttributes?["user_country"] as? String,
        "us",
        "Country is populated from the config"
      )
      XCTAssertEqual(optimizelyClient.userAttributes?["user_display_language"] as? String, "en")

      XCTAssertEqual(optimizelyClient.userAttributes?["session_ref_tag"] as? String, "discovery")
      XCTAssertEqual(optimizelyClient.userAttributes?["session_referrer_credit"] as? String, "discovery")
      XCTAssertEqual(optimizelyClient.userAttributes?["session_os_version"] as? String, "MockSystemVersion")
      XCTAssertEqual(optimizelyClient.userAttributes?["session_user_is_logged_in"] as? Bool, false)
      XCTAssertEqual(
        optimizelyClient.userAttributes?["session_app_release_version"] as? String,
        "1.2.3.4.5.6.7.8.9.0"
      )
      XCTAssertEqual(optimizelyClient.userAttributes?["session_apple_pay_device"] as? Bool, true)
      XCTAssertEqual(optimizelyClient.userAttributes?["session_device_format"] as? String, "phone")
    }
  }

  func testPledgeCTA_NonBacker_LiveProject_LoggedIn_OptimizelyExperimental_Variant1() {
    let user = User.template
      |> User.lens.id .~ 5
      |> \.location .~ Location.template
      |> \.stats.backedProjectsCount .~ 50
      |> \.stats.createdProjectsCount .~ 25
      |> \.facebookConnected .~ true

    let project = Project.template
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.personalization.isBacking .~ false

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.pledgeCTACopy.rawValue: OptimizelyExperiment.Variant.variant1.rawValue]

    withEnvironment(currentUser: user, optimizelyClient: optimizelyClient) {
      self.vm.inputs.configureWith(value: (.left((project, .discovery)), false, .projectPamphlet))
      self.buttonStyleType.assertValues([ButtonStyleType.green])
      self.buttonTitleText.assertValues(["See the rewards"])
      self.spacerIsHidden.assertValues([true])
      self.stackViewIsHidden.assertValues([true])
      XCTAssertTrue(optimizelyClient.activatePathCalled)
      XCTAssertFalse(optimizelyClient.getVariantPathCalled)

      XCTAssertEqual(optimizelyClient.userAttributes?["user_backed_projects_count"] as? Int, 50)
      XCTAssertEqual(optimizelyClient.userAttributes?["user_launched_projects_count"] as? Int, 25)
      XCTAssertEqual(optimizelyClient.userAttributes?["user_country"] as? String, "us")
      XCTAssertEqual(optimizelyClient.userAttributes?["user_facebook_account"] as? Bool, true)
      XCTAssertEqual(optimizelyClient.userAttributes?["user_display_language"] as? String, "en")

      XCTAssertEqual(optimizelyClient.userAttributes?["session_ref_tag"] as? String, "discovery")
      XCTAssertEqual(optimizelyClient.userAttributes?["session_referrer_credit"] as? String, "discovery")
      XCTAssertEqual(optimizelyClient.userAttributes?["session_os_version"] as? String, "MockSystemVersion")
      XCTAssertEqual(optimizelyClient.userAttributes?["session_user_is_logged_in"] as? Bool, true)
      XCTAssertEqual(
        optimizelyClient.userAttributes?["session_app_release_version"] as? String,
        "1.2.3.4.5.6.7.8.9.0"
      )
      XCTAssertEqual(optimizelyClient.userAttributes?["session_apple_pay_device"] as? Bool, true)
      XCTAssertEqual(optimizelyClient.userAttributes?["session_device_format"] as? String, "phone")
    }
  }

  func testPledgeCTA_NonBacker_LiveProject_LoggedIn_OptimizelyExperimental_Variant2() {
    let user = User.template |> User.lens.id .~ 5
      |> \.location .~ Location.template
      |> \.stats.backedProjectsCount .~ 50
      |> \.stats.createdProjectsCount .~ 25
      |> \.facebookConnected .~ true
    let project = Project.template
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.personalization.isBacking .~ false

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.pledgeCTACopy.rawValue: OptimizelyExperiment.Variant.variant2.rawValue]

    withEnvironment(currentUser: user, optimizelyClient: optimizelyClient) {
      self.vm.inputs.configureWith(value: (.left((project, .discovery)), false, .projectPamphlet))
      self.buttonStyleType.assertValues([ButtonStyleType.green])
      self.buttonTitleText.assertValues(["View the rewards"])
      self.spacerIsHidden.assertValues([true])
      self.stackViewIsHidden.assertValues([true])
      XCTAssertTrue(optimizelyClient.activatePathCalled)
      XCTAssertFalse(optimizelyClient.getVariantPathCalled)

      XCTAssertEqual(optimizelyClient.userAttributes?["user_backed_projects_count"] as? Int, 50)
      XCTAssertEqual(optimizelyClient.userAttributes?["user_launched_projects_count"] as? Int, 25)
      XCTAssertEqual(optimizelyClient.userAttributes?["user_country"] as? String, "us")
      XCTAssertEqual(optimizelyClient.userAttributes?["user_facebook_account"] as? Bool, true)
      XCTAssertEqual(optimizelyClient.userAttributes?["user_display_language"] as? String, "en")

      XCTAssertEqual(optimizelyClient.userAttributes?["session_ref_tag"] as? String, "discovery")
      XCTAssertEqual(optimizelyClient.userAttributes?["session_referrer_credit"] as? String, "discovery")
      XCTAssertEqual(optimizelyClient.userAttributes?["session_os_version"] as? String, "MockSystemVersion")
      XCTAssertEqual(optimizelyClient.userAttributes?["session_user_is_logged_in"] as? Bool, true)
      XCTAssertEqual(
        optimizelyClient.userAttributes?["session_app_release_version"] as? String,
        "1.2.3.4.5.6.7.8.9.0"
      )
      XCTAssertEqual(optimizelyClient.userAttributes?["session_apple_pay_device"] as? Bool, true)
      XCTAssertEqual(optimizelyClient.userAttributes?["session_device_format"] as? String, "phone")
    }
  }

  func testPledgeCTA_NonBacker_LiveProject_LoggedIn_OptimizelyExperimental_Variant1_IsAdmin() {
    let user = User.template
      |> User.lens.id .~ 5
      |> \.location .~ Location.template
      |> \.stats.backedProjectsCount .~ 50
      |> \.stats.createdProjectsCount .~ 25
      |> \.facebookConnected .~ true
      |> User.lens.isAdmin .~ true
    let project = Project.template
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.personalization.isBacking .~ false

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.pledgeCTACopy.rawValue: OptimizelyExperiment.Variant.variant1.rawValue]

    withEnvironment(currentUser: user, optimizelyClient: optimizelyClient) {
      self.vm.inputs.configureWith(value: (.left((project, .discovery)), false, .projectPamphlet))
      self.buttonStyleType.assertValues([ButtonStyleType.green])
      self.buttonTitleText.assertValues(["See the rewards"])
      self.spacerIsHidden.assertValues([true])
      self.stackViewIsHidden.assertValues([true])
      XCTAssertFalse(optimizelyClient.activatePathCalled)
      XCTAssertTrue(optimizelyClient.getVariantPathCalled)

      XCTAssertEqual(optimizelyClient.userAttributes?["user_backed_projects_count"] as? Int, 50)
      XCTAssertEqual(optimizelyClient.userAttributes?["user_launched_projects_count"] as? Int, 25)
      XCTAssertEqual(optimizelyClient.userAttributes?["user_country"] as? String, "us")
      XCTAssertEqual(optimizelyClient.userAttributes?["user_facebook_account"] as? Bool, true)
      XCTAssertEqual(optimizelyClient.userAttributes?["user_display_language"] as? String, "en")

      XCTAssertEqual(optimizelyClient.userAttributes?["session_ref_tag"] as? String, "discovery")
      XCTAssertEqual(optimizelyClient.userAttributes?["session_referrer_credit"] as? String, "discovery")
      XCTAssertEqual(optimizelyClient.userAttributes?["session_os_version"] as? String, "MockSystemVersion")
      XCTAssertEqual(optimizelyClient.userAttributes?["session_user_is_logged_in"] as? Bool, true)
      XCTAssertEqual(
        optimizelyClient.userAttributes?["session_app_release_version"] as? String,
        "1.2.3.4.5.6.7.8.9.0"
      )
      XCTAssertEqual(optimizelyClient.userAttributes?["session_apple_pay_device"] as? Bool, true)
      XCTAssertEqual(optimizelyClient.userAttributes?["session_device_format"] as? String, "phone")
    }
  }

  func testPledgeCTA_Backer_LiveProject_LoggedIn_OptimizelyExperimental_Variant1() {
    let project = Project.template
      |> Project.lens.personalization.backing .~ Backing.template
      |> Project.lens.personalization.isBacking .~ true

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.pledgeCTACopy.rawValue: OptimizelyExperiment.Variant.variant1.rawValue]

    withEnvironment(currentUser: .template, optimizelyClient: optimizelyClient) {
      self.vm.inputs.configureWith(value: (.left((project, .discovery)), false, .projectPamphlet))
      self.buttonStyleType.assertValues([ButtonStyleType.blue])
      self.buttonTitleText.assertValues(["Manage"])
      self.spacerIsHidden.assertValues([false])
      self.stackViewIsHidden.assertValues([false])

      XCTAssertFalse(
        optimizelyClient.activatePathCalled,
        "Optimizely client should not be called when the pledge button won't be shown"
      )
      XCTAssertFalse(
        optimizelyClient.getVariantPathCalled,
        "Optimizely client should not be called when the pledge button won't be shown"
      )

      XCTAssertNil(optimizelyClient.userAttributes)
    }
  }

  func testPledgeCTA_NonBacker_NonLiveProject_loggedIn() {
    let project = Project.template
      |> Project.lens.state .~ .successful
      |> Project.lens.personalization.isBacking .~ false

    self.vm.inputs.configureWith(value: (.left((project, nil)), false, .projectPamphlet))
    self.buttonStyleType.assertValues([ButtonStyleType.black])
    self.buttonTitleText.assertValues([Strings.View_rewards()])
    self.spacerIsHidden.assertValues([true])
    self.stackViewIsHidden.assertValues([true])
  }

  func testPledgeCTA_LiveProject_UserIsCreator() {
    let user = User.template |> User.lens.id .~ 5
    let project = Project.template
      |> Project.lens.creator.id .~ 5
      |> Project.lens.state .~ .live

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(value: (.left((project, nil)), false, .projectPamphlet))
      self.buttonStyleType.assertValues([ButtonStyleType.black])
      self.buttonTitleText.assertValues(["View your rewards"])
      self.spacerIsHidden.assertValues([true])
      self.stackViewIsHidden.assertValues([true])
    }
  }

  func testPledgeCTA_NonLiveProject_UserIsCreator() {
    let user = User.template |> User.lens.id .~ 5
    let project = Project.template
      |> Project.lens.creator.id .~ 5
      |> Project.lens.state .~ .successful

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(value: (.left((project, nil)), false, .projectPamphlet))
      self.buttonStyleType.assertValues([ButtonStyleType.black])
      self.buttonTitleText.assertValues(["View your rewards"])
      self.spacerIsHidden.assertValues([true])
      self.stackViewIsHidden.assertValues([true])
    }
  }

  func testPledgeCTA_activityIndicator() {
    let project = Project.template
      |> Project.lens.state .~ .live

    self.vm.inputs.configureWith(value: (.left((project, nil)), true, .projectPamphlet))
    self.activityIndicatorIsHidden.assertValues([false])
    self.pledgeCTAButtonIsHidden.assertValues([true])
    self.pledgeRetryButtonIsHidden.assertValues([true])

    self.buttonTitleText.assertDidNotEmitValue()
    self.buttonStyleType.assertValues([])
    self.spacerIsHidden.assertDidNotEmitValue()
    self.stackViewIsHidden.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: (.left((project, nil)), false, .projectPamphlet))
    self.activityIndicatorIsHidden.assertValues([false, true])
    self.pledgeCTAButtonIsHidden.assertValues([true, false])
    self.pledgeRetryButtonIsHidden.assertValues([true])

    self.buttonTitleText.assertDidEmitValue()
    self.buttonStyleType.assertValues([ButtonStyleType.green])
    self.spacerIsHidden.assertDidEmitValue()
    self.stackViewIsHidden.assertDidEmitValue()
  }

  func testPledgeCTA_pledgeRetryButtonIsVisible_AfterFailure() {
    let project = Project.template
      |> Project.lens.state .~ .live

    self.pledgeRetryButtonIsHidden.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: (.left((project, nil)), false, .projectPamphlet))
    self.pledgeRetryButtonIsHidden.assertValues([true])

    self.vm.inputs.configureWith(value: (.right(.couldNotParseJSON), false, .projectPamphlet))
    self.pledgeRetryButtonIsHidden.assertValues([true, false])
  }

  func testNotifyDelegateCTATapped() {
    let project = Project.template
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.personalization.isBacking .~ false

    self.notifyDelegateCTATapped.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: (.left((project, nil)), false, .projectPamphlet))
    self.buttonStyleType.assertValues([ButtonStyleType.green])
    self.buttonTitleText.assertValues([Strings.Back_this_project()])

    self.vm.inputs.pledgeCTAButtonTapped()
    self.notifyDelegateCTATapped.assertValueCount(1)
  }

  func testTrackingEvents_ViewRewards() {
    let project = Project.template
      |> Project.lens.state .~ .successful
      |> Project.lens.personalization.isBacking .~ false

    self.notifyDelegateCTATapped.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: (.left((project, nil)), false, .projectPamphlet))
    self.buttonStyleType.assertValues([ButtonStyleType.black])
    self.buttonTitleText.assertValues([Strings.View_rewards()])

    self.vm.inputs.pledgeCTAButtonTapped()
    self.notifyDelegateCTATapped.assertValueCount(1)

    XCTAssertEqual(["View Rewards Button Clicked"], self.trackingClient.events)

    XCTAssertEqual(
      self.trackingClient.properties(forKey: "optimizely_api_key"),
      [nil],
      "Event does not include Optimizely properties"
    )
    XCTAssertEqual(
      self.trackingClient.properties(forKey: "optimizely_environment"),
      [nil],
      "Event does not include Optimizely properties"
    )
    XCTAssertEqual(
      self.trackingClient.properties(forKey: "optimizely_experiments"),
      [nil],
      "Event does not include Optimizely properties"
    )
  }

  func testTrackingEvents_Pledge() {
    self.vm.inputs.configureWith(value: (.left((Project.template, nil)), false, .projectPamphlet))

    self.notifyDelegateCTATapped.assertDidNotEmitValue()

    self.vm.inputs.pledgeCTAButtonTapped()

    self.notifyDelegateCTATapped.assertValueCount(1)

    XCTAssertEqual(["Project Page Pledge Button Clicked"], self.trackingClient.events)

    let properties = self.trackingClient.properties.last

    XCTAssertNotNil(properties?["optimizely_api_key"], "Event includes Optimizely properties")
    XCTAssertNotNil(properties?["optimizely_environment"], "Event includes Optimizely properties")
    XCTAssertNotNil(properties?["optimizely_experiments"], "Event includes Optimizely properties")
  }
}
