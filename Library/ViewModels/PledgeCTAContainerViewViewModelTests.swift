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

    self.vm.inputs.configureWith(value: (.left(project), false))
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

    self.vm.inputs.configureWith(value: (.left(project), false))
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

    self.vm.inputs.configureWith(value: (.left(project), false))
    self.buttonStyleType.assertValues([ButtonStyleType.black])
    self.buttonTitleText.assertValues([Strings.View_your_pledge()])
    self.spacerIsHidden.assertValues([true])
    self.stackViewIsHidden.assertValues([true])
  }

  func testPledgeCTA_NonBacker_LiveProject_loggedOut() {
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ nil
      |> Project.lens.state .~ .live

    self.vm.inputs.configureWith(value: (.left(project), false))
    self.buttonStyleType.assertValues([ButtonStyleType.green])
    self.buttonTitleText.assertValues([Strings.Back_this_project()])
    self.spacerIsHidden.assertValues([true])
    self.stackViewIsHidden.assertValues([true])
  }

  func testPledgeCTA_NonBacker_NonLiveProject_loggedOut() {
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ nil
      |> Project.lens.state .~ .successful

    self.vm.inputs.configureWith(value: (.left(project), false))
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

    self.vm.inputs.configureWith(value: (.left(project), false))
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

    self.vm.inputs.configureWith(value: (.left(project), false))
    self.buttonStyleType.assertValues([ButtonStyleType.black])
    self.buttonTitleText.assertValues([Strings.View_your_pledge()])
    self.titleText.assertValues([])
    self.subtitleText.assertValues(["$10"])
    self.spacerIsHidden.assertValues([true])
    self.stackViewIsHidden.assertValues([true])
  }

  func testPledgeCTA_NonBacker_LiveProject_loggedIn() {
    let project = Project.template
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.personalization.isBacking .~ false

    self.vm.inputs.configureWith(value: (.left(project), false))
    self.buttonStyleType.assertValues([ButtonStyleType.green])
    self.buttonTitleText.assertValues([Strings.Back_this_project()])
    self.spacerIsHidden.assertValues([true])
    self.stackViewIsHidden.assertValues([true])
  }

  func testPledgeCTA_NonBacker_LiveProject_LoggedIn_OptimizelyExperimental() {
    let user = User.template |> User.lens.id .~ 5
    let project = Project.template
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.personalization.isBacking .~ false

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.pledgeCTACopy.rawValue: OptimizelyExperiment.Variant.experimental.rawValue]

    withEnvironment(currentUser: user, optimizelyClient: optimizelyClient) {
      self.vm.inputs.configureWith(value: (.left(project), false))
      self.buttonStyleType.assertValues([ButtonStyleType.green])
      self.buttonTitleText.assertValues([Strings.See_rewards()])
      self.spacerIsHidden.assertValues([true])
      self.stackViewIsHidden.assertValues([true])
    }
  }

  func testPledgeCTA_NonBacker_NonLiveProject_loggedIn() {
    let project = Project.template
      |> Project.lens.state .~ .successful
      |> Project.lens.personalization.isBacking .~ false

    self.vm.inputs.configureWith(value: (.left(project), false))
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
      self.vm.inputs.configureWith(value: (.left(project), false))
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
      self.vm.inputs.configureWith(value: (.left(project), false))
      self.buttonStyleType.assertValues([ButtonStyleType.black])
      self.buttonTitleText.assertValues(["View your rewards"])
      self.spacerIsHidden.assertValues([true])
      self.stackViewIsHidden.assertValues([true])
    }
  }

  func testPledgeCTA_activityIndicator() {
    let project = Project.template
      |> Project.lens.state .~ .live

    self.vm.inputs.configureWith(value: (.left(project), true))
    self.activityIndicatorIsHidden.assertValues([false])
    self.pledgeCTAButtonIsHidden.assertValues([true])
    self.pledgeRetryButtonIsHidden.assertValues([true])

    self.buttonTitleText.assertDidNotEmitValue()
    self.buttonStyleType.assertValues([])
    self.spacerIsHidden.assertDidNotEmitValue()
    self.stackViewIsHidden.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: (.left(project), false))
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

    self.vm.inputs.configureWith(value: (.left(project), false))
    self.pledgeRetryButtonIsHidden.assertValues([true])

    self.vm.inputs.configureWith(value: (.right(.couldNotParseJSON), false))
    self.pledgeRetryButtonIsHidden.assertValues([true, false])
  }

  func testNotifyDelegateCTATapped() {
    let project = Project.template
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.personalization.isBacking .~ false

    self.notifyDelegateCTATapped.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: (.left(project), false))
    self.buttonStyleType.assertValues([ButtonStyleType.green])
    self.buttonTitleText.assertValues([Strings.Back_this_project()])

    self.vm.inputs.pledgeCTAButtonTapped()
    self.notifyDelegateCTATapped.assertValueCount(1)
  }

  func testTrackingEvents() {
    let project = Project.template
      |> Project.lens.state .~ .successful
      |> Project.lens.personalization.isBacking .~ false

    self.notifyDelegateCTATapped.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: (.left(project), false))
    self.buttonStyleType.assertValues([ButtonStyleType.black])
    self.buttonTitleText.assertValues([Strings.View_rewards()])

    self.vm.inputs.pledgeCTAButtonTapped()
    self.notifyDelegateCTATapped.assertValueCount(1)
    XCTAssertEqual(["View Rewards Button Clicked"], self.trackingClient.events)
  }
}
